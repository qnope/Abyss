import 'package:abysses/domain/models/resource.dart';

enum DefenseType { underwaterMine, turret, magneticShield }

class StaticDefense {
  final DefenseType type;
  final int damage;
  final int hp;
  final Duration? cooldown;
  final Resources cost;
  final int maxCount;

  const StaticDefense({
    required this.type,
    required this.damage,
    this.hp = 0,
    this.cooldown,
    required this.cost,
    required this.maxCount,
  });

  static const underwaterMine = StaticDefense(
    type: DefenseType.underwaterMine,
    damage: 150,
    cooldown: Duration(hours: 8),
    cost: Resources(minerals: 500, energy: 300, biomass: 50),
    maxCount: 3,
  );

  static const turret = StaticDefense(
    type: DefenseType.turret,
    damage: 80,
    hp: 200,
    cost: Resources(minerals: 800, energy: 400, biomass: 150),
    maxCount: 2,
  );
}
