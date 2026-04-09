import 'action_result.dart';
import 'action_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';

abstract class Action {
  ActionType get type;
  String get description;
  ActionResult validate(Game game, Player player);
  ActionResult execute(Game game, Player player);

  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) => null;
}
