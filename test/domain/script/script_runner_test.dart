import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScriptRunner', () {
    test('stops at the turn limit when nothing ends the game', () {
      final report = ScriptRunner(maxTurns: 5).run(const IdleScript(), seed: 1);

      expect(report.status, GameStatus.playing);
      expect(report.turnsPlayed, 5);
      expect(report.log, isEmpty);
    });

    test('replays the very same game from the same seed', () {
      final runner = ScriptRunner(maxTurns: 30);
      final first = runner.run(const BalancedStrategy(), seed: 7);
      final second = runner.run(const BalancedStrategy(), seed: 7);

      expect(second.toJson(), first.toJson());
      expect(
        second.log.map((e) => e.toString()),
        first.log.map((e) => e.toString()),
      );
    });

    test('plays every turn through the action system', () {
      final report =
          ScriptRunner(maxTurns: 3).run(const BalancedStrategy(), seed: 1);

      expect(report.log, isNotEmpty);
      expect(report.log.every((e) => e.success), isTrue);
      expect(report.log.map((e) => e.turn).toSet(), containsAll(<int>[1]));
      expect(report.totalNoise, greaterThan(0));
    });
  });
}
