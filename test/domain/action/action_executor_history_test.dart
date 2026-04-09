import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action.dart';
import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';

({Game game, Player player}) _createScenario({
  int coral = 80,
  int ore = 50,
  int hqLevel = 0,
  int turn = 1,
}) {
  final player = Player(
    id: 'test',
    name: 'Test',
    resources: {
      ResourceType.algae: Resource(type: ResourceType.algae, amount: 100),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: coral),
      ResourceType.ore: Resource(type: ResourceType.ore, amount: ore),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: 60),
      ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 5),
    },
    buildings: {
      BuildingType.headquarters:
          Building(type: BuildingType.headquarters, level: hqLevel),
    },
  );
  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    turn: turn,
  );
  return (game: game, player: player);
}

/// Test-only action whose `validate` returns success but `execute` returns
/// a failure. Used to exercise the "execute failed after validation passed"
/// branch of [ActionExecutor].
class _FailingExecuteAction extends Action {
  @override
  ActionType get type => ActionType.upgradeBuilding;

  @override
  String get description => 'failing execute';

  @override
  ActionResult validate(Game game, Player player) =>
      const ActionResult.success();

  @override
  ActionResult execute(Game game, Player player) =>
      const ActionResult.failure('boom');

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) =>
      BuildingEntry(
        turn: turn,
        buildingType: BuildingType.headquarters,
        newLevel: 99,
      );
}

void main() {
  group('ActionExecutor history recording', () {
    late ActionExecutor executor;

    setUp(() {
      executor = ActionExecutor();
    });

    test('successful UpgradeBuildingAction appends a BuildingEntry', () {
      final s = _createScenario(turn: 7);
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);

      final result = executor.execute(action, s.game, s.player);

      expect(result.isSuccess, isTrue);
      expect(s.player.historyEntries.length, 1);
      final entry = s.player.historyEntries.first;
      expect(entry, isA<BuildingEntry>());
      final building = entry as BuildingEntry;
      expect(building.turn, 7);
      expect(building.buildingType, BuildingType.headquarters);
      expect(building.newLevel, 1);
    });

    test('failed validation does not append a history entry', () {
      final s = _createScenario(coral: 10, ore: 5);
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);

      final result = executor.execute(action, s.game, s.player);

      expect(result.isSuccess, isFalse);
      expect(s.player.historyEntries, isEmpty);
    });

    test('failed execute does not append a history entry', () {
      final s = _createScenario();
      final action = _FailingExecuteAction();

      final result = executor.execute(action, s.game, s.player);

      expect(result.isSuccess, isFalse);
      expect(s.player.historyEntries, isEmpty);
    });

    test('105 successful actions cap history at 100 (FIFO)', () {
      final player = Player(
        id: 'test',
        name: 'Test',
        buildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 0),
        },
      );
      final game = Game(
        humanPlayerId: player.id,
        players: {player.id: player},
        turn: 1,
      );
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);

      for (int i = 0; i < 105; i++) {
        // Top up resources and reset level/turn so each call succeeds with
        // a fresh entry carrying a distinct turn number.
        player.resources[ResourceType.algae]!.amount = 1000;
        player.resources[ResourceType.coral]!.amount = 1000;
        player.resources[ResourceType.ore]!.amount = 1000;
        player.resources[ResourceType.energy]!.amount = 1000;
        player.resources[ResourceType.pearl]!.amount = 1000;
        player.buildings[BuildingType.headquarters]!.level = 0;
        game.turn = i + 1;

        final result = executor.execute(action, game, player);
        expect(result.isSuccess, isTrue);
      }

      expect(player.historyEntries.length, 100);
      // Oldest 5 dropped → the first remaining entry should be from turn 6.
      final first = player.historyEntries.first as BuildingEntry;
      expect(first.turn, 6);
      final last = player.historyEntries.last as BuildingEntry;
      expect(last.turn, 105);
    });
  });
}
