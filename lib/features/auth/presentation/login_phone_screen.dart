import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/result.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_theme.dart';

/// Convert user input to E.164, or null if it is not a valid Malaysian mobile
/// number. Accepts an optional leading 0; the national part must start with 1
/// and be 9–10 digits.
String? nationalToE164(String input) {
  var d = input.replaceAll(RegExp('[^0-9]'), '');
  if (d.startsWith('0')) d = d.substring(1);
  if (!d.startsWith('1')) return null;
  if (d.length < 9 || d.length > 10) return null;
  return '+60$d';
}

/// Login step 1 — phone number entry (V1_SPEC §4.2).
class LoginPhoneScreen extends ConsumerStatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  ConsumerState<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends ConsumerState<LoginPhoneScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? get _e164 => nationalToE164(_controller.text);

  Future<void> _continue() async {
    final e164 = _e164;
    if (e164 == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await ref.read(authRepositoryProvider).sendOtp(e164);
    if (!mounted) return;
    switch (res) {
      case Ok():
        setState(() => _loading = false);
        context.push('/login/otp', extra: e164);
      case Err(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
    }
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
              Text("What's your number?", style: text.title1),
              const SizedBox(height: AppSpacing.space8),
              Text(
                "We'll text you a 6-digit code to sign in.",
                style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space24),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixText: '+60   ',
                  hintText: '12-345 6789',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.space12),
                Text(
                  _error!,
                  style: text.footnote.copyWith(color: AppColors.destructive),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: (_e164 != null && !_loading) ? _continue : null,
                child: _loading
                    ? const ButtonSpinner()
                    : const Text('Continue'),
              ),
              const SizedBox(height: AppSpacing.space8),
            ],
          ),
        ),
      ),
    );
  }
}
