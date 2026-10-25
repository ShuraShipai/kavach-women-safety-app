class UserProfile {
  const UserProfile({required this.displayName, required this.phoneNumber});

  final String displayName;
  final String phoneNumber;
}

abstract interface class UserProfileRepository {
  Future<UserProfile?> getProfile();

  Future<void> saveDisplayName(String displayName);
}
