import 'package:image_picker/image_picker.dart';

import 'package:kavach/features/shield/domain/shield_image_picker.dart';
import 'package:kavach/features/shield/domain/shield_picked_media.dart';

class ImagePickerShieldImagePicker implements ShieldImagePicker {
  ImagePickerShieldImagePicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<ShieldPickedMedia?> chooseFromPhotos() async => _toMedia(
    await _picker.pickImage(source: ImageSource.gallery),
    kind: 'image',
  );

  @override
  Future<ShieldPickedMedia?> takePhoto() async => _toMedia(
    await _picker.pickImage(source: ImageSource.camera),
    kind: 'image',
  );

  @override
  Future<ShieldPickedMedia?> chooseVideo() async => _toMedia(
    await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    ),
    kind: 'video',
  );

  @override
  Future<ShieldPickedMedia?> retrieveLostMedia() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return null;
    if (response.files case final files? when files.isNotEmpty) {
      return _toMedia(files.first, kind: _kindFromName(files.first.name));
    }
    if (response.file case final file?) {
      return _toMedia(file, kind: _kindFromName(file.name));
    }
    if (response.exception case final exception?) throw exception;
    return null;
  }

  ShieldPickedMedia? _toMedia(XFile? file, {required String kind}) =>
      file == null
      ? null
      : ShieldPickedMedia(path: file.path, fileName: file.name, kind: kind);

  String _kindFromName(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.webm') ||
            lower.endsWith('.mkv') ||
            lower.endsWith('.avi')
        ? 'video'
        : 'image';
  }
}
