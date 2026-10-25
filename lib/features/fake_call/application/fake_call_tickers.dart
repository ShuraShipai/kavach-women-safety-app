import 'package:flutter_riverpod/flutter_riverpod.dart';

final fakeCallCountdownProvider = StreamProvider.autoDispose.family<int, int>(
  (ref, seconds) => seconds == 0
      ? Stream<int>.value(0)
      : Stream<int>.periodic(
          const Duration(seconds: 1),
          (tick) => seconds - tick - 1,
        ).take(seconds),
);

final fakeCallElapsedProvider = StreamProvider.autoDispose<int>(
  (ref) => Stream<int>.periodic(const Duration(seconds: 1), (tick) => tick + 1),
);
