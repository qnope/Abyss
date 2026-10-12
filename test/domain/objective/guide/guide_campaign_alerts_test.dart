import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_defence_advisor.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/guide_campaign_helpers.dart';
import '../../../helpers/guide_helpers.dart';
import '../../../helpers/objective_helpers.dart';

/// A game on [id] whose Faille at (7, 5) is held with its Module built.
Game _heldFaille(ObjectiveId id) {
  final game = campaignGame(id);
  setBuilding(game.humanPlayer, BuildingType.descentModule, 1);
  placePost(game, 1, 7, 5, held: true);
  return game;
}

/// A game on [id] whose kernel at (4, 4) is held, [wave] announced.
Game _waveOn(ObjectiveId id, MonsterLair wave) {
  final game = campaignGame(id);
  placeKernel(game, 4, 4, held: true);
  game.humanPlayer.volcanoState.announce(wave, game.turn);
  return game;
}

void main() {
  final faille = GuideTarget.cell(1, GridPosition(x: 7, y: 5));
  final firstWave = VolcanoWaveFactory.fromKernelLevel(0, firstWave: true);

  group('a post nobody defends', () {
    test('comes first once its passage is built', () {
      expect(
        adviceOf(_heldFaille(ObjectiveId.hqLevel8)),
        GuideAdvice(
          const GuidePostUndefended(TransitionBaseType.faille, 2),
          faille,
        ),
      );
    });

    test('is forgotten once a unit stands below', () {
      final game = _heldFaille(ObjectiveId.hqLevel8);
      setUnits(game.humanPlayer, UnitType.scout, 1, level: 2);
      expect(adviceOf(game)!.message, const GuideLesson(ObjectiveId.hqLevel8));
    });

    test('waits for the passage to be built', () {
      final game = _heldFaille(ObjectiveId.hqLevel8);
      setBuilding(game.humanPlayer, BuildingType.descentModule, 0);
      expect(adviceOf(game)!.message, const GuideLesson(ObjectiveId.hqLevel8));
    });

    test('leaves the descent onto its level to its own lesson', () {
      expect(
        adviceOf(_heldFaille(ObjectiveId.descendLevel2))!.message,
        const GuideLesson(ObjectiveId.descendLevel2),
      );
    });
  });

  group('an announced kraken wave', () {
    test('asks for a garrison large enough', () {
      final game = _waveOn(ObjectiveId.kernelLevel1, firstWave);
      final int? needed = KernelDefenceAdvisor.unitsFor(
        game.humanPlayer,
        firstWave,
      );
      expect(needed, greaterThan(0));
      expect(
        adviceOf(game),
        GuideAdvice(
          GuideKernelWave(firstWave.totalCount, needed: needed),
          GuideTarget.garrison(3, GridPosition(x: 4, y: 4)),
        ),
      );
    });

    test('says nothing of a garrison that holds', () {
      final game = _waveOn(ObjectiveId.kernelLevel1, firstWave);
      setUnits(
        game.humanPlayer,
        UnitType.domeBreaker,
        40,
        level: KernelGarrison.stockKey,
      );
      expect(
        adviceOf(game)!.message,
        const GuideLesson(ObjectiveId.kernelLevel1),
      );
    });

    test('names no number when none would hold, even past chapter 5', () {
      const flood = MonsterLair(
        difficulty: MonsterDifficulty.hard,
        family: MonsterFamily.kraken,
        unitCount: 2000,
      );
      final game = _waveOn(ObjectiveId.kernelLevel5, flood);
      expect(adviceOf(game)!.message, const GuideKernelWave(2000));
    });

    test('comes before a post nobody defends', () {
      final game = _waveOn(ObjectiveId.kernelLevel1, firstWave);
      setBuilding(game.humanPlayer, BuildingType.descentModule, 1);
      placePost(game, 1, 7, 5, held: true);
      expect(adviceOf(game)!.message, isA<GuideKernelWave>());
    });
  });
}
