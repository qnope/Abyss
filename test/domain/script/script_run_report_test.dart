import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_run_report.dart';
import 'package:flutter_test/flutter_test.dart';

const ScriptLogEntry _done =
    ScriptLogEntry(turn: 2, description: 'Explorer (3, 4)', success: true);
const ScriptLogEntry _refused = ScriptLogEntry(
  turn: 3,
  description: 'Recruter 5 UnitType.guardian',
  success: false,
  reason: ActionFailure.notEnoughResources,
);

void main() {
  group('ScriptLogEntry', () {
    test('a done action reads as its turn and description', () {
      expect('$_done', 'T2 ✓ Explorer (3, 4)');
    });

    test('a refused action also tells why it was refused', () {
      expect('$_refused',
          'T3 ✗ Recruter 5 UnitType.guardian (notEnoughResources)');
    });
  });

  group('ScriptRunReport.of', () {
    Game game() => GameFactory.newSinglePlayer(playerName: 'p', mapSeed: 5)
      ..turn = 4;

    test('without milestones, reports none reached and no raid', () {
      final report = ScriptRunReport.of(game(),
          scriptName: 'rush', seed: 7, log: const [_done, _refused]);

      expect(report.milestones.failleCaptured, isNull);
      expect(report.milestones.kernelCaptured, isNull);
      expect(report.milestones.raids, isEmpty);
      expect(report.toJson()['raids'], isEmpty);
    });

    test('counts the turns ended and the refused actions', () {
      final report = ScriptRunReport.of(game(),
          scriptName: 'rush', seed: 7, log: const [_done, _refused]);

      expect(report.status, GameStatus.playing);
      expect(report.turnsPlayed, 3);
      expect(report.failedActions, 1);
    });
  });
}
