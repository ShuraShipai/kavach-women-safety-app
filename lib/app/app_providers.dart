import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:kavach/features/vault/application/vault_providers.dart';
import 'package:kavach/features/vault/application/vault_recording_provider.dart';
import 'package:kavach/features/vault/application/public/vault_evidence_capture_api.dart';
import 'package:kavach/features/vault/infrastructure/secure_vault_repository.dart';
import 'package:kavach/features/vault/infrastructure/device_vault_media_capture_service.dart';
import 'package:kavach/features/vault/infrastructure/share_plus_vault_report_sharer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kavach/features/shield/application/shield_draft_provider.dart';
import 'package:kavach/features/shield/application/shield_media_analysis_provider.dart';
import 'package:kavach/features/shield/application/cybercrime_portal_provider.dart';
import 'package:kavach/features/shield/infrastructure/image_picker_shield_image_picker.dart';
import 'package:kavach/features/shield/infrastructure/url_cybercrime_portal_launcher.dart';
import 'package:kavach/features/shield/infrastructure/firebase_shield_media_analyzer.dart';
import 'package:kavach/features/help/application/help_resource_provider.dart';
import 'package:kavach/features/help/infrastructure/url_help_resource_launcher.dart';

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
  vaultRepositoryProvider.overrideWith(
    (ref) => SecureVaultRepository(const FlutterSecureStorage()),
  ),
  vaultReportSharerProvider.overrideWith((ref) => SharePlusVaultReportSharer()),
  vaultMediaCaptureServiceProvider.overrideWith((ref) {
    final service = DeviceVaultMediaCaptureService(ImagePicker());
    ref.onDispose(service.dispose);
    return service;
  }),
  vaultEvidenceCaptureApiProvider.overrideWith(
    (ref) => ref.watch(vaultControllerProvider.notifier),
  ),
  shieldImagePickerProvider.overrideWith(
    (ref) => ImagePickerShieldImagePicker(ImagePicker()),
  ),
  shieldMediaAnalyzerProvider.overrideWith(
    (ref) => FirebaseShieldMediaAnalyzer(
      FirebaseAuth.instance,
      FirebaseStorage.instance,
      FirebaseFunctions.instanceFor(region: 'asia-south1'),
    ),
  ),
  cybercrimePortalLauncherProvider.overrideWith(
    (ref) => UrlCybercrimePortalLauncher(),
  ),
  helpResourceLauncherProvider.overrideWith((ref) => UrlHelpResourceLauncher()),
];
