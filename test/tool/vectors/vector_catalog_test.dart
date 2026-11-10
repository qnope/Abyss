import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/vectors/vector_catalog.dart';
import '../../../tool/vectors/vector_exporter.dart';
import '../../../tool/vectors/vector_file.dart';

/// Every value under [value] that is not what a vector may hold.
Iterable<Object?> _foreign(Object? value) sync* {
  if (value is Map<String, Object?>) {
    yield* value.values.expand(_foreign);
  } else if (value is List<Object?>) {
    yield* value.expand(_foreign);
  } else if (value != null && value is! String && value is! int && value is! bool) {
    yield value;
  }
}

/// The `.sort(` calls of each file of `lib/domain`, by path under it.
Map<String, int> _sortsOfDomain() {
  final sorts = <String, int>{};
  for (final entity in Directory('lib/domain').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final int calls = '.sort('.allMatches(entity.readAsStringSync()).length;
    final String path = entity.path.replaceAll('\\', '/');
    if (calls > 0) sorts[path.substring('lib/domain/'.length)] = calls;
  }
  return sorts;
}

void main() {
  final String readme =
      File('${VectorCatalog.folder}/README.md').readAsStringSync();

  group('VectorCatalog', () {
    test('names each file once, the language first', () {
      final names = [for (final file in VectorCatalog.all) file.name];
      expect(names.toSet(), hasLength(names.length));
      expect(names.take(4), everyElement(startsWith('dart_')));
      expect(VectorCatalog.domain, isNotEmpty);
    });

    test('generates the same bytes twice', () {
      for (final VectorFile file in VectorCatalog.all) {
        expect(file.render(), file.render(), reason: file.name);
      }
    });

    test('is what reference/vectors holds: run bin/export_vectors.dart', () {
      final folder = Directory(VectorCatalog.folder);
      expect(VectorExporter(VectorCatalog.all).staleIn(folder), isEmpty);
    });

    test('writes plain JSON: no double, a few hundred KB a file', () {
      var total = 0;
      for (final VectorFile file in VectorCatalog.all) {
        final String text = file.render();
        expect(_foreign(jsonDecode(text)), isEmpty, reason: file.name);
        expect(text.length, lessThan(400 * 1024), reason: file.name);
        expect(text.endsWith('}\n'), isTrue);
        total += text.length;
      }
      expect(total, lessThan(4 * 1024 * 1024));
    });

    test('gives cases and the Dart API of every section', () {
      for (final VectorFile file in VectorCatalog.all) {
        for (final e in file.sections.entries) {
          expect(e.value.api, isNotEmpty);
          expect(e.value.cases(), isNotEmpty, reason: '${file.name} ${e.key}');
        }
      }
    });
  });

  group('reference/vectors/README.md', () {
    test('names every file and every section', () {
      for (final VectorFile file in VectorCatalog.all) {
        expect(readme, contains('`${file.fileName}`'));
        final String row = readme
            .split('\n')
            .firstWhere((line) => line.startsWith('| `${file.fileName}`'));
        for (final String section in file.sections.keys) {
          expect(row, contains('`$section`'), reason: file.name);
        }
      }
    });

    test('lists every .sort( of lib/domain', () {
      final listed = <String, int>{};
      for (final String line in readme.split('\n')) {
        final match = RegExp(r'^\| `([\w/]+\.dart)` \|').firstMatch(line);
        if (match != null) listed[match[1]!] = (listed[match[1]!] ?? 0) + 1;
      }
      expect(listed, _sortsOfDomain());
    });
  });
}
