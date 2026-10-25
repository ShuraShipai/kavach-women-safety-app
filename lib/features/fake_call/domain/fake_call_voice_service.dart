abstract interface class FakeCallVoiceService {
  Future<void> speak(String text);

  Future<void> stop();

  Future<void> setVolume(double volume);
}
