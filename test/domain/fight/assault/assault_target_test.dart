import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:flutter_test/flutter_test.dart';

Game _gameWith(Map<int, MapCell> special) {
  final cells = List.generate(
    16,
    (i) => special[i] ?? MapCell(terrain: TerrainType.plain),
  );
  final player = Player(id: 'p1', name: 'Test');
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: {1: GameMap(width: 4, height: 4, cells: cells, seed: 1)},
  );
}

MapCell _base(TransitionBaseType type, {String? capturedBy}) => MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.transitionBase,
      transitionBase:
          TransitionBase(type: type, name: 'x', capturedBy: capturedBy),
    );

MapCell _kernel(CellContentType content, {String? by}) => MapCell(
    terrain: TerrainType.plain, content: content, collectedBy: by);

void main() {
  test('each target fights its own guardians', () {
    expect(AssaultTarget.faille.guardians().length,
        GuardianFactory.forFaille().length);
    expect(AssaultTarget.cheminee.guardians().first.typeKey,
        GuardianFactory.forCheminee().first.typeKey);
    expect(AssaultTarget.kernel.guardians().length,
        GuardianFactory.forVolcanicKernel().length);
  });

  test('the passage to build after the capture, none for the kernel', () {
    expect(AssaultTarget.faille.passage, BuildingType.descentModule);
    expect(AssaultTarget.cheminee.passage, BuildingType.pressureCapsule);
    expect(AssaultTarget.kernel.passage, isNull);
  });

  test('reads an uncaptured Faille or Cheminée on the map', () {
    final game = _gameWith({
      0: _base(TransitionBaseType.faille),
      1: _base(TransitionBaseType.cheminee),
      2: _base(TransitionBaseType.faille, capturedBy: 'p1'),
    });

    expect(AssaultTarget.at(game, 1, 0, 0), AssaultTarget.faille);
    expect(AssaultTarget.at(game, 1, 1, 0), AssaultTarget.cheminee);
    expect(AssaultTarget.at(game, 1, 2, 0), isNull);
    expect(AssaultTarget.at(game, 1, 3, 0), isNull);
  });

  test('reads the kernel from any cell of the volcano', () {
    final game = _gameWith({
      5: _kernel(CellContentType.volcanicKernel),
      6: _kernel(CellContentType.volcanicKernelPart),
      9: _kernel(CellContentType.volcanicKernelPart),
      10: _kernel(CellContentType.volcanicKernelPart),
    });

    expect(AssaultTarget.at(game, 1, 1, 1), AssaultTarget.kernel);
    expect(AssaultTarget.at(game, 1, 2, 2), AssaultTarget.kernel);
  });

  test('none on a captured kernel, an unknown level or a bare cell', () {
    final game = _gameWith({5: _kernel(CellContentType.volcanicKernel, by: 'p1')});

    expect(AssaultTarget.at(game, 1, 1, 1), isNull);
    expect(AssaultTarget.at(game, 2, 1, 1), isNull);
  });
}
