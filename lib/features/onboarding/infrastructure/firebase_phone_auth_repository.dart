import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:kavach/features/onboarding/domain/phone_auth_repository.dart';

class FirebasePhoneAuthRepository implements PhoneAuthRepository {
  FirebasePhoneAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<PhoneCodeRequestResult> requestCode(String phoneNumber) async {
    final result = Completer<PhoneCodeRequestResult>();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          try {
            await _auth.signInWithCredential(credential);
            if (!result.isCompleted) {
              result.complete(
                const PhoneCodeRequestResult(automaticallyVerified: true),
              );
            }
          } on FirebaseAuthException catch (error) {
            _completeWithError(result, _mapFailure(error));
          } on Object {
            _completeWithError(
              result,
              const PhoneAuthFailure(PhoneAuthFailureReason.unknown),
            );
          }
        },
        verificationFailed: (error) =>
            _completeWithError(result, _mapFailure(error)),
        codeSent: (verificationId, _) {
          if (!result.isCompleted) {
            result.complete(
              PhoneCodeRequestResult(verificationId: verificationId),
            );
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
      return await result.future.timeout(
        const Duration(seconds: 70),
        onTimeout: () =>
            throw const PhoneAuthFailure(PhoneAuthFailureReason.unavailable),
      );
    } on PhoneAuthFailure {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw _mapFailure(error);
    } on TimeoutException {
      throw const PhoneAuthFailure(PhoneAuthFailureReason.unavailable);
    } on Object {
      throw const PhoneAuthFailure(PhoneAuthFailureReason.unknown);
    }
  }

  @override
  Future<void> verifyCode({
    required String verificationId,
    required String code,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw _mapFailure(error);
    } on Object {
      throw const PhoneAuthFailure(PhoneAuthFailureReason.unknown);
    }
  }

  void _completeWithError(
    Completer<PhoneCodeRequestResult> completer,
    PhoneAuthFailure failure,
  ) {
    if (!completer.isCompleted) completer.completeError(failure);
  }

  PhoneAuthFailure _mapFailure(FirebaseAuthException error) {
    // The code is useful for setup diagnosis and does not include the user's
    // phone number or the SMS code.
    debugPrint('Firebase phone authentication error: ${error.code}');
    final reason = switch (error.code) {
      'invalid-phone-number' => PhoneAuthFailureReason.invalidNumber,
      'invalid-verification-code' => PhoneAuthFailureReason.invalidCode,
      'invalid-verification-id' ||
      'session-expired' => PhoneAuthFailureReason.expiredCode,
      'too-many-requests' ||
      'quota-exceeded' => PhoneAuthFailureReason.tooManyRequests,
      'network-request-failed' => PhoneAuthFailureReason.network,
      'operation-not-allowed' ||
      'app-not-authorized' => PhoneAuthFailureReason.unavailable,
      _ => PhoneAuthFailureReason.unknown,
    };
    return PhoneAuthFailure(reason);
  }
}
