/// User-selectable details for a local, simulated incoming call.
class FakeCallDetails {
  const FakeCallDetails({
    this.callerName = 'Meera',
    this.delaySeconds = 0,
    this.photoPath,
  });

  final String callerName;
  final int delaySeconds;
  final String? photoPath;

  FakeCallDetails copyWith({
    String? callerName,
    int? delaySeconds,
    String? photoPath,
    bool clearPhoto = false,
  }) => FakeCallDetails(
    callerName: callerName ?? this.callerName,
    delaySeconds: delaySeconds ?? this.delaySeconds,
    photoPath: clearPhoto ? null : photoPath ?? this.photoPath,
  );
}
