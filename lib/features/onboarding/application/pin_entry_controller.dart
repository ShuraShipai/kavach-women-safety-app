import 'package:flutter_riverpod/flutter_riverpod.dart';

final pinEntryProvider = NotifierProvider<PinEntryController, PinEntryState>(
  PinEntryController.new,
);

enum PinEntryStage { create, confirm, complete }

class PinEntryState {
  const PinEntryState({
    this.entry = '',
    this.firstPin,
    this.stage = PinEntryStage.create,
    this.mismatch = false,
  });

  final String entry;
  final String? firstPin;
  final PinEntryStage stage;
  final bool mismatch;
}

class PinEntryController extends Notifier<PinEntryState> {
  @override
  PinEntryState build() => const PinEntryState();

  void enterDigit(String digit) {
    if (state.stage == PinEntryStage.complete || state.entry.length >= 4) {
      return;
    }

    final nextEntry = '${state.entry}$digit';
    if (nextEntry.length < 4) {
      state = PinEntryState(
        entry: nextEntry,
        firstPin: state.firstPin,
        stage: state.stage,
      );
      return;
    }

    if (state.stage == PinEntryStage.create) {
      state = PinEntryState(firstPin: nextEntry, stage: PinEntryStage.confirm);
      return;
    }

    if (nextEntry == state.firstPin) {
      state = PinEntryState(
        entry: nextEntry,
        firstPin: state.firstPin,
        stage: PinEntryStage.complete,
      );
    } else {
      state = PinEntryState(
        firstPin: state.firstPin,
        stage: PinEntryStage.confirm,
        mismatch: true,
      );
    }
  }

  void eraseDigit() {
    if (state.stage == PinEntryStage.complete || state.entry.isEmpty) return;
    state = PinEntryState(
      entry: state.entry.substring(0, state.entry.length - 1),
      firstPin: state.firstPin,
      stage: state.stage,
    );
  }

  void reset() => state = const PinEntryState();
}
