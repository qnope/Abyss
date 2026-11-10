import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/reference/game_capture.dart';
import 'package:abyss/domain/reference/game_snapshot.dart';
import 'package:abyss/domain/reference/reference_recorder.dart';
import 'package:abyss/domain/reference/seeded_script.dart';
import 'package:abyss/domain/reference/snapshot_sections.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

/// A digest that tells two texts apart well enough for a test.
String _digest(String text) => '${text.length}:${text.hashCode}';

ReferenceRecorder _play(int turns, {int? traceTurn, int? dumpTurn}) {
  final recorder = ReferenceRecorder(
    _digest,
    traceTurn: traceTurn,
    dumpTurn: dumpTurn,
  );
  ScriptRunner(maxTurns: turns, executor: recorder).run(
    SeededScript(const BalancedStrategy(), seed: 2, executor: recorder),
    seed: 2,
  );
  return recorder;
}

void main() {
  test('a capture has no game before an action is executed', () {
    expect(() => GameCapture().game, throwsStateError);
  });

  test('records the start of turn 1, then the state after each end of '
      'turn', () {
    final recorder = ReferenceRecorder(_digest);
    ScriptRunner(
      maxTurns: 3,
      executor: recorder,
    ).run(const IdleScript(), seed: 1);

    expect(recorder.turns.map((t) => t.turn), [1, 2, 3, 4]);
    expect(recorder.game.turn, 4);
    expect(
      recorder.turns.last.digests,
      GameSnapshot.digests(recorder.game, _digest),
    );
    for (final t in recorder.turns) {
      expect(t.digests, hasLength(SnapshotSections.names.length));
    }
    // An idle turn only moves the turn on: the maps stay as they are.
    final int game = SnapshotSections.names.indexOf('game');
    final int map1 = SnapshotSections.names.indexOf('map1');
    expect(
      recorder.turns[0].digests[game],
      isNot(recorder.turns[1].digests[game]),
    );
    expect(recorder.turns[0].digests[map1], recorder.turns[3].digests[map1]);
    expect(recorder.actions, {ActionType.endTurn: 3});
  });

  test('counts the successful actions by type, and the events drawn', () {
    final recorder = _play(30);

    expect(recorder.actions[ActionType.endTurn], 30);
    expect(recorder.actions[ActionType.upgradeBuilding], greaterThan(5));
    expect(recorder.actions.keys, contains(ActionType.recruitUnit));
    expect(
      recorder.events.values.fold<int>(0, (a, b) => a + b),
      recorder.game.humanPlayer.eventState.eventsSeen,
    );
    expect(recorder.events, isNotEmpty);
  });

  test('traces the digests after each action of one turn only', () {
    final recorder = _play(8, traceTurn: 6);
    final int inTurn = recorder.game.replay!.actionsOf(6).length;

    expect(inTurn, greaterThan(0));
    expect(recorder.traced, hasLength(inTurn));
    expect(recorder.traced.last, isNot(recorder.turns[5].digests));
    expect(_play(8).traced, isEmpty);
  });

  test('dumps the texts of the turn asked, as it starts', () {
    final recorder = _play(8, dumpTurn: 5);

    expect(recorder.dump!.keys, SnapshotSections.names);
    expect(recorder.dump!['game'], contains('"turn":5'));
    expect([
      for (final text in recorder.dump!.values) _digest(text),
    ], recorder.turns[4].digests);
    expect(_play(3, dumpTurn: 9).dump, isNull);
    expect(_play(3, dumpTurn: 1).dump!['game'], contains('"turn":1'));
  });
}
