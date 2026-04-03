import 'action_result.dart';
import 'action_type.dart';
import 'game.dart';

abstract class Action {
  ActionType get type;
  String get description;
  ActionResult validate(Game game);
  ActionResult execute(Game game);
}
