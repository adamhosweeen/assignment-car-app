import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/user/auth/registration_controller.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/validators.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/inline_notice.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

class StepAboutYou extends StatefulWidget {
  const StepAboutYou({super.key});

  @override
  State<StepAboutYou> createState() => _StepAboutYouState();
}

class _StepAboutYouState extends State<StepAboutYou> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final s = context.read<RegistrationController>().state;
    _firstName = TextEditingController(text: s.firstName);
    _lastName = TextEditingController(text: s.lastName);
    _phone = TextEditingController(text: s.phoneInput);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  RegistrationController get _notifier =>
      context.read<RegistrationController>();

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final latest = DateTime(now.year - 18, now.month, now.day);
    final current = context.read<RegistrationController>().state.dob;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(latest.year - 7),
      firstDate: DateTime(now.year - 100),
      lastDate: latest,
      helpText: 'Date of birth',
    );
    if (picked != null) _notifier.setDob(picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<RegistrationController>().state;
    final text = Theme.of(context).textTheme;
    final phoneInvalid =
        s.phoneInput.isNotEmpty && nationalToE164(s.phoneInput) == null;
    final underage = s.dob != null && !isAtLeast18(s.dob!);

    return SellStepScaffold(
      title: 'About you',
      subtitle: 'Sellers and buyers see your name on listings and chats.',
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('First name'),
                        TextField(
                          controller: _firstName,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.givenName],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(hintText: 'Aiman'),
                          onChanged: _notifier.setFirstName,
                          onSubmitted: (_) => _lastNameFocus.requestFocus(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Last name'),
                        TextField(
                          controller: _lastName,
                          focusNode: _lastNameFocus,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.familyName],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(hintText: 'Rahman'),
                          onChanged: _notifier.setLastName,
                          onSubmitted: (_) => _phoneFocus.requestFocus(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space20),
              const FieldLabel('Phone number'),
              TextField(
                controller: _phone,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixText: '+60   ',
                  hintText: '12 345 6789',
                ),
                onChanged: _notifier.setPhoneInput,
              ),
              if (phoneInvalid) ...[
                const SizedBox(height: AppSpacing.space8),
                Text(
                  "That doesn't look like a Malaysian mobile number.",
                  style: text.footnote.copyWith(color: AppColors.destructive),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
        const FieldLabel('Date of birth'),
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Born on',
              value: s.dob == null ? 'Select' : formatDate(s.dob!),
              valueColor: s.dob == null ? AppColors.tertiaryLabel : null,
              showChevron: true,
              onTap: _pickDob,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        underage
            ? const InlineNotice(
                kind: NoticeKind.error,
                text: 'You must be 18 or older to use CarSell.',
              )
            : const InlineNotice(
                text:
                    'You need to be 18 or older. Your date of birth is never '
                    'shown to other users.',
              ),
      ],
    );
  }
}
