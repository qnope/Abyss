import 'class_snapshot.dart';
import 'snapshots/base_snapshots.dart';
import 'snapshots/fight_snapshots.dart';
import 'snapshots/game_snapshots.dart';
import 'snapshots/history_snapshots.dart';
import 'snapshots/journal_snapshots.dart';
import 'snapshots/map_snapshots.dart';
import 'snapshots/player_snapshots.dart';
import 'snapshots/threat_snapshots.dart';

/// Every class snapshot, one per persisted class of the model, so a test
/// can check that none is missing and that each declares every persisted
/// field of its class.
abstract final class SnapshotCatalog {
  static List<ClassSnapshot<Object>> get all => <ClassSnapshot<Object>>[
    GameSnapshots.game,
    PlayerSnapshots.player,
    PlayerSnapshots.objectives,
    JournalSnapshots.journal,
    BaseSnapshots.resource,
    BaseSnapshots.building,
    BaseSnapshots.techBranch,
    BaseSnapshots.unit,
    BaseSnapshots.worksite,
    MapSnapshots.position,
    MapSnapshots.lair,
    MapSnapshots.transitionBase,
    MapSnapshots.cell,
    MapSnapshots.gameMap,
    MapSnapshots.exploration,
    MapSnapshots.reinforcement,
    ThreatSnapshots.attack,
    ThreatSnapshots.raid,
    ThreatSnapshots.volcano,
    ThreatSnapshots.event,
    ThreatSnapshots.leviathan,
    ThreatSnapshots.intel,
    FightSnapshots.combatant,
    FightSnapshots.turn,
    FightSnapshots.result,
    ...HistorySnapshots.all,
  ];
}
