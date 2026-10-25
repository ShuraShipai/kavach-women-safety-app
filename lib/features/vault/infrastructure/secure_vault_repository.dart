import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:kavach/features/vault/domain/vault_case.dart';
import 'package:kavach/features/vault/domain/vault_repository.dart';

class SecureVaultRepository implements VaultRepository {
  SecureVaultRepository(this._storage);

  static const _storageKey = 'kavach_vault_cases_v1';
  static const _mediaKeyStorageKey = 'kavach_vault_media_key_v1';
  static const _mediaFileMagic = [0x4B, 0x56, 0x31]; // KV1
  final FlutterSecureStorage _storage;

  @override
  Future<List<VaultCase>> loadCases() async {
    final payload = await _storage.read(key: _storageKey);
    if (payload == null || payload.isEmpty) return const [];
    final decoded = jsonDecode(payload) as List<Object?>;
    return decoded
        .map((item) => VaultCase.fromJson(item! as Map<String, Object?>))
        .toList(growable: false);
  }

  @override
  Future<void> saveCases(List<VaultCase> cases) => _storage.write(
    key: _storageKey,
    value: jsonEncode(cases.map((item) => item.toJson()).toList()),
  );

  @override
  Future<String> saveEncryptedMedia(String evidenceId, List<int> bytes) async {
    if (bytes.isEmpty) throw ArgumentError('The evidence file is empty.');
    if (bytes.length > 80 * 1024 * 1024) {
      throw ArgumentError(
        'This evidence file is too large to save in the Vault.',
      );
    }
    final algorithm = FlutterAesGcm.with256bits();
    final encrypted = await algorithm.encrypt(
      bytes,
      secretKey: await _mediaEncryptionKey(),
    );
    final mediaDirectory = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/vault_media',
    );
    await mediaDirectory.create(recursive: true);
    final file = File('${mediaDirectory.path}/$evidenceId.vault');
    await file.writeAsBytes([
      ..._mediaFileMagic,
      ...encrypted.nonce,
      ...encrypted.mac.bytes,
      ...encrypted.cipherText,
    ], flush: true);
    return file.path;
  }

  Future<SecretKey> _mediaEncryptionKey() async {
    final encoded = await _storage.read(key: _mediaKeyStorageKey);
    if (encoded != null) return SecretKey(base64.decode(encoded));
    final keyBytes = List<int>.generate(
      32,
      (_) => Random.secure().nextInt(256),
      growable: false,
    );
    await _storage.write(
      key: _mediaKeyStorageKey,
      value: base64.encode(keyBytes),
    );
    return SecretKey(keyBytes);
  }

  @override
  Future<void> deleteEvidence({
    required List<VaultCase> previousCases,
    required List<VaultCase> updatedCases,
    required String? mediaPath,
  }) async {
    await saveCases(updatedCases);
    if (mediaPath == null) return;
    try {
      await _deleteEncryptedMedia(mediaPath);
    } on Object {
      await saveCases(previousCases);
      rethrow;
    }
  }

  Future<void> _deleteEncryptedMedia(String path) async {
    final root = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/vault_media',
    ).absolute.path;
    final file = File(path).absolute;
    if (file.parent.path != root) {
      throw ArgumentError('The media path is outside the Vault folder.');
    }
    if (await file.exists()) await file.delete();
  }

  @override
  Future<String> createTemporaryDecryptedMediaFile(
    String mediaPath,
    String fileName,
  ) async {
    final root = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/vault_media',
    ).absolute.path;
    final source = File(mediaPath).absolute;
    if (source.parent.path != root) {
      throw ArgumentError('The media path is outside the Vault folder.');
    }
    final encoded = await source.readAsBytes();
    if (encoded.length < 3 + 12 + 16 ||
        !_mediaFileMagic.every(
          (value) => encoded[_mediaFileMagic.indexOf(value)] == value,
        )) {
      throw const FormatException('This Vault recording cannot be opened.');
    }
    const nonceLength = 12;
    const macLength = 16;
    final nonceStart = _mediaFileMagic.length;
    final macStart = nonceStart + nonceLength;
    final contentStart = macStart + macLength;
    final secretBox = SecretBox(
      encoded.sublist(contentStart),
      nonce: encoded.sublist(nonceStart, macStart),
      mac: Mac(encoded.sublist(macStart, contentStart)),
    );
    final clearBytes = await FlutterAesGcm.with256bits().decrypt(
      secretBox,
      secretKey: await _mediaEncryptionKey(),
    );
    final directory = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final temporaryFile = File('${directory.path}/$safeName');
    await temporaryFile.writeAsBytes(clearBytes, flush: true);
    return temporaryFile.path;
  }

  @override
  Future<void> deleteTemporaryMediaFile(String path) async {
    final root = (await getTemporaryDirectory()).absolute.path;
    final file = File(path).absolute;
    if (file.parent.path != root) {
      throw ArgumentError('The temporary media path is invalid.');
    }
    if (await file.exists()) await file.delete();
  }

  @override
  Future<String> saveIncidentReport(
    String caseTitle,
    List<String> lines,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeName = caseTitle
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final file = File(
      '${directory.path}/incident_report_${safeName.isEmpty ? 'case' : safeName}_$timestamp.pdf',
    );
    final document = pw.Document(
      title: 'Kavach Incident Report - $caseTitle',
      author: 'Kavach',
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            'KAVACH INCIDENT REPORT',
            style: const pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 18),
          ...lines.map(
            (line) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 7),
              child: pw.Text(
                _safePdfText(line),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
    final bytes = await document.save();
    if (bytes.length < 8 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const FormatException(
        'The incident report could not be encoded as a PDF.',
      );
    }
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _safePdfText(String text) =>
      text.replaceAll(RegExp(r'[^\x20-\x7E]'), '?');
}
