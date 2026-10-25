enum PhoneAuthFailureReason {
  invalidNumber,
  invalidCode,
  expiredCode,
  tooManyRequests,
  network,
  unavailable,
  unknown,
}

class PhoneAuthFailure implements Exception {
  const PhoneAuthFailure(this.reason);

  final PhoneAuthFailureReason reason;
}

class PhoneCodeRequestResult {
  const PhoneCodeRequestResult({
    this.verificationId,
    this.automaticallyVerified = false,
  });

  final String? verificationId;
  final bool automaticallyVerified;
}

abstract interface class PhoneAuthRepository {
  Future<PhoneCodeRequestResult> requestCode(String phoneNumber);

  Future<void> verifyCode({
    required String verificationId,
    required String code,
  });
}
