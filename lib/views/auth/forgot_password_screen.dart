import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/validators.dart';
import 'package:assignment/widgets/common/button_spinner.dart';

/// Forgot-password flow, two stages on one route: request a 6-digit recovery
/// code by email, then enter the code plus a new password. Success signs the
/// user in — the router redirect lands them on the Buy feed.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _codeSent = false;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_loading) return false;
    if (!_codeSent) return isValidEmail(_emailController.text);
    return _codeController.text.length == 6 &&
        isValidPassword(_passwordController.text) &&
        _confirmController.text == _passwordController.text;
  }

  Future<void> _sendCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await ref
        .read(authRepositoryProvider)
        .sendPasswordReset(_emailController.text.trim());
    if (!mounted) return;
    switch (res) {
      case Ok():
        setState(() {
          _loading = false;
          _codeSent = true;
        });
      case Err(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await ref
        .read(authRepositoryProvider)
        .confirmPasswordReset(
          email: _emailController.text.trim(),
          code: _codeController.text,
          newPassword: _passwordController.text,
        );
    if (!mounted) return;
    switch (res) {
      case Ok():
        // Signed in — the router's refreshListenable redirects to /home/buy.
        setState(() => _loading = false);
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
    final showWeakPassword =
        _passwordController.text.isNotEmpty &&
        !isValidPassword(_passwordController.text);
    final showMismatch =
        _confirmController.text.isNotEmpty &&
        _confirmController.text != _passwordController.text;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: ListView(
            children: [
              Text(
                _codeSent ? 'Check your email' : 'Forgot your password?',
                style: text.title1,
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                _codeSent
                    ? 'Enter the 6-digit code we sent to '
                          '${_emailController.text.trim()} and choose a new '
                          'password.'
                    : "Enter your account email and we'll send you a 6-digit "
                          'code.',
                style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space24),
              if (!_codeSent)
                TextField(
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _canSubmit ? _sendCode() : null,
                  decoration: const InputDecoration(hintText: 'Email'),
                )
              else ...[
                TextField(
                  controller: _codeController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: '6-digit code'),
                ),
                const SizedBox(height: AppSpacing.space12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'New password',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        size: AppSpacing.iconMd,
                        color: AppColors.tertiaryLabel,
                      ),
                    ),
                  ),
                ),
                if (showWeakPassword) ...[
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Use at least 8 characters with letters and numbers.',
                    style: text.footnote.copyWith(color: AppColors.destructive),
                  ),
                ],
                const SizedBox(height: AppSpacing.space12),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Confirm new password',
                  ),
                ),
                if (showMismatch) ...[
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    "Passwords don't match.",
                    style: text.footnote.copyWith(color: AppColors.destructive),
                  ),
                ],
                const SizedBox(height: AppSpacing.space8),
                TextButton(
                  onPressed: _loading ? null : _sendCode,
                  child: const Text('Resend code'),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.space12),
                Text(
                  _error!,
                  style: text.footnote.copyWith(color: AppColors.destructive),
                ),
              ],
              const SizedBox(height: AppSpacing.space24),
              FilledButton(
                onPressed: _canSubmit
                    ? (_codeSent ? _resetPassword : _sendCode)
                    : null,
                child: _loading
                    ? const ButtonSpinner()
                    : Text(_codeSent ? 'Reset password' : 'Send code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
