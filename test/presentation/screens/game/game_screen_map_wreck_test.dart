import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';

final GridPosition _wreck = GridPosition(x: 2, y: 2);

/// Cell left hidden in every test game.
final GridPosition _corner = GridPosition(x: 0, y: 0);

/// Game of turn 10 whose wreck at [_wreck] can be searched through the
/// end of turn 13, revealed when [revealed].
Game _game({required bool revealed}) {
  final map = plainMap({
    _wreck: MapCell(terrain: TerrainType.plain, content: CellContentType.wreck),
  });
  final cells = [
    for (final p in allPositions())
      if ((revealed || p != _wreck) && p != _corner) p,
  ];
  final game = harnessGame(map, revealed: cells, scouts: 1)..turn = 10;
  game.humanPlayer.eventState
    ..wreckPosition = _wreck
    ..wreckUntilTurn = 13;
  return game;
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> tapWreck(WidgetTester tester, Game game) async {
    await tester.pumpWidget(mapTabHost(game));
    await tester.pumpAndSettle();
    await tapMapCell(tester, _wreck.x, _wreck.y);
  }

  testWidgets('a hidden wreck offers the exploration with its countdown', (
    tester,
  ) async {
    await tapWreck(tester, _game(revealed: false));
    expect(find.text('Explorer (2, 2)'), findsOneWidget);
    expect(find.text('Épave : encore 4 tours'), findsOneWidget);
  });

  testWidgets('a revealed wreck offers the search with its countdown', (
    tester,
  ) async {
    await tapWreck(tester, _game(revealed: true));
    expect(find.text('Collecter le trésor'), findsOneWidget);
    expect(find.text('Épave : encore 4 tours'), findsOneWidget);
  });

  testWidgets('the last turn of a wreck reads in the singular', (
    tester,
  ) async {
    final game = _game(revealed: true)..turn = 13;
    await tapWreck(tester, game);
    expect(find.text('Épave : encore 1 tour'), findsOneWidget);
  });

  testWidgets('another hidden cell shows no countdown', (tester) async {
    await tester.pumpWidget(mapTabHost(_game(revealed: false)));
    await tester.pumpAndSettle();
    await tapMapCell(tester, _corner.x, _corner.y);
    expect(find.text('Explorer (0, 0)'), findsOneWidget);
    expect(find.textContaining('Épave'), findsNothing);
  });
}
