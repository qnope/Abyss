import '../../domain/game/defeat_checker.dart';
import '../../domain/raid/noise_rules.dart';
import '../l10n/app_localizations.dart';
import 'tip_text.dart';

/// The tips of the threats: the raids on the base, the monster families
/// and the waves of the Volcano.
TipText raidAnnouncedTip(AppLocalizations l10n) => (
  title: l10n.tipRaidAnnouncedTitle,
  lines: [
    l10n.tipRaidAnnouncedLine1(NoiseRules.warningTurns),
    l10n.tipRaidAnnouncedLine2,
    l10n.tipRaidAnnouncedLine3,
  ],
);

TipText raidReportTip(AppLocalizations l10n) => (
  title: l10n.tipRaidReportTitle,
  lines: [
    l10n.tipRaidReportLine1,
    l10n.tipRaidReportLine2,
    l10n.tipRaidReportLine3,
  ],
);

TipText lastChanceTip(AppLocalizations l10n) => (
  title: l10n.tipLastChanceTitle,
  lines: [
    l10n.tipLastChanceLine1(DefeatChecker.lostRaidsLimit - 1),
    l10n.tipLastChanceLine2,
    l10n.tipLastChanceLine3,
  ],
);

TipText monsterFamiliesTip(AppLocalizations l10n) => (
  title: l10n.tipMonsterFamiliesTitle,
  lines: [
    l10n.tipMonsterFamiliesLine1,
    l10n.tipMonsterFamiliesLine2,
    l10n.tipMonsterFamiliesLine3,
  ],
);

TipText volcanoWaveTip(AppLocalizations l10n) => (
  title: l10n.tipVolcanoWaveTitle,
  lines: [
    l10n.tipVolcanoWaveLine1,
    l10n.tipVolcanoWaveLine2,
    l10n.tipVolcanoWaveLine3,
  ],
);

TipText factionAttackTip(AppLocalizations l10n) => (
  title: l10n.tipFactionAttackTitle,
  lines: [
    l10n.tipFactionAttackLine1,
    l10n.tipFactionAttackLine2,
    l10n.tipFactionAttackLine3,
  ],
);
