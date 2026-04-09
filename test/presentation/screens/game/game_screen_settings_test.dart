import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/screens/menu/main_menu_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/history/history_sheet_body.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('GameScreen settings dialog', () {
    late Game game;
    late FakeGameRepository repository;

    setUp(() {
      mockSvgAssets();
      final gen = MapGenerator.generate(seed: 1);
      final player = Player.withBase(
        name: 'Nemo',
        baseX: gen.baseX,
        baseY: gen.baseY,
        mapWidth: gen.map.width,
        mapHeight: gen.map.height,
      );
      player.historyEntries.add(
        BuildingEntry(
          turn: 1,
          buildingType: BuildingType.algaeFarm,
          newLevel: 2,
        ),
      );
      game = Game.singlePlayer(player)..gameMap = gen.map;
      repository = FakeGameRepository();
    });

    tearDown(() => clearSvgMocks());

    Widget createApp() => MaterialApp(
      theme: AbyssTheme.create(),
      home: GameScreen(game: game, repository: repository),
    );

    testWidgets(
        'tapping Voir l\'historique opens the history sheet without leaving '
        'the game', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Parametres'), findsOneWidget);

      await tester.tap(find.text('Voir l\'historique'));
      await tester.pumpAndSettle();

      expect(find.byType(HistorySheetBody), findsOneWidget);
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(MainMenuScreen), findsNothing);
      expect(repository.saveCallCount, 0);
    });

    testWidgets(
        'tapping Sauvegarder et quitter saves and navigates to main menu',
        (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sauvegarder et quitter'));
      await tester.pumpAndSettle();

      expect(repository.saveCallCount, 1);
      expect(find.byType(MainMenuScreen), findsOneWidget);
      expect(find.byType(GameScreen), findsNothing);
    });

    testWidgets('tapping Annuler closes dialog without effect',
        (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Parametres'), findsNothing);
      expect(find.byType(HistorySheetBody), findsNothing);
      expect(find.byType(MainMenuScreen), findsNothing);
      expect(repository.saveCallCount, 0);
    });
  });
}
