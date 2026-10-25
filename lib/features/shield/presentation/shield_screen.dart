import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/core/design_system/widgets/kavach_bottom_navigation.dart';
import 'package:kavach/features/shield/application/cybercrime_portal_provider.dart';

class ShieldScreen extends ConsumerWidget {
  const ShieldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.warmCream,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Text(
                    'Shield',
                    style: TextStyle(
                      color: AppColors.charcoal,
                      fontSize: 34,
                      height: 1.12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text(
                    'Message and image safety checks.',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 12),
                _actionCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Analyze a message',
                  detail: 'Paste or share abusive text',
                  onTap: () => context.push('/shield/message'),
                ),
                const SizedBox(height: 1),
                _actionCard(
                  context,
                  icon: Icons.image_search_outlined,
                  title: 'Check an image',
                  detail: 'Estimate if it was manipulated',
                  onTap: () => context.push('/shield/image'),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'TAKE ACTION',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.phaseSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _actionCard(
                  context,
                  icon: Icons.flag_outlined,
                  title: 'Report cybercrime',
                  detail: 'cybercrime.gov.in',
                  onTap: () => _openCybercrimePortal(context, ref),
                ),
              ],
            ),
          ),
          const KavachBottomNavigation(selected: 'Shield'),
        ],
      ),
    ),
  );

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String detail,
    required VoidCallback onTap,
  }) => Material(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.coolGray,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: AppColors.brandCrimson),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17)),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.phaseSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.brandCrimson),
          ],
        ),
      ),
    ),
  );

  Future<void> _openCybercrimePortal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final opened = await ref.read(openCybercrimePortalProvider)();
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the official portal.')),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the official portal: $error')),
        );
      }
    }
  }
}
