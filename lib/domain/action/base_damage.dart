import '../building/building.dart';
import '../building/building_type.dart';
import '../building/coral_citadel_rampart.dart';
import '../game/player.dart';
import '../raid/raid_spoils.dart';
import '../resource/resource_credit.dart';
import '../resource/resource_type.dart';

/// What a won attack did to a base, and what it brought the attacker.
class BaseDamage {
  /// Levels of the Citadel (the rampart) and of the headquarters.
  final int rampartBefore;
  final int rampartAfter;
  final int headquartersBefore;
  final int headquartersAfter;

  /// Taken from the stocks of the defender, pearls aside.
  final Map<ResourceType, int> pillaged;

  /// Part of [pillaged] the attacker's storage could hold.
  final Map<ResourceType, int> loot;

  const BaseDamage({
    required this.rampartBefore,
    required this.rampartAfter,
    required this.headquartersBefore,
    required this.headquartersAfter,
    this.pillaged = const <ResourceType, int>{},
    this.loot = const <ResourceType, int>{},
  });

  /// Nothing broken, nothing taken: the state of [target] as it stands.
  factory BaseDamage.none(Player target) {
    final int rampart = CoralCitadelRampart.levelOf(target.buildings);
    final int hq = _headquarters(target).level;
    return BaseDamage(
      rampartBefore: rampart,
      rampartAfter: rampart,
      headquartersBefore: hq,
      headquartersAfter: hq,
    );
  }

  static Building _headquarters(Player p) =>
      p.buildings[BuildingType.headquarters]!;
}

/// The price of a lost base: the rampart falls by [rampartLevels] levels,
/// or the headquarters by one when there is none, and the attacker
/// pillages [RaidSpoils.pillageRate] of the stocks.
abstract final class BaseRaze {
  static const int rampartLevels = 2;

  static BaseDamage apply({required Player attacker, required Player target}) {
    final BaseDamage before = BaseDamage.none(target);
    int rampart = before.rampartBefore;
    int hq = before.headquartersBefore;
    if (rampart > 0) {
      rampart = (rampart - rampartLevels).clamp(0, rampart);
      target.buildings[BuildingType.coralCitadel]!.level = rampart;
    } else {
      hq = target.lowerHeadquarters(1);
    }
    final Map<ResourceType, int> pillaged = RaidSpoils.pillage(
      target.resources,
    );
    return BaseDamage(
      rampartBefore: before.rampartBefore,
      rampartAfter: rampart,
      headquartersBefore: before.headquartersBefore,
      headquartersAfter: hq,
      pillaged: pillaged,
      loot: ResourceCredit.add(attacker.resources, pillaged),
    );
  }
}
