import '../../domain/building/building_type.dart';
import '../../domain/event/random_event_choice.dart';
import '../../domain/history/history_entry.dart';
import '../l10n/app_localizations.dart';
import 'building_type_extensions.dart';
import 'random_event_type_extensions.dart';
import 'tech_branch_extensions.dart';
import 'unit_type_extensions.dart';

/// Title and subtitle of a [HistoryEntry], worded in the player's language
/// from the entry's data. The French texts older saves stored are not
/// shown.
extension HistoryEntryTexts on HistoryEntry {
  /// Title shown on the card, e.g. "3 éclaireurs recrutés".
  String displayTitle(AppLocalizations l10n) => switch (this) {
    BuildingEntry(:final buildingType, :final newLevel) => l10n
        .historyBuildingTitle(buildingType.displayName(l10n), newLevel),
    final ResearchEntry entry => _researchTitle(l10n, entry),
    RecruitEntry(:final unitType, :final quantity) => l10n.historyRecruitTitle(
      quantity,
      unitType.units(l10n, quantity),
    ),
    ExploreEntry(:final targetX, :final targetY) => l10n.historyExploreTitle(
      targetX,
      targetY,
    ),
    CollectEntry(:final targetX, :final targetY) => l10n.historyCollectTitle(
      targetX,
      targetY,
    ),
    CombatEntry(:final victory, :final lair) =>
      victory
          ? l10n.historyCombatVictory(lair.level)
          : l10n.historyCombatDefeat(lair.level),
    TurnEndEntry(:final turn) => l10n.historyTurnEndTitle(turn),
    final CaptureEntry entry => l10n.historyCaptureTitle(
      entry.isVolcanicKernel
          ? BuildingType.volcanicKernel.displayName(l10n)
          : entry.transitionBaseName,
    ),
    DescentEntry(:final targetLevel) => l10n.historyDescentTitle(targetLevel),
    ReinforcementEntry(:final targetLevel) => l10n.historyReinforcementTitle(
      targetLevel,
    ),
    final RaidEntry entry => _raidTitle(l10n, entry),
    VolcanoEntry(:final victory) =>
      victory ? l10n.historyVolcanoRepelled : l10n.historyVolcanoLost,
    EventEntry(:final type) => type.label(l10n),
  };

  /// Detail under the title, `null` when the entry has none.
  String? displaySubtitle(AppLocalizations l10n) => switch (this) {
    CaptureEntry(:final fightResult) => l10n.historyCaptureVictory(
      fightResult.turnCount,
    ),
    DescentEntry(:final unitCount) => l10n.historyDescentUnits(unitCount),
    ReinforcementEntry(:final unitCount) => l10n.historyReinforcementUnits(
      unitCount,
    ),
    final EventEntry entry => _eventChoice(l10n, entry),
    _ => null,
  };
}

String _researchTitle(AppLocalizations l10n, ResearchEntry entry) {
  final branch = entry.branch.displayName(l10n);
  final level = entry.newLevel;
  if (entry.isUnlock) return l10n.historyResearchUnlocked(branch);
  if (level != null) return l10n.historyResearchLevel(branch, level);
  return l10n.historyResearchImproved(branch);
}

String _raidTitle(AppLocalizations l10n, RaidEntry entry) {
  if (entry.surprise) {
    return entry.victory
        ? l10n.historyPredatorsRepelled
        : l10n.historyPredatorsLost;
  }
  return entry.victory ? l10n.historyRaidRepelled : l10n.historyRaidLost;
}

/// The choice the player made, for an event that offered one.
String? _eventChoice(AppLocalizations l10n, EventEntry entry) {
  if (!entry.type.hasChoice) return null;
  if (entry.defaulted) return l10n.historyEventDefaulted;
  return entry.accepted ? l10n.historyEventAccepted : l10n.historyEventRefused;
}
