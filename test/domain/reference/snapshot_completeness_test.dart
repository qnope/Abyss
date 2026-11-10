import 'dart:io';

import 'package:abyss/domain/reference/class_snapshot.dart';
import 'package:abyss/domain/reference/snapshot_catalog.dart';
import 'package:abyss/domain/reference/snapshot_sections.dart';
import 'package:abyss/domain/reference/snapshots/game_snapshots.dart';
import 'package:abyss/domain/reference/snapshots/player_snapshots.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hive_source.dart';

void main() {
  final Map<String, Set<String>> persisted = hiveClassesOf(Directory('lib'));
  final Map<String, ClassSnapshot<Object>> snapshots = {
    for (final s in SnapshotCatalog.all) s.className: s,
  };

  group('the source reader', () {
    test('reads the fields of a class, whatever stands before them', () {
      expect(
        hiveClassesIn('''
@HiveType(typeId: 1)
class A extends HiveObject {
  @HiveField(0)
  final Map<int, List<String>> actions;

  /// A comment.
  @HiveField(1, defaultValue: false)
  @override
  bool over;

  @HiveField(2)
  // Kept for old saves.
  late final GridPosition? at;

  int notSaved = 0;
}

@HiveType(typeId: 2)
enum E { @HiveField(0) a }

@HiveType(typeId: 3)
class B {
  @HiveField(4) final int x;
}
'''),
        {
          'A': {'actions', 'over', 'at'},
          'B': {'x'},
        },
      );
    });

    test('fails on a field it cannot read rather than skip it', () {
      expect(
        () => hiveClassesIn(
          '@HiveType(typeId: 1)\nclass A {\n  @HiveField(0)\n  void Function() x;\n}',
        ),
        throwsStateError,
      );
    });

    test('finds the model', () {
      expect(persisted.keys, containsAll(['Game', 'Player', 'MapCell']));
      expect(persisted['Building'], {'type', 'level'});
    });
  });

  test('every persisted class has a snapshot, and no snapshot is stale', () {
    expect(snapshots.keys.toSet(), persisted.keys.toSet());
    expect(snapshots.length, SnapshotCatalog.all.length, reason: 'twice');
  });

  test('a snapshot writes or omits, with a reason, every persisted field: '
      'adding a @HiveField to the model fails here until the snapshot '
      'knows it', () {
    for (final MapEntry<String, Set<String>> c in persisted.entries) {
      final ClassSnapshot<Object> snapshot = snapshots[c.key]!;
      final written = snapshot.fieldNames.toSet();
      final omitted = snapshot.omitted.keys.toSet();
      expect(written.intersection(omitted), isEmpty, reason: c.key);
      expect(
        written.union(omitted),
        c.value,
        reason:
            '${c.key}: the fields of the snapshot (written or omitted) '
            'against the @HiveField of the class',
      );
      for (final String reason in snapshot.omitted.values) {
        expect(reason.length, greaterThan(20), reason: c.key);
      }
      expect(snapshot.fieldNames, containsAll(snapshot.renamed.keys));
    }
  });

  test('no two fields of a class are written under the same key', () {
    for (final ClassSnapshot<Object> s in SnapshotCatalog.all) {
      final keys = s.fieldNames.map(s.keyOf).toList();
      expect(keys.toSet().length, keys.length, reason: s.className);
    }
  });

  group('the sections', () {
    test('share out every written field of Game but the maps', () {
      final fields = [
        for (final names in SnapshotSections.ofGame.values) ...names,
      ];
      expect(fields.toSet().length, fields.length, reason: 'in two sections');
      expect(fields.toSet(), GameSnapshots.game.fieldNames.toSet());
    });

    test('share out every written field of Player', () {
      final fields = [
        for (final names in SnapshotSections.ofPlayers.values) ...names,
      ];
      expect(fields.toSet().length, fields.length, reason: 'in two sections');
      expect(fields.toSet(), PlayerSnapshots.player.fieldNames.toSet());
    });

    test('are listed by name, each once', () {
      final names = SnapshotSections.names;
      expect(names, [...names]..sort());
      expect(names.toSet().length, names.length);
      expect(names, hasLength(20));
      expect(names, containsAll(['map1', 'map2', 'map3', 'game', 'fog']));
    });
  });
}
