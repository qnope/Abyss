import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/base_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_fight_summary_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect_painter.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/faction_attack_harness.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/volcano_fight_fixtures.dart';

/// Lets routes and sheets come and go while the sea keeps moving.
Future<void> _wait(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _select(WidgetTester tester, UnitType type, int count) async {
  tester.widget<UnitQuantityRow>(find.byWidgetPredicate(
    (w) => w is UnitQuantityRow && w.type == type,
  )).onChanged(count);
  await tester.pump();
}

/// Opens [game] on its map, taps ([x], [y]) and presses [attack].
Future<void> _open(WidgetTester tester, Game game, (int, int) cell,
    String attack) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AbyssTheme.create(),
    home: GameScreen(game: game, repository: FakeGameRepository()),
  ));
  await _wait(tester);
  await tester.tap(find.text('Carte'));
  await _wait(tester);
  tester.widget<GameMapView>(find.byType(GameMapView))
      .onCellTap!(cell.$1, cell.$2);
  await _wait(tester);
  final button = find.text(attack).last;
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await _wait(tester);
}

Future<void> _launch(WidgetTester tester) async {
  final launch = find.widgetWithText(ElevatedButton, 'Lancer l\'assaut');
  await tester.ensureVisible(launch);
  await tester.pump();
  await tester.tap(launch);
  await tester.pump();
}

/// Assaults the base of the first faction from the map.
Future<void> _assaultBase(WidgetTester tester) async {
  final game = factionAttackGame();
  final base = factionPlayer(game);
  await _open(tester, game, (base.baseX, base.baseY), 'Attaquer');
  await _select(tester, UnitType.harpoonist, 40);
  await _launch(tester);
}

/// Assaults the free volcano from the map.
Future<void> _assaultVolcano(WidgetTester tester) async {
  await _open(
      tester, volcanoFightGame(), volcanoFightCell, 'Lancer l\'assaut');
  await _select(tester, UnitType.abyssAdmiral, 1);
  await _select(tester, UnitType.domeBreaker, 30);
  await _launch(tester);
}

bool _strikeShown(WidgetTester tester) => find
    .byWidgetPredicate((w) => w is CustomPaint && w.painter is MapEffectPainter)
    .evaluate()
    .isNotEmpty;

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  for (final (name, assault, selection, report) in [
    ('a rival base', _assaultBase, BaseArmySelectionScreen,
        BaseAssaultSummaryScreen),
    ('the volcano', _assaultVolcano, KernelArmySelectionScreen,
        KernelFightSummaryScreen),
  ]) {
    group('an assault on $name', () {
      testWidgets('plays on the map before its report opens', (tester) async {
        await assault(tester);
        await _wait(tester);
        expect(find.byType(selection), findsNothing);
        expect(find.byType(report), findsNothing);
        expect(_strikeShown(tester), isTrue);
        for (var i = 0; i < 8; i++) {
          await _wait(tester);
        }
        expect(find.byType(report), findsOneWidget);
      });

      testWidgets('ends at once on a tap on the map', (tester) async {
        await assault(tester);
        await _wait(tester);
        await tester.tapAt(tester.getCenter(find.byType(GameMapView)));
        await _wait(tester);
        expect(find.byType(report), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);
      });

      testWidgets('opens its report at once with reduced motion',
          (tester) async {
        reduceMotion(tester);
        await assault(tester);
        await tester.pumpAndSettle();
        expect(find.byType(report), findsOneWidget);
      });
    });
  }
}
