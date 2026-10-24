import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

const _widgetBaseTypes = {
  'Widget',
  'StatelessWidget',
  'StatefulWidget',
  'State',
  'ConsumerWidget',
  'ConsumerStatefulWidget',
  'ConsumerState',
  'HookWidget',
  'HookConsumerWidget',
};

const _platformAndBackendPackages = {
  'cloud_firestore',
  'cloud_functions',
  'firebase_',
  'dio',
  'http',
  'geolocator',
  'location',
  'permission_handler',
  'flutter_local_notifications',
  'sqflite',
  'drift',
  'shared_preferences',
  'flutter_secure_storage',
  'url_launcher',
  'image_picker',
  'record',
  'contacts_service',
};

Future<void> main() async {
  final files = await _dartFilesIn('lib');
  files.addAll(await _dartFilesIn('test'));

  final parsedFiles = <_ParsedFile>[];
  for (final file in files) {
    final source = await file.readAsString();
    final unit = parseString(content: source, path: file.path).unit;
    final visitor = _ClassCollector();
    unit.accept(visitor);
    parsedFiles.add(_ParsedFile(file, unit, visitor.classes));
  }

  final widgetClassNames = <String>{..._widgetBaseTypes};
  var changed = true;
  while (changed) {
    changed = false;
    for (final parsedFile in parsedFiles) {
      for (final declaration in parsedFile.classes) {
        final baseName = declaration.extendsClause?.superclass.name.lexeme;
        if (baseName != null && widgetClassNames.contains(baseName)) {
          changed =
              widgetClassNames.add(declaration.namePart.typeName.lexeme) ||
              changed;
        }
      }
    }
  }

  final violations = <String>[];
  for (final parsedFile in parsedFiles) {
    final widgets = parsedFile.classes
        .where(
          (declaration) =>
              widgetClassNames.contains(declaration.namePart.typeName.lexeme),
        )
        .toList();
    if (widgets.length > 1) {
      violations.add(
        '${parsedFile.file.path}: multiple widget classes: '
        '${widgets.map((widget) => widget.namePart.typeName.lexeme).join(', ')}',
      );
    }

    for (final directive
        in parsedFile.unit.directives.whereType<ImportDirective>()) {
      final import = directive.uri.stringValue;
      if (import != null) {
        violations.addAll(_checkImport(parsedFile.file.path, import));
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Architecture check failed:');
    for (final violation in violations) {
      stderr.writeln('  - $violation');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Architecture check passed (${files.length} Dart files scanned).',
  );
}

Future<List<File>> _dartFilesIn(String path) async {
  final directory = Directory(path);
  if (!await directory.exists()) return [];

  return directory
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .map((entity) => entity as File)
      .toList();
}

List<String> _checkImport(String sourcePath, String import) {
  if (import.startsWith('dart:')) return [];

  final violations = <String>[];
  final normalizedSource = sourcePath.replaceAll('\\', '/');
  final isPackageImport = import.startsWith('package:');
  final packagePath = isPackageImport ? import.split(':').last : import;
  final normalizedImport = packagePath.replaceAll('\\', '/');
  final sourceParts = normalizedSource.split('/');
  final featureIndex = sourceParts.indexOf('features');
  final sourceFeature =
      featureIndex >= 0 && sourceParts.length > featureIndex + 1
      ? sourceParts[featureIndex + 1]
      : null;
  final sourceLayer = featureIndex >= 0 && sourceParts.length > featureIndex + 2
      ? sourceParts[featureIndex + 2]
      : null;

  if (!isPackageImport && normalizedSource.startsWith('lib/')) {
    violations.add('$sourcePath: use package imports inside lib/ ($import)');
  }

  final featureMatch = RegExp(
    r'(?:^|/)features/([^/]+)/([^/]+)(?:/|$)',
  ).firstMatch(normalizedImport);
  final targetFeature = featureMatch?.group(1);
  final targetLayer = featureMatch?.group(2);
  final isCompositionRoot = normalizedSource == 'lib/app/app_providers.dart';

  if (normalizedSource.startsWith('lib/core/') &&
      normalizedImport.contains('/features/')) {
    violations.add(
      '$sourcePath: core code must not import feature code ($import)',
    );
  }

  if (sourceFeature != null &&
      targetFeature != null &&
      sourceFeature != targetFeature &&
      !(isCompositionRoot ||
          targetLayer == 'domain' ||
          (targetLayer == 'application' &&
              normalizedImport.contains('/application/public/')))) {
    violations.add(
      '$sourcePath: cross-feature import must target an explicit domain '
      'contract or application/public API ($import)',
    );
  }

  if (sourceFeature != null) {
    final forbiddenLayers = switch (sourceLayer) {
      'presentation' => {'data', 'infrastructure'},
      'application' => {'presentation', 'data', 'infrastructure'},
      'domain' => {'presentation', 'application', 'data', 'infrastructure'},
      'data' => {'presentation', 'infrastructure'},
      'infrastructure' => {'presentation'},
      _ => <String>{},
    };
    if (targetFeature == sourceFeature &&
        targetLayer != null &&
        forbiddenLayers.contains(targetLayer)) {
      violations.add(
        '$sourcePath: $sourceLayer must not import $targetLayer code ($import)',
      );
    }
  }

  if (sourceLayer == 'domain' &&
      (normalizedImport.startsWith('flutter/') ||
          normalizedImport.startsWith('flutter_riverpod/') ||
          normalizedImport.startsWith('riverpod/') ||
          normalizedImport.startsWith('firebase_') ||
          normalizedImport.startsWith('cloud_'))) {
    violations.add(
      '$sourcePath: domain must stay framework/backend independent ($import)',
    );
  }

  if (sourceLayer == 'presentation' ||
      sourceLayer == 'application' ||
      sourceLayer == 'domain' ||
      sourceLayer == 'data') {
    final packageName = normalizedImport.startsWith('package:')
        ? normalizedImport.split('/').first
        : normalizedImport.split('/').first;
    if (_platformAndBackendPackages.any(
      (blocked) => packageName == blocked || packageName.startsWith(blocked),
    )) {
      violations.add(
        '$sourcePath: $sourceLayer must not depend directly on platform/backend '
        'package $packageName ($import)',
      );
    }
  }

  if (normalizedSource.startsWith('lib/app/') &&
      !isCompositionRoot &&
      (normalizedImport.contains('/data/') ||
          normalizedImport.contains('/infrastructure/'))) {
    violations.add(
      '$sourcePath: only app/app_providers.dart may wire data/infrastructure '
      'implementations ($import)',
    );
  }

  if (normalizedSource == 'lib/app/app_router.dart' &&
      normalizedImport.contains('/features/') &&
      !normalizedImport.contains('/presentation/')) {
    violations.add(
      '$sourcePath: app_router.dart may import feature presentation only ($import)',
    );
  }

  return violations;
}

class _ClassCollector extends RecursiveAstVisitor<void> {
  final classes = <ClassDeclaration>[];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    classes.add(node);
    super.visitClassDeclaration(node);
  }
}

class _ParsedFile {
  const _ParsedFile(this.file, this.unit, this.classes);

  final File file;
  final CompilationUnit unit;
  final List<ClassDeclaration> classes;
}
