import 'dart:convert';

import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/reference/digest_rows.dart';
import 'package:abyss/domain/reference/game_snapshot.dart';
import 'package:abyss/domain/reference/reference_exporter.dart';
import 'package:abyss/domain/reference/reference_recorder.dart';
import 'package:abyss/domain/reference/reference_source.dart';
import 'package:abyss/domain/reference/snapshot_sections.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/reference/sha256_hex.dart';
import 'reference_sources.dart';

void main() {
  const exporter = ReferenceExporter(
    digest: sha256Hex,
    read: readScenario,
    everyTurn: true,
  );

  for (final MapEntry<String, ReferenceSource> source in sources.entries) {
    test('${source.key}: replaying the exported journal the way the '
        'simulator does gives the same digests at every turn', () {
      final file =
          jsonDecode(exporter.export(source.value).game.text)
              as Map<String, Object?>;
      final journal = file['journal']! as Map<String, Object?>;
      final turns = (file['turns']! as List).cast<Map<String, Object?>>();
      expect(journal['exact'], isTrue);

      // Another seed for the runner, and an id drawn for the human: only
      // the journal decides the game.
      final recorder = ReferenceRecorder(sha256Hex);
      ScriptRunner(
        executor: recorder,
      ).run(ScenarioParser.parse(jsonEncode(journal)), seed: 99);

      expect(recorder.turns.map((t) => t.turn), turns.map((t) => t['turn']));
      expect(
        [for (final t in recorder.turns) t.digests],
        DigestRows.expand([
          for (final t in turns) (t['digests']! as List).cast<String>(),
        ]),
      );
      expect(GameSnapshot.digests(recorder.game, sha256Hex), file['final']);
      expect(recorder.game.status.name, (file['result']! as Map)['status']);
      expect(recorder.game.turn, (file['result']! as Map)['turn']);
    });
  }

  test('the same source gives the same file, byte for byte', () {
    final source = sources['conquest against two factions']!;

    expect(
      exporter.export(source).game.text,
      exporter.export(source).game.text,
    );
  });

  test('the file names its format, its source, its sections and what the '
      'game went through', () {
    const source = ReferenceSource(
      strategy: 'balanced',
      seed: 2,
      difficulty: Difficulty.easy,
      factions: [FactionPersonality.pearlOrder],
      turns: 12,
    );
    final game = exporter.export(source).game;
    final file = jsonDecode(game.text) as Map<String, Object?>;

    expect(file.keys, [
      'format',
      'source',
      'result',
      'coverage',
      'sections',
      'turns',
      'final',
      'journal',
    ]);
    expect(file['format'], 1);
    expect(file['source'], source.toJson());
    expect(file['result'], {'status': 'playing', 'turn': 13});
    expect(file['sections'], SnapshotSections.names);
    expect(file['turns'], hasLength(13));
    expect((file['coverage']! as Map)['actions'], containsPair('endTurn', 12));
    final journal = file['journal']! as Map<String, Object?>;
    expect(journal['difficulty'], 'easy');
    expect(journal['factions'], ['pearlOrder']);
    expect(journal['lastTurn'], 13);
    expect((journal['endTurnSeeds']! as Map).keys, hasLength(12));
    expect(journal['players'], [
      {'id': ReferenceExporter.humanId, 'name': 'balanced'},
      {'id': 'faction-pearlOrder', 'name': "L'Ordre de Nacre"},
    ]);
    // One line per turn, for the digests and for the journal.
    expect(game.text, contains('\n{"turn":13,"digests":['));
    expect(game.text, contains('\n"1":[{"do":"upgrade",'));
    expect(game.finalDigests, game.turns.last.digests);
  });
}
