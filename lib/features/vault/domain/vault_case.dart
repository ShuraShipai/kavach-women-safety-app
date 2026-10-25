class VaultCase {
  const VaultCase({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final List<VaultEvidence> items;

  VaultCase add(VaultEvidence item) => VaultCase(
    id: id,
    title: title,
    createdAt: createdAt,
    items: List.unmodifiable([...items, item]),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
  };

  factory VaultCase.fromJson(Map<String, Object?> json) => VaultCase(
    id: json['id']! as String,
    title: json['title']! as String,
    createdAt: DateTime.parse(json['createdAt']! as String).toLocal(),
    items: (json['items']! as List<Object?>)
        .map((item) => VaultEvidence.fromJson(item! as Map<String, Object?>))
        .toList(growable: false),
  );
}

class VaultEvidence {
  const VaultEvidence({
    required this.id,
    required this.text,
    required this.sha256,
    required this.capturedAt,
    this.kind = 'note',
    this.mediaPath,
    this.mediaName,
    this.durationSeconds,
  });

  final String id;
  final String text;
  final String sha256;
  final DateTime capturedAt;
  final String kind;
  final String? mediaPath;
  final String? mediaName;
  final int? durationSeconds;

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'sha256': sha256,
    'capturedAt': capturedAt.toUtc().toIso8601String(),
    'kind': kind,
    'mediaPath': mediaPath,
    'mediaName': mediaName,
    'durationSeconds': durationSeconds,
  };

  factory VaultEvidence.fromJson(Map<String, Object?> json) => VaultEvidence(
    id: json['id']! as String,
    text: json['text']! as String,
    sha256: json['sha256']! as String,
    capturedAt: DateTime.parse(json['capturedAt']! as String).toLocal(),
    kind: json['kind'] as String? ?? 'note',
    mediaPath: json['mediaPath'] as String?,
    mediaName: json['mediaName'] as String?,
    durationSeconds: json['durationSeconds'] as int?,
  );
}
