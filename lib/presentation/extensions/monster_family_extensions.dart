import '../../domain/map/monster_difficulty.dart';
import '../../domain/map/monster_family.dart';
import '../l10n/app_localizations.dart';
import 'cell_content_type_extensions.dart';

/// Wording and sprites of the monster families. A `null` family
/// is the generic monster (Rôdeurs) of games started before them.
/// Sprite of the kraken, the volcano's own family: it has no lair.
const String krakenSvgPath = 'assets/icons/map_content/monster_kraken.svg';

extension MonsterFamilyDisplay on MonsterFamily? {
  /// Name of the family, e.g. "Carapaces".
  String label(AppLocalizations l10n) => switch (this) {
        null => l10n.monsterFamilyGenericLabel,
        MonsterFamily.swarm => l10n.monsterFamilySwarmLabel,
        MonsterFamily.armoured => l10n.monsterFamilyArmouredLabel,
        MonsterFamily.hunter => l10n.monsterFamilyHunterLabel,
        MonsterFamily.colossus => l10n.monsterFamilyColossusLabel,
        MonsterFamily.kraken => l10n.monsterFamilyKrakenLabel,
      };

  /// [count] monsters of the family, e.g. "12 Isopodes cuirassés".
  String monsters(AppLocalizations l10n, int count) => switch (this) {
        null => l10n.monsterFamilyGenericCount(count),
        MonsterFamily.swarm => l10n.monsterFamilySwarmCount(count),
        MonsterFamily.armoured => l10n.monsterFamilyArmouredCount(count),
        MonsterFamily.hunter => l10n.monsterFamilyHunterCount(count),
        MonsterFamily.colossus => l10n.monsterFamilyColossusCount(count),
        MonsterFamily.kraken => l10n.monsterFamilyKrakenCount(count),
      };

  /// The family's combat rule, `null` for the generic monsters.
  String? rule(AppLocalizations l10n) => switch (this) {
        null => null,
        MonsterFamily.swarm => l10n.monsterFamilySwarmRule,
        MonsterFamily.armoured => l10n.monsterFamilyArmouredRule,
        MonsterFamily.hunter => l10n.monsterFamilyHunterRule,
        MonsterFamily.colossus => l10n.monsterFamilyColossusRule,
        MonsterFamily.kraken => l10n.monsterFamilyKrakenRule,
      };

  /// Unit type that answers the family, `null` for the generic monsters.
  String? weakness(AppLocalizations l10n) => switch (this) {
        null => null,
        MonsterFamily.swarm => l10n.monsterFamilySwarmWeakness,
        MonsterFamily.armoured => l10n.monsterFamilyArmouredWeakness,
        MonsterFamily.hunter => l10n.monsterFamilyHunterWeakness,
        MonsterFamily.colossus ||
        MonsterFamily.kraken =>
          l10n.monsterFamilyColossusWeakness,
      };

  /// Sprite of a lair of the family at [difficulty].
  String svgPathAt(MonsterDifficulty difficulty) => switch (this) {
        null => difficulty.svgPath,
        MonsterFamily.kraken => krakenSvgPath,
        final MonsterFamily family =>
          'assets/icons/map_content/monster_${family.name}_'
              '${difficulty.name}.svg',
      };
}
