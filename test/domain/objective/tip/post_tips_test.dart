import 'package:abyss/domain/action/attack_held_kernel_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/post_tip_triggers.dart';
import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_category.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/kernel_garrison_helpers.dart';
import '../../../helpers/objective_helpers.dart';
import '../../../helpers/post_attack_helper.dart';

/// Turns the tips on for the human of [game], every tip but [id] seen.
Game _only(Game game, TipId id) {
  game.humanPlayer.savedObjectiveState = ObjectiveState(tipsEnabled: true);
  for (final other in TipId.values) {
    if (other != id) game.humanPlayer.savedObjectiveState!.markSeen(other);
  }
  return game;
}

TipId? _next(Game game) => TipCatalog.nextFor(game, game.humanPlayer)?.id;

void main() {
  test('files the admiral with the map, the posts with the threats', () {
    expect(TipCatalog.byId(TipId.admiral).category, TipCategory.map);
    for (final id in [
      TipId.postDefence,
      TipId.kernelGarrison,
      TipId.postLost,
    ]) {
      expect(TipCatalog.byId(id).category, TipCategory.threats, reason: '$id');
    }
  });

  group('admiral', () {
    test('waits for an Abyss Admiral', () {
      final game = _only(objectiveGame(), TipId.admiral);
      setBuilding(game.humanPlayer, BuildingType.barracks, 2);
      expect(_next(game), isNull);
    });

    test('opens once the player owns one, on any level', () {
      final game = _only(objectiveGame(), TipId.admiral);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1, level: 2);
      expect(PostTipTriggers.admiral(game, game.humanPlayer), isTrue);
      expect(_next(game), TipId.admiral);
    });
  });

  group('postDefence', () {
    test('opens once the human holds a post', () {
      final war = PostWar(TransitionBaseType.faille, humanHolds: true);
      _only(war.game, TipId.postDefence);
      expect(_next(war.game), TipId.postDefence);
    });

    test('stays shut while another player holds it', () {
      final war = PostWar(TransitionBaseType.faille);
      _only(war.game, TipId.postDefence);
      expect(PostTipTriggers.postHeld(war.game, war.human), isFalse);
      expect(_next(war.game), isNull);
    });
  });

  group('kernelGarrison', () {
    test('opens once the kernel is held and built', () {
      final game = _only(kernelGarrisonGame(), TipId.kernelGarrison);
      expect(_next(game), TipId.kernelGarrison);
    });

    test('waits for the kernel building', () {
      final game = _only(kernelGarrisonGame(), TipId.kernelGarrison);
      setBuilding(game.humanPlayer, BuildingType.volcanicKernel, 0);
      expect(_next(game), isNull);
    });

    test('waits for the kernel to be taken', () {
      final game = _only(
        kernelGarrisonGame(captured: false),
        TipId.kernelGarrison,
      );
      expect(_next(game), isNull);
    });
  });

  group('postLost', () {
    Game withEntry({
      required bool victory,
      required bool defending,
      String? post,
    }) {
      final game = _only(objectiveGame(), TipId.postLost);
      game.humanPlayer.addHistoryEntry(
        baseAssaultEntry(victory: victory, defending: defending, post: post),
      );
      return game;
    }

    test('opens once a post of the player was taken', () {
      final game = withEntry(victory: true, defending: true, post: 'faille:0');
      expect(_next(game), TipId.postLost);
    });

    test('not for a post that held', () {
      expect(
        _next(withEntry(victory: false, defending: true, post: 'faille:0')),
        isNull,
      );
    });

    test('not for a post the player took', () {
      expect(
        _next(withEntry(victory: true, defending: false, post: 'faille:0')),
        isNull,
      );
    });

    test('not for the base nor the kernel', () {
      expect(_next(withEntry(victory: true, defending: true)), isNull);
      expect(
        _next(
          withEntry(
            victory: true,
            defending: true,
            post: AttackHeldKernelAction.kernelCode,
          ),
        ),
        isNull,
      );
    });
  });
}
