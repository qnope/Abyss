import 'package:hive/hive.dart';

part 'combat_side.g.dart';

@HiveType(typeId: 26)
enum CombatSide {
  @HiveField(0)
  player,
  @HiveField(1)
  monster,
}

extension CombatSideX on CombatSide {
  CombatSide get opponent {
    switch (this) {
      case CombatSide.player:
        return CombatSide.monster;
      case CombatSide.monster:
        return CombatSide.player;
    }
  }
}
