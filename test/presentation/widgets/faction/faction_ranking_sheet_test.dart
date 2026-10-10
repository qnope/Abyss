import 'package:abyss/domain/faction/faction_standing.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/presentation/widgets/common/settings_dialog.dart';
import 'package:abyss/presentation/widgets/common/status_pill.dart';
import 'package:abyss/presentation/widgets/faction/faction_ranking_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/sheet_opener.dart';

Game _game(int factions) => GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 7,
      factionCount: factions,
    );

void main() {
  testWidgets('the ranking lists the human and every faction', (tester) async {
    final game = _game(3);
    await openSheet(
      tester,
      const Locale('fr'),
      (context) => showFactionRankingSheet(context, game),
    );
    expect(find.text('Classement des factions'), findsOneWidget);
    expect(find.text('Nemo (Vous)'), findsOneWidget);
    for (final faction in game.factions) {
      expect(find.text(faction.name), findsOneWidget);
    }
    expect(find.textContaining('Profondeur : niveau 1'), findsNWidgets(4));
    expect(find.byType(StatusPill), findsNothing);
  });

  testWidgets('a fallen faction is marked', (tester) async {
    final game = _game(2);
    game.players[game.factions.first.id]!.savedFallen = true;
    await tester.pumpWidget(localizedApp(Scaffold(
      body: FactionRankingSheetBody(standings: FactionStanding.ranking(game)),
    )));
    expect(find.byType(StatusPill), findsOneWidget);
    expect(find.text('TOMBÉE'), findsOneWidget);
  });

  group('the settings entry', () {
    Future<void> openSettings(WidgetTester tester, Game game) => openSheet(
          tester,
          const Locale('fr'),
          (context) => showSettingsDialog(
            context,
            game: game,
            repository: FakeGameRepository(),
          ),
        );

    testWidgets('is offered when the game has factions', (tester) async {
      await openSettings(tester, _game(2));
      expect(find.text('Classement'), findsOneWidget);
    });

    testWidgets('is absent from a solo game', (tester) async {
      await openSettings(tester, _game(0));
      expect(find.text('Classement'), findsNothing);
    });
  });
}
