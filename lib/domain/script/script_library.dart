import 'game_script.dart';
import 'idle_script.dart';
import 'strategies/balanced_strategy.dart';
import 'strategies/conquest_strategy.dart';
import 'strategies/economy_strategy.dart';
import 'variant/plan_library.dart';

/// Built-in strategies, by the name a scenario or the command line uses,
/// with the human plans of [PlanLibrary] (`plan85`, `plan85-newmap`...).
abstract final class ScriptLibrary {
  static final Map<String, GameScript Function()> _builders =
      <String, GameScript Function()>{
    'economy': () => const EconomyStrategy(),
    'balanced': () => const BalancedStrategy(),
    'idle': () => const IdleScript(),
    'conquest': () => const ConquestStrategy(),
    'rush': () => const ConquestStrategy(defends: false, name: 'rush'),
    ...PlanLibrary.builders,
  };

  static Iterable<String> get names => _builders.keys;

  static GameScript byName(String name) {
    final GameScript Function()? build = _builders[name];
    if (build == null) {
      throw FormatException(
        'Stratégie inconnue : $name (connues : ${names.join(', ')})',
      );
    }
    return build();
  }
}
