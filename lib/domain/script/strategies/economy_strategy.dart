import '../../building/building_type.dart';
import '../game_script.dart';
import '../script_turn.dart';
import 'script_turn_moves.dart';

/// "Tout éco": grows production as fast as it can and never trains a
/// single defender. Raids should end it.
class EconomyStrategy extends GameScript {
  static const List<BuildingType> buildOrder = <BuildingType>[
    BuildingType.solarPanel,
    BuildingType.algaeFarm,
    BuildingType.coralMine,
    BuildingType.oreExtractor,
    BuildingType.headquarters,
  ];

  const EconomyStrategy();

  @override
  String get name => 'economy';

  @override
  void playTurn(ScriptTurn turn) => turn.upgradeInOrder(buildOrder);
}
