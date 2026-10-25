import 'package:url_launcher/url_launcher.dart';

import 'package:kavach/features/shield/domain/cybercrime_portal_launcher.dart';

class UrlCybercrimePortalLauncher implements CybercrimePortalLauncher {
  static final _portalUri = Uri.https('cybercrime.gov.in');

  @override
  Future<bool> openPortal() =>
      launchUrl(_portalUri, mode: LaunchMode.externalApplication);
}
