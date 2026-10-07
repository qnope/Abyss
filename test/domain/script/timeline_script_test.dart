import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/script/action_spec.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/timeline_script.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingScript extends GameScript {
  final List<int> turns = <int>[];

  @override
  String get name => 'counting';

  @override
  void playTurn(ScriptTurn turn) => turns.add(turn.number);
}

void main() {
  ActionSpec upgrade(BuildingType type) =>
      (_) => UpgradeBuildingAction(buildingType: type);

  test('plays the planned actions on their turn', () {
    final script = TimelineScript(
      name: 'hq',
      turns: <int, List<ActionSpec>>{
        2: <ActionSpec>[upgrade(BuildingType.headquarters)],
      },
    );

    final report = ScriptRunner(maxTurns: 3).run(script, seed: 1);

    expect(report.log, hasLength(1));
    expect(report.log.single.turn, 2);
    expect(report.log.single.success, isTrue);
    expect(report.buildings[BuildingType.headquarters], 1);
  });

  test('logs a refused action with its reason', () {
    final script = TimelineScript(
      name: 'too-soon',
      turns: <int, List<ActionSpec>>{
        1: <ActionSpec>[upgrade(BuildingType.barracks)],
      },
    );

    final report = ScriptRunner(maxTurns: 1).run(script, seed: 1);

    expect(report.log.single.success, isFalse);
    expect(report.log.single.reason, isNotNull);
    expect(report.failedActions, 1);
  });

  test('hands the turns left out to the fallback script', () {
    final fallback = _CountingScript();
    final script = TimelineScript(
      name: 'mixed',
      turns: <int, List<ActionSpec>>{2: <ActionSpec>[]},
      otherwise: fallback,
    );

    ScriptRunner(maxTurns: 4).run(script, seed: 1);

    expect(fallback.turns, <int>[1, 3, 4]);
  });
}
