import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A single-field text prompt dialog, e.g. for the "Other" free-text make/model.
/// Returns the trimmed value, or null if cancelled/empty.
Future<String?> promptForText(
  BuildContext context, {
  required String title,
  String? initial,
  String? hint,
}) async {
  final controller = TextEditingController(text: initial ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: Theme.of(dialogContext).textTheme.headline),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return (result == null || result.isEmpty) ? null : result;
}
