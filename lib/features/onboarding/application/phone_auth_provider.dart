import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/onboarding/domain/phone_auth_repository.dart';

final phoneAuthRepositoryProvider = Provider<PhoneAuthRepository>(
  (ref) => throw StateError('Phone authentication is not configured.'),
);

final phoneAuthControllerProvider =
    NotifierProvider<PhoneAuthController, PhoneAuthState>(
      PhoneAuthController.new,
    );

enum PhoneAuthStage { phone, sendingCode, code, verifyingCode, verified }

class PhoneAuthState {
  const PhoneAuthState({
    this.phoneDigits = '',
    this.code = '',
    this.verificationId,
    this.stage = PhoneAuthStage.phone,
    this.failure,
    this.hasConsent = false,
  });

  final String phoneDigits;
  final String code;
  final String? verificationId;
  final PhoneAuthStage stage;
  final PhoneAuthFailureReason? failure;
  final bool hasConsent;
}

class PhoneAuthController extends Notifier<PhoneAuthState> {
  @override
  PhoneAuthState build() => const PhoneAuthState();

  void updatePhoneDigits(String value) {
    state = PhoneAuthState(
      phoneDigits: value
          .replaceAll(RegExp(r'\D'), '')
          .substring(
            0,
            value.replaceAll(RegExp(r'\D'), '').length.clamp(0, 10),
          ),
      hasConsent: state.hasConsent,
    );
  }

  void updateCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    state = PhoneAuthState(
      phoneDigits: state.phoneDigits,
      code: digits.substring(0, digits.length.clamp(0, 6)),
      verificationId: state.verificationId,
      stage: state.stage,
      hasConsent: state.hasConsent,
    );
  }

  void setConsent(bool value) {
    state = PhoneAuthState(
      phoneDigits: state.phoneDigits,
      code: state.code,
      verificationId: state.verificationId,
      stage: state.stage,
      failure: state.failure,
      hasConsent: value,
    );
  }

  Future<bool> requestCode() async {
    if (state.phoneDigits.length != 10 || !state.hasConsent) return false;
    state = PhoneAuthState(
      phoneDigits: state.phoneDigits,
      stage: PhoneAuthStage.sendingCode,
      hasConsent: state.hasConsent,
    );

    try {
      final result = await ref
          .read(phoneAuthRepositoryProvider)
          .requestCode('+91${state.phoneDigits}');
      if (result.automaticallyVerified) {
        state = PhoneAuthState(
          phoneDigits: state.phoneDigits,
          stage: PhoneAuthStage.verified,
          hasConsent: state.hasConsent,
        );
      } else if (result.verificationId case final verificationId?) {
        state = PhoneAuthState(
          phoneDigits: state.phoneDigits,
          verificationId: verificationId,
          stage: PhoneAuthStage.code,
          hasConsent: state.hasConsent,
        );
      }
      return state.stage == PhoneAuthStage.code ||
          state.stage == PhoneAuthStage.verified;
    } on PhoneAuthFailure catch (failure) {
      state = PhoneAuthState(
        phoneDigits: state.phoneDigits,
        stage: PhoneAuthStage.phone,
        failure: failure.reason,
        hasConsent: state.hasConsent,
      );
      return false;
    } on Object {
      state = PhoneAuthState(
        phoneDigits: state.phoneDigits,
        stage: PhoneAuthStage.phone,
        failure: PhoneAuthFailureReason.unknown,
        hasConsent: state.hasConsent,
      );
      return false;
    }
  }

  Future<bool> verifyCode() async {
    final verificationId = state.verificationId;
    if (verificationId == null || state.code.length != 6) return false;
    state = PhoneAuthState(
      phoneDigits: state.phoneDigits,
      code: state.code,
      verificationId: verificationId,
      stage: PhoneAuthStage.verifyingCode,
      hasConsent: state.hasConsent,
    );

    try {
      await ref
          .read(phoneAuthRepositoryProvider)
          .verifyCode(verificationId: verificationId, code: state.code);
      state = PhoneAuthState(
        phoneDigits: state.phoneDigits,
        stage: PhoneAuthStage.verified,
        hasConsent: state.hasConsent,
      );
      return true;
    } on PhoneAuthFailure catch (failure) {
      state = PhoneAuthState(
        phoneDigits: state.phoneDigits,
        code: state.code,
        verificationId: verificationId,
        stage: PhoneAuthStage.code,
        failure: failure.reason,
        hasConsent: state.hasConsent,
      );
      return false;
    } on Object {
      state = PhoneAuthState(
        phoneDigits: state.phoneDigits,
        code: state.code,
        verificationId: verificationId,
        stage: PhoneAuthStage.code,
        failure: PhoneAuthFailureReason.unknown,
        hasConsent: state.hasConsent,
      );
      return false;
    }
  }
}

String phoneAuthFailureMessage(PhoneAuthFailureReason? reason) =>
    switch (reason) {
      PhoneAuthFailureReason.invalidNumber =>
        'Enter a valid 10-digit mobile number.',
      PhoneAuthFailureReason.invalidCode =>
        'That code is incorrect. Check it and try again.',
      PhoneAuthFailureReason.expiredCode =>
        'That code expired. Request a new one.',
      PhoneAuthFailureReason.tooManyRequests =>
        'Too many attempts. Wait a while and try again.',
      PhoneAuthFailureReason.network =>
        'Check your internet connection and try again.',
      PhoneAuthFailureReason.unavailable =>
        'Phone verification is unavailable right now. Try again shortly.',
      PhoneAuthFailureReason.unknown =>
        'We couldn’t verify your number. Check the details and try again.',
      null => '',
    };
