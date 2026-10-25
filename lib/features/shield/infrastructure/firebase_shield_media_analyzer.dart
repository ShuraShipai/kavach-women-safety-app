import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:kavach/features/shield/domain/shield_media_analysis_result.dart';
import 'package:kavach/features/shield/domain/shield_media_analyzer.dart';

class FirebaseShieldMediaAnalyzer implements ShieldMediaAnalyzer {
  FirebaseShieldMediaAnalyzer(this._auth, this._storage, this._functions);

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  @override
  Future<ShieldMediaAnalysisResult> analyze({
    required String path,
    required String fileName,
    required String kind,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Sign in before checking this media.');
    }
    final file = File(path);
    if (!await file.exists()) {
      throw StateError(
        'The selected media is no longer available. Choose it again.',
      );
    }
    final size = await file.length();
    if (size == 0) throw StateError('The selected file is empty.');
    if (size > 150 * 1024 * 1024) {
      throw StateError('The selected file must be smaller than 150 MB.');
    }

    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final objectPath =
        'shield-analysis/$uid/${DateTime.now().microsecondsSinceEpoch}_${safeName.hashCode.abs()}_$safeName';
    final object = _storage.ref(objectPath);
    try {
      await object.putFile(
        file,
        SettableMetadata(contentType: _contentType(safeName, kind)),
      );
      final callable = _functions.httpsCallable(
        'analyzeShieldMedia',
        options: HttpsCallableOptions(timeout: const Duration(minutes: 9)),
      );
      final response = await callable.call<Map<Object?, Object?>>({
        'storagePath': objectPath,
        'fileName': safeName,
        'kind': kind,
      });
      return _parseResult(response.data, kind);
    } finally {
      try {
        await object.delete();
      } on Object {
        // The backend also deletes this temporary object after analysis.
      }
    }
  }

  ShieldMediaAnalysisResult _parseResult(
    Map<Object?, Object?> data,
    String kind,
  ) {
    final verdict = data['isManipulated'];
    final confidence = data['confidencePercent'];
    return ShieldMediaAnalysisResult(
      kind: kind,
      isManipulated: verdict is bool ? verdict : null,
      confidencePercent: confidence is num ? confidence.round() : null,
      summary: data['summary'] as String? ?? 'The result is inconclusive.',
      details: data['details'] as String?,
    );
  }

  String _contentType(String fileName, String kind) {
    final extension = fileName.split('.').last.toLowerCase();
    if (kind == 'video') {
      return switch (extension) {
        'mov' => 'video/quicktime',
        'webm' => 'video/webm',
        'mkv' => 'video/x-matroska',
        'avi' => 'video/x-msvideo',
        _ => 'video/mp4',
      };
    }
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }
}
