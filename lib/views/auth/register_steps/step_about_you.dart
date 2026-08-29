import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:assignment/control/auth/registration_controller.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/utils/validators.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

/// Registration step 2 — name, date of birth (18+), phone number.
class StepAboutYou extends ConsumerStatefulWidget {
  const StepAboutYou({super.key});

  @override
  ConsumerState<StepAboutYou> createState() => _StepAboutYouState();
}

class _StepAboutYouState extends ConsumerState<StepAboutYou> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final s = ref.read(registrationControllerProvider);
    _firstName = TextEditingController(text: s.firstName);
    _lastName = TextEditingController(text: s.lastName);
    _phone = TextEditingController(text: s.phoneInput);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  RegistrationController get _notifier =>
      ref.read(registrationControllerProvider.notifier);

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final latest = DateTime(now.year - 18, now.month, now.day);
    final current = ref.read(registrationControllerProvider).dob;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(latest.year - 7),
      firstDate: DateTime(now.year - 100),
      lastDate: latest,
    );
    if (picked != null) _notifier.setDob(picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(registrationControllerProvider);
    final text = Theme.of(context).textTheme;
    final phoneInvalid =
        s.phoneInput.isNotEmpty && nationalToE164(s.phoneInput) == null;
    final underage = s.dob != null && !isAtLeast18(s.dob!);

    return SellStepScaffold(
      title: 'About you',
      subtitle: 'Buyers and sellers see your name on listings and chats.',
      children: [
        const FieldLabel('First name'),
        TextField(
          controller: _firstName,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'e.g. Aiman'),
          onChanged: _notifier.setFirstName,
        ),
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('Last name'),
        TextField(
          controller: _lastName,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'e.g. Rahman'),
          onChanged: _notifier.setLastName,
        ),
        const SizedBox(height: AppSpacing.space20),
        GroupedSection(
          children: [
            GroupedRow(
              label: 'Date of birth',
              value: s.dob == null ? 'Select' : formatDate(s.dob!),
              valueColor: s.dob == null ? AppColors.tertiaryLabel : null,
              showChevron: true,
              onTap: _pickDob,
            ),
          ],
        ),
        if (underage) ...[
          const SizedBox(height: AppSpacing.space8),
          Text(
            'You must be 18 or older to use Garaj.',
            style: text.footnote.copyWith(color: AppColors.destructive),
          ),
        ],
        const SizedBox(height: AppSpacing.space20),
        const FieldLabel('Phone number'),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixText: '+60   ',
            hintText: '12-345 6789',
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
    );
  }
}
