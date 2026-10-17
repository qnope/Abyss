import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_category.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/kernel_garrison_helpers.dart';
import '../../../helpers/objective_helpers.dart';
import '../../../helpers/post_attack_helper.dart';

const _archives = [
  TipId.abyssListens,
  TipId.rivalColonies,
  TipId.ancients,
  TipId.forgeTowers,
  TipId.awakening,
];

bool _applies(Game game, TipId id) =>
    TipCatalog.byId(id).appliesTo(game, game.humanPlayer);

void main() {
  group('Archives', () {
    test('the last section of the Guide holds the five archive tips', () {
      expect(TipCategory.values.last, TipCategory.archives);
      expect([
        for (final tip in TipCatalog.all)
          if (tip.category == TipCategory.archives) tip.id,
      ], _archives);
    });

    test('open after the gameplay tips of the same turn', () {
      final game =
          objectiveGame()
            ..humanPlayer.savedObjectiveState = ObjectiveState(
              tipsEnabled: true,
            );
      game.humanPlayer.raidState.recordOutcome(victory: false);
      final pending = TipCatalog.pendingFor(game, game.humanPlayer);
      expect(pending.map((t) => t.id), [TipId.raidReport, TipId.abyssListens]);
      expect(
        TipCatalog.all.skip(TipCatalog.all.length - 5).map((t) => t.id),
        _archives,
      );
    });
  });

  test('abyssListens: once a first raid was fought, won or lost', () {
    for (final victory in [true, false]) {
      final game = objectiveGame();
      expect(_applies(game, TipId.abyssListens), isFalse);
      game.humanPlayer.raidState.recordOutcome(victory: victory);
      expect(_applies(game, TipId.abyssListens), isTrue);
    }
  });

  test('rivalColonies: once the base of a faction is revealed', () {
    expect(_applies(objectiveGame(), TipId.rivalColonies), isFalse);
    final game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 7,
      factionCount: 2,
    );
    expect(_applies(game, TipId.rivalColonies), isFalse);
    final rival = game.players[game.factions.last.id]!;
    game.humanPlayer.addRevealedCell(
      1,
      GridPosition(x: rival.baseX, y: rival.baseY),
    );
    expect(_applies(game, TipId.rivalColonies), isTrue);
  });

  group('ancients', () {
    test('once the player holds a Faille', () {
      final held = PostWar(TransitionBaseType.faille, humanHolds: true);
      expect(_applies(held.game, TipId.ancients), isTrue);
    });

    test('not while another holds it, nor for a Cheminée', () {
      final war = PostWar(TransitionBaseType.faille);
      expect(_applies(war.game, TipId.ancients), isFalse);
      final vent = PostWar(TransitionBaseType.cheminee, humanHolds: true);
      expect(_applies(vent.game, TipId.ancients), isFalse);
    });

    test('also for a Faille captured once, then lost', () {
      final game = objectiveGame();
      game.humanPlayer.addHistoryEntry(captureEntry('cheminee:0'));
      expect(_applies(game, TipId.ancients), isFalse);
      game.humanPlayer.addHistoryEntry(captureEntry('faille:1'));
      expect(_applies(game, TipId.ancients), isTrue);
    });
  });

  test('forgeTowers: once units stand below the reef', () {
    final game = objectiveGame();
    setUnits(game.humanPlayer, UnitType.scout, 4);
    setUnits(game.humanPlayer, UnitType.scout, 0, level: 2);
    expect(_applies(game, TipId.forgeTowers), isFalse);
    setUnits(game.humanPlayer, UnitType.scout, 1, level: 2);
    expect(_applies(game, TipId.forgeTowers), isTrue);
  });

  test('forgeTowers: not for the garrison of the kernel alone', () {
    final game = kernelGarrisonGame(onVolcano: 0, garrisoned: 3);
    expect(_applies(game, TipId.forgeTowers), isFalse);
    setUnits(game.humanPlayer, UnitType.scout, 1, level: 3);
    expect(_applies(game, TipId.forgeTowers), isTrue);
  });

  group('awakening', () {
    test('once the kernel is taken', () {
      final game = kernelGarrisonGame();
      setBuilding(game.humanPlayer, BuildingType.volcanicKernel, 0);
      expect(_applies(game, TipId.awakening), isTrue);
    });

    test('not before', () {
      final game = kernelGarrisonGame(captured: false);
      setBuilding(game.humanPlayer, BuildingType.volcanicKernel, 0);
      expect(_applies(game, TipId.awakening), isFalse);
      expect(_applies(objectiveGame(), TipId.awakening), isFalse);
    });

    test('also once taken then lost, its fires already lit', () {
      final game = kernelGarrisonGame(captured: false);
      expect(_applies(game, TipId.awakening), isTrue);
    });
  });
}
