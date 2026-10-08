import 'package:abyss/domain/action/attack_transition_base_result.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a small deterministic [FightResult] with two turns.
FightResult buildTestFight({
  required bool playerWins,
  int initialMonsters = 4,
  int finalMonsters = 0,
}) {
  return FightResult(
    winner: playerWins ? CombatSide.player : CombatSide.monster,
    turnCount: 2,
    turnSummaries: const [
      FightTurnSummary(
        turnNumber: 1,
        attacksPlayed: 2,
        critCount: 0,
        damageDealtByPlayer: 10,
        damageDealtByMonster: 5,
        playerAliveAtEnd: 3,
        monsterAliveAtEnd: 2,
        playerHpAtEnd: 12,
        monsterHpAtEnd: 8,
      ),
      FightTurnSummary(
        turnNumber: 2,
        attacksPlayed: 2,
        critCount: 1,
        damageDealtByPlayer: 7,
        damageDealtByMonster: 3,
        playerAliveAtEnd: 3,
        monsterAliveAtEnd: 0,
        playerHpAtEnd: 9,
        monsterHpAtEnd: 0,
      ),
    ],
    initialPlayerCombatants: const [],
    finalPlayerCombatants: const [],
    initialMonsterCount: initialMonsters,
    finalMonsterCount: finalMonsters,
  );
}

/// Builds a successful [AttackTransitionBaseResult].
AttackTransitionBaseResult buildTransitionResult({
  required bool victory,
  required bool captured,
  bool withFight = true,
}) {
  return AttackTransitionBaseResult.success(
    victory: victory,
    captured: captured,
    fight: withFight
        ? buildTestFight(playerWins: victory, finalMonsters: victory ? 0 : 3)
        : null,
    sent: const {UnitType.abyssAdmiral: 1, UnitType.scout: 5},
    survivorsIntact: const {UnitType.abyssAdmiral: 1, UnitType.scout: 2},
    wounded: const {UnitType.scout: 1},
    dead: const {UnitType.scout: 2},
  );
}

/// Hosts a button labelled [label] that runs [onTap] with a context that
/// sits under a [Scaffold] (so snackbars and navigation work).
Widget buildLauncherHost(String label, void Function(BuildContext) onTap) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => onTap(ctx),
          child: Text(label),
        ),
      ),
    ),
  );
}

/// Enlarges the test surface so long scrollable screens render fully.
void useTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
