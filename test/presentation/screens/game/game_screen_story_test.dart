import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect_painter.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

const _size = 20;

/// A game whose player has seen the cells around its base, and has sent
/// a scout to (12, 10) when [exploring].
Game _game({bool exploring = true}) => Game.singlePlayer(Player(
      name: 'Nemo',
      baseX: 7,
      baseY: 10,
      revealedCellsPerLevel: {
        1: [
          for (var y = 8; y <= 12; y++)
            for (var x = 5; x <= 9; x++) GridPosition(x: x, y: y),
        ],
      },
      pendingExplorations: [
        if (exploring)
          ExplorationOrder(target: GridPosition(x: 12, y: 10)),
      ],
    ))
      ..levels = {
        1: GameMap(
          width: _size,
          height: _size,
          cells: List.generate(
              _size * _size, (_) => MapCell(terrain: TerrainType.plain)),
          seed: 1,
        ),
      };

/// Lets routes and dialogs come and go while the sea keeps moving.
Future<void> _wait(WidgetTester tester, {int frames = 10}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Shows the base of [game], then ends the turn.
Future<void> _endTurn(WidgetTester tester, Game game) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AbyssTheme.create(),
    home: GameScreen(game: game, repository: FakeGameRepository()),
  ));
  await _wait(tester);
  await tester.tap(find.text('Tour suivant'));
  await _wait(tester);
  await tester.tap(find.text('Confirmer'));
  await tester.pump();
  await tester.pump();
}

bool _storyShown() => find
    .byWidgetPredicate((w) => w is CustomPaint && w.painter is MapEffectPainter)
    .evaluate()
    .isNotEmpty;

Finder get _summary => find.text('OK');

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('the fog lifts on the map, then the summary opens', (
    tester,
  ) async {
    await _endTurn(tester, _game());
    expect(find.byType(GameMapView), findsOneWidget);
    expect(_storyShown(), isTrue);
    expect(find.text('Passer ›'), findsOneWidget);
    expect(_summary, findsNothing);
    await _wait(tester, frames: 20);
    expect(_storyShown(), isFalse);
    expect(find.text('Passer ›'), findsNothing);
    expect(_summary, findsOneWidget);
    expect(find.byType(GameMapView), findsOneWidget);
  });

  testWidgets('"Passer" skips to the summary', (tester) async {
    await _endTurn(tester, _game());
    await tester.tap(find.text('Passer ›'));
    await _wait(tester, frames: 3);
    expect(_storyShown(), isFalse);
    expect(_summary, findsOneWidget);
  });

  testWidgets('a tap on the map skips to the summary', (tester) async {
    await _endTurn(tester, _game());
    await tester.tapAt(tester.getCenter(find.byType(GameMapView)));
    await _wait(tester, frames: 3);
    expect(_summary, findsOneWidget);
  });

  testWidgets('a turn with nothing to tell opens the summary at once', (
    tester,
  ) async {
    await _endTurn(tester, _game(exploring: false));
    await _wait(tester, frames: 3);
    expect(find.byType(GameMapView), findsNothing);
    expect(_summary, findsOneWidget);
  });

  testWidgets('with reduced motion, the summary opens at once', (
    tester,
  ) async {
    reduceMotion(tester);
    await _endTurn(tester, _game());
    await tester.pumpAndSettle();
    expect(find.byType(GameMapView), findsNothing);
    expect(_summary, findsOneWidget);
  });
}
