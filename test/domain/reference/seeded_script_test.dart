import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/reference/game_capture.dart';
import 'package:abyss/domain/reference/seeded_script.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:abyss/domain/script/timeline_script.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a strategy alone leaves a journal that is not exact: its dice '
      'are those of the whole game', () {
    final capture = GameCapture();
    ScriptRunner(
      maxTurns: 25,
      executor: capture,
    ).run(const ConquestStrategy(), seed: 3);

    expect(ReplayExport.isExact(capture.game), isFalse);
  });

  test('played seeded, the same strategy leaves an exact journal: every '
      'end of turn and every roll has its seed', () {
    final capture = GameCapture();
    ScriptRunner(maxTurns: 25, executor: capture).run(
      SeededScript(const ConquestStrategy(), seed: 3, executor: capture),
      seed: 3,
    );
    final journal = capture.game.replay!;

    expect(ReplayExport.isExact(capture.game), isTrue);
    expect(journal.endTurnSeeds.keys, [for (int t = 1; t <= 25; t++) t]);
    final rolled = [
      for (final turn in journal.actions.keys)
        for (final action in journal.actionsOf(turn))
          if (action['do'] == 'collect' || action['do'] == 'fight') action,
    ];
    expect(rolled, isNotEmpty);
    expect(rolled.every((a) => a['seed'] is int), isTrue);
    expect(journal.actions.values.expand((a) => a).length, greaterThan(40));
  });

  test('the same seed plays the same game, another seed another one', () {
    String play(int seed) {
      final capture = GameCapture();
      ScriptRunner(maxTurns: 20, executor: capture).run(
        SeededScript(const ConquestStrategy(), seed: seed, executor: capture),
        seed: seed,
      );
      return ReplayExport.toText(capture.game);
    }

    expect(play(4), play(4));
    expect(play(4), isNot(play(5)));
  });

  test('is the script it wraps for everything else', () {
    const inner = TimelineScript(
      name: 'timeline',
      turns: {},
      player: 'Nemo',
      mapSeed: 12,
      difficulty: Difficulty.hard,
      lastTurn: 9,
      factions: [FactionPersonality.magmaSmiths],
      endTurnSeeds: {2: 77},
    );
    final script = SeededScript(inner, seed: 1, executor: ActionExecutor());

    expect(script.name, 'timeline');
    expect(script.playerName, 'Nemo');
    expect(script.mapSeed, 12);
    expect(script.difficulty, Difficulty.hard);
    expect(script.lastTurn, 9);
    expect(script.factions, [FactionPersonality.magmaSmiths]);
    expect(script.factionsPlay, isFalse);
    expect(
      SeededScript(
        const IdleScript(),
        seed: 1,
        executor: ActionExecutor(),
      ).factionsPlay,
      isTrue,
    );
  });

  test('keeps the seed a replay recorded for an end of turn, and draws '
      'the others', () {
    const inner = TimelineScript(name: 't', turns: {}, endTurnSeeds: {2: 77});
    final script = SeededScript(inner, seed: 1, executor: ActionExecutor());

    expect((script.endTurnRandom(2)! as SeededRandom).seed, 77);
    expect(script.endTurnRandom(3), isA<SeededRandom>());
    expect(
      (script.endTurnRandom(4)! as SeededRandom).seed,
      isNot((script.endTurnRandom(5)! as SeededRandom).seed),
    );
  });
}
