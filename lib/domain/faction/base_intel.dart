import 'dart:math';

import 'package:hive_ce/hive.dart';

import '../resource/resource_type.dart';
import '../unit/unit_type.dart';

part 'base_intel.g.dart';

/// What a scout brought back from the base of another player: a snapshot
/// of its headquarters, rampart, army and stocks, good for [duration]
/// turns. Past that the base may have changed, and the report is only
/// history.
@HiveType(typeId: 59)
class BaseIntel {
  /// Turns a report stays fresh once written.
  static const int duration = 5;

  /// Turn the scout got back.
  @HiveField(0)
  final int turn;

  @HiveField(1)
  final int headquartersLevel;

  /// Level of the Citadel, the rampart of the base; 0 when there is none.
  @HiveField(2)
  final int rampartLevel;

  /// The units standing on the base level, by type.
  @HiveField(3)
  final Map<UnitType, int> army;

  /// What the stocks held, pearls included.
  @HiveField(4)
  final Map<ResourceType, int> stocks;

  BaseIntel({
    required this.turn,
    required this.headquartersLevel,
    required this.rampartLevel,
    required this.army,
    required this.stocks,
  });

  /// Whether the report still holds on [now].
  bool isFresh(int now) => now <= turn + duration;

  /// Turns the report has left on [now], 0 once stale.
  int turnsLeft(int now) => max(0, turn + duration - now);
}
