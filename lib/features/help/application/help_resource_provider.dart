import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/help/domain/help_resource_launcher.dart';

final helpResourceLauncherProvider = Provider<HelpResourceLauncher>(
  (ref) => throw StateError('Help resources are not configured.'),
);

final helpResourcesProvider = Provider<HelpResources>(
  (ref) => HelpResources(ref.watch(helpResourceLauncherProvider)),
);

class HelpResources {
  const HelpResources(this._launcher);

  final HelpResourceLauncher _launcher;

  Future<bool> callNumber(String number) => _launcher.callNumber(number);

  Future<bool> openWebsite(Uri uri) => _launcher.openWebsite(uri);
}
