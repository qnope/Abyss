import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/save/empty_saves.dart';
import 'package:abyss/presentation/widgets/save/save_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/load_game_harness.dart';

void main() {
  late FakeGameRepository repository;

  setUp(() => repository = FakeGameRepository());

  double topOf(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  testWidgets('shows the empty state when there is no save', (tester) async {
    await tester.pumpWidget(loadGameApp(repository));

    expect(find.byType(EmptySaves), findsOneWidget);
    expect(find.byType(SaveCard), findsNothing);
  });

  testWidgets('sits on the dimmed backdrop under its title', (tester) async {
    repository.addGame(savedGame('Alice'));
    await tester.pumpWidget(loadGameApp(repository));

    expect(find.text('Charger une partie'), findsOneWidget);
    final backdrop = tester.widget<AbyssBackdrop>(find.byType(AbyssBackdrop));
    expect(backdrop.dimmed, isTrue);
  });

  testWidgets('keeps the veiled backdrop still', (tester) async {
    await tester.pumpWidget(loadGameApp(repository));

    final backdrop = tester.widget<AbyssBackdrop>(find.byType(AbyssBackdrop));
    // Barely visible under the veil, moving snow would only cost frames.
    expect(backdrop.animate, isFalse);
  });

  testWidgets('groups games in progress above finished ones, latest first', (
    tester,
  ) async {
    repository
      ..addGame(savedGame('Ancien', hoursAgo: 5))
      ..addGame(savedGame('Perdu', status: GameStatus.defeat, hoursAgo: 3))
      ..addGame(savedGame('Recent', hoursAgo: 1))
      ..addGame(savedGame('Gagne', status: GameStatus.victory, hoursAgo: 2));
    await tester.pumpWidget(loadGameApp(repository));

    final order =
        [
          'EN COURS',
          'Recent',
          'Ancien',
          'TERMINÉES',
          'Gagne',
        ].map((text) => topOf(tester, text)).toList();
    expect(order, orderedEquals([...order]..sort()));
    expect(topOf(tester, 'Perdu'), greaterThan(topOf(tester, 'Gagne')));
  });

  testWidgets('leaves out the header of an empty section', (tester) async {
    repository.addGame(savedGame('Alice'));
    await tester.pumpWidget(loadGameApp(repository));
    expect(find.text('EN COURS'), findsOneWidget);
    expect(find.text('TERMINÉES'), findsNothing);
  });

  testWidgets('shows only finished games under their header', (tester) async {
    repository.addGame(savedGame('Nemo', status: GameStatus.victory));
    await tester.pumpWidget(loadGameApp(repository));
    expect(find.text('EN COURS'), findsNothing);
    expect(find.text('TERMINÉES'), findsOneWidget);
  });

  testWidgets('dates each save from the injected clock', (tester) async {
    repository.addGame(savedGame('Alice', hoursAgo: 2));
    await tester.pumpWidget(loadGameApp(repository));
    expect(find.text('il y a 2 h'), findsOneWidget);
  });

  testWidgets('highlights the game in progress played last', (tester) async {
    repository
      ..addGame(savedGame('Gagne', status: GameStatus.victory, hoursAgo: 1))
      ..addGame(savedGame('Ancien', hoursAgo: 4))
      ..addGame(savedGame('Recent', hoursAgo: 2));
    await tester.pumpWidget(loadGameApp(repository));

    final cards = tester.widgetList<SaveCard>(find.byType(SaveCard));
    final highlighted = {
      for (final card in cards) card.summary.playerName: card.highlighted,
    };
    expect(highlighted, {'Recent': true, 'Ancien': false, 'Gagne': false});
  });

  for (final size in [const Size(320, 640), const Size(1280, 720)]) {
    testWidgets('fits a ${size.width.toInt()} px wide window', (tester) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      repository
        ..addGame(savedGame('Alice ' * 10))
        ..addGame(savedGame('Nemo', status: GameStatus.defeat, turn: 27))
        ..addGame(savedGame('Cousteau', status: GameStatus.victory));
      await tester.pumpWidget(loadGameApp(repository));

      expect(tester.takeException(), isNull);
      final cardWidth = tester.getSize(find.byType(SaveCard).first).width;
      expect(cardWidth, lessThanOrEqualTo(560));
      final center = tester.getCenter(find.byType(SaveCard).first).dx;
      expect(center, moreOrLessEquals(size.width / 2, epsilon: 1));
    });
  }
}
