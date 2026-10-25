import 'package:image_picker/image_picker.dart';

import 'package:kavach/features/fake_call/domain/fake_call_photo_picker.dart';

class ImagePickerFakeCallPhotoPicker implements FakeCallPhotoPicker {
  ImagePickerFakeCallPhotoPicker(this._imagePicker);

  final ImagePicker _imagePicker;

  @override
  Future<String?> pickPhotoPath() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return image?.path;
  }
}
