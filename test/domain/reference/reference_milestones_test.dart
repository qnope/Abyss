import 'dart:convert';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/reference/reference_exporter.dart';
import 'package:abyss/domain/reference/reference_milestones.dart';
import 'package:abyss/domain/reference/reference_source.dart';
import 'package:abyss/domain/script/script_milestones.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/reference/sha256_hex.dart';
import 'reference_sources.dart';

Game _game() => GameFactory.newGame(
  playerName: 'Nemo',
  mapSeed: 3,
  personalities: const [
    FactionPersonality.pearlOrder,
    FactionPersonality.anglerCult,
  ],
);

void main() {
  test('a game that just started went nowhere', () {
    expect(ReferenceMilestones.of(_game(), ScriptMilestones()), {
      'failleCaptured': null,
      'chemineeCaptured': null,
      'kernelCaptured': null,
      'leviathanStruck': null,
      'leviathanHeld': null,
      'raidsRepelled': 0,
      'raidsLost': 0,
      'wavesRepelled': 0,
      'wavesLost': 0,
      'fallenFactions': 0,
      'winner': null,
    });
  });

  test('tells the steps taken, the fights at home and on the kernel, the '
      'factions fallen and who tamed the volcano', () {
    final game = _game();
    final rival = game.players['faction-anglerCult']!;
    game.humanPlayer.raidState
      ..recordOutcome(victory: true)
      ..recordOutcome(victory: true)
      ..recordOutcome(victory: false);
    game.humanPlayer.volcanoState
      ..recordOutcome(victory: true)
      ..recordOutcome(victory: false);
    game.players['faction-pearlOrder']!.savedFallen = true;
    rival.buildings[BuildingType.headquarters]!.level = 10;
    rival.buildings[BuildingType.volcanicKernel]!.level = 10;
    final milestones =
        ScriptMilestones()
          ..failleCaptured = 30
          ..chemineeCaptured = 45
          ..kernelCaptured = 60
          ..leviathanStruck = 36
          ..leviathanHeld = true;

    expect(ReferenceMilestones.of(game, milestones), {
      'failleCaptured': 30,
      'chemineeCaptured': 45,
      'kernelCaptured': 60,
      'leviathanStruck': 36,
      'leviathanHeld': true,
      'raidsRepelled': 2,
      'raidsLost': 1,
      'wavesRepelled': 1,
      'wavesLost': 1,
      'fallenFactions': 1,
      'winner': 'faction-anglerCult',
    });
  });

  test('the human who wins is written human, not by its id', () {
    final game = _game();
    game.humanPlayer.buildings[BuildingType.headquarters]!.level = 10;
    game.humanPlayer.buildings[BuildingType.volcanicKernel]!.level = 10;

    expect(ReferenceMilestones.of(game, ScriptMilestones())['winner'], 'human');
  });

  test('a reference file tells how far its game went', () {
    const exporter = ReferenceExporter(digest: sha256Hex, read: readScenario);
    final file =
        jsonDecode(
              exporter
                  .export(const ReferenceSource(strategy: 'idle', turns: 50))
                  .game
                  .text,
            )
            as Map<String, Object?>;
    final milestones = (file['coverage']! as Map)['milestones']! as Map;

    expect((file['result']! as Map)['status'], 'defeat');
    expect(milestones['raidsLost'], 3);
    expect(milestones['kernelCaptured'], isNull);
    expect(milestones['winner'], isNull);
  });
}
