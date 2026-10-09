import 'package:hive_ce/hive.dart';

part 'monster_family.g.dart';

/// Kind of monster a lair or a raid wave is made of. Each family has its
/// own stats and one combat rule, and a unit type that answers it.
@HiveType(typeId: 46)
enum MonsterFamily {
  /// Dents-de-verre: many fragile fish. A Harponneur's hit strikes two.
  @HiveField(0)
  swarm,

  /// Isopodes cuirassés: a huge DEF that only Saboteurs ignore.
  @HiveField(1)
  armoured,

  /// Calmars-chasseurs: they hunt the frailest unit and hit it twice as
  /// hard, unless a taunting unit draws them.
  @HiveField(2)
  hunter,

  /// Requins dormeurs: a few giants, all bosses, that Briseurs hit twice.
  @HiveField(3)
  colossus,

  /// Le terrifiant Kraken: it only rises from the volcano to take the
  /// kernel back. A boss whose tentacles strike two defenders at once.
  @HiveField(4)
  kraken;

  /// Families by name, built once: [ofTypeKey] runs on every attack.
  static final Map<String, MonsterFamily> _byName =
      MonsterFamily.values.asNameMap();

  /// Families that can make up a lair or a raid of [level] monsters:
  /// colossi only show up from level 2, the kraken never leaves the
  /// volcano.
  static List<MonsterFamily> availableAt(int level) =>
      level < 2
          ? const <MonsterFamily>[swarm, armoured, hunter]
          : const <MonsterFamily>[swarm, armoured, hunter, colossus];

  /// Whether the monsters of this family fight as bosses, that Briseurs
  /// hit twice.
  bool get isBoss => this == colossus || this == kraken;

  /// Combatant key of a monster of [family] at [level]; the generic
  /// monsters of older games keep their `monsterL<level>` key.
  static String typeKeyOf(MonsterFamily? family, int level) =>
      '${family?.name ?? 'monster'}L$level';

  /// Family of a monster combatant key, or `null` for player units and
  /// the generic monsters of older games.
  static MonsterFamily? ofTypeKey(String typeKey) {
    final int cut = typeKey.lastIndexOf('L');
    if (cut <= 0) return null;
    return _byName[typeKey.substring(0, cut)];
  }
}
