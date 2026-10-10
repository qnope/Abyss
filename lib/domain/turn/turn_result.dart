import 'package:hive_ce/hive.dart';
import '../building/building_type.dart';
import '../event/random_event_type.dart';
import '../map/exploration_result.dart';
import '../map/monster_lair.dart';
import '../map/reinforcement_order.dart';
import '../objective/objective_completion.dart';
import '../raid/raid_report.dart';
import '../volcano/volcano_report.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';

part 'turn_result.g.dart';

@HiveType(typeId: 30)
class TurnResourceChange {
  @HiveField(0)
  final ResourceType type;

  @HiveField(1)
  final int produced;

  @HiveField(2)
  final int consumed;

  @HiveField(3)
  final bool wasCapped;

  @HiveField(4)
  final int beforeAmount;

  @HiveField(5)
  final int afterAmount;

  const TurnResourceChange({
    required this.type,
    required this.produced,
    this.consumed = 0,
    required this.wasCapped,
    required this.beforeAmount,
    required this.afterAmount,
  });
}

class TurnResult {
  final List<TurnResourceChange> changes;
  final int previousTurn;
  final int newTurn;
  final bool hadRecruitedUnits;
  final List<BuildingType> deactivatedBuildings;
  final Map<UnitType, int> lostUnits;
  final List<ExplorationResult> explorations;
  final List<ReinforcementOrder> arrivedReinforcements;

  /// Raid fought on the base at the end of this turn, if any.
  final RaidReport? raid;

  /// Raid announced at the end of this turn, if any; it hits the base at
  /// the end of [announcedRaidTurn].
  final MonsterLair? announcedRaid;
  final int? announcedRaidTurn;

  /// Kraken wave fought on the kernel at the end of this turn, if any.
  final VolcanoReport? volcano;

  /// Kraken wave announced at the end of this turn; it hits the kernel at
  /// the end of the next one.
  final MonsterLair? announcedWave;

  /// Random event drawn at the end of this turn, if any; one with a
  /// choice waits for it during the next turn.
  final RandomEventType? event;

  /// Event left without a choice this turn, settled with its prudent
  /// option.
  final RandomEventType? defaultedEvent;

  /// School of predators faced this turn and fought at its end, if any.
  final RaidReport? predators;

  /// Objectives completed at the end of this turn, in catalog order, with
  /// the rewards they credited.
  final List<ObjectiveCompletion> objectives;

  const TurnResult({
    required this.changes,
    required this.previousTurn,
    required this.newTurn,
    required this.hadRecruitedUnits,
    this.deactivatedBuildings = const [],
    this.lostUnits = const {},
    this.explorations = const [],
    this.arrivedReinforcements = const [],
    this.raid,
    this.announcedRaid,
    this.announcedRaidTurn,
    this.volcano,
    this.announcedWave,
    this.event,
    this.defaultedEvent,
    this.predators,
    this.objectives = const [],
  });
}
