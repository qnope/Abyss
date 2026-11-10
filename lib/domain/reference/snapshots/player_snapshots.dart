import '../../faction/base_intel.dart';
import '../../game/player.dart';
import '../../history/history_entry.dart';
import '../../map/grid_position.dart';
import '../../objective/objective_state.dart';
import '../../unit/unit.dart';
import '../../unit/unit_type.dart';
import '../class_snapshot.dart';
import '../snapshot_values.dart';
import 'base_snapshots.dart';
import 'history_snapshots.dart';
import 'map_snapshots.dart';
import 'threat_snapshots.dart';

/// Snapshot of a player, human or faction, and of its objectives.
abstract final class PlayerSnapshots {
  static final ClassSnapshot<ObjectiveState> objectives =
      ClassSnapshot<ObjectiveState>('ObjectiveState', {
        'completed': (o, _) => SnapshotValues.names(o.completed),
        'tutorialEnabled': (o, _) => o.tutorialEnabled,
        'tipsEnabled': (o, _) => o.tipsEnabled,
        'seenTips': (o, _) => SnapshotValues.names(o.seenTips),
      });

  static final ClassSnapshot<Player> player = ClassSnapshot<Player>(
    'Player',
    {
      'name': (p, _) => p.name,
      'id': (p, ids) => ids.of(p.id),
      'baseX': (p, _) => p.baseX,
      'baseY': (p, _) => p.baseY,
      'resources':
          (p, ids) => SnapshotValues.pairs(
            p.resources,
            SnapshotValues.name,
            (r) => BaseSnapshots.resource.of(r, ids),
          ),
      'buildings':
          (p, ids) => SnapshotValues.pairs(
            p.buildings,
            SnapshotValues.name,
            (b) => BaseSnapshots.building.of(b, ids),
          ),
      'techBranches':
          (p, ids) => SnapshotValues.pairs(
            p.techBranches,
            SnapshotValues.name,
            (t) => BaseSnapshots.techBranch.of(t, ids),
          ),
      'unitsPerLevel':
          (p, ids) => SnapshotValues.pairs(
            p.unitsPerLevel,
            (int level) => level,
            (Map<UnitType, Unit> units) => SnapshotValues.pairs(
              units,
              SnapshotValues.name,
              (u) => BaseSnapshots.unit.of(u, ids),
            ),
          ),
      'recruitedUnitTypes':
          (p, _) => SnapshotValues.names(p.recruitedUnitTypes),
      'pendingExplorations':
          (p, ids) =>
              MapSnapshots.exploration.listOf(p.pendingExplorations, ids),
      'revealedCellsPerLevel':
          (p, ids) => SnapshotValues.pairs(
            p.revealedCellsPerLevel,
            (int level) => level,
            (List<GridPosition> cells) =>
                MapSnapshots.position.listOf(cells, ids),
          ),
      'historyEntries':
          (p, ids) => <Object?>[
            for (final HistoryEntry e in p.historyEntries)
              HistorySnapshots.of(e, ids),
          ],
      'pendingReinforcements':
          (p, ids) =>
              MapSnapshots.reinforcement.listOf(p.pendingReinforcements, ids),
      'raidState': (p, ids) => ThreatSnapshots.raid.of(p.raidState, ids),
      'worksite': (p, ids) => BaseSnapshots.worksite.of(p.worksite, ids),
      'volcanoState':
          (p, ids) => ThreatSnapshots.volcano.of(p.volcanoState, ids),
      'eventState': (p, ids) => ThreatSnapshots.event.of(p.eventState, ids),
      'savedObjectiveState':
          (p, ids) => objectives.orNull(p.savedObjectiveState, ids),
      'savedFallen': (p, _) => p.hasFallen,
      // Not `intel`, which fills the field in when it is missing.
      'savedIntel':
          (p, ids) => SnapshotValues.pairs(
            p.savedIntel ?? const <String, BaseIntel>{},
            ids.of,
            (i) => ThreatSnapshots.intel.of(i, ids),
          ),
    },
    renamed: const <String, String>{
      'savedObjectiveState': 'objectiveState',
      'savedFallen': 'fallen',
      'savedIntel': 'intel',
    },
  );
}
