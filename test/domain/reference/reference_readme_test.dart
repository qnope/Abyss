import 'dart:io';

import 'package:abyss/domain/reference/class_snapshot.dart';
import 'package:abyss/domain/reference/snapshot_catalog.dart';
import 'package:abyss/domain/reference/snapshot_sections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reference/README.md', () {
    final String readme = File('reference/README.md').readAsStringSync();

    test('lists the keys of every class, as the snapshots write them', () {
      final String listed =
          readme
              .split('<!-- keys:start -->')[1]
              .split('<!-- keys:end -->')[0]
              .trim();

      expect(listed.split('\n'), [
        for (final ClassSnapshot<Object> s in SnapshotCatalog.all)
          '- `${s.className}`: '
              '${(s.fieldNames.map(s.keyOf).toList()..sort()).map((k) => '`$k`').join(', ')}',
      ]);
    });

    test('names every field left out', () {
      final String leftOut = readme.split('### Fields left out')[1];
      for (final ClassSnapshot<Object> s in SnapshotCatalog.all) {
        for (final String field in s.omitted.keys) {
          expect(
            leftOut.contains('`${s.className}.$field`') ||
                leftOut.contains('`$field` of a history entry'),
            isTrue,
            reason: '${s.className}.$field',
          );
        }
      }
    });

    test('names every section', () {
      for (final String name in SnapshotSections.names) {
        expect(readme, contains('`$name`'), reason: name);
      }
    });
  });
}
