import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/result.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_theme.dart';
import '../../../shared/widgets/grouped_section.dart';

/// Standalone route for editing the display name, pushed from [ProfileScreen]
/// via its "Edit" action — mirrors how Listing Detail and Sell are pushed
/// routes rather than inline state on their landing screens.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(authRepositoryProvider).currentUser;
    _nameController = TextEditingController(text: current?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Enter a display name.');
      return;
    }
    setState(() => _saving = true);
    final result = await ref
        .read(authRepositoryProvider)
        .updateProfile(displayName: name);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          GroupedSection(
            header: 'DISPLAY NAME',
            children: [
              Semantics(
                container: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                    vertical: AppSpacing.space8,
                  ),
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: Theme.of(context).textTheme.body,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: AppSpacing.iconMd,
                    height: AppSpacing.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
