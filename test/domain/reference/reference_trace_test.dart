import 'dart:convert';

import 'package:abyss/domain/reference/reference_exporter.dart';
import 'package:abyss/domain/reference/reference_recorder.dart';
import 'package:abyss/domain/reference/reference_trace.dart';
import 'package:abyss/domain/reference/snapshot_sections.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/reference/sha256_hex.dart';
import 'reference_sources.dart';

void main() {
  const exporter = ReferenceExporter(digest: sha256Hex, read: readScenario);
  final source = sources['conquest against two factions']!;

  test('a dump holds the canonical text of every section at the start of '
      'the turn: the very texts the digests of that turn are made of', () {
    final export = exporter.export(source, dumpTurn: 20);
    final dump = jsonDecode(export.dump!) as Map<String, Object?>;
    final sections = dump['sections']! as Map<String, Object?>;

    expect(dump['format'], 1);
    expect(dump['turn'], 20);
    expect(sections.keys, SnapshotSections.names);
    expect((sections['game']! as Map)['turn'], 20);
    // One line per section, each one "name": and its canonical text.
    final lines = export.dump!.split('\n');
    final digests = [
      for (final String name in SnapshotSections.names)
        sha256Hex(
          lines
              .firstWhere((l) => l.startsWith('"$name":'))
              .substring('"$name":'.length)
              .replaceFirst(RegExp(r',$'), ''),
        ),
    ];
    expect(digests, export.game.turns[19].digests);
  });

  test('the dump of the last state is asked as "final"', () {
    final export = exporter.export(source, dumpTurn: 'final');
    final dump = jsonDecode(export.dump!) as Map<String, Object?>;

    expect(dump['turn'], 'final');
    expect(((dump['sections']! as Map)['game'] as Map)['turn'], 36);
    expect(exporter.export(source).dump, isNull);
  });

  test('a trace holds the digests after each action of the turn, those '
      'of the factions included, between its start and its end', () {
    final export = exporter.export(source, traceTurn: 20);
    final trace = jsonDecode(export.trace!) as Map<String, Object?>;
    final actions = (trace['actions']! as List).cast<Map<String, Object?>>();
    final journal =
        ((export.game.journal['turns']! as Map)['20'] as List)
            .cast<Map<String, Object?>>();

    expect(trace['turn'], 20);
    expect(trace['sections'], SnapshotSections.names);
    expect(trace['start'], export.game.turns[19].digests);
    expect(trace['end'], export.game.turns[20].digests);
    expect([for (final a in actions) a['action']], journal);
    expect(journal.any((a) => a.containsKey('player')), isTrue);
    expect(actions.first['digests'], isNot(trace['start']));
    expect(actions.every((a) => (a['digests']! as List).length == 20), isTrue);
    expect(exporter.export(source).trace, isNull);
  });

  test('the trace of the turn a game stopped in has no end', () {
    final export = exporter.export(sources['an exported game']!, traceTurn: 85);
    final trace = jsonDecode(export.trace!) as Map<String, Object?>;

    expect(export.game.turn, 85);
    expect(trace['start'], export.game.turns.last.digests);
    expect(trace['end'], isNull);
  });

  test('a journal that does not hold the actions executed is refused', () {
    final recorder = ReferenceRecorder(sha256Hex, traceTurn: 1)
      ..traced.add(const []);

    expect(() => ReferenceTrace.trace(recorder, 1, const []), throwsStateError);
  });
}
