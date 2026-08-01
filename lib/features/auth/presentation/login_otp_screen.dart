import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/result.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_theme.dart';

const int _otpLength = 6;
const int _resendSeconds = 60;

/// Login step 2 — 6-digit OTP entry with a 60s resend countdown and a
/// "wrong number?" escape (V1_SPEC §4.2).
class LoginOtpScreen extends ConsumerStatefulWidget {
  const LoginOtpScreen({super.key, required this.phoneE164});

  final String phoneE164;

  @override
  ConsumerState<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends ConsumerState<LoginOtpScreen> {
  String _code = '';
  bool _loading = false;
  String? _error;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _verify() async {
    if (_code.length != _otpLength || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await ref
        .read(authRepositoryProvider)
        .verifyOtp(phoneE164: widget.phoneE164, code: _code);
    if (!mounted) return;
    switch (res) {
      case Ok():
        context.go('/home/buy');
      case Err(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
    }
  }

  Future<void> _resend() async {
    await ref.read(authRepositoryProvider).sendOtp(widget.phoneE164);
    if (!mounted) return;
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Enter the code', style: text.title1),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Sent to ${widget.phoneE164}',
                style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space24),
              _OtpBoxes(
                onChanged: (v) {
                  setState(() => _code = v);
                  if (v.length == _otpLength) _verify();
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.space12),
                Text(
                  _error!,
                  style: text.footnote.copyWith(color: AppColors.destructive),
                ),
              ],
              const SizedBox(height: AppSpacing.space20),
              Align(
                alignment: Alignment.center,
                child: _secondsLeft > 0
                    ? Text(
                        'Resend code in ${_secondsLeft}s',
                        style: text.subhead.copyWith(
                          color: AppColors.tertiaryLabel,
                        ),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend code'),
                      ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Wrong number?'),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: (_code.length == _otpLength && !_loading)
                    ? _verify
                    : null,
                child: _loading ? const ButtonSpinner() : const Text('Verify'),
              ),
              const SizedBox(height: AppSpacing.space8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Six auto-advancing single-digit boxes.
class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _nodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String value) {
    if (value.isNotEmpty) {
      if (i < _otpLength - 1) {
        _nodes[i + 1].requestFocus();
      } else {
        _nodes[i].unfocus();
      }
    } else if (i > 0) {
      _nodes[i - 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _otpLength; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: TextField(
              controller: _controllers[i],
              focusNode: _nodes[i],
              autofocus: i == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: Theme.of(context).textTheme.title3,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppSpacing.space16,
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        ],
      ],
    );
  }
}
