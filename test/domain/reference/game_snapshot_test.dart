import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/reference/game_snapshot.dart';
import 'package:abyss/domain/reference/snapshot_sections.dart';
import 'package:flutter_test/flutter_test.dart';

import 'section_changes.dart';

Game _newGame() => GameFactory.newGame(
  playerName: 'Nemo',
  mapSeed: 7,
  personalities: const [
    FactionPersonality.pearlOrder,
    FactionPersonality.wreckPillagers,
  ],
);

Set<String> _changed(Map<String, String> before, Map<String, String> after) => {
  for (final String name in before.keys)
    if (before[name] != after[name]) name,
};

void main() {
  test('two games in the same state give the same texts, though the id of '
      'the human differs', () {
    final a = _newGame();
    final b = _newGame();

    expect(a.humanPlayerId, isNot(b.humanPlayerId));
    expect(GameSnapshot.texts(a), GameSnapshot.texts(b));
  });

  test('lists every section, by name', () {
    expect(GameSnapshot.texts(_newGame()).keys, SnapshotSections.names);
    expect(GameSnapshot.sections(_newGame()).keys, SnapshotSections.names);
  });

  test('the changes below cover every section', () {
    expect(sectionChanges.keys.toSet(), SnapshotSections.names.toSet());
  });

  for (final MapEntry<String, List<Change>> section in sectionChanges.entries) {
    test('a change of ${section.key} changes that section alone', () {
      final Map<String, String> before = GameSnapshot.texts(_newGame());
      for (int i = 0; i < section.value.length; i++) {
        final Game game = _newGame();
        section.value[i](game);

        expect(_changed(before, GameSnapshot.texts(game)), {
          section.key,
        }, reason: 'change $i');
      }
    });
  }

  test('reading a game twice gives the same texts and changes nothing', () {
    final game = _newGame();
    final first = GameSnapshot.texts(game);

    expect(GameSnapshot.texts(game), first);
    expect(game.humanPlayer.savedIntel, isNull);
  });

  test('never writes the id drawn for the human', () {
    final game = _newGame();
    for (final String section in ['map1', 'intel', 'raids']) {
      for (final Change change in sectionChanges[section]!) {
        change(game);
      }
    }

    final texts = GameSnapshot.texts(game);

    expect(texts.values.join(), isNot(contains(game.humanPlayerId)));
    expect(texts['map1'], contains('"collectedBy":"human"'));
    expect(texts['players'], startsWith('[["human",{"baseX":'));
    expect(texts['intel'], contains('[["human",{"army":[["scout",2]]'));
    expect(texts['raids'], contains('"postAttackTurns":[["human",3]]'));
    expect(texts['raids'], contains('"attackerId":"faction-pearlOrder"'));
  });

  test('a level not generated yet is null: a game without faction starts '
      'with the first one only', () {
    final texts = GameSnapshot.texts(
      GameFactory.newGame(playerName: 'Nemo', mapSeed: 7),
    );

    expect(texts['map1'], startsWith('{"cells":[{"collectedBy":null,'));
    expect(texts['map2'], 'null');
    expect(texts['map3'], 'null');
  });

  test('a level no section holds fails loudly', () {
    final game = _newGame();
    game.levels[4] = GameMap(width: 0, height: 0, cells: [], seed: 0);

    expect(() => GameSnapshot.texts(game), throwsStateError);
  });

  test('the digests follow the sections, through the digest given', () {
    final game = _newGame();
    final texts = GameSnapshot.texts(game);

    expect(GameSnapshot.digests(game, (String text) => 'h${text.length}'), [
      for (final String text in texts.values) 'h${text.length}',
    ]);
  });

  test('a section reads as specified', () {
    final texts = GameSnapshot.texts(_newGame());

    expect(
      texts['game'],
      '{"difficulty":"normal","factions":["pearlOrder","wreckPillagers"],'
      '"humanPlayerId":"human","status":"playing","turn":1}',
    );
    expect(
      texts['worksite'],
      '[["human",{"worksite":{"research":0,"upgrades":0}}],'
      '["faction-pearlOrder",{"worksite":{"research":0,"upgrades":0}}],'
      '["faction-wreckPillagers",{"worksite":{"research":0,"upgrades":0}}]]',
    );
    expect(
      texts['journal'],
      '{"replay":{"actions":[],"endTurnSeeds":[],"exact":true,"mapSeed":7,'
      '"playerName":"Nemo"}}',
    );
    expect(
      texts['resources'],
      startsWith(
        '[["human",{"resources":[["algae",{"amount":100,"maxStorage":5000,'
        '"type":"algae"}],["coral",',
      ),
    );
  });
}
