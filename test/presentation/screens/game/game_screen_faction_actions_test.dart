import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/base_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/faction/faction_base_sheet.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/faction_attack_harness.dart';
import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart' show useTallView;

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> tapFactionBase(WidgetTester tester, Game game) async {
    useTallView(tester);
    final p = factionPlayer(game);
    await tapMapCell(tester, p.baseX, p.baseY);
  }

  testWidgets('tapping a faction base opens its sheet', (tester) async {
    final game = factionAttackGame();
    await tester.pumpWidget(factionMapHost(game));
    await tapFactionBase(tester, game);

    expect(find.byType(FactionBaseSheet), findsOneWidget);
    expect(find.text(firstFaction(game).name), findsOneWidget);
    expect(find.text('Quartier général'), findsOneWidget);
    expect(find.text('Attaquer'), findsOneWidget);
    final attack = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Attaquer'),
    );
    expect(attack.onPressed, isNotNull);
  });

  testWidgets('a base in the fog still starts an exploration, not a sheet',
      (tester) async {
    final game = factionAttackGame(revealed: false);
    await tester.pumpWidget(factionMapHost(game));
    await tapFactionBase(tester, game);

    expect(find.byType(FactionBaseSheet), findsNothing);
  });

  testWidgets('before turn 10 the attack is refused with the reason',
      (tester) async {
    final game = factionAttackGame(turn: 5);
    await tester.pumpWidget(factionMapHost(game));
    await tapFactionBase(tester, game);

    expect(find.text('Trop tôt pour attaquer une base'), findsOneWidget);
    final attack = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Attaquer'),
    );
    expect(attack.onPressed, isNull);
  });

  testWidgets('the attack button leads to the army selection',
      (tester) async {
    final game = factionAttackGame();
    await tester.pumpWidget(factionMapHost(game));
    await tapFactionBase(tester, game);
    await tester.tap(find.text('Attaquer'));
    await tester.pumpAndSettle();

    expect(find.byType(BaseArmySelectionScreen), findsOneWidget);
    expect(find.text('Assaut : ${factionPlayer(game).name}'), findsOneWidget);
    expect(find.byType(UnitQuantityRow), findsWidgets);
  });

  testWidgets('launching runs the action, saves and shows the report',
      (tester) async {
    final game = factionAttackGame();
    final repo = FakeGameRepository();
    var changed = 0;
    await tester.pumpWidget(
      factionMapHost(game, repository: repo, onChanged: () => changed++),
    );
    await tapFactionBase(tester, game);
    await tester.tap(find.text('Attaquer'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is UnitQuantityRow && w.type == UnitType.harpoonist,
      ),
      matching: find.byIcon(Icons.add),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Lancer l'assaut"));
    await tester.pumpAndSettle();

    expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
    expect(
      game.humanPlayer.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
    expect(
      factionPlayer(game).historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
    expect(repo.saveCallCount, greaterThan(0));
    expect(changed, 1);
  });

  testWidgets('launch stays off until some units are picked', (tester) async {
    final game = factionAttackGame();
    await tester.pumpWidget(factionMapHost(game));
    await tapFactionBase(tester, game);
    await tester.tap(find.text('Attaquer'));
    await tester.pumpAndSettle();

    final launch = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, "Lancer l'assaut"),
    );
    expect(launch.onPressed, isNull);
  });

  testWidgets('a cell next to the faction base opens no faction sheet',
      (tester) async {
    final game = factionAttackGame();
    await tester.pumpWidget(factionMapHost(game));
    useTallView(tester);
    final p = factionPlayer(game);
    game.humanPlayer.addRevealedCell(
      1,
      GridPosition(x: p.baseX + 1, y: p.baseY),
    );
    await tapMapCell(tester, p.baseX + 1, p.baseY);

    expect(find.byType(FactionBaseSheet), findsNothing);
  });

  testWidgets('without factions the map taps are unchanged', (tester) async {
    final game = harnessGame(plainMap());
    await tester.pumpWidget(mapTabHost(game));
    await tapMapCell(tester, 2, 2);

    expect(find.byType(FactionBaseSheet), findsNothing);
    expect(find.text("Il n'y a rien à voir ici"), findsOneWidget);
  });
}
