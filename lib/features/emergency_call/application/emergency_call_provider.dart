import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/emergency_call/domain/emergency_call_launcher.dart';

final emergencyCallLauncherProvider = Provider<EmergencyCallLauncher>(
  (ref) => throw StateError('Emergency call handoff is not configured.'),
);

final openEmergencyDialerProvider = Provider<OpenEmergencyDialer>(
  (ref) => OpenEmergencyDialer(ref.watch(emergencyCallLauncherProvider)),
);

class OpenEmergencyDialer {
  const OpenEmergencyDialer(this._launcher);

  final EmergencyCallLauncher _launcher;

  Future<bool> call() => _launcher.openEmergencyDialer();
}
