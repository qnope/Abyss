import 'package:hive_ce/hive.dart';

part 'random_event_type.g.dart';

/// Events drawn every few turns that ask the player for a choice.
@HiveType(typeId: 50)
enum RandomEventType {
  @HiveField(0) warmCurrent,
  @HiveField(1) wreck,
  @HiveField(2) predators,
  @HiveField(3) storm,
  @HiveField(4) survivors,
  @HiveField(5) caravan,
  @HiveField(6) coldCurrent,
}
