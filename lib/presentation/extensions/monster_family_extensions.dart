import '../../domain/map/monster_difficulty.dart';
import '../../domain/map/monster_family.dart';
import 'cell_content_type_extensions.dart';

/// French wording and sprites of the monster families. A `null` family
/// is the generic monster (Rôdeurs) of games started before them.
/// Sprite of the kraken, the volcano's own family: it has no lair.
const String krakenSvgPath = 'assets/icons/map_content/monster_kraken.svg';

extension MonsterFamilyDisplay on MonsterFamily? {
  /// Name of the family, e.g. "Carapaces".
  String get label => switch (this) {
        null => 'Rôdeurs',
        MonsterFamily.swarm => 'Nuée',
        MonsterFamily.armoured => 'Carapaces',
        MonsterFamily.hunter => 'Chasseurs',
        MonsterFamily.colossus => 'Colosses',
        MonsterFamily.kraken => 'Kraken',
      };

  /// [count] monsters of the family, e.g. "12 Isopodes cuirassés".
  String monsters(int count) {
    final bool many = count > 1;
    final String name = switch (this) {
      null => many ? 'monstres' : 'monstre',
      MonsterFamily.swarm => 'Dents-de-verre',
      MonsterFamily.armoured =>
        many ? 'Isopodes cuirassés' : 'Isopode cuirassé',
      MonsterFamily.hunter => many ? 'Calmars-chasseurs' : 'Calmar-chasseur',
      MonsterFamily.colossus => many ? 'Requins dormeurs' : 'Requin dormeur',
      MonsterFamily.kraken => many ? 'Krakens' : 'Kraken',
    };
    return '$count $name';
  }

  /// The family's combat rule, `null` for the generic monsters.
  String? get rule => switch (this) {
        null => null,
        MonsterFamily.swarm =>
          'Essaim : un coup de Harponneur touche deux poissons.',
        MonsterFamily.armoured =>
          'Cuirasse : seuls les Saboteurs ignorent leur DEF.',
        MonsterFamily.hunter => "Traque : ils visent l'unité la plus "
            'fragile et frappent deux fois plus fort, sauf un Gardien ou '
            'le rempart qui provoque.',
        MonsterFamily.colossus =>
          'Géants : tous des boss, que les Briseurs frappent double.',
        MonsterFamily.kraken => 'Étreinte : chaque coup de tentacule '
            'frappe aussi un deuxième défenseur. Des boss, que les '
            'Briseurs frappent double.',
      };

  /// Unit type that answers the family, `null` for the generic monsters.
  String? get weakness => switch (this) {
        null => null,
        MonsterFamily.swarm => 'Harponneurs',
        MonsterFamily.armoured => 'Saboteurs',
        MonsterFamily.hunter => 'Gardiens',
        MonsterFamily.colossus || MonsterFamily.kraken => 'Briseurs de dôme',
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
