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
  ],
);
