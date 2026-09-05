import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    this.controller,
    this.autofocus = false,
    this.onChanged,
    this.onTap,
  });

  final String hint;
  final TextEditingController? controller;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final field = c == null
        ? _field(context, showClear: false)
        : ValueListenableBuilder<TextEditingValue>(
            valueListenable: c,
            builder: (context, value, _) =>
                _field(context, showClear: value.text.isNotEmpty),
          );
    if (onTap == null) return field;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AbsorbPointer(child: field),
    );
  }

  Widget _field(BuildContext context, {required bool showClear}) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      readOnly: onTap != null,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      style: Theme.of(context).textTheme.body,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        prefixIcon: const Icon(
          Icons.search,
          size: AppSpacing.iconMd,
          color: AppColors.tertiaryLabel,
        ),
        suffixIcon: !showClear
            ? null
            : IconButton(
                onPressed: () {
                  controller?.clear();
                  onChanged?.call('');
                },
                icon: const Icon(
                  Icons.cancel,
                  size: AppSpacing.iconMd,
                  color: AppColors.tertiaryLabel,
                ),
              ),
      ),
    );
  }
}
