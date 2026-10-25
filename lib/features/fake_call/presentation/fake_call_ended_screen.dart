import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/fake_call/domain/fake_call_details.dart';

class FakeCallEndedScreen extends ConsumerWidget {
  const FakeCallEndedScreen({
    this.details = const FakeCallDetails(),
    super.key,
  });

  static FakeCallEndedScreen fromRoute(Object? value) => FakeCallEndedScreen(
    details: value is FakeCallDetails ? value : const FakeCallDetails(),
  );

  final FakeCallDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.warmCream,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to Home',
                  onPressed: () => context.go('/home'),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: AppColors.brandCrimson,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Call ended',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.coolGray,
                    child: Icon(
                      Icons.check,
                      color: AppColors.brandCrimson,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Call ended',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text('${details.callerName} · simulated call'),
                  const SizedBox(height: 8),
                  const Text(
                    'You can return to Kavach when you’re ready.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Return to Kavach'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go(
                        '/fake-call/setup',
                        extra: details.copyWith(delaySeconds: 0),
                      ),
                      child: const Text('Set up another call'),
                    ),
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
