import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kavach/features/vault/domain/vault_case.dart';
import 'package:kavach/features/vault/domain/vault_repository.dart';
import 'package:kavach/features/vault/domain/vault_report_sharer.dart';
import 'package:kavach/features/vault/domain/vault_media_capture_service.dart';
import 'package:kavach/features/vault/application/public/vault_evidence_capture_api.dart';

final vaultRepositoryProvider = Provider<VaultRepository>(
  (ref) => throw StateError('The evidence vault is not configured.'),
);

final vaultReportSharerProvider = Provider<VaultReportSharer>(
  (ref) => throw StateError('Incident report sharing is not configured.'),
);

final vaultControllerProvider =
    AsyncNotifierProvider<VaultController, List<VaultCase>>(
      VaultController.new,
    );

class VaultController extends AsyncNotifier<List<VaultCase>>
    implements VaultEvidenceCaptureApi {
  @override
  Future<List<VaultCase>> build() =>
      ref.read(vaultRepositoryProvider).loadCases();

  Future<String> createCase(String title) async {
    final normalized = title.trim();
    if (normalized.isEmpty) throw ArgumentError('Enter a case name.');
    final cases = [...?state.value];
    final now = DateTime.now();
    cases.insert(
      0,
      VaultCase(
        id: now.microsecondsSinceEpoch.toString(),
        title: normalized,
        createdAt: now,
        items: const [],
      ),
    );
    await _save(cases);
    return cases.first.id;
  }

  @override
  Future<String> saveNote({
    required String caseTitle,
    required String note,
  }) async {
    var target = state.value
        ?.where((item) => item.title.toLowerCase() == caseTitle.toLowerCase())
        .firstOrNull;
    if (target == null) {
      await createCase(caseTitle);
      target = state.value
          ?.where((item) => item.title.toLowerCase() == caseTitle.toLowerCase())
          .firstOrNull;
    }
    if (target == null) throw StateError('Could not open the Vault case.');
    await addNote(target.id, note);
    return target.id;
  }

  Future<void> addNote(String caseId, String note) async {
    final normalized = note.trim();
    if (normalized.isEmpty) throw ArgumentError('Write a note first.');
    final cases = [...?state.value];
    final caseIndex = cases.indexWhere((item) => item.id == caseId);
    if (caseIndex < 0) throw StateError('This case is no longer available.');
    final now = DateTime.now();
    final bytes = utf8.encode(normalized);
    final item = VaultEvidence(
      id: now.microsecondsSinceEpoch.toString(),
      text: normalized,
      sha256: sha256.convert(bytes).toString(),
      capturedAt: now,
    );
    cases[caseIndex] = cases[caseIndex].add(item);
    await _save(cases);
  }

  Future<void> saveRecording(VaultCapturedMedia media) async {
    await _saveMedia(media, caseTitle: 'Saved Recordings');
  }

  @override
  Future<String> saveImage({
    required String fileName,
    required List<int> bytes,
  }) async {
    return _saveMedia(
      VaultCapturedMedia(bytes: bytes, fileName: fileName, kind: 'photo'),
      caseTitle: 'Image review',
    );
  }

  Future<String> _saveMedia(
    VaultCapturedMedia media, {
    required String caseTitle,
  }) async {
    final previousCases = [...?state.value];
    final now = DateTime.now();
    final evidenceId = '${now.microsecondsSinceEpoch}-media';
    final caseIndex = previousCases.indexWhere(
      (item) => item.title.toLowerCase() == caseTitle.toLowerCase(),
    );
    final incident = caseIndex < 0
        ? VaultCase(
            id: '${now.microsecondsSinceEpoch}-case',
            title: caseTitle,
            createdAt: now,
            items: const [],
          )
        : previousCases[caseIndex];
    String? mediaPath;
    try {
      mediaPath = await ref
          .read(vaultRepositoryProvider)
          .saveEncryptedMedia(evidenceId, media.bytes);
      final evidence = VaultEvidence(
        id: evidenceId,
        text: switch (media.kind) {
          'audio' => 'Audio recording',
          'video' => 'Video recording',
          _ => 'Image evidence',
        },
        sha256: sha256.convert(media.bytes).toString(),
        capturedAt: now,
        kind: media.kind,
        mediaPath: mediaPath,
        mediaName: media.fileName,
        durationSeconds: media.durationSeconds,
      );
      final updatedCases = [...previousCases];
      final updatedIncident = incident.add(evidence);
      if (caseIndex < 0) {
        updatedCases.insert(0, updatedIncident);
      } else {
        updatedCases[caseIndex] = updatedIncident;
      }
      await _save(updatedCases);
      return updatedIncident.id;
    } on Object {
      if (mediaPath != null) {
        try {
          await ref
              .read(vaultRepositoryProvider)
              .deleteEvidence(
                previousCases: previousCases,
                updatedCases: previousCases,
                mediaPath: mediaPath,
              );
        } finally {
          state = AsyncData(List.unmodifiable(previousCases));
        }
      }
      rethrow;
    }
  }

  Future<void> deleteEvidence(String caseId, String evidenceId) async {
    final previousCases = [...?state.value];
    final caseIndex = previousCases.indexWhere((item) => item.id == caseId);
    if (caseIndex < 0) throw StateError('This case is no longer available.');
    final incident = previousCases[caseIndex];
    final evidence = incident.items
        .where((item) => item.id == evidenceId)
        .firstOrNull;
    if (evidence == null) {
      throw StateError('This evidence is no longer available.');
    }
    final updatedCases = [...previousCases];
    updatedCases[caseIndex] = VaultCase(
      id: incident.id,
      title: incident.title,
      createdAt: incident.createdAt,
      items: List.unmodifiable(
        incident.items.where((item) => item.id != evidenceId),
      ),
    );
    await ref
        .read(vaultRepositoryProvider)
        .deleteEvidence(
          previousCases: previousCases,
          updatedCases: updatedCases,
          mediaPath: evidence.mediaPath,
        );
    state = AsyncData(List.unmodifiable(updatedCases));
  }

  Future<void> deleteCase(String caseId) async {
    final incident = state.value
        ?.where((item) => item.id == caseId)
        .firstOrNull;
    if (incident == null) throw StateError('This case is no longer available.');
    for (final evidence in [...incident.items]) {
      await deleteEvidence(caseId, evidence.id);
    }
    final updatedCases = [...?state.value]
      ..removeWhere((item) => item.id == caseId);
    await _save(updatedCases);
  }

  Future<void> shareRecording(String evidenceId) async {
    final items = state.value?.expand((item) => item.items) ?? const [];
    final evidence = items.where((item) => item.id == evidenceId).firstOrNull;
    final mediaPath = evidence?.mediaPath;
    if (evidence == null || mediaPath == null) {
      throw StateError('This recording is no longer available.');
    }
    final fileName =
        evidence.mediaName ??
        '${evidence.kind}_${evidence.id}.${evidence.kind == 'audio' ? 'm4a' : 'mp4'}';
    final temporaryPath = await ref
        .read(vaultRepositoryProvider)
        .createTemporaryDecryptedMediaFile(mediaPath, fileName);
    try {
      await ref
          .read(vaultReportSharerProvider)
          .shareRecording(
            path: temporaryPath,
            fileName: fileName,
            mimeType: _mimeType(evidence.kind, fileName),
          );
    } finally {
      await ref
          .read(vaultRepositoryProvider)
          .deleteTemporaryMediaFile(temporaryPath);
    }
  }

  String _mimeType(String kind, String fileName) {
    if (kind == 'audio') return 'audio/mp4';
    final lowerName = fileName.toLowerCase();
    if (kind == 'photo') {
      if (lowerName.endsWith('.png')) return 'image/png';
      if (lowerName.endsWith('.webp')) return 'image/webp';
      return 'image/jpeg';
    }
    return lowerName.endsWith('.mov') ? 'video/quicktime' : 'video/mp4';
  }

  Future<String> exportReport(String caseId) async {
    final cases = state.value ?? const <VaultCase>[];
    final incident = cases.where((item) => item.id == caseId).firstOrNull;
    if (incident == null) throw StateError('This case is no longer available.');
    final timeline = incident.items
        .map((item) {
          final type = item.kind == 'note' ? 'Note' : '${item.kind} recording';
          final content = item.mediaName ?? item.text;
          return '${item.capturedAt.toLocal()} | $type | SHA-256: ${item.sha256}\n$content';
        })
        .toList(growable: false);
    final lines = [
      'KAVACH INCIDENT REPORT',
      'Case: ${incident.title}',
      'Created: ${incident.createdAt.toLocal()}',
      'Generated: ${DateTime.now().toLocal()}',
      'Evidence items: ${incident.items.length}',
      'Location: Not recorded',
      '',
      'Summary: This report contains ${incident.items.length} locally stored evidence item(s).',
      '',
      'TIMELINE',
      if (timeline.isEmpty)
        'No evidence has been added to this case.'
      else
        ...timeline,
    ];
    return ref
        .read(vaultRepositoryProvider)
        .saveIncidentReport(incident.title, lines);
  }

  Future<void> shareReport(String path) =>
      ref.read(vaultReportSharerProvider).sharePdf(path);

  Future<void> _save(List<VaultCase> cases) async {
    state = const AsyncLoading();
    try {
      await ref.read(vaultRepositoryProvider).saveCases(cases);
      state = AsyncData(List.unmodifiable(cases));
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
