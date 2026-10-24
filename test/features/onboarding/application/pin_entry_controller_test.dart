import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavach/features/onboarding/application/pin_entry_controller.dart';

void main() {
  test('PIN entry requires matching four digit confirmation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(pinEntryProvider.notifier);

    for (final digit in '2580'.split('')) {
      controller.enterDigit(digit);
    }
    expect(container.read(pinEntryProvider).stage, PinEntryStage.confirm);
    expect(container.read(pinEntryProvider).entry, isEmpty);

    for (final digit in '2581'.split('')) {
      controller.enterDigit(digit);
    }
    expect(container.read(pinEntryProvider).mismatch, isTrue);
    expect(container.read(pinEntryProvider).entry, isEmpty);

    for (final digit in '2580'.split('')) {
      controller.enterDigit(digit);
    }
    expect(container.read(pinEntryProvider).stage, PinEntryStage.complete);
    expect(container.read(pinEntryProvider).entry, '2580');
  });

  test('backspace removes only the latest digit', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(pinEntryProvider.notifier);

    controller.enterDigit('4');
    controller.enterDigit('6');
    controller.eraseDigit();

    expect(container.read(pinEntryProvider).entry, '4');
  });
}
