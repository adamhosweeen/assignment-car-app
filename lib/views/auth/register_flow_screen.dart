import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:provider/provider.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/validators.dart';
import 'package:assignment/views/auth/register_steps/step_about_you.dart';
import 'package:assignment/views/auth/register_steps/step_account.dart';
import 'package:assignment/views/auth/register_steps/step_interests.dart';
import 'package:assignment/views/auth/register_steps/step_location.dart';
import 'package:assignment/widgets/auth/auth_hero.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/common/inline_notice.dart';

const int _lastStep = 3;

class RegisterFlowScreen extends StatefulWidget {
  const RegisterFlowScreen({super.key});

  @override
  State<RegisterFlowScreen> createState() => _RegisterFlowScreenState();
}

class _RegisterFlowScreenState extends State<RegisterFlowScreen> {
  int _step = 0;
  bool _submitting = false;
  String? _error;

  void _goTo(int step) => setState(() {
    _step = step.clamp(0, _lastStep);
    _error = null;
  });

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
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
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });
    final registration = context.read<RegistrationController>();
    final s = registration.state;
    final res = await context.read<AuthRepository>().signUp(
      email: s.email.trim(),
      password: s.password,
      data: registration.buildData(),
    );
    if (!mounted) return;
    switch (res) {
      case Ok():
        registration.reset();
        setState(() => _submitting = false);
      case Err(:final message):
        setState(() {
          _submitting = false;
          _error = message;
        });
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
    final s = context.watch<RegistrationController>().state;
    final isLast = _step == _lastStep;
    final content = switch (_step) {
      0 => const StepAccount(),
      1 => const StepAboutYou(),
      2 => const StepPickLocation(),
      _ => const StepInterests(),
    };

    final text = Theme.of(context).textTheme;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: Column(
            children: [
              AuthHero(
                height: AppSpacing.heroCompactHeight,
                onBack: _back,
                backIcon: _step == 0 ? Icons.close : Icons.arrow_back_ios_new,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create account',
                      style: text.title3.copyWith(color: AppColors.onHero),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'Step ${_step + 1} of ${_lastStep + 1}',
                      style: text.footnote.copyWith(
                        color: AppColors.onHeroSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    _StepProgress(step: _step, total: _lastStep + 1),
                  ],
                ),
              ),
              Expanded(
                child: AuthSheet(padding: EdgeInsets.zero, child: content),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[
                    InlineNotice(text: _error!, kind: NoticeKind.error),
                    const SizedBox(height: AppSpacing.space12),
                  ],
                  FilledButton(
                    style: AuthButtons.dark(context),
                    onPressed: (!_submitting && _canAdvance(s)) ? _next : null,
                    child: _submitting
                        ? const ButtonSpinner()
                        : Text(isLast ? 'Create account' : 'Continue'),
                  ),
                  if (isLast) ...[
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      'By creating an account you agree to list honestly and '
                      'keep your contact details up to date.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption.copyWith(
                        color: AppColors.tertiaryLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Container(
              height: AppSpacing.strengthBarHeight,
              decoration: BoxDecoration(
                color: i <= step ? AppColors.onHero : AppColors.heroBlob,
                borderRadius: BorderRadius.circular(AppSpacing.radiusBar),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
