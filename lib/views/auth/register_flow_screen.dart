import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/control/providers.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/validators.dart';
import 'package:assignment/views/auth/register_steps/step_about_you.dart';
import 'package:assignment/views/auth/register_steps/step_account.dart';
import 'package:assignment/views/auth/register_steps/step_interests.dart';
import 'package:assignment/views/auth/register_steps/step_location.dart';
import 'package:assignment/widgets/common/button_spinner.dart';

const int _lastStep = 3;

/// The 4-step registration flow: account → about you → location → interests.
/// Mirrors [SellFlowScreen]'s mechanics; on success the router's auth
/// redirect lands the new user on the Buy feed.
class RegisterFlowScreen extends ConsumerStatefulWidget {
  const RegisterFlowScreen({super.key});

  @override
  ConsumerState<RegisterFlowScreen> createState() => _RegisterFlowScreenState();
}

class _RegisterFlowScreenState extends ConsumerState<RegisterFlowScreen> {
  int _step = 0;
  bool _submitting = false;

  void _goTo(int step) => setState(() => _step = step.clamp(0, _lastStep));

  void _back() {
    if (_step == 0) {
      context.pop();
    } else {
      _goTo(_step - 1);
    }
  }

  Future<void> _next() async {
    if (_step < _lastStep) {
      _goTo(_step + 1);
    } else {
      await _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final s = ref.read(registrationControllerProvider);
    final data = ref.read(registrationControllerProvider.notifier).buildData();
    final res = await ref
        .read(authRepositoryProvider)
        .signUp(email: s.email.trim(), password: s.password, data: data);
    if (!mounted) return;
    switch (res) {
      case Ok():
        // The router's refreshListenable redirects to /home/buy.
        ref.invalidate(registrationControllerProvider);
        setState(() => _submitting = false);
      case Err(:final message):
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool _canAdvance(RegistrationState s) => switch (_step) {
    0 =>
      isValidEmail(s.email) &&
          isValidPassword(s.password) &&
          s.confirmPassword == s.password,
    1 =>
      s.firstName.trim().isNotEmpty &&
          s.lastName.trim().isNotEmpty &&
          s.dob != null &&
          isAtLeast18(s.dob!) &&
          nationalToE164(s.phoneInput) != null,
    2 => s.stateName != null,
    _ =>
      s.interests.budgetMinMyr == null ||
          s.interests.budgetMaxMyr == null ||
          (s.interests.budgetMinMyr! > 0 &&
              s.interests.budgetMinMyr! <= s.interests.budgetMaxMyr!),
  };

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(registrationControllerProvider);
    final isLast = _step == _lastStep;
    final content = switch (_step) {
      0 => const StepAccount(),
      1 => const StepAboutYou(),
      2 => const StepPickLocation(),
      _ => const StepInterests(),
    };

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(_step == 0 ? Icons.close : Icons.arrow_back_ios_new),
            onPressed: _back,
          ),
          title: const Text('Create account'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(AppSpacing.space4),
            child: LinearProgressIndicator(
              value: (_step + 1) / (_lastStep + 1),
              minHeight: AppSpacing.space4,
              backgroundColor: AppColors.separator,
              color: AppColors.primary,
            ),
          ),
        ),
        body: SafeArea(child: content),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: FilledButton(
              onPressed: (!_submitting && _canAdvance(s)) ? _next : null,
              child: _submitting
                  ? const ButtonSpinner()
                  : Text(isLast ? 'Create account' : 'Next'),
            ),
          ),
        ),
      ),
    );
  }
}
