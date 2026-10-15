import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/fight_summary_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect_painter.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

const _lair = (11, 10);
const _size = 20;

Game _lairGame() {
  final cells = List.generate(
      _size * _size, (_) => MapCell(terrain: TerrainType.plain));
  cells[_lair.$2 * _size + _lair.$1] = MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.monsterLair,
    lair: const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 1),
  );
  final game = Game.singlePlayer(Player(
    name: 'Nemo',
    baseX: 7,
    baseY: 10,
    revealedCellsPerLevel: {1: [
      for (var y = 0; y < _size; y++)
        for (var x = 0; x < _size; x++) GridPosition(x: x, y: y),
    ]},
  ))
    ..levels = {1: GameMap(width: _size, height: _size, cells: cells, seed: 1)};
  game.humanPlayer.unitsOnLevel(1)[UnitType.scout]!.count = 3;
  return game;
}

/// Lets routes and sheets come and go while the sea keeps moving.
Future<void> _wait(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Opens the lair from the map and launches a fight with a scout.
Future<void> _launchFight(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AbyssTheme.create(),
    home: GameScreen(game: _lairGame(), repository: FakeGameRepository()),
  ));
  await _wait(tester);
  await tester.tap(find.text('Carte'));
  await _wait(tester);
  tester.widget<GameMapView>(find.byType(GameMapView))
      .onCellTap!(_lair.$1, _lair.$2);
  await _wait(tester);
  await tester.tap(find.text('Préparer le combat'));
  await _wait(tester);
  await tester.tap(find.byIcon(Icons.add).first);
  await tester.pump();
  final launch = find.widgetWithText(ElevatedButton, 'Lancer le combat');
  await tester.ensureVisible(launch);
  await tester.pump();
  await tester.tap(launch);
  await tester.pump();
}

bool _strikeShown(WidgetTester tester) => find
    .byWidgetPredicate((w) => w is CustomPaint && w.painter is MapEffectPainter)
    .evaluate()
    .isNotEmpty;

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a fight plays on the map before its report opens', (
    tester,
  ) async {
    await _launchFight(tester);
    await _wait(tester);
    expect(find.byType(ArmySelectionScreen), findsNothing);
    expect(find.byType(FightSummaryScreen), findsNothing);
    expect(_strikeShown(tester), isTrue);
    for (var i = 0; i < 5; i++) {
      await _wait(tester);
    }
    expect(find.byType(FightSummaryScreen), findsOneWidget);
  });

  testWidgets('a tap on the map ends the fight animation at once', (
    tester,
  ) async {
    await _launchFight(tester);
    await _wait(tester);
    await tester.tapAt(tester.getCenter(find.byType(GameMapView)));
    await _wait(tester);
    expect(find.byType(FightSummaryScreen), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('with reduced motion, the report opens at once', (
    tester,
  ) async {
    reduceMotion(tester);
    await _launchFight(tester);
    await tester.pumpAndSettle();
    expect(find.byType(FightSummaryScreen), findsOneWidget);
  });
}
