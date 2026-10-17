import '../../faction/faction_standing.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../../history/history_entry.dart';
import '../../map/transition_base_name.dart';
import '../../map/transition_base_type.dart';
import '../../volcano/kernel_garrison.dart';

/// The moments the Archives of the Trench open: each card tells the lore
/// of what the player has just reached, and stays true once reached, so a
/// game saved past it shows the card once. Each check is cheap: a few
/// fields, the history, or one pass over the cells.
abstract final class ArchiveTipTriggers {
  /// A rival dome found: the base cell of a faction revealed by [player].
  static bool rivalColony(Game game, Player player) => game.factions.any((f) {
    final rival = game.players[f.id];
    return rival != null &&
        rival.id != player.id &&
        FactionStanding.isDiscoveredBy(player, rival);
  });

  /// A Faille of the Ancients held by [player], or captured once.
  static bool faille(Game game, Player player) =>
      game.capturedBaseTypesOf(player.id).contains(TransitionBaseType.faille) ||
      player.historyEntries.any(
        (entry) =>
            entry is CaptureEntry &&
            entry.captured &&
            TransitionBaseName.parse(entry.transitionBaseName)?.type ==
                TransitionBaseType.faille,
      );

  /// Units of [player] standing below the reef: on the level of the
  /// Cheminées or deeper, the kernel's garrison left out.
  static bool belowReef(Game game, Player player) {
    for (var level = 2; level <= KernelGarrison.volcanoLevel; level++) {
      if (player.unitCountsOnLevel(level).isNotEmpty) return true;
    }
    return false;
  }

  /// The kernel taken by [player], or rekindled once: its building is
  /// raised only once the kernel is taken.
  static bool kernel(Game game, Player player) =>
      game.isVolcanicKernelCapturedBy(player.id) ||
      KernelGarrison.kernelLevelOf(player) >= 1;
}
