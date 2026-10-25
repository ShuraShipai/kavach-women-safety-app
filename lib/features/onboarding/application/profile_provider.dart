import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/onboarding/domain/user_profile.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => throw StateError('Profile storage is not configured.'),
);

final userProfileProvider = FutureProvider<UserProfile?>(
  (ref) => ref.watch(userProfileRepositoryProvider).getProfile(),
);

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

class ProfileState {
  const ProfileState({this.displayName = '', this.saving = false, this.error});

  final String displayName;
  final bool saving;
  final String? error;
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  void updateDisplayName(String value) {
    state = ProfileState(displayName: value);
  }

  Future<bool> save() async {
    var name = state.displayName.trim();
    if (name.isEmpty) {
      try {
        name =
            (await ref.read(userProfileRepositoryProvider).getProfile())
                ?.displayName ??
            '';
      } on Object {
        // The save below provides the user-facing failure state.
      }
    }
    if (name.isEmpty || name.length > 80) {
      state = ProfileState(
        displayName: state.displayName,
        error: 'Enter a name between 1 and 80 characters.',
      );
      return false;
    }
    state = ProfileState(displayName: name, saving: true);
    try {
      await ref.read(userProfileRepositoryProvider).saveDisplayName(name);
      state = ProfileState(displayName: name);
      return true;
    } on Object {
      state = ProfileState(
        displayName: name,
        error:
            'Could not save your profile. Sign in and check your connection.',
      );
      return false;
    }
  }
}
