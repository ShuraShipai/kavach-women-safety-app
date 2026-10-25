import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kavach/core/design_system/tokens/app_colors.dart';
import 'package:kavach/features/onboarding/application/phone_auth_provider.dart';

class PhoneSignInScreen extends ConsumerWidget {
  const PhoneSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(phoneAuthControllerProvider);
    final topInset = MediaQuery.paddingOf(context).top;
    final topSpacing = (52.0 - topInset).clamp(0.0, 52.0);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: topSpacing),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.go('/welcome'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(44, 44),
                            foregroundColor: AppColors.brandCrimson,
                          ),
                          child: const Icon(Icons.chevron_left, size: 24),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your phone number',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'We’ll text you a one-time code to verify your number.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.35,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                width: 96,
                                child: Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                onChanged: ref
                                    .read(phoneAuthControllerProvider.notifier)
                                    .updatePhoneDigits,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: AppColors.charcoal,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '98765 43210',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed:
                      authState.phoneDigits.length == 10 &&
                          authState.hasConsent &&
                          authState.stage != PhoneAuthStage.sendingCode
                      ? () async {
                          final requested = await ref
                              .read(phoneAuthControllerProvider.notifier)
                              .requestCode();
                          if (!context.mounted || !requested) return;
                          final verified =
                              ref.read(phoneAuthControllerProvider).stage ==
                              PhoneAuthStage.verified;
                          context.go(
                            verified
                                ? '/onboarding/permissions'
                                : '/onboarding/code',
                          );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandCrimson,
                    foregroundColor: AppColors.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    authState.stage == PhoneAuthStage.sendingCode
                        ? 'Sending…'
                        : 'Send code',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            if (authState.failure != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  phoneAuthFailureMessage(authState.failure),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.brandCrimson),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: authState.hasConsent,
                    onChanged: (value) => ref
                        .read(phoneAuthControllerProvider.notifier)
                        .setConsent(value ?? false),
                    activeColor: AppColors.brandCrimson,
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'I agree to use my number for verification. Firebase '
                        'processes it for authentication and abuse prevention.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(40, 12, 40, 34),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'You can leave this screen without verifying. ',
                    ),
                    TextSpan(text: 'Privacy policy setup is still pending.'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.charcoal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
