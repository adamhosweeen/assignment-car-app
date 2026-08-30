import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/providers.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/validators.dart';
import 'package:assignment/widgets/common/button_spinner.dart';

/// Login with email and password. New users branch off to the multi-step
/// registration flow.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      isValidEmail(_emailController.text) &&
      _passwordController.text.isNotEmpty;

  Future<void> _logIn() async {
    if (!_canSubmit) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await ref
        .read(authRepositoryProvider)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    switch (res) {
      case Ok():
        // The router's refreshListenable redirects to /home/buy.
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
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome back', style: text.title1),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Log in with your email to keep buying and selling.',
                style: text.subhead.copyWith(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: AppSpacing.space24),
              TextField(
                controller: _emailController,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: AppSpacing.space12),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _logIn(),
                decoration: InputDecoration(
                  hintText: 'Password',
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
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.space12),
                Text(
                  _error!,
                  style: text.footnote.copyWith(color: AppColors.destructive),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: (_canSubmit && !_loading) ? _logIn : null,
                child: _loading ? const ButtonSpinner() : const Text('Log in'),
              ),
              const SizedBox(height: AppSpacing.space8),
              TextButton(
                onPressed: _loading ? null : () => context.push('/register'),
                child: const Text('New here? Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
