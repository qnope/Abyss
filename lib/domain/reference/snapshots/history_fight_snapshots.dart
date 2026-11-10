import '../../history/history_entry.dart';
import '../class_snapshot.dart';
import '../snapshot_values.dart';
import 'fight_snapshots.dart';
import 'history_entry_snapshot.dart';
import 'map_snapshots.dart';

/// Snapshots of the history entries that hold a fight.
abstract final class HistoryFightSnapshots {
  static final combat = HistoryEntrySnapshot.of<CombatEntry>('CombatEntry', {
    'victory': (e, _) => e.victory,
    'targetX': (e, _) => e.targetX,
    'targetY': (e, _) => e.targetY,
    'lair': (e, ids) => MapSnapshots.lair.of(e.lair, ids),
    'fightResult': (e, ids) => FightSnapshots.result.of(e.fightResult, ids),
    'loot': (e, _) => SnapshotValues.counts(e.loot),
    'sent': (e, _) => SnapshotValues.counts(e.sent),
    'survivorsIntact': (e, _) => SnapshotValues.counts(e.survivorsIntact),
    'wounded': (e, _) => SnapshotValues.counts(e.wounded),
    'dead': (e, _) => SnapshotValues.counts(e.dead),
  });

  static final capture = HistoryEntrySnapshot.of<CaptureEntry>('CaptureEntry', {
    'transitionBaseName': (e, _) => e.transitionBaseName,
    'fightResult': (e, ids) => FightSnapshots.result.of(e.fightResult, ids),
    'captured': (e, _) => e.captured,
  });

  static final raid = HistoryEntrySnapshot.of<RaidEntry>('RaidEntry', {
    'victory': (e, _) => e.victory,
    'wave': (e, ids) => MapSnapshots.lair.of(e.wave, ids),
    'fightResult': (e, ids) => FightSnapshots.result.of(e.fightResult, ids),
    'loot': (e, _) => SnapshotValues.counts(e.loot),
    'pillaged': (e, _) => SnapshotValues.counts(e.pillaged),
    'defenders': (e, _) => SnapshotValues.counts(e.defenders),
    'survivorsIntact': (e, _) => SnapshotValues.counts(e.survivorsIntact),
    'wounded': (e, _) => SnapshotValues.counts(e.wounded),
    'dead': (e, _) => SnapshotValues.counts(e.dead),
    'rampartLevel': (e, _) => e.rampartLevel,
    'surprise': (e, _) => e.surprise,
  });

  static final volcano = HistoryEntrySnapshot.of<VolcanoEntry>('VolcanoEntry', {
    'victory': (e, _) => e.victory,
    'wave': (e, ids) => MapSnapshots.lair.of(e.wave, ids),
    'fightResult': (e, ids) => FightSnapshots.result.of(e.fightResult, ids),
    'kernelLevel': (e, _) => e.kernelLevel,
    'defenders': (e, _) => SnapshotValues.counts(e.defenders),
    'survivorsIntact': (e, _) => SnapshotValues.counts(e.survivorsIntact),
    'wounded': (e, _) => SnapshotValues.counts(e.wounded),
    'dead': (e, _) => SnapshotValues.counts(e.dead),
  });

  static final assault =
      HistoryEntrySnapshot.of<BaseAssaultEntry>('BaseAssaultEntry', {
        'victory': (e, _) => e.victory,
        'defending': (e, _) => e.defending,
        'opponentName': (e, _) => e.opponentName,
        'fightResult': (e, ids) => FightSnapshots.result.of(e.fightResult, ids),
        'units': (e, _) => SnapshotValues.counts(e.units),
        'survivorsIntact': (e, _) => SnapshotValues.counts(e.survivorsIntact),
        'wounded': (e, _) => SnapshotValues.counts(e.wounded),
        'dead': (e, _) => SnapshotValues.counts(e.dead),
        'rampartBefore': (e, _) => e.rampartBefore,
        'rampartAfter': (e, _) => e.rampartAfter,
        'headquartersBefore': (e, _) => e.headquartersBefore,
        'headquartersAfter': (e, _) => e.headquartersAfter,
        'pillaged': (e, _) => SnapshotValues.counts(e.pillaged),
        'loot': (e, _) => SnapshotValues.counts(e.loot),
        'postName': (e, _) => e.postName,
        'lostWithPost': (e, _) => SnapshotValues.counts(e.lostWithPost),
        'passageDestroyed': (e, _) => e.passageDestroyed,
      }, omitted: const <String, String>{});

  static List<ClassSnapshot<Object>> get all => <ClassSnapshot<Object>>[
    combat,
    capture,
    raid,
    volcano,
    assault,
  ];
}
