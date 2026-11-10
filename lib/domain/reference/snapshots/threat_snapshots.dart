import '../../event/event_state.dart';
import '../../faction/base_intel.dart';
import '../../leviathan/leviathan_return.dart';
import '../../raid/announced_attack.dart';
import '../../raid/raid_state.dart';
import '../../volcano/volcano_state.dart';
import '../class_snapshot.dart';
import '../player_ids.dart';
import '../snapshot_values.dart';
import 'map_snapshots.dart';

/// Snapshots of what comes at a player: raids, attacks of factions,
/// kraken waves, random events, the guardians' return, and what its
/// scouts know of the others.
abstract final class ThreatSnapshots {
  static final ClassSnapshot<AnnouncedAttack> attack =
      ClassSnapshot<AnnouncedAttack>('AnnouncedAttack', {
        'attackerId': (a, ids) => ids.of(a.attackerId),
        'units': (a, _) => SnapshotValues.counts(a.units),
        'arrivalTurn': (a, _) => a.arrivalTurn,
        'seed': (a, _) => a.seed,
      });

  static final ClassSnapshot<RaidState> raid =
      ClassSnapshot<RaidState>('RaidState', {
        'noise': (r, _) => r.noise,
        'totalNoise': (r, _) => r.totalNoise,
        'incoming': (r, ids) => MapSnapshots.lair.orNull(r.incoming, ids),
        'arrivalTurn': (r, _) => r.arrivalTurn,
        'lostInARow': (r, _) => r.lostInARow,
        'raidsRepelled': (r, _) => r.raidsRepelled,
        'raidsLost': (r, _) => r.raidsLost,
        'attacks': (r, ids) => attack.listOf(r.attacks, ids),
        'kernelSiegeLostTurn': (r, _) => r.kernelSiegeLostTurn,
        'postAttackTurns': (r, ids) => _turnsById(r.postAttackTurns, ids),
        'kernelAttackTurns': (r, ids) => _turnsById(r.kernelAttackTurns, ids),
      });

  static final ClassSnapshot<VolcanoState> volcano =
      ClassSnapshot<VolcanoState>('VolcanoState', {
        'incoming': (v, ids) => MapSnapshots.lair.orNull(v.incoming, ids),
        'arrivalTurn': (v, _) => v.arrivalTurn,
        'wavesRepelled': (v, _) => v.wavesRepelled,
        'levelsLost': (v, _) => v.levelsLost,
      });

  static final ClassSnapshot<EventState> event = ClassSnapshot<EventState>(
    'EventState',
    {
      'nextDrawTurn': (e, _) => e.nextDrawTurn,
      'pending': (e, _) => e.pending?.name,
      'pendingTurn': (e, _) => e.pendingTurn,
      'lastDrawn': (e, _) => e.lastDrawn?.name,
      'active': (e, _) => e.active?.name,
      'activeUntilTurn': (e, _) => e.activeUntilTurn,
      'heating': (e, _) => e.heating,
      'eventsSeen': (e, _) => e.eventsSeen,
      'survivors': (e, _) => e.survivors,
      'tradeFrom': (e, _) => e.tradeFrom?.name,
      'tradeTo': (e, _) => e.tradeTo?.name,
      'predatorWave': (e, ids) => MapSnapshots.lair.orNull(e.predatorWave, ids),
      'predatorsTurn': (e, _) => e.predatorsTurn,
      'wreckPosition':
          (e, ids) => MapSnapshots.position.orNull(e.wreckPosition, ids),
      'wreckUntilTurn': (e, _) => e.wreckUntilTurn,
    },
  );

  static final ClassSnapshot<LeviathanReturn> leviathan =
      ClassSnapshot<LeviathanReturn>('LeviathanReturn', {
        'postName': (l, _) => l.postName,
        'level': (l, _) => l.level,
        'at': (l, ids) => MapSnapshots.position.orNull(l.at, ids),
        'strikeTurn': (l, _) => l.strikeTurn,
        'over': (l, _) => l.over,
        'readyTurn': (l, _) => l.readyTurn,
      });

  static final ClassSnapshot<BaseIntel> intel =
      ClassSnapshot<BaseIntel>('BaseIntel', {
        'turn': (i, _) => i.turn,
        'headquartersLevel': (i, _) => i.headquartersLevel,
        'rampartLevel': (i, _) => i.rampartLevel,
        'army': (i, _) => SnapshotValues.counts(i.army),
        'stocks': (i, _) => SnapshotValues.counts(i.stocks),
      });

  static List<Object?> _turnsById(Map<String, int> turns, PlayerIds ids) =>
      SnapshotValues.pairs<String, int>(turns, ids.of, (int turn) => turn);
}
