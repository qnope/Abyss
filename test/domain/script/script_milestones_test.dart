import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/script/batch_runner.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/script_milestones.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notes the first turn a Faille is held, and only the first', () {
    final game = GameFactory.newSinglePlayer(playerName: 'p', mapSeed: 3);
    final milestones = ScriptMilestones()..observe(game, 4);
    expect(milestones.failleCaptured, isNull);

    final faille = game.levels[1]!.cells.firstWhere((c) =>
        c.content == CellContentType.transitionBase &&
        c.transitionBase!.type == TransitionBaseType.faille);
    faille.transitionBase!.capturedBy = game.humanPlayerId;
    milestones
      ..observe(game, 9)
      ..observe(game, 12);

    expect(milestones.failleCaptured, 9);
    expect(milestones.chemineeCaptured, isNull);
    expect(milestones.kernelCaptured, isNull);
  });

  test('the runner records every raid of the game', () {
    final report = ScriptRunner(maxTurns: 60).run(const IdleScript(), seed: 1);
    final raids = report.milestones.raids;

    expect(raids, hasLength(report.raidsLost + report.raidsRepelled));
    expect(raids.every((r) => !r.victory && r.monsters > 0), isTrue);
  });

  test('a batch tells how many games reached a milestone, and when', () async {
    final report = await BatchRunner(runner: ScriptRunner(maxTurns: 60))
        .run((_) => const IdleScript(), games: 2);

    final fall = report.milestone((r) => r.isDefeat ? r.turnsPlayed : null);
    expect(fall.games, 2);
    expect(fall.averageTurn, report.earliestDefeat);
    expect(report.milestone((r) => r.milestones.kernelCaptured).games, 0);
  });
}
