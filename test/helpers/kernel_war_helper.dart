import 'package:abyss/domain/action/attack_held_kernel_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';

/// A game against two factions at turn 12, tutorial over, where `owner`
/// holds the volcanic kernel at [kernelLevel] and `attacker` stands ready
/// on the volcano level. With [humanHolds], the human is the owner;
/// [personalities] pins the two factions.
class KernelWar {
  final Game game;
  final GridPosition at;
  final bool humanHolds;

  KernelWar._(this.game, this.at, this.humanHolds);

  factory KernelWar({
    int kernelLevel = 3,
    int mapSeed = 7,
    bool humanHolds = false,
    List<FactionPersonality>? personalities,
  }) {
    final Game game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: mapSeed,
      factionCount: 2,
      personalities: personalities,
    )..turn = 12;
    final GameMap map = game.levels[KernelGarrison.volcanoLevel]!;
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        if (map.cellAt(x, y).content == CellContentType.volcanicKernel) {
          final war = KernelWar._(game, GridPosition(x: x, y: y), humanHolds);
          return war.._setUp(kernelLevel);
        }
      }
    }
    throw StateError('no kernel on the volcano level');
  }

  Player get attacker => game.players[game.factions[0].id]!;
  Player get owner =>
      humanHolds ? game.humanPlayer : game.players[game.factions[1].id]!;
  Player get human => game.humanPlayer;

  GameMap get _map => game.levels[KernelGarrison.volcanoLevel]!;

  String? get holder => _map.cellAt(at.x, at.y).collectedBy;

  int kernelOf(Player p) => KernelGarrison.kernelLevelOf(p);

  void _setUp(int kernelLevel) {
    ObjectiveMigration.stateOf(game, human).tutorialEnabled = false;
    _map.setCell(
      at.x,
      at.y,
      _map.cellAt(at.x, at.y).copyWith(collectedBy: owner.id),
    );
    owner.buildings[BuildingType.volcanicKernel] = Building(
      type: BuildingType.volcanicKernel,
      level: kernelLevel,
    );
    for (final p in [attacker, owner, human]) {
      p.addRevealedCell(KernelGarrison.volcanoLevel, at);
      for (final l in [1, 2, 3, KernelGarrison.stockKey]) {
        for (final t in UnitType.values) {
          KernelGarrison.stockAt(p, l)[t]!.count = 0;
        }
      }
    }
  }

  void put(Player player, int level, Map<UnitType, int> units) => units.forEach(
    (t, n) => KernelGarrison.stockAt(player, level)[t]!.count = n,
  );

  int count(Player player, int level, UnitType type) =>
      KernelGarrison.stockAt(player, level)[type]!.count;

  /// Puts [army] on the volcano level of the attacker.
  void arm([Map<UnitType, int> army = horde]) =>
      put(attacker, KernelGarrison.volcanoLevel, army);

  /// Puts [units] in the garrison of the owner.
  void garrison(Map<UnitType, int> units) =>
      put(owner, KernelGarrison.stockKey, units);

  AttackHeldKernelAction strike(Map<UnitType, int> army, {int seed = 1}) =>
      AttackHeldKernelAction(
        targetX: at.x,
        targetY: at.y,
        selectedUnits: army,
        random: SeededRandom(seed),
      );
}

const Map<UnitType, int> horde = {UnitType.harpoonist: 80};
const Map<UnitType, int> smallGarrison = {UnitType.harpoonist: 3};
const Map<UnitType, int> fortress = {
  UnitType.guardian: 120,
  UnitType.harpoonist: 120,
};
