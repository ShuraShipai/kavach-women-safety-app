class SafetyReportVisibility {
  static bool isPubliclyVisible({
    required String moderationStatus,
    required DateTime createdAt,
    required DateTime now,
  }) =>
      moderationStatus == 'approved' &&
      createdAt.isAfter(now.subtract(const Duration(days: 30)));
}
