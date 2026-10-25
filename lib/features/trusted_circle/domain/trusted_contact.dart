class TrustedContact {
  const TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.createdAt,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final DateTime? createdAt;
}

enum TrustedContactFailure {
  invalidName,
  invalidPhone,
  duplicate,
  limitReached,
}

class TrustedContactException implements Exception {
  const TrustedContactException(this.reason);

  final TrustedContactFailure reason;
}

String normalizeIndianPhoneNumber(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  final nationalNumber = digits.startsWith('91') && digits.length == 12
      ? digits.substring(2)
      : digits;
  if (nationalNumber.length != 10 ||
      !RegExp(r'^[6-9]\d{9}$').hasMatch(nationalNumber)) {
    throw const TrustedContactException(TrustedContactFailure.invalidPhone);
  }
  return '+91$nationalNumber';
}

String trustedContactFailureMessage(TrustedContactFailure reason) =>
    switch (reason) {
      TrustedContactFailure.invalidName =>
        'Enter a name between 1 and 60 characters.',
      TrustedContactFailure.invalidPhone =>
        'Enter a valid Indian mobile number.',
      TrustedContactFailure.duplicate =>
        'That phone number is already in your circle.',
      TrustedContactFailure.limitReached =>
        'Your trusted circle can have up to 5 people.',
    };
