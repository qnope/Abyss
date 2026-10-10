import '../../domain/building/coral_citadel_rampart.dart';
import '../../domain/volcano/magma_rampart.dart';
import '../l10n/app_localizations.dart';

/// Short statistics of the ramparts, such as "120 PV, DEF 7".
abstract final class RampartTexts {
  /// The rampart of a Coral Citadel at [level], "none" when unbuilt.
  static String coral(AppLocalizations l10n, int level) {
    if (level <= 0) return l10n.baseRampartNone;
    return l10n.baseCoralRampartStats(
      CoralCitadelRampart.hpForLevel(level),
      CoralCitadelRampart.defForLevel(level),
    );
  }

  /// The magma rampart of a volcanic kernel at [level].
  static String magma(AppLocalizations l10n, int level) =>
      l10n.baseMagmaRampartStats(
        MagmaRampart.hpForLevel(level),
        MagmaRampart.atkForLevel(level),
        MagmaRampart.defForLevel(level),
      );
}
