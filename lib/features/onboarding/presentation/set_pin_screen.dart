import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/onboarding/application/pin_entry_controller.dart';

class SetPinScreen extends ConsumerWidget {
  const SetPinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.paddingOf(context).top;
    final topSpacing = (52.0 - topInset).clamp(0.0, 52.0);

    ref.listen<PinEntryState>(pinEntryProvider, (previous, next) {
      if (next.mismatch && previous?.mismatch != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PINs don’t match. Try again.')),
        );
      }
      if (next.stage == PinEntryStage.complete &&
          previous?.stage != PinEntryStage.complete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            unawaited(ref.read(pinEntryProvider.notifier).savePin());
          }
        });
      }
      if (next.stage == PinEntryStage.saved &&
          previous?.stage != PinEntryStage.saved) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ref.read(pinEntryProvider.notifier).reset();
          context.go('/onboarding/contact');
        });
      }
      if (next.stage == PinEntryStage.saveFailed &&
          previous?.stage != PinEntryStage.saveFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your PIN securely. Try again.'),
          ),
        );
      }
    });

    final pinState = ref.watch(pinEntryProvider);
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),
                    SizedBox(
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            ref.read(pinEntryProvider.notifier).reset();
                            context.go('/onboarding/profile');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(44, 44),
                            foregroundColor: AppColors.brandCrimson,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.chevron_left, size: 24),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Create and confirm a PIN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 9),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.brandCrimson,
                              width: 1.5,
                            ),
                            color: index < pinState.entry.length
                                ? AppColors.brandCrimson
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 276,
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 24,
                        childAspectRatio: 1,
                        children: [
                          for (final digit in [
                            '1',
                            '2',
                            '3',
                            '4',
                            '5',
                            '6',
                            '7',
                            '8',
                            '9',
                            '',
                            '0',
                            '⌫',
                          ])
                            if (digit.isEmpty)
                              const SizedBox(width: 72, height: 72)
                            else
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: FilledButton(
                                  onPressed: () {
                                    if (digit == '⌫') {
                                      ref
                                          .read(pinEntryProvider.notifier)
                                          .eraseDigit();
                                    } else {
                                      ref
                                          .read(pinEntryProvider.notifier)
                                          .enterDigit(digit);
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.surfaceWhite,
                                    foregroundColor: AppColors.charcoal,
                                    shape: const CircleBorder(),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(72, 72),
                                  ),
                                  child: Text(
                                    digit,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                    if (pinState.stage == PinEntryStage.saving)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    if (pinState.stage == PinEntryStage.saveFailed)
                      TextButton(
                        onPressed: () => unawaited(
                          ref.read(pinEntryProvider.notifier).savePin(),
                        ),
                        child: const Text('Retry saving PIN'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
