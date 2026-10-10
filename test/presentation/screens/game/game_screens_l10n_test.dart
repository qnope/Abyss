import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game_statistics.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/game/defeat_screen.dart';
import 'package:abyss/presentation/screens/game/descent_dialog.dart';
import 'package:abyss/presentation/screens/game/game_screen_collect_messages.dart';
import 'package:abyss/presentation/screens/game/game_screen_troops_actions.dart';
import 'package:abyss/presentation/screens/game/reinforcement_dialog.dart';
import 'package:abyss/presentation/screens/game/victory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../integration/transition_test_helper.dart';

const _statistics = GameStatistics(
  turnsPlayed: 27,
  monstersDefeated: 40,
  basesCaptured: 1,
  totalResourcesCollected: 5000,
  raidsRepelled: 2,
  raidsLost: 4,
);

final _units = {UnitType.scout: Unit(type: UnitType.scout, count: 3)};

Future<void> _openDialog(WidgetTester t, Widget dialog, Locale locale) async {
  await t.pumpWidget(localizedApp(
    Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showDialog<void>(
            context: ctx,
            builder: (_) => dialog,
          ),
          child: const Text('open'),
        ),
      ),
    ),
    locale: locale,
  ));
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('the defeat in English', (t) async {
    await t.pumpWidget(localizedApp(
      DefeatScreen(
        statistics: _statistics,
        fallTurn: 26,
        onReturnToMenu: () {},
        onExport: () {},
      ),
      locale: AbyssLocale.en,
    ));
    expect(find.text('DEFEAT'), findsOneWidget);
    expect(
      find.text('Your base fell at the end of turn 26, after 3 raids lost '
          'in a row.'),
      findsOneWidget,
    );
    expect(find.text('Back to menu'), findsOneWidget);
    expect(find.text('Export the game'), findsOneWidget);
    expect(find.text('Turns played: 27'), findsOneWidget);
    expect(find.text('Raids lost: 4'), findsOneWidget);
  });

  testWidgets('the victory in Spanish', (t) async {
    await t.pumpWidget(localizedApp(
      VictoryScreen(
        statistics: _statistics,
        onContinue: () {},
        onReturnToMenu: () {},
      ),
      locale: AbyssLocale.es,
    ));
    expect(find.text('¡VICTORIA!'), findsOneWidget);
    expect(find.text('¡Has conquistado el Núcleo Volcánico!'), findsOneWidget);
    expect(find.text('Continuar en modo libre'), findsOneWidget);
    expect(find.text('Monstruos vencidos: 40'), findsOneWidget);
  });

  testWidgets('the descent in English', (t) async {
    await _openDialog(
      t,
      DescentDialog(
        availableUnits: _units,
        targetLevel: 2,
        transitionBaseName: 'Alpha Rift',
        onConfirm: (_) {},
      ),
      AbyssLocale.en,
    );
    expect(find.text('Descent to Level 2'), findsOneWidget);
    expect(find.textContaining('the descent is final'), findsOneWidget);
    expect(find.text('Descend (0 units)'), findsOneWidget);
    await t.tap(find.byIcon(Icons.add).first);
    await t.pump();
    expect(find.text('Descend (1 unit)'), findsOneWidget);
  });

  testWidgets('the reinforcements in Spanish', (t) async {
    await _openDialog(
      t,
      ReinforcementDialog(
        availableUnits: _units,
        targetLevel: 3,
        transitionBaseName: 'Chimenea Primaria',
        onConfirm: (_) {},
      ),
      AbyssLocale.es,
    );
    expect(find.text('Refuerzos hacia el Nivel 3'), findsOneWidget);
    expect(find.text('Los refuerzos llegarán el próximo turno.'),
        findsOneWidget);
    expect(find.text('Enviar (0 unidades)'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  test('the collect messages in each language', () {
    expect(titleFor(fr, CellContentType.wreck), 'Épave fouillée !');
    expect(titleFor(en, CellContentType.ruins), 'Ruins searched!');
    expect(emptyMessageFor(es, CellContentType.wreck),
        'El pecio estaba vacío...');
    expect(emptyMessageFor(fr, CellContentType.resourceBonus),
        'Rien à récupérer ici...');
  });

  testWidgets('the descent through a captured base in Spanish', (t) async {
    final game = buildTransitionScenario().game;
    game.levels = {1: buildMapWithFaille(capturedBy: 'player-1')};
    await t.pumpWidget(localizedApp(
      Scaffold(
        body: Builder(
          builder: (ctx) => troopsSectionFor(
            ctx,
            game,
            FakeGameRepository(),
            Building(type: BuildingType.descentModule, level: 1),
            () {},
          )!,
        ),
      ),
      locale: AbyssLocale.es,
    ));
    expect(find.text('Bajar tropas por Falla Alfa'), findsOneWidget);
  });
}
