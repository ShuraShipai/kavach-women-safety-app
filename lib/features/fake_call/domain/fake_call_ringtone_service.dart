abstract interface class FakeCallRingtoneService {
  Future<void> start();

  Future<void> stop();

  Future<void> dispose();
}
