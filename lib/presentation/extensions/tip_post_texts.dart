import '../../domain/volcano/kernel_garrison.dart';
import '../l10n/app_localizations.dart';
import 'tip_text.dart';

/// The tips of the posts: the admiral, the defence of a post, the
/// kernel's garrison and a post lost.
TipText admiralTip(AppLocalizations l10n) => (
  title: l10n.tipAdmiralTitle,
  lines: [l10n.tipAdmiralLine1, l10n.tipAdmiralLine2, l10n.tipAdmiralLine3],
);

TipText postDefenceTip(AppLocalizations l10n) => (
  title: l10n.tipPostDefenceTitle,
  lines: [
    l10n.tipPostDefenceLine1,
    l10n.tipPostDefenceLine2,
    l10n.tipPostDefenceLine3,
  ],
);

TipText kernelGarrisonTip(AppLocalizations l10n) => (
  title: l10n.tipKernelGarrisonTitle,
  lines: [
    l10n.tipKernelGarrisonLine1,
    l10n.tipKernelGarrisonLine2(KernelGarrison.volcanoLevel),
    l10n.tipKernelGarrisonLine3(l10n.volcanoGarrisonUnits),
  ],
);

TipText postLostTip(AppLocalizations l10n) => (
  title: l10n.tipPostLostTitle,
  lines: [l10n.tipPostLostLine1, l10n.tipPostLostLine2, l10n.tipPostLostLine3],
);
