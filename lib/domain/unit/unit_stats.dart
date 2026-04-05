import 'package:abyss/domain/unit/unit_type.dart';

class UnitStats {
  final int hp;
  final int atk;
  final int def;

  const UnitStats({
    required this.hp,
    required this.atk,
    required this.def,
  });

  static UnitStats forType(UnitType type) => switch (type) {
        UnitType.scout => const UnitStats(hp: 10, atk: 2, def: 1),
        UnitType.harpoonist => const UnitStats(hp: 15, atk: 5, def: 2),
        UnitType.guardian => const UnitStats(hp: 25, atk: 2, def: 6),
        UnitType.domeBreaker => const UnitStats(hp: 20, atk: 8, def: 3),
        UnitType.siphoner => const UnitStats(hp: 12, atk: 3, def: 2),
        UnitType.saboteur => const UnitStats(hp: 8, atk: 10, def: 1),
      };
}
