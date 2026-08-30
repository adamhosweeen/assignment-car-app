import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:assignment/control/services/image_utils.dart';
import 'package:assignment/utils/app_spacing.dart';
import 'package:assignment/utils/app_theme.dart';
import 'package:assignment/control/listings/sell_controller.dart';
import 'package:assignment/widgets/common/sell_step_scaffold.dart';
import 'package:assignment/widgets/listing/media_image.dart';

/// Step 1 — pick, compress, reorder, and delete photos. Min 3, max 12; the
/// first photo is the cover (V1_SPEC §3, §4.5).
class StepPhotos extends ConsumerStatefulWidget {
  const StepPhotos({super.key});

  @override
  ConsumerState<StepPhotos> createState() => _StepPhotosState();
}

class _StepPhotosState extends ConsumerState<StepPhotos> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  /// Compress on-device: longest edge 1920, JPEG q80 (V1_SPEC §3).
  Future<String> _compress(String src) => compressImage(src);

  Future<void> _add(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final notifier = ref.read(sellControllerProvider.notifier);
      if (source == ImageSource.gallery) {
        final picked = await _picker.pickMultiImage(limit: 12);
        final paths = <String>[];
        for (final x in picked) {
          paths.add(await _compress(x.path));
        }
        if (paths.isNotEmpty) await notifier.addPhotos(paths);
      } else {
        final x = await _picker.pickImage(source: ImageSource.camera);
        if (x != null) await notifier.addPhotos([await _compress(x.path)]);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(sellControllerProvider);
    final notifier = ref.read(sellControllerProvider.notifier);
    final photos = draft.photoPaths;
    final text = Theme.of(context).textTheme;
    final needed = 3 - photos.length;

    return SellStepScaffold(
      title: 'Add photos',
      subtitle: '3–12 photos. Long-press to reorder — the first is the cover.',
      children: [
        if (photos.isNotEmpty)
          SizedBox(
            height: AppSpacing.thumbMd + AppSpacing.space20,
            child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: true,
              onReorderItem: notifier.reorderPhoto,
              children: [
                for (var i = 0; i < photos.length; i++)
                  Padding(
                    key: ValueKey(photos[i]),
                    padding: const EdgeInsets.only(right: AppSpacing.space8),
                    child: _Thumb(
                      path: photos[i],
                      isCover: i == 0,
                      onRemove: () => notifier.removePhotoAt(i),
                    ),
                  ),
              ],
            ),
          ),
        if (photos.isNotEmpty) const SizedBox(height: AppSpacing.space12),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _busy ? null : () => _add(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: _busy ? null : () => _add(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
        if (_busy) ...[
          const SizedBox(height: AppSpacing.space16),
          const Center(
            child: SizedBox(
              height: AppSpacing.space20,
              width: AppSpacing.space20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space12),
        if (needed > 0)
          Text(
            'Add at least $needed more ${needed == 1 ? 'photo' : 'photos'}.',
            style: text.footnote.copyWith(color: AppColors.destructive),
          )
        else
          Text(
            '${photos.length} of 12 photos',
            style: text.footnote.copyWith(color: AppColors.secondaryLabel),
          ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.path,
    required this.isCover,
    required this.onRemove,
  });

  final String path;
  final bool isCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.thumbMd,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
            // A local file for new picks, a bucket path when editing an
            // existing listing — MediaImage resolves either.
            child: MediaImage(
              path: path,
              width: AppSpacing.thumbMd,
              height: AppSpacing.thumbMd,
            ),
          ),
          if (isCover)
            Positioned(
              left: AppSpacing.space4,
              bottom: AppSpacing.space4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.space4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.hairline,
                  ),
                  child: Text(
                    'Cover',
                    style: Theme.of(
                      context,
                    ).textTheme.navLabel.copyWith(color: AppColors.onPrimary),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.label,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.hairline),
                  child: Icon(
                    Icons.close,
                    size: AppSpacing.iconMd,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
