import '../building/building_type.dart';
import '../building/upgrade_readiness.dart';
import '../tech/tech_effects.dart';
import 'game.dart';
import 'player.dart';

/// Which buildings a player can raise right now in this game: the bases
/// and the volcanic core they captured, their research's discount.
extension GameUpgradeReadiness on Game {
  /// The readiness of the building of [type] of [player].
  UpgradeReadiness upgradeReadinessOf(Player player, BuildingType type) =>
      upgradeReadinessesOf(player, only: {type})[type]!;

  /// The readiness of every building of [player], or of the [only] ones.
  Map<BuildingType, UpgradeReadiness> upgradeReadinessesOf(
    Player player, {
    Iterable<BuildingType>? only,
  }) {
    final captured = capturedBaseTypesOf(player.id);
    final kernel = isVolcanicKernelCapturedBy(player.id);
    final discount = TechEffects.of(player).upgradeDiscountPercent;
    return {
      for (final type in only ?? player.buildings.keys)
        type: UpgradeReadiness.of(
          type,
          buildings: player.buildings,
          resources: player.resources,
          worksite: player.worksite,
          capturedBaseTypes: captured,
          isVolcanicKernelCaptured: kernel,
          discountPercent: discount,
        ),
    };
  }
}
