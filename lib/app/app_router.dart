import 'package:go_router/go_router.dart';

import 'package:kavach/features/splash/presentation/splash_screen.dart';
import 'package:kavach/features/onboarding/presentation/welcome_screen.dart';
import 'package:kavach/features/onboarding/presentation/phone_sign_in_screen.dart';
import 'package:kavach/features/onboarding/presentation/enter_code_screen.dart';
import 'package:kavach/features/onboarding/presentation/permissions_screen.dart';
import 'package:kavach/features/onboarding/presentation/profile_screen.dart';
import 'package:kavach/features/onboarding/presentation/set_pin_screen.dart';
import 'package:kavach/features/onboarding/presentation/add_first_contact_screen.dart';
import 'package:kavach/features/onboarding/presentation/home_screen.dart';
import 'package:kavach/features/trusted_circle/presentation/trusted_circle_screen.dart';
import 'package:kavach/features/vault/presentation/vault_case_screen.dart';
import 'package:kavach/features/vault/presentation/vault_export_preview_screen.dart';
import 'package:kavach/features/vault/presentation/vault_screen.dart';
import 'package:kavach/features/vault/presentation/vault_recordings_screen.dart';
import 'package:kavach/features/vault/presentation/vault_audio_recording_screen.dart';
import 'package:kavach/features/vault/presentation/vault_recording_review_screen.dart';
import 'package:kavach/features/shield/presentation/analyze_message_screen.dart';
import 'package:kavach/features/shield/presentation/check_image_screen.dart';
import 'package:kavach/features/shield/presentation/image_check_result_screen.dart';
import 'package:kavach/features/shield/presentation/message_analysis_progress_screen.dart';
import 'package:kavach/features/shield/presentation/message_analysis_result_screen.dart';
import 'package:kavach/features/shield/presentation/shield_screen.dart';
import 'package:kavach/features/help/presentation/help_screen.dart';
import 'package:kavach/features/help/presentation/guided_help_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: 'splash',
      path: '/',
      builder: (context, state) =>
          SplashScreen(onContinue: () => context.go('/welcome')),
    ),
    GoRoute(
      name: 'welcome',
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      name: 'phone-sign-in',
      path: '/onboarding/phone',
      builder: (context, state) => const PhoneSignInScreen(),
    ),
    GoRoute(
      name: 'enter-code',
      path: '/onboarding/code',
      builder: (context, state) => const EnterCodeScreen(),
    ),
    GoRoute(
      name: 'permissions',
      path: '/onboarding/permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      name: 'profile',
      path: '/onboarding/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      name: 'set-pin',
      path: '/onboarding/pin',
      builder: (context, state) => const SetPinScreen(),
    ),
    GoRoute(
      name: 'first-contact',
      path: '/onboarding/contact',
      builder: (context, state) => const AddFirstContactScreen(),
    ),
    GoRoute(
      name: 'home',
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: 'trusted-circle',
      path: '/trusted-circle',
      builder: (context, state) => const TrustedCircleScreen(),
    ),
    GoRoute(
      name: 'vault',
      path: '/vault',
      builder: (context, state) => const VaultScreen(),
      routes: [
        GoRoute(
          name: 'vault-recordings',
          path: 'recordings',
          builder: (context, state) => const VaultRecordingsScreen(),
          routes: [
            GoRoute(
              name: 'vault-audio-recording',
              path: 'capture',
              builder: (context, state) => const VaultAudioRecordingScreen(),
            ),
            GoRoute(
              name: 'vault-recording-review',
              path: 'review',
              builder: (context, state) => const VaultRecordingReviewScreen(),
            ),
          ],
        ),
        GoRoute(
          name: 'vault-case',
          path: ':caseId',
          builder: (context, state) =>
              VaultCaseScreen(caseId: state.pathParameters['caseId']!),
          routes: [
            GoRoute(
              name: 'vault-export-preview',
              path: 'export',
              builder: (context, state) => VaultExportPreviewScreen(
                caseId: state.pathParameters['caseId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: 'shield',
      path: '/shield',
      builder: (context, state) => const ShieldScreen(),
      routes: [
        GoRoute(
          name: 'shield-message',
          path: 'message',
          builder: (context, state) => const AnalyzeMessageScreen(),
          routes: [
            GoRoute(
              name: 'shield-message-progress',
              path: 'analyzing',
              builder: (context, state) =>
                  const MessageAnalysisProgressScreen(),
            ),
            GoRoute(
              name: 'shield-message-result',
              path: 'result',
              builder: (context, state) => const MessageAnalysisResultScreen(),
            ),
          ],
        ),
        GoRoute(
          name: 'shield-image',
          path: 'image',
          builder: (context, state) => const CheckImageScreen(),
          routes: [
            GoRoute(
              name: 'shield-image-result',
              path: 'result',
              builder: (context, state) => const ImageCheckResultScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: 'help',
      path: '/help',
      builder: (context, state) => const HelpScreen(),
      routes: [
        GoRoute(
          name: 'guided-help',
          path: 'guided',
          builder: (context, state) => const GuidedHelpScreen(),
        ),
      ],
    ),
  ],
);
