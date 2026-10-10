import '../../domain/map/monster_family.dart';
import '../../domain/map/monster_lair.dart';
import '../l10n/app_localizations.dart';
import 'monster_family_extensions.dart';

/// Wording for a monster group, used by raid alerts and reports.
extension MonsterLairDisplay on MonsterLair {
  /// e.g. "40 Dents-de-verre et 12 Calmars-chasseurs niv. 2".
  String waveLabel(AppLocalizations l10n) {
    final List<String> parts = [
      for (final MapEntry(:key, :value) in groups.entries)
        key.monsters(l10n, value),
    ];
    final String monsters =
        parts.isEmpty ? '' : parts.reduce(l10n.monsterLairGroupsAnd);
    return l10n.monsterLairWave(monsters, level);
  }

  /// e.g. "Faibles contre : Harponneurs, Gardiens", `null` when no family
  /// of the group has a weakness.
  String? weaknessLabel(AppLocalizations l10n) {
    final List<String> answers = groups.keys
        .map((MonsterFamily? f) => f.weakness(l10n))
        .whereType<String>()
        .toList();
    if (answers.isEmpty) return null;
    return l10n.monsterLairWeakAgainst(answers.join(', '));
  }

  /// Sprite of the group, drawn after its first family.
  String get svgPath => family.svgPathAt(difficulty);
}
