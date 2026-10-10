import '../l10n/app_localizations.dart';
import 'tip_text.dart';

/// The tips of the map: what the exploration reveals, and the way down.
TipText lairTip(AppLocalizations l10n) => (
  title: l10n.tipLairTitle,
  lines: [l10n.tipLairLine1, l10n.tipLairLine2, l10n.tipLairLine3],
);

TipText chestAndRuinsTip(AppLocalizations l10n) => (
  title: l10n.tipChestAndRuinsTitle,
  lines: [l10n.tipChestAndRuinsLine1, l10n.tipChestAndRuinsLine2],
);

TipText transitionBaseTip(AppLocalizations l10n) => (
  title: l10n.tipTransitionBaseTitle,
  lines: [
    l10n.tipTransitionBaseLine1,
    l10n.tipTransitionBaseLine2,
    l10n.tipTransitionBaseLine3,
  ],
);

TipText descentTip(AppLocalizations l10n) => (
  title: l10n.tipDescentTitle,
  lines: [l10n.tipDescentLine1, l10n.tipDescentLine2, l10n.tipDescentLine3],
);
