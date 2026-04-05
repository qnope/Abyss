import 'game.dart';
import 'maintenance_calculator.dart';
import 'production_calculator.dart';
import 'resource_type.dart';
import 'turn_result.dart';

class TurnResolver {
  TurnResult resolve(Game game) {
    final previousTurn = game.turn;
    final hadRecruitedUnits = game.recruitedUnitTypes.isNotEmpty;

    final production = ProductionCalculator.fromBuildings(
      game.buildings,
      techBranches: game.techBranches,
    );
    final maintenance = MaintenanceCalculator.fromUnits(game.units);

    final allTypes = <ResourceType>{...production.keys, ...maintenance.keys};
    final changes = <TurnResourceChange>[];

    for (final type in allTypes) {
      final resource = game.resources[type];
      if (resource == null) continue;

      final prod = production[type] ?? 0;
      final maint = maintenance[type] ?? 0;
      final net = prod - maint;

      final beforeAmount = resource.amount;
      final newAmount = resource.amount + net;
      final capped = newAmount > resource.maxStorage;
      resource.amount = capped
          ? resource.maxStorage
          : (newAmount < 0 ? 0 : newAmount);

      changes.add(TurnResourceChange(
        type: type,
        produced: net,
        wasCapped: capped,
        beforeAmount: beforeAmount,
        afterAmount: resource.amount,
      ));
    }

    game.recruitedUnitTypes.clear();
    game.turn++;

    return TurnResult(
      changes: changes,
      previousTurn: previousTurn,
      newTurn: game.turn,
      hadRecruitedUnits: hadRecruitedUnits,
    );
  }
}
