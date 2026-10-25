import 'package:permission_handler/permission_handler.dart' as handler;

import 'package:kavach/features/onboarding/domain/device_permission_repository.dart';

class PermissionHandlerDevicePermissionRepository
    implements DevicePermissionRepository {
  @override
  Future<DevicePermissionStatus> request(DevicePermission permission) async {
    final result = await _permissionFor(permission).request();
    return switch (result) {
      handler.PermissionStatus.granted => DevicePermissionStatus.granted,
      handler.PermissionStatus.limited => DevicePermissionStatus.limited,
      handler.PermissionStatus.provisional =>
        DevicePermissionStatus.provisional,
      handler.PermissionStatus.denied => DevicePermissionStatus.denied,
      handler.PermissionStatus.permanentlyDenied =>
        DevicePermissionStatus.permanentlyDenied,
      handler.PermissionStatus.restricted => DevicePermissionStatus.restricted,
    };
  }

  handler.Permission _permissionFor(DevicePermission permission) =>
      switch (permission) {
        DevicePermission.location => handler.Permission.locationWhenInUse,
        DevicePermission.microphone => handler.Permission.microphone,
        DevicePermission.camera => handler.Permission.camera,
        DevicePermission.notifications => handler.Permission.notification,
      };

  @override
  Future<bool> openAppSettings() => handler.openAppSettings();
}
