import '../../domain/event/random_event_type.dart';
import '../../domain/objective/tip/tip_category.dart';
import '../../domain/objective/tip/tip_id.dart';
import '../l10n/app_localizations.dart';
import 'tip_archive_texts.dart';
import 'tip_base_texts.dart';
import 'tip_event_texts.dart';
import 'tip_map_texts.dart';
import 'tip_post_texts.dart';
import 'tip_text.dart';
import 'tip_threat_texts.dart';

/// Name of a section of the Guide.
extension TipCategoryLabel on TipCategory {
  String label(AppLocalizations l10n) => switch (this) {
    TipCategory.base => l10n.tipCategoryBase,
    TipCategory.threats => l10n.tipCategoryThreats,
    TipCategory.map => l10n.tipCategoryMap,
    TipCategory.events => l10n.tipCategoryEvents,
    TipCategory.archives => l10n.tipCategoryArchives,
  };
}

/// What the card of a tip says, in the player's language.
extension TipIdText on TipId {
  /// Shown on the card and in the Guide.
  String title(AppLocalizations l10n) => text(l10n).title;

  /// Two or three short lines addressed to the player.
  List<String> lines(AppLocalizations l10n) => text(l10n).lines;

  TipText text(AppLocalizations l10n) => switch (this) {
    TipId.noiseGauge => noiseGaugeTip(l10n),
    TipId.worksites => worksitesTip(l10n),
    TipId.techChoice => techChoiceTip(l10n),
    TipId.raidAnnounced => raidAnnouncedTip(l10n),
    TipId.raidReport => raidReportTip(l10n),
    TipId.lastChance => lastChanceTip(l10n),
    TipId.monsterFamilies => monsterFamiliesTip(l10n),
    TipId.volcanoWave => volcanoWaveTip(l10n),
    TipId.factionAttack => factionAttackTip(l10n),
    TipId.lair => lairTip(l10n),
    TipId.chestAndRuins => chestAndRuinsTip(l10n),
    TipId.transitionBase => transitionBaseTip(l10n),
    TipId.descent => descentTip(l10n),
    TipId.admiral => admiralTip(l10n),
    TipId.postDefence => postDefenceTip(l10n),
    TipId.kernelGarrison => kernelGarrisonTip(l10n),
    TipId.postLost => postLostTip(l10n),
    TipId.events => eventsTip(l10n),
    TipId.warmCurrent => eventTip(RandomEventType.warmCurrent, l10n),
    TipId.wreck => eventTip(RandomEventType.wreck, l10n),
    TipId.predators => eventTip(RandomEventType.predators, l10n),
    TipId.storm => eventTip(RandomEventType.storm, l10n),
    TipId.survivors => eventTip(RandomEventType.survivors, l10n),
    TipId.caravan => eventTip(RandomEventType.caravan, l10n),
    TipId.coldCurrent => eventTip(RandomEventType.coldCurrent, l10n),
    TipId.abyssListens => abyssListensTip(l10n),
    TipId.rivalColonies => rivalColoniesTip(l10n),
    TipId.ancients => ancientsTip(l10n),
    TipId.forgeTowers => forgeTowersTip(l10n),
    TipId.awakening => awakeningTip(l10n),
  };
}
