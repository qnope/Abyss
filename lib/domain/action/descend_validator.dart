import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/map_cell.dart';
import '../map/transition_base.dart';
import '../map/transition_base_type.dart';
import '../unit/unit_type.dart';
import 'descend_result.dart';

class DescendValidator {
  const DescendValidator._();

  static DescendResult validate({
    required Game game,
    required Player player,
    required int transitionX,
    required int transitionY,
    required int fromLevel,
    required Map<UnitType, int> selectedUnits,
  }) {
    final map = game.levels[fromLevel];
    if (map == null) {
      return const DescendResult.failure('Carte non generee');
    }

    final MapCell cell = map.cellAt(transitionX, transitionY);
    if (cell.content != CellContentType.transitionBase) {
      return const DescendResult.failure('Pas de base de transition');
    }

    final TransitionBase? base = cell.transitionBase;
    if (base == null || base.capturedBy != player.id) {
      return const DescendResult.failure('Base non capturee');
    }

    final error = _validateBuilding(player, base.type);
    if (error != null) return error;

    return _validateUnits(player, fromLevel, selectedUnits);
  }

  static DescendResult? _validateBuilding(
    Player player,
    TransitionBaseType type,
  ) {
    final BuildingType required = type == TransitionBaseType.faille
        ? BuildingType.descentModule
        : BuildingType.pressureCapsule;

    final level = player.buildings[required]?.level ?? 0;
    if (level <= 0) {
      return const DescendResult.failure('Batiment requis manquant');
    }
    return null;
  }

  static DescendResult _validateUnits(
    Player player,
    int fromLevel,
    Map<UnitType, int> selectedUnits,
  ) {
    int total = 0;
    for (final entry in selectedUnits.entries) {
      if (entry.value <= 0) continue;
      final stock = player.unitsOnLevel(fromLevel)[entry.key]?.count ?? 0;
      if (entry.value > stock) {
        return const DescendResult.failure('Unites insuffisantes');
      }
      total += entry.value;
    }
    if (total <= 0) {
      return const DescendResult.failure('Aucune unite selectionnee');
    }
    return const DescendResult.success(targetLevel: 0, unitsSent: {});
  }
}
