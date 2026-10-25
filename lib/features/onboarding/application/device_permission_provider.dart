import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/onboarding/domain/device_permission_repository.dart';

final devicePermissionRepositoryProvider = Provider<DevicePermissionRepository>(
  (ref) => throw StateError('Device permissions are not configured.'),
);

final devicePermissionControllerProvider =
    NotifierProvider<DevicePermissionController, DevicePermissionState>(
      DevicePermissionController.new,
    );

class DevicePermissionState {
  const DevicePermissionState({
    this.statuses = const {},
    this.hasRequested = false,
    this.isRequesting = false,
    this.hasError = false,
  });

  final Map<DevicePermission, DevicePermissionStatus> statuses;
  final bool hasRequested;
  final bool isRequesting;
  final bool hasError;

  bool get hasPermanentlyDenied =>
      statuses.values.contains(DevicePermissionStatus.permanentlyDenied);

  bool get allRequestedPermissionsGranted =>
      DevicePermission.values.every((permission) {
        final status = statuses[permission];
        return status == DevicePermissionStatus.granted ||
            status == DevicePermissionStatus.limited ||
            status == DevicePermissionStatus.provisional;
      });
}

class DevicePermissionController extends Notifier<DevicePermissionState> {
  @override
  DevicePermissionState build() => const DevicePermissionState();

  Future<void> requestOnboardingPermissions() async {
    if (state.isRequesting) return;
    state = DevicePermissionState(
      statuses: state.statuses,
      hasRequested: state.hasRequested,
      isRequesting: true,
    );

    final statuses = Map<DevicePermission, DevicePermissionStatus>.of(
      state.statuses,
    );
    var hasError = false;
    for (final permission in DevicePermission.values) {
      try {
        statuses[permission] = await ref
            .read(devicePermissionRepositoryProvider)
            .request(permission);
      } on Object {
        statuses[permission] = DevicePermissionStatus.unavailable;
        hasError = true;
      }
    }

    state = DevicePermissionState(
      statuses: Map.unmodifiable(statuses),
      hasRequested: true,
      hasError: hasError,
    );
  }

  Future<bool> openAppSettings() =>
      ref.read(devicePermissionRepositoryProvider).openAppSettings();
}
