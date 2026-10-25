import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/shield/domain/shield_image_picker.dart';
import 'package:kavach/features/shield/domain/shield_picked_media.dart';

final shieldImagePickerProvider = Provider<ShieldImagePicker>(
  (ref) => throw StateError('Image selection is not configured.'),
);

final shieldLostMediaProvider = FutureProvider<ShieldPickedMedia?>(
  (ref) => ref.read(shieldImagePickerProvider).retrieveLostMedia(),
);

final shieldDraftProvider =
    NotifierProvider<ShieldDraftController, ShieldDraft>(
      ShieldDraftController.new,
    );

class ShieldDraft {
  const ShieldDraft({
    this.message = '',
    this.saveToVault = false,
    this.selectedMedia,
  });

  final String message;
  final bool saveToVault;
  final ShieldPickedMedia? selectedMedia;

  ShieldDraft copyWith({String? message, bool? saveToVault}) => ShieldDraft(
    message: message ?? this.message,
    saveToVault: saveToVault ?? this.saveToVault,
    selectedMedia: selectedMedia,
  );
}

class ShieldDraftController extends Notifier<ShieldDraft> {
  @override
  ShieldDraft build() => const ShieldDraft();

  void updateMessage(String message) =>
      state = state.copyWith(message: message);

  void setSaveToVault(bool value) => state = state.copyWith(saveToVault: value);

  void setSelectedMedia(ShieldPickedMedia? media) => state = ShieldDraft(
    message: state.message,
    saveToVault: state.saveToVault,
    selectedMedia: media,
  );
}
