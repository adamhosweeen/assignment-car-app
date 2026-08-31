import 'package:flutter/material.dart';

import 'package:assignment/utils/app_theme.dart';

/// A single-field text prompt dialog, e.g. for the "Other" free-text make/model.
/// Returns the trimmed value, or null if cancelled/empty.
Future<String?> promptForText(
  BuildContext context, {
  required String title,
  String? initial,
  String? hint,
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (_) =>
        _TextPromptDialog(title: title, initial: initial, hint: hint),
  );
  return (result == null || result.isEmpty) ? null : result;
}

/// Owns the [TextEditingController] so its lifetime is tied to the dialog route,
/// not to the `await showDialog` call site. Disposing the controller right after
/// `showDialog` returns crashes: the route is still playing its close animation
/// and rebuilds the [TextField] against a disposed controller.
class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({required this.title, this.initial, this.hint});

  final String title;
  final String? initial;
  final String? hint;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.title, style: Theme.of(context).textTheme.headline),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
