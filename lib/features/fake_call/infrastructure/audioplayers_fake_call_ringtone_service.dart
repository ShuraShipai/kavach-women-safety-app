import 'package:audioplayers/audioplayers.dart';

import 'package:kavach/features/fake_call/domain/fake_call_ringtone_service.dart';

class AudioplayersFakeCallRingtoneService implements FakeCallRingtoneService {
  AudioplayersFakeCallRingtoneService(this._player);

  final AudioPlayer _player;
  bool _configured = false;
  bool _playing = false;

  Future<void> _configure() async {
    if (_configured) return;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setAudioContext(
      AudioContextConfig(respectSilence: true).build(),
    );
    await _player.setVolume(0.65);
    _configured = true;
  }

  @override
  Future<void> start() async {
    if (_playing) return;
    _playing = true;
    try {
      await _configure();
      await _player.play(AssetSource('audio/fake_call_ringtone.wav'));
    } on Object {
      _playing = false;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (!_playing) return;
    await _player.stop();
    _playing = false;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
