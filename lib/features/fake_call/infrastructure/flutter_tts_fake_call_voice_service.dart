import 'package:flutter_tts/flutter_tts.dart';

import 'package:kavach/features/fake_call/domain/fake_call_voice_service.dart';

class FlutterTtsFakeCallVoiceService implements FakeCallVoiceService {
  FlutterTtsFakeCallVoiceService(this._tts);

  final FlutterTts _tts;
  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    await _tts.awaitSpeakCompletion(true);
    var locale = 'en-US';
    try {
      final dynamic languages = await _tts.getLanguages;
      if (languages is List &&
          languages.any((language) => language.toString() == 'en-IN')) {
        locale = 'en-IN';
      }
    } on Object {
      // Keep the device's standard US English fallback.
    }
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.86);
    await _tts.setPitch(1.0);
    await _selectLocalEnglishVoice(locale);
    _configured = true;
  }

  Future<void> _selectLocalEnglishVoice(String locale) async {
    try {
      final dynamic available = await _tts.getVoices;
      if (available is! List) return;
      final voices = available
          .whereType<Map>()
          .map(
            (voice) => voice.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
          .where((voice) {
            final voiceLocale = voice['locale']?.toLowerCase() ?? '';
            return voiceLocale.startsWith(locale.toLowerCase()) &&
                voice['network_required']?.toLowerCase() != 'true';
          })
          .toList();
      if (voices.isEmpty) return;
      voices.sort((first, second) {
        final firstPreferred = _isNaturalEnglishVoice(first) ? 0 : 1;
        final secondPreferred = _isNaturalEnglishVoice(second) ? 0 : 1;
        return firstPreferred.compareTo(secondPreferred);
      });
      final selected = voices.first;
      final identifier = selected['identifier'];
      if (identifier != null && identifier.isNotEmpty) {
        await _tts.setVoice({'identifier': identifier});
      } else if (selected['name'] case final name?) {
        await _tts.setVoice({'name': name, 'locale': selected['locale']!});
      }
    } on Object {
      // Use the device's default voice if voice selection is unavailable.
    }
  }

  bool _isNaturalEnglishVoice(Map<String, String> voice) {
    final descriptor = '${voice['gender']} ${voice['quality']} ${voice['name']}'
        .toLowerCase();
    return descriptor.contains('female') ||
        descriptor.contains('enhanced') ||
        descriptor.contains('premium');
  }

  @override
  Future<void> speak(String text) async {
    await _configure();
    final result = await _tts.speak(text, focus: true);
    if (result == 0) {
      throw StateError('The device could not speak the simulated dialogue.');
    }
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> setVolume(double volume) => _tts.setVolume(volume);

  Future<void> dispose() async {
    await stop();
  }
}
