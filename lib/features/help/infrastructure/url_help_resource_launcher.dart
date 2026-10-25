import 'package:url_launcher/url_launcher.dart';

import 'package:kavach/features/help/domain/help_resource_launcher.dart';

class UrlHelpResourceLauncher implements HelpResourceLauncher {
  @override
  Future<bool> callNumber(String number) async {
    try {
      return await launchUrl(
        Uri(scheme: 'tel', path: number),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> openWebsite(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
