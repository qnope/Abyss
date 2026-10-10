import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/objective/objectives_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('the objective banner opens the sheet of the objectives', (
    tester,
  ) async {
    final game = Game.singlePlayer(Player(name: 'Nemo'));
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: GameScreen(game: game, repository: FakeGameRepository()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Monte le QG au niveau 1 : 0/1'));
    await tester.pumpAndSettle();

    expect(find.byType(ObjectivesSheetBody), findsOneWidget);
    expect(find.text('1. Installation'), findsOneWidget);
  });
}
