import '../../domain/raid/noise_rules.dart';
import '../../domain/worksite/worksite_rules.dart';
import '../l10n/app_localizations.dart';
import 'tip_text.dart';

/// The tips of the base: the noise, the building sites, the research
/// choices.
TipText noiseGaugeTip(AppLocalizations l10n) => (
  title: l10n.tipNoiseGaugeTitle,
  lines: [
    l10n.tipNoiseGaugeLine1,
    l10n.tipNoiseGaugeLine2(NoiseRules.threshold),
  ],
);

TipText worksitesTip(AppLocalizations l10n) => (
  title: l10n.tipWorksitesTitle,
  lines: [
    l10n.tipWorksitesLine1(WorksiteRules.extraSiteAtHq[0]),
    l10n.tipWorksitesLine2(WorksiteRules.extraSiteAtHq[1]),
  ],
);

TipText techChoiceTip(AppLocalizations l10n) => (
  title: l10n.tipTechChoiceTitle,
  lines: [
    l10n.tipTechChoiceLine1,
    l10n.tipTechChoiceLine2,
    l10n.tipTechChoiceLine3,
  ],
);
