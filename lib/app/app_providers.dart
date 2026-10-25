import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:kavach/features/onboarding/application/device_permission_provider.dart';
import 'package:kavach/features/onboarding/application/phone_auth_provider.dart';
import 'package:kavach/features/onboarding/application/pin_entry_controller.dart';
import 'package:kavach/features/onboarding/application/profile_provider.dart';
import 'package:kavach/features/emergency_call/application/emergency_call_provider.dart';
import 'package:kavach/features/onboarding/infrastructure/firebase_phone_auth_repository.dart';
import 'package:kavach/features/onboarding/infrastructure/firestore_user_profile_repository.dart';
import 'package:kavach/features/onboarding/infrastructure/permission_handler_device_permission_repository.dart';
import 'package:kavach/features/onboarding/infrastructure/secure_local_pin_repository.dart';
import 'package:kavach/features/emergency_call/infrastructure/url_emergency_call_launcher.dart';
import 'package:kavach/features/trusted_circle/application/trusted_contact_providers.dart';
import 'package:kavach/features/trusted_circle/infrastructure/firestore_trusted_contact_repository.dart';

final appProviderOverrides = [
  phoneAuthRepositoryProvider.overrideWith(
    (ref) => FirebasePhoneAuthRepository(FirebaseAuth.instance),
  ),
  devicePermissionRepositoryProvider.overrideWith(
    (ref) => PermissionHandlerDevicePermissionRepository(),
  ),
  localPinRepositoryProvider.overrideWith(
    (ref) => SecureLocalPinRepository(const FlutterSecureStorage()),
  ),
  userProfileRepositoryProvider.overrideWith(
    (ref) => FirestoreUserProfileRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ),
  ),
  trustedContactRepositoryProvider.overrideWith(
    (ref) => FirestoreTrustedContactRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ),
  ),
  emergencyCallLauncherProvider.overrideWith(
    (ref) => UrlEmergencyCallLauncher(),
  ),
];
