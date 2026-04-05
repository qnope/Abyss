import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/saved_game_card.dart';

void main() {
  group('SavedGameCard', () {
    late Game game;

    setUp(() {
      game = Game(
        player: Player(name: 'Alice'),
        turn: 7,
        createdAt: DateTime(2026, 1, 15, 10, 30),
      );
    });

    Widget createApp({
      VoidCallback? onLoad,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: SavedGameCard(
            game: game,
            onLoad: onLoad ?? () {},
            onDelete: onDelete ?? () {},
          ),
        ),
      );
    }

    testWidgets('displays player name', (tester) async {
      await tester.pumpWidget(createApp());
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('displays turn number', (tester) async {
      await tester.pumpWidget(createApp());
      expect(find.text('Tour 7'), findsOneWidget);
    });

    testWidgets('displays formatted date', (tester) async {
      await tester.pumpWidget(createApp());
      expect(find.text('15/01/2026 10:30'), findsOneWidget);
    });

    testWidgets('calls onLoad when tapped', (tester) async {
      var loaded = false;
      await tester.pumpWidget(createApp(onLoad: () => loaded = true));

      await tester.tap(find.text('Alice'));
      expect(loaded, isTrue);
    });

    testWidgets('calls onDelete when delete pressed', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        createApp(onDelete: () => deleted = true),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });
  });
}
