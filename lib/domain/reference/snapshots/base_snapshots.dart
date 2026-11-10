import '../../building/building.dart';
import '../../resource/resource.dart';
import '../../tech/tech_branch_state.dart';
import '../../unit/unit.dart';
import '../../worksite/worksite.dart';
import '../class_snapshot.dart';

/// Snapshots of what a base holds: stocks, buildings, research, units
/// and the work started this turn.
abstract final class BaseSnapshots {
  static final ClassSnapshot<Resource> resource =
      ClassSnapshot<Resource>('Resource', {
        'type': (r, _) => r.type.name,
        'amount': (r, _) => r.amount,
        'maxStorage': (r, _) => r.maxStorage,
      });

  static final ClassSnapshot<Building> building = ClassSnapshot<Building>(
    'Building',
    {'type': (b, _) => b.type.name, 'level': (b, _) => b.level},
  );

  static final ClassSnapshot<TechBranchState> techBranch =
      ClassSnapshot<TechBranchState>('TechBranchState', {
        'branch': (t, _) => t.branch.name,
        'unlocked': (t, _) => t.unlocked,
        'researchLevel': (t, _) => t.researchLevel,
        'choices': (t, _) => <Object?>[...t.choices],
      });

  static final ClassSnapshot<Unit> unit = ClassSnapshot<Unit>('Unit', {
    'type': (u, _) => u.type.name,
    'count': (u, _) => u.count,
  });

  static final ClassSnapshot<Worksite> worksite = ClassSnapshot<Worksite>(
    'Worksite',
    {'upgrades': (w, _) => w.upgrades, 'research': (w, _) => w.research},
  );
}
