import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/validators.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

/// Registration step 1 — email and password.
class StepAccount extends ConsumerStatefulWidget {
  const StepAccount({super.key});

  @override
  ConsumerState<StepAccount> createState() => _StepAccountState();
}

class _StepAccountState extends ConsumerState<StepAccount> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirm;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final s = ref.read(registrationControllerProvider);
    _email = TextEditingController(text: s.email);
    _password = TextEditingController(text: s.password);
    _confirm = TextEditingController(text: s.confirmPassword);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  RegistrationController get _notifier =>
      ref.read(registrationControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(registrationControllerProvider);
    final text = Theme.of(context).textTheme;
    final showWeakPassword =
        s.password.isNotEmpty && !isValidPassword(s.password);
    final showMismatch =
        s.confirmPassword.isNotEmpty && s.confirmPassword != s.password;

    return SellStepScaffold(
      title: 'Create your account',
      subtitle: "You'll log in with this email and password.",
      children: [
        const FieldLabel('Email'),
        TextField(
          controller: _email,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'you@example.com'),
          onChanged: _notifier.setEmail,
        ),
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('Password'),
        TextField(
          controller: _password,
          obscureText: _obscure,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'At least 8 characters',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                size: AppSpacing.iconMd,
                color: AppColors.tertiaryLabel,
              ),
            ),
          ),
          onChanged: _notifier.setPassword,
        ),
        if (showWeakPassword) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Use at least 8 characters with letters and numbers.',
            style: text.footnote.copyWith(color: AppColors.destructive),
          ),
        ],
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('Confirm password'),
        TextField(
          controller: _confirm,
          obscureText: _obscure,
          autocorrect: false,
          decoration: const InputDecoration(hintText: 'Repeat your password'),
          onChanged: _notifier.setConfirmPassword,
        ),
        if (showMismatch) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            "Passwords don't match.",
            style: text.footnote.copyWith(color: AppColors.destructive),
          ),
        ],
      ],
    );
  }
}
