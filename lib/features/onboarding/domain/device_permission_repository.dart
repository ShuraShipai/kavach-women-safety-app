enum DevicePermission { location, microphone, camera, notifications }

enum DevicePermissionStatus {
  granted,
  limited,
  provisional,
  denied,
  permanentlyDenied,
  restricted,
  unavailable,
}

abstract interface class DevicePermissionRepository {
  Future<DevicePermissionStatus> request(DevicePermission permission);

  Future<bool> openAppSettings();
}

String devicePermissionStatusLabel(DevicePermissionStatus? status) =>
    switch (status) {
      DevicePermissionStatus.granted => 'Allowed',
      DevicePermissionStatus.limited => 'Limited access',
      DevicePermissionStatus.provisional => 'Quiet notifications allowed',
      DevicePermissionStatus.denied => 'Not allowed',
      DevicePermissionStatus.permanentlyDenied => 'Allow in Settings',
      DevicePermissionStatus.restricted => 'Restricted by device',
      DevicePermissionStatus.unavailable => 'Unavailable on this device',
      null => 'Not requested',
    };
