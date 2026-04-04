import 'game.dart';
import 'production_calculator.dart';
import 'turn_result.dart';

class TurnResolver {
  TurnResult resolve(Game game) {
    final production = ProductionCalculator.fromBuildings(
      game.buildings,
      techBranches: game.techBranches,
    );
    final changes = <TurnResourceChange>[];

    for (final entry in production.entries) {
      final resource = game.resources[entry.key];
      if (resource == null) continue;

      final produced = entry.value;
      final newAmount = resource.amount + produced;
      final capped = newAmount > resource.maxStorage;
      resource.amount = capped ? resource.maxStorage : newAmount;

      changes.add(TurnResourceChange(
        type: entry.key,
        produced: produced,
        wasCapped: capped,
      ));
    }

    game.turn++;
    return TurnResult(changes: changes);
  }
}
