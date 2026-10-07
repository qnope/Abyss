import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/resource/pearl_income.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';

GameMap _map(List<TransitionBase> bases) => GameMap(
      width: 3,
      height: 3,
      seed: 1,
      cells: [
        for (final base in bases)
          MapCell(
            terrain: TerrainType.plain,
            content: CellContentType.transitionBase,
            transitionBase: base,
          ),
        for (var i = bases.length; i < 9; i++)
          MapCell(terrain: TerrainType.plain),
      ],
    );

TransitionBase _base(TransitionBaseType type, [String? owner]) =>
    TransitionBase(type: type, name: type.name, capturedBy: owner);

Game _game(Map<int, GameMap> levels) {
  final player = Player(id: 'p', name: 'p', baseX: 1, baseY: 1);
  return Game(humanPlayerId: 'p', players: {'p': player}, levels: levels);
}

void main() {
  group('PearlIncome', () {
    test('is zero without captured bases', () {
      final game = _game({1: _map([_base(TransitionBaseType.faille)])});
      expect(PearlIncome.of(game, 'p'), 0);
      expect(PearlIncome.asProduction(game, 'p'), isEmpty);
    });

    test('sums captured bases across levels', () {
      final game = _game({
        1: _map([
          _base(TransitionBaseType.faille, 'p'),
          _base(TransitionBaseType.faille, 'p'),
          _base(TransitionBaseType.faille, 'other'),
        ]),
        2: _map([_base(TransitionBaseType.cheminee, 'p')]),
      });
      expect(PearlIncome.of(game, 'p'), 2 + 2 + 3);
      expect(PearlIncome.asProduction(game, 'p'),
          {ResourceType.pearl: 7});
    });

    test('end of turn credits the pearls', () {
      final game = _game({
        1: _map([_base(TransitionBaseType.faille, 'p')]),
        2: _map([_base(TransitionBaseType.cheminee, 'p')]),
      });
      final pearls = game.humanPlayer.resources[ResourceType.pearl]!;
      final before = pearls.amount;
      final result = TurnResolver().resolve(game);
      expect(pearls.amount, before + 5);
      final change =
          result.changes.firstWhere((c) => c.type == ResourceType.pearl);
      expect(change.produced, 5);
    });

    test('end of turn caps pearls at max storage', () {
      final game = _game({
        1: _map([_base(TransitionBaseType.faille, 'p')]),
      });
      final pearls = game.humanPlayer.resources[ResourceType.pearl]!;
      pearls.amount = pearls.maxStorage - 1;
      TurnResolver().resolve(game);
      expect(pearls.amount, pearls.maxStorage);
    });
  });
}
