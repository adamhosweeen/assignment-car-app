import 'package:flutter/material.dart';

import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';

Future<List<T>?> showMultiSelectSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  List<T> selected = const [],
}) {
  return showModalBottomSheet<List<T>>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusSheet),
      ),
    ),
    builder: (sheetContext) {
      final text = Theme.of(sheetContext).textTheme;
      final chosen = {...selected};
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space16,
                    0,
                    AppSpacing.space16,
                    AppSpacing.space8,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(title, style: text.headline)),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(chosen.toList()),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: AppSpacing.hairline),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: AppSpacing.hairline,
                      indent: AppSpacing.space16,
                    ),
                    itemBuilder: (_, i) {
                      final option = options[i];
                      final isSelected = chosen.contains(option);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setSheetState(() {
                          if (isSelected) {
                            chosen.remove(option);
                          } else {
                            chosen.add(option);
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space16,
                            vertical: AppSpacing.space16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(labelOf(option), style: text.body),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  size: AppSpacing.iconMd,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
