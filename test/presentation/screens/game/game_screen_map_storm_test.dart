import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';

/// Game of turn 10 with a scout and a hidden cell at (3, 5), next to the
/// base, under a storm when [stormUntil] is set.
Game _game({int? stormUntil}) {
  final hidden = GridPosition(x: 3, y: 5);
  final game = harnessGame(
    plainMap(),
    revealed: [for (final p in allPositions()) if (p != hidden) p],
    scouts: 1,
  )..turn = 10;
  if (stormUntil != null) {
    game.humanPlayer.eventState.activate(
      RandomEventType.storm,
      untilTurn: stormUntil,
    );
  }
  return game;
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  FilledButton sendButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Envoyer'));

  Future<void> tapHidden(WidgetTester tester, Game game) async {
    await tester.pumpWidget(mapTabHost(game));
    await tester.pumpAndSettle();
    await tapMapCell(tester, 3, 5);
  }

  testWidgets('a storm closes the exploration before the player sends', (
    tester,
  ) async {
    await tapHidden(tester, _game(stormUntil: 11));
    expect(find.text('Tempête : exploration impossible'), findsOneWidget);
    expect(sendButton(tester).onPressed, isNull);
  });

  testWidgets('once the storm is over, the scout can leave', (tester) async {
    await tapHidden(tester, _game(stormUntil: 9));
    expect(find.text('Tempête : exploration impossible'), findsNothing);
    expect(sendButton(tester).onPressed, isNotNull);
  });
}
