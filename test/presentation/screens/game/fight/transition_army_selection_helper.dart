import 'package:abyss/domain/action/attack_transition_base_result.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/transition_army_selection_screen.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_game_repository.dart';
import '../../../../helpers/test_svg_helper.dart';
import '../../../../helpers/transition_fight_fixtures.dart';
import '../../../../integration/transition_test_helper.dart';

const admiralWarning = 'Un Amiral des Abysses est requis pour lancer l\'assaut';

/// The Faille of the transition scenario.
TransitionBase faille(Game game) =>
    game.levels[1]!.cellAt(kFailleX, kFailleY).transitionBase!;

/// The army selection screen opened on the Faille of a game, with the
/// repository it saves to and the count of changes it notified.
class ArmySelectionHarness {
  final FakeGameRepository repo = FakeGameRepository();
  int changedCount = 0;

  /// What the screen returned once launched, if it did.
  AttackTransitionBaseResult? result;

  Future<void> pump(WidgetTester tester, Game game) async {
    useTallView(tester);
    await tester.pumpWidget(buildLauncherHost('open', (ctx) async {
      result = await Navigator.of(ctx)
          .push(MaterialPageRoute<AttackTransitionBaseResult>(
        builder: (_) => TransitionArmySelectionScreen(
          game: game,
          repository: repo,
          targetX: kFailleX,
          targetY: kFailleY,
          level: 1,
          transitionBase: faille(game),
          onChanged: () => changedCount++,
        ),
      ));
    }));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }
}

Future<void> select(WidgetTester tester, UnitType type, int count) async {
  final row = find.byWidgetPredicate(
    (w) => w is UnitQuantityRow && w.type == type,
  );
  tester.widget<UnitQuantityRow>(row).onChanged(count);
  await tester.pumpAndSettle();
}

/// Adds one admiral with the + of its row.
Future<void> addAdmiral(WidgetTester tester) async {
  await tester.tap(find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is UnitQuantityRow && w.type == UnitType.abyssAdmiral,
    ),
    matching: find.byIcon(Icons.add),
  ));
  await tester.pumpAndSettle();
}

ElevatedButton launchButton(WidgetTester tester) => tester.widget(
      find.widgetWithText(ElevatedButton, 'Lancer l\'assaut'),
    );

void mockSvgs() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);
}
