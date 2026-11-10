import 'package:abyss/domain/action/action.dart';
import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

class _Watching extends ActionExecutor {
  Game? game;

  @override
  ActionResult execute(Action action, Game game, Player player) {
    this.game = game;
    return super.execute(action, game, player);
  }
}

void main() {
  test('the human of a scripted game gets a drawn id by default', () {
    final a = _Watching();
    final b = _Watching();
    ScriptRunner(maxTurns: 1, executor: a).run(const IdleScript(), seed: 1);
    ScriptRunner(maxTurns: 1, executor: b).run(const IdleScript(), seed: 1);

    expect(a.game!.humanPlayerId, isNot(b.game!.humanPlayerId));
  });

  test('a runner can pin the id of the human, so that a game against '
      'factions is the same whatever id was drawn', () {
    final watching = _Watching();
    ScriptRunner(
      maxTurns: 1,
      executor: watching,
      humanId: 'pinned',
    ).run(const IdleScript(), seed: 1);

    expect(watching.game!.humanPlayerId, 'pinned');
  });
}
