abstract interface class HelpResourceLauncher {
  Future<bool> callNumber(String number);

  Future<bool> openWebsite(Uri uri);
}
