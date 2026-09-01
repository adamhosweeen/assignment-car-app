import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/model/profile/car_interests.dart';
import 'package:assignment/model/malaysian_states.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/utils/result.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/utils/formatters.dart';
import 'package:assignment/widgets/common/button_spinner.dart';
import 'package:assignment/widgets/profile/car_interest_fields.dart';
import 'package:assignment/widgets/common/grouped_section.dart';
import 'package:assignment/widgets/common/select_sheet.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';

/// Standalone route for editing the profile, pushed from [ProfileScreen] via
/// its "Edit" action. Name, phone, location, and car interests are editable;
/// email is the login identity and date of birth protects the 18+ gate, so
/// both are shown read-only.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Profile? _profile;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  String? _state;
  late CarInterests _interests;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = context.read<AuthRepository>().currentUser;
    _profile = current;
    _firstNameController = TextEditingController(
      text: current?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: current?.lastName ?? '');
    _phoneController = TextEditingController(
      text: _nationalDigits(current?.phone),
    );
    _state = current?.state;
    _interests = current?.interests ?? const CarInterests();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// "+60123456789" → "123456789" for the +60-prefixed field.
  static String _nationalDigits(String? e164) {
    if (e164 == null) return '';
    return e164.startsWith('+60') ? e164.substring(3) : e164;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickState() async {
    final picked = await showSelectSheet<String>(
      context: context,
      title: 'Your state',
      options: MalaysianStates.all,
      labelOf: (s) => s,
      selected: _state,
    );
    if (picked != null) setState(() => _state = picked);
  }

  Future<void> _save() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isEmpty) {
      _showMessage('Enter your first name.');
      return;
    }
    final phoneInput = _phoneController.text.trim();
    String? phoneE164;
    if (phoneInput.isNotEmpty) {
      phoneE164 = nationalToE164(phoneInput);
      if (phoneE164 == null) {
        _showMessage('Enter a valid Malaysian mobile number.');
        return;
      }
    }
    final min = _interests.budgetMinMyr;
    final max = _interests.budgetMaxMyr;
    if (min != null && max != null && (min <= 0 || min > max)) {
      _showMessage(
        'The minimum budget must be more than RM 0 and no higher than '
        'the maximum.',
      );
      return;
    }
    setState(() => _saving = true);
    final result = await context.read<AuthRepository>().updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phoneE164,
      state: _state,
      interests: _interests,
    );
    if (!mounted) return;
    switch (result) {
      case Ok():
        context.pop();
      case Err(:final message):
        setState(() => _saving = false);
        _showMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          GroupedSection(
            header: 'NAME',
            children: [
              _FieldRow(
                child: TextField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(context).textTheme.body,
                  decoration: const InputDecoration(labelText: 'First name'),
                ),
              ),
              _FieldRow(
                child: TextField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(context).textTheme.body,
                  decoration: const InputDecoration(labelText: 'Last name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space24),
          GroupedSection(
            header: 'CONTACT',
            children: [
              _FieldRow(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: Theme.of(context).textTheme.body,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixText: '+60   ',
                  ),
                ),
              ),
              GroupedRow(
                label: 'Location',
                value: _state ?? 'Select',
                valueColor: _state == null ? AppColors.tertiaryLabel : null,
                showChevron: true,
                onTap: _pickState,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space24),
          GroupedSection(
            header: 'ACCOUNT',
            children: [
              GroupedRow(label: 'Email', value: profile?.email ?? ''),
              GroupedRow(
                label: 'Date of birth',
                value: profile?.dob == null
                    ? 'Not set'
                    : formatDate(profile!.dob!),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space24),
          const FieldLabel('CAR INTERESTS'),
          CarInterestFields(
            value: _interests,
            onChanged: (v) => setState(() => _interests = v),
          ),
          const SizedBox(height: AppSpacing.space24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const ButtonSpinner() : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        child: child,
      ),
    );
  }
}
