import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/validators.dart';
import 'package:assignment/widgets/auth/auth_hero.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      isValidEmail(_emailController.text) &&
      _passwordController.text.isNotEmpty;

  Future<void> _logIn() async {
    if (!_canSubmit || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await context.read<AuthRepository>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    switch (res) {
      case Ok():
        setState(() => _loading = false);
      case Err(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
    }
  }

  void _back() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final emailTouched = _emailController.text.isNotEmpty;
    final emailInvalid = emailTouched && !isValidEmail(_emailController.text);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: AutofillGroup(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                AuthHero(
                  onBack: _back,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome\nback',
                        style: text.largeTitle.copyWith(
                          color: AppColors.onHero,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Text(
                        'Log in to keep buying and selling.',
                        style: text.subhead.copyWith(
                          color: AppColors.onHeroSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AuthSheet(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel('Email'),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() => _error = null),
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                        ),
                      ),
                      if (emailInvalid) ...[
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          "That email address doesn't look right.",
                          style: text.footnote.copyWith(
                            color: AppColors.destructive,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.space16),
                      const FieldLabel('Password'),
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: _obscure,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() => _error = null),
                        onSubmitted: (_) => _logIn(),
                        decoration: InputDecoration(
                          hintText: 'Your password',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: AppSpacing.iconMd,
                              color: AppColors.tertiaryLabel,
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.space16),
                        InlineNotice(text: _error!, kind: NoticeKind.error),
                      ],
                      const SizedBox(height: AppSpacing.space24),
                      FilledButton(
                        style: AuthButtons.dark(context),
                        onPressed: (_canSubmit && !_loading) ? _logIn : null,
                        child: _loading
                            ? const ButtonSpinner()
                            : const Text('Log in'),
                      ),
                      const SizedBox(height: AppSpacing.space24),
                      const _OrDivider(),
                      const SizedBox(height: AppSpacing.space24),
                      OutlinedButton(
                        style: AuthButtons.darkOutlined(context),
                        onPressed: _loading
                            ? null
                            : () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Create an account'),
                      ),
                      const SizedBox(height: AppSpacing.space12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(height: AppSpacing.hairline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
          child: Text(
            'New here?',
            style: Theme.of(
              context,
            ).textTheme.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
        ),
        const Expanded(child: Divider(height: AppSpacing.hairline)),
      ],
    );
  }
}
