import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/fake_call/domain/fake_call_voice_service.dart';

final fakeCallVoiceServiceProvider = Provider<FakeCallVoiceService>(
  (ref) => throw UnimplementedError('Fake Call voice is not configured.'),
);
