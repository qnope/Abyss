import '../../history/history_entry.dart';
import '../../turn/turn_result.dart';
import '../class_snapshot.dart';
import '../player_ids.dart';
import '../snapshot_values.dart';
import 'history_entry_snapshot.dart';
import 'history_fight_snapshots.dart';

/// Snapshots of the history entries that hold no fight, and the way to
/// write any entry.
abstract final class HistorySnapshots {
  /// The snapshot of [entry], whatever its class; its `category` tells
  /// the classes apart, one each.
  static Map<String, Object?> of(HistoryEntry entry, PlayerIds ids) =>
      switch (entry) {
        BuildingEntry e => building.of(e, ids),
        CollectEntry e => collect.of(e, ids),
        ExploreEntry e => explore.of(e, ids),
        RecruitEntry e => recruit.of(e, ids),
        ResearchEntry e => research.of(e, ids),
        TurnEndEntry e => turnEnd.of(e, ids),
        DescentEntry e => descent.of(e, ids),
        ReinforcementEntry e => reinforcement.of(e, ids),
        EventEntry e => event.of(e, ids),
        CombatEntry e => HistoryFightSnapshots.combat.of(e, ids),
        CaptureEntry e => HistoryFightSnapshots.capture.of(e, ids),
        RaidEntry e => HistoryFightSnapshots.raid.of(e, ids),
        VolcanoEntry e => HistoryFightSnapshots.volcano.of(e, ids),
        BaseAssaultEntry e => HistoryFightSnapshots.assault.of(e, ids),
      };

  static final building = HistoryEntrySnapshot.of<BuildingEntry>(
    'BuildingEntry',
    {
      'buildingType': (e, _) => e.buildingType.name,
      'newLevel': (e, _) => e.newLevel,
    },
  );

  static final collect = HistoryEntrySnapshot.of<CollectEntry>('CollectEntry', {
    'targetX': (e, _) => e.targetX,
    'targetY': (e, _) => e.targetY,
    'gains': (e, _) => SnapshotValues.counts(e.gains),
  });

  static final explore = HistoryEntrySnapshot.of<ExploreEntry>('ExploreEntry', {
    'targetX': (e, _) => e.targetX,
    'targetY': (e, _) => e.targetY,
  });

  static final recruit = HistoryEntrySnapshot.of<RecruitEntry>('RecruitEntry', {
    'unitType': (e, _) => e.unitType.name,
    'quantity': (e, _) => e.quantity,
  });

  static final research =
      HistoryEntrySnapshot.of<ResearchEntry>('ResearchEntry', {
        'branch': (e, _) => e.branch.name,
        'isUnlock': (e, _) => e.isUnlock,
        'newLevel': (e, _) => e.newLevel,
      });

  static final ClassSnapshot<TurnResourceChange> resourceChange =
      ClassSnapshot<TurnResourceChange>('TurnResourceChange', {
        'type': (c, _) => c.type.name,
        'produced': (c, _) => c.produced,
        'consumed': (c, _) => c.consumed,
        'wasCapped': (c, _) => c.wasCapped,
        'beforeAmount': (c, _) => c.beforeAmount,
        'afterAmount': (c, _) => c.afterAmount,
      });

  static final turnEnd = HistoryEntrySnapshot.of<TurnEndEntry>('TurnEndEntry', {
    'changes': (e, ids) => resourceChange.listOf(e.changes, ids),
    'deactivatedBuildings':
        (e, _) => SnapshotValues.names(e.deactivatedBuildings),
    'lostUnits': (e, _) => SnapshotValues.counts(e.lostUnits),
  });

  static final descent = HistoryEntrySnapshot.of<DescentEntry>('DescentEntry', {
    'targetLevel': (e, _) => e.targetLevel,
    'unitCount': (e, _) => e.unitCount,
  });

  static final reinforcement = HistoryEntrySnapshot.of<ReinforcementEntry>(
    'ReinforcementEntry',
    {
      'targetLevel': (e, _) => e.targetLevel,
      'unitCount': (e, _) => e.unitCount,
    },
  );

  static final event = HistoryEntrySnapshot.of<EventEntry>('EventEntry', {
    'type': (e, _) => e.type.name,
    'accepted': (e, _) => e.accepted,
    'defaulted': (e, _) => e.defaulted,
  });

  /// Every class of entry, for the completeness guard.
  static List<ClassSnapshot<Object>> get all => <ClassSnapshot<Object>>[
    building,
    collect,
    explore,
    recruit,
    research,
    resourceChange,
    turnEnd,
    descent,
    reinforcement,
    event,
    ...HistoryFightSnapshots.all,
  ];
}
