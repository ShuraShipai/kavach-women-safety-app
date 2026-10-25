# Kavach Agent Memory

## Verified project facts

- App directory: `/Users/shurashipai/Projects/kavach-women-safety-app`; the directory is not a Git repository and has no remote configured.
- Sibling design directory: `/Users/shurashipai/Projects/kavach-design`.
- Design source is a static `all_screens.html` deck with 50 numbered screen frames and 15 reusable popup/sheet examples. `SCREEN_FLOW_AUDIT.md` agrees; some older sibling documents say 51. The deck does not establish functioning app or service behavior.
- Flutter stable 3.44.3 and Dart 3.12.2 are installed. The SDK's normal wrapper cannot write to its protected Homebrew cache in this environment; Flutter CLI work uses a temporary writable cache proxy and package resolution uses the local pub cache offline.
- The Android/iOS Flutter scaffold and minimal `lib/` foundation have been created. Riverpod and GoRouter dependencies are resolved. This is bootstrap scaffolding only; there is no Firebase configuration or integration.

## Architecture decisions

- Feature-first layered architecture with Presentation, Application, Domain, Data, and Infrastructure boundaries is mandatory; details and dependency direction are in [`ARCHITECTURE.md`](ARCHITECTURE.md).
- Riverpod is mandatory for dependency injection and reactive state; GoRouter owns centralized navigation.
- Every widget class, including private/helper and `State` classes, must be declared in its own Dart file.
- Firebase/external integrations remain behind inner-layer contracts and data/infrastructure adapters. No IDs or credentials are known or to be guessed.
- [`RULES.md`](RULES.md) is the mandatory review contract. `tool/check_architecture.dart` checks AST-based widget-file separation and documented import boundaries; semantic requirements remain review-enforced.

## Current status

- Documentation, native Android/iOS scaffold, Riverpod/GoRouter bootstrap, centralized theme, and supplied transparent lockup exist.
- Designed screens 1–9 are represented: Splash, Welcome, phone sign-in, code entry, permissions, profile, PIN setup, first contact, and Home. The onboarding path is navigable from the Splash logo through Home. Screen 9 controls respond; destinations without an implemented screen explain that they are unavailable.
- Screens 3–8 remain prototypes without SMS/OTP, OS permission, profile/PIN persistence, contacts access, or backend integration. PIN entry supports an in-memory four-digit create-and-confirm interaction only; no PIN is saved. Unavailable operations disclose that they did not happen before offering preview navigation.
- Typography tokens in `lib/core/design_system/tokens/app_typography.dart` use measured CSS values for screens 2–9. The supplied design uses a system font stack; no font files or font license were supplied. Flutter therefore uses the platform default; Android glyph metrics versus the Apple-first CSS stack remain unverified. Explicit CSS line heights/tracking are represented, and unspecified values are left unspecified.
- Each widget class added for this milestone is in a separate Dart file. `tool/check_architecture.dart` is the automated check for this rule and its documented import constraints; other semantic boundaries remain manually reviewed.
- Architecture docs now describe the intended enforceable boundaries; `AGENTS.md` directs agents to read and follow them.
- Flutter dependency resolution succeeded from the existing cache in offline mode. The exact online `flutter pub get` attempt could not complete because network access is restricted.
- Splash and onboarding routing widget tests are present, along with a PIN controller unit test. Current `flutter analyze` reports no issues and `dart run tool/check_architecture.dart` passes with 30 Dart files scanned.
- The relevant widget tests were attempted but could not load because the Flutter test harness cannot bind `127.0.0.1` (OS Error: Operation not permitted). They have not passed at runtime.
- Simulator screenshot comparison is unavailable in this environment because CoreSimulator is not reachable. The new screens have source-level measurements but no rendered visual sign-off; pixel fidelity remains unverified.
- The architecture checker covers AST-based widget-class-per-file and documented static import-boundary rules. Other semantic rules remain review-enforced.

## Next milestone

### Firebase integration update (2026-10-25)

- Firebase project `kavach-ac412` is registered for Android and iOS using the current `com.example.kavach` identifiers. FlutterFire generated `lib/firebase_options.dart`; Firebase Core is initialized from the app bootstrap. Android and iOS platform configuration files are present.
- Phone sign-in calls Firebase Auth through an onboarding domain contract, Riverpod workflow, and infrastructure adapter. The screen collects consent before requesting an OTP and exposes retryable failure states. Actual phone verification is still pending Phone-provider enablement and device-level verification.
- Profile display name and verified phone persistence, plus trusted-contact add/edit/remove, now have Firestore repositories. The default `asia-south1` database is created with deletion protection and the owner-only rules in `firestore.rules` compiled and deployed. No user records have been written. PINs are saved through Android Keystore/iOS Keychain using encrypted secure storage; Android app backup is disabled to avoid restoring an unusable key. SOS delivery and location are not configured. Home asks before handing off 112 to the phone app and reports only whether the dialer opened; target-device behavior is unverified.
- `flutter analyze` reports no issues and `dart run tool/check_architecture.dart` passes with 49 Dart files scanned. Runtime tests were not run for this integration.
- The owner reports Phone sign-in enabled; target-device verification remains pending. Continue with consent-based SOS review/delivery after selecting an SMS delivery provider, then add consent-based location and device tests.

- The onboarding permissions page now uses the `permission_handler` adapter to request location while in use, microphone, camera, and notifications, report outcomes, and open app settings for permanently denied permissions. The app can continue if the user declines optional access. Platform descriptions and Android declarations are present. Pub dependency resolution and device verification remain pending in the current workspace.

Phone authentication and Firestore app reads/writes still need device-level verification. The Firestore rules were compiled by Firebase and deployed, but were not emulator-tested. Continue with SOS delivery after selecting an SMS provider, then build consent-based location and test on devices.
