import 'dart:ui';

import '../base/base_rampart.dart';
import 'army_layout.dart';

export '../base/base_rampart.dart';

/// The base's coral wall raised around the parade ground once the Coral
/// Citadel stands at [level], along the rim of its 9 cells, its gate
/// opening on the front corner, before the depot.
BaseRampart armyRampartOf(int level) {
  const far = ArmyLayout.islandSize - BaseRampart.inset;
  return BaseRampart(
    size: ArmyLayout.islandSize.toInt(),
    level: level,
    gates: const [Offset(far, far)],
  );
}
