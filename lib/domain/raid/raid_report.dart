import '../fight/fight_result.dart';
import '../history/history_entry.dart';
import '../map/monster_lair.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';

/// Outcome of a raid on the base, for the turn summary and the history.
///
/// A [surprise] attack, the school of predators of a random event, is
/// fought like a raid but does not count as one.
class RaidReport {
  final int turn;
  final bool victory;
  final MonsterLair wave;
  final FightResult fight;
  final int rampartLevel;
  final Map<UnitType, int> defenders;
  final Map<UnitType, int> survivorsIntact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;
  final Map<ResourceType, int> loot;
  final Map<ResourceType, int> pillaged;
  final bool surprise;

  const RaidReport({
    required this.turn,
    required this.victory,
    required this.wave,
    required this.fight,
    required this.rampartLevel,
    required this.defenders,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
    required this.loot,
    required this.pillaged,
    this.surprise = false,
  });

  /// The history entry that replays this fight.
  RaidEntry toEntry() => RaidEntry(
    turn: turn,
    victory: victory,
    wave: wave,
    fightResult: fight,
    loot: loot,
    pillaged: pillaged,
    defenders: defenders,
    survivorsIntact: survivorsIntact,
    wounded: wounded,
    dead: dead,
    rampartLevel: rampartLevel,
    surprise: surprise,
  );
}
