import 'package:kavach/features/shield/domain/shield_picked_media.dart';

abstract interface class ShieldImagePicker {
  Future<ShieldPickedMedia?> chooseFromPhotos();

  Future<ShieldPickedMedia?> takePhoto();

  Future<ShieldPickedMedia?> chooseVideo();

  Future<ShieldPickedMedia?> retrieveLostMedia();
}
