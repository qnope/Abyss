import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/common/game_bottom_bar.dart';
import 'package:abyss/presentation/widgets/common/replay_export_dialog.dart';
import 'package:abyss/presentation/widgets/common/settings_dialog.dart';
import 'package:abyss/presentation/widgets/common/tab_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/localized_app.dart';

Future<void> _show(WidgetTester t, Widget child, Locale locale) =>
    t.pumpWidget(localizedApp(Scaffold(body: child), locale: locale));

void main() {
  testWidgets('the bottom bar in English', (t) async {
    await t.pumpWidget(localizedApp(
      Scaffold(
        bottomNavigationBar: GameBottomBar(
          currentTab: 0,
          turnNumber: 7,
          onTabChanged: (_) {},
          onNextTurn: () {},
          onSettings: () {},
        ),
      ),
      locale: AbyssLocale.en,
    ));
    expect(find.text('Turn 7'), findsOneWidget);
    expect(find.text('Next turn'), findsOneWidget);
    for (final tab in ['Base', 'Map', 'Army', 'Tech']) {
      expect(find.text(tab), findsOneWidget);
    }
    expect(find.byTooltip('Settings'), findsOneWidget);
  });

  testWidgets('the settings in Spanish', (t) async {
    final game = Game.singlePlayer(Player(name: 'Nemo'));
    await _show(
      t,
      Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showSettingsDialog(
            ctx,
            game: game,
            repository: FakeGameRepository(),
          ),
          child: const Text('Open'),
        ),
      ),
      AbyssLocale.es,
    );
    await t.tap(find.text('Open'));
    await t.pumpAndSettle();
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Partida en curso'), findsOneWidget);
    expect(find.text('Guía del tutorial'), findsOneWidget);
    expect(find.text('Consejos'), findsOneWidget);
    expect(find.text('Volver a ver las fichas'), findsOneWidget);
    expect(find.text('Ver el historial'), findsOneWidget);
    expect(find.text('Exportar la partida'), findsOneWidget);
    expect(find.text('Guardar y salir'), findsOneWidget);
  });

  testWidgets('the replay export in English', (t) async {
    final game = GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 1);
    await _show(t, ReplayExportDialog(game: game), AbyssLocale.en);
    expect(find.textContaining('over 1 turn played.'), findsOneWidget);
    expect(find.textContaining('exactly the same'), findsOneWidget);
    expect(find.text('Share the file'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('an old game cannot be exported, in Spanish', (t) async {
    final game = GameFactory.newSinglePlayer(playerName: 'Nemo')
      ..replay = null;
    await _show(t, ReplayExportDialog(game: game), AbyssLocale.es);
    expect(find.textContaining('no se puede exportar'), findsOneWidget);
  });

  testWidgets('a tab still to come in English', (t) async {
    await _show(
      t,
      const TabPlaceholder(icon: Icons.science, label: 'Tech'),
      AbyssLocale.en,
    );
    expect(find.text('Coming soon'), findsOneWidget);
  });
}
