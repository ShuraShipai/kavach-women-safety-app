import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/fake_call/domain/fake_call_ringtone_service.dart';

final fakeCallRingtoneServiceProvider = Provider<FakeCallRingtoneService>(
  (ref) => throw UnimplementedError('Fake Call ringtone is not configured.'),
);
