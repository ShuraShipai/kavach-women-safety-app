import 'package:url_launcher/url_launcher.dart';

import 'package:kavach/features/emergency_call/domain/emergency_call_launcher.dart';

class UrlEmergencyCallLauncher implements EmergencyCallLauncher {
  @override
  Future<bool> openEmergencyDialer() async {
    try {
      return await launchUrl(
        Uri(scheme: 'tel', path: '112'),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      return false;
    }
  }
}
