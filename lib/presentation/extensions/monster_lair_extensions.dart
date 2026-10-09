import '../../domain/map/monster_family.dart';
import '../../domain/map/monster_lair.dart';
import 'monster_family_extensions.dart';

/// French wording for a monster group, used by raid alerts and reports.
extension MonsterLairDisplay on MonsterLair {
  /// e.g. "40 Dents-de-verre et 12 Calmars-chasseurs niv. 2".
  String get waveLabel {
    final String monsters = groups.entries
        .map((MapEntry<MonsterFamily?, int> e) => e.key.monsters(e.value))
        .join(' et ');
    return '$monsters niv. $level';
  }

  /// e.g. "Faibles contre : Harponneurs, Gardiens", `null` when no family
  /// of the group has a weakness.
  String? get weaknessLabel {
    final List<String> answers = groups.keys
        .map((MonsterFamily? f) => f.weakness)
        .whereType<String>()
        .toList();
    return answers.isEmpty ? null : 'Faibles contre : ${answers.join(', ')}';
  }

  /// Sprite of the group, drawn after its first family.
  String get svgPath => family.svgPathAt(difficulty);
}
