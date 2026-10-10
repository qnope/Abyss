import 'package:abyss/domain/action/attack_post_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';

/// A game against two factions where `owner` holds a Faille (on level 1)
/// or a Cheminée (on level 2) with its passage building, and `attacker`
/// stands ready to take it, at turn 12 with the tutorial over.
class PostWar {
  final Game game;
  final TransitionBaseType kind;
  final int level;
  final GridPosition at;
  final TransitionBase post;

  PostWar._(this.game, this.kind, this.level, this.at, this.post);

  factory PostWar(TransitionBaseType kind, {int mapSeed = 7}) {
    final Game game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: mapSeed,
      factionCount: 2,
    )..turn = 12;
    final int level = kind == TransitionBaseType.faille ? 1 : 2;
    final GameMap map = game.levels[level]!;
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        final TransitionBase? base = map.cellAt(x, y).transitionBase;
        if (base != null && base.type == kind) {
          final war = PostWar._(
            game,
            kind,
            level,
            GridPosition(x: x, y: y),
            base,
          );
          return war.._setUp();
        }
      }
    }
    throw StateError('no $kind on level $level');
  }

  Player get attacker => game.players[game.factions[0].id]!;
  Player get owner => game.players[game.factions[1].id]!;
  Player get human => game.humanPlayer;

  BuildingType get passage =>
      kind == TransitionBaseType.faille
          ? BuildingType.descentModule
          : BuildingType.pressureCapsule;

  /// The level whose units defend the post.
  int get below => post.targetLevel;

  void _setUp() {
    ObjectiveMigration.stateOf(game, human).tutorialEnabled = false;
    post.capturedBy = owner.id;
    owner.buildings[passage] = Building(type: passage, level: 2);
    attacker.addRevealedCell(level, at);
    human.addRevealedCell(level, at);
    for (final p in [attacker, owner, human]) {
      for (final l in [1, 2, 3]) {
        for (final t in UnitType.values) {
          KernelGarrison.stockAt(p, l)[t]!.count = 0;
        }
      }
    }
  }

  /// Puts [units] on [player]'s stock of [onLevel].
  void put(Player player, int onLevel, Map<UnitType, int> units) => units
      .forEach((t, n) => KernelGarrison.stockAt(player, onLevel)[t]!.count = n);

  int count(Player player, int onLevel, UnitType type) =>
      KernelGarrison.stockAt(player, onLevel)[type]!.count;

  AttackPostAction strike(Map<UnitType, int> army, {int seed = 1}) =>
      AttackPostAction(
        targetX: at.x,
        targetY: at.y,
        level: level,
        selectedUnits: army,
        random: SeededRandom(seed),
      );

  /// The attacker's army: an overwhelming force on the attack level.
  void arm(Player player, [Map<UnitType, int> army = horde]) =>
      put(player, level, army);
}

const Map<UnitType, int> horde = {UnitType.harpoonist: 60};
const Map<UnitType, int> wall = {
  UnitType.guardian: 80,
  UnitType.harpoonist: 80,
};
const Map<UnitType, int> garrison = {UnitType.harpoonist: 3};
