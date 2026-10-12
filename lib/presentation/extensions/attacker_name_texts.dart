import '../../domain/leviathan/leviathan_force.dart';
import '../l10n/app_localizations.dart';

/// The name of who attacked, or was attacked, as the reports show it:
/// the guardians of the Faille in the player's language, any other
/// player by its own name.
String attackerLabel(AppLocalizations l10n, String name) =>
    name == LeviathanForce.attackerName ? l10n.leviathanAttackerName : name;
