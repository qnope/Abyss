import '../../domain/faction/faction_personality.dart';
import '../l10n/app_localizations.dart';

extension FactionPersonalityDisplay on FactionPersonality {
  /// Where the faction comes from: the ship its crew sank with, and
  /// what it kept of it, e.g. "Un monastère flottant : …".
  String origin(AppLocalizations l10n) => switch (this) {
    FactionPersonality.wreckPillagers => l10n.factionOriginWreckPillagers,
    FactionPersonality.pearlOrder => l10n.factionOriginPearlOrder,
    FactionPersonality.anglerCult => l10n.factionOriginAnglerCult,
    FactionPersonality.murenaHorde => l10n.factionOriginMurenaHorde,
    FactionPersonality.siphonophoreGuild => l10n.factionOriginSiphonophoreGuild,
    FactionPersonality.silenceMonks => l10n.factionOriginSilenceMonks,
    FactionPersonality.currentNomads => l10n.factionOriginCurrentNomads,
    FactionPersonality.pyrosomeHive => l10n.factionOriginPyrosomeHive,
    FactionPersonality.magmaSmiths => l10n.factionOriginMagmaSmiths,
    FactionPersonality.krakenFaithful => l10n.factionOriginKrakenFaithful,
  };
}
