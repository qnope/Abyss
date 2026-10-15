import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/transition_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/transition_fight_summary_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect_painter.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

const _post = (11, 10);
const _size = 20;

Game _postGame() {
  final cells = List.generate(
      _size * _size, (_) => MapCell(terrain: TerrainType.plain));
  cells[_post.$2 * _size + _post.$1] = MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.transitionBase,
    transitionBase:
        TransitionBase(type: TransitionBaseType.faille, name: 'Faille Alpha'),
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
  final units = game.humanPlayer.unitsOnLevel(1);
  units[UnitType.abyssAdmiral]!.count = 1;
  units[UnitType.domeBreaker]!.count = 30;
  return game;
}

/// Lets routes and sheets come and go while the sea keeps moving.
Future<void> _wait(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _select(WidgetTester tester, UnitType type, int count) async {
  tester.widget<UnitQuantityRow>(find.byWidgetPredicate(
    (w) => w is UnitQuantityRow && w.type == type,
  )).onChanged(count);
  await tester.pump();
}

/// Opens the Faille from the map and launches its assault.
Future<void> _launchAssault(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AbyssTheme.create(),
    home: GameScreen(game: _postGame(), repository: FakeGameRepository()),
  ));
  await _wait(tester);
  await tester.tap(find.text('Carte'));
  await _wait(tester);
  tester.widget<GameMapView>(find.byType(GameMapView))
      .onCellTap!(_post.$1, _post.$2);
  await _wait(tester);
  await tester.tap(find.text('Assaut'));
  await _wait(tester);
  await _select(tester, UnitType.abyssAdmiral, 1);
  await _select(tester, UnitType.domeBreaker, 30);
  final launch = find.widgetWithText(ElevatedButton, 'Lancer l\'assaut');
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

  testWidgets('an assault plays on the map before its report opens', (
    tester,
  ) async {
    await _launchAssault(tester);
    await _wait(tester);
    expect(find.byType(TransitionArmySelectionScreen), findsNothing);
    expect(find.byType(TransitionFightSummaryScreen), findsNothing);
    expect(_strikeShown(tester), isTrue);
    for (var i = 0; i < 8; i++) {
      await _wait(tester);
    }
    expect(find.byType(TransitionFightSummaryScreen), findsOneWidget);
  });

  testWidgets('a tap on the map ends the assault animation at once', (
    tester,
  ) async {
    await _launchAssault(tester);
    await _wait(tester);
    await tester.tapAt(tester.getCenter(find.byType(GameMapView)));
    await _wait(tester);
    expect(find.byType(TransitionFightSummaryScreen), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('with reduced motion, the report opens at once', (
    tester,
  ) async {
    reduceMotion(tester);
    await _launchAssault(tester);
    await tester.pumpAndSettle();
    expect(find.byType(TransitionFightSummaryScreen), findsOneWidget);
  });
}
