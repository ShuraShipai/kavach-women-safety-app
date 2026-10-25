import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/shield/domain/cybercrime_portal_launcher.dart';

final cybercrimePortalLauncherProvider = Provider<CybercrimePortalLauncher>(
  (ref) => throw StateError('Cybercrime portal link is not configured.'),
);

final openCybercrimePortalProvider = Provider<OpenCybercrimePortal>(
  (ref) => OpenCybercrimePortal(ref.watch(cybercrimePortalLauncherProvider)),
);

class OpenCybercrimePortal {
  const OpenCybercrimePortal(this._launcher);

  final CybercrimePortalLauncher _launcher;

  Future<bool> call() => _launcher.openPortal();
}
