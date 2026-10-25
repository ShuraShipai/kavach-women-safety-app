import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/shield/application/shield_draft_provider.dart';

class CheckImageScreen extends ConsumerWidget {
  const CheckImageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(shieldLostMediaProvider);
    ref.listen(shieldLostMediaProvider, (previous, next) {
      next.when(
        data: (media) {
          if (media != null) {
            ref.read(shieldDraftProvider.notifier).setSelectedMedia(media);
            context.go('/shield/image/result');
          }
        },
        loading: () {},
        error: (error, _) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not recover the selected image: $error'),
              ),
            );
          }
        },
      );
    });
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: AppColors.warmCream,
        title: const Text('Choose media'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const Text(
                    'Choose an image or video',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Results are estimates, not proof. Review image privacy before continuing.',
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  _option(
                    context,
                    icon: Icons.photo_library_outlined,
                    title: 'Choose from Photos',
                    onTap: () => _pick(context, ref, fromCamera: false),
                  ),
                  const SizedBox(height: 10),
                  _option(
                    context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Take a photo',
                    onTap: () => _pick(context, ref, fromCamera: true),
                  ),
                  const SizedBox(height: 10),
                  _option(
                    context,
                    icon: Icons.video_library_outlined,
                    title: 'Choose a video',
                    onTap: () => _pickVideo(context, ref),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.coolGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Analysis sends your selected file to an external service only after you confirm on the next screen. Results are estimates, not proof.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const KavachBottomNavigation(selected: 'Shield'),
          ],
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) => Material(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brandCrimson),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17))),
            const Icon(Icons.chevron_right, color: AppColors.brandCrimson),
          ],
        ),
      ),
    ),
  );

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref, {
    required bool fromCamera,
  }) async {
    try {
      final picker = ref.read(shieldImagePickerProvider);
      final media = fromCamera
          ? await picker.takePhoto()
          : await picker.chooseFromPhotos();
      if (media == null || !context.mounted) return;
      ref.read(shieldDraftProvider.notifier).setSelectedMedia(media);
      context.push('/shield/image/result');
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select the image: $error')),
        );
      }
    }
  }

  Future<void> _pickVideo(BuildContext context, WidgetRef ref) async {
    try {
      final media = await ref.read(shieldImagePickerProvider).chooseVideo();
      if (media == null || !context.mounted) return;
      ref.read(shieldDraftProvider.notifier).setSelectedMedia(media);
      context.push('/shield/image/result');
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select the video: $error')),
        );
      }
    }
  }
}
