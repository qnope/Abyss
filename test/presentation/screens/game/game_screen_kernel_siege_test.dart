import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/base_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:abyss/presentation/widgets/map/rival_post_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/faction_attack_harness.dart';
import '../../../helpers/kernel_war_helper.dart';
import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart' show useTallView;
import '../../../helpers/reduced_motion.dart';

KernelWar _siege({int turn = 12}) {
  final war = KernelWar(kernelLevel: 0);
  war.game.turn = turn;
  war.human.addRevealedCell(3, war.at);
  war.put(war.human, 3, {UnitType.harpoonist: 60});
  return war;
}

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('tapping a kernel a faction holds offers to attack it', (
    tester,
  ) async {
    final war = _siege();
    await tester.pumpWidget(factionMapHost(war.game, level: 3));
    useTallView(tester);
    await tapMapCell(tester, war.at.x, war.at.y);

    expect(find.byType(RivalPostSheet), findsOneWidget);
    expect(find.text('Tenue par ${war.owner.name}'), findsOneWidget);
    final attack = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Attaquer'),
    );
    expect(attack.onPressed, isNotNull);
  });

  testWidgets('before turn 10 the siege is refused with the reason', (
    tester,
  ) async {
    final war = _siege(turn: 5);
    await tester.pumpWidget(factionMapHost(war.game, level: 3));
    useTallView(tester);
    await tapMapCell(tester, war.at.x, war.at.y);

    expect(find.text('Trop tôt pour attaquer une base'), findsOneWidget);
  });

  testWidgets('launching takes the kernel, saves and shows the report', (
    tester,
  ) async {
    final war = _siege();
    final repo = FakeGameRepository();
    await tester.pumpWidget(factionMapHost(war.game, repository: repo, level: 3));
    useTallView(tester);
    await tapMapCell(tester, war.at.x, war.at.y);
    await tester.tap(find.text('Attaquer'));
    await tester.pumpAndSettle();
    expect(find.byType(BaseArmySelectionScreen), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is UnitQuantityRow && w.type == UnitType.harpoonist,
        ),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Lancer l'assaut"));
    await tester.pumpAndSettle();

    expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
    expect(war.holder, war.human.id);
    final mine =
        war.human.historyEntries.whereType<BaseAssaultEntry>().single;
    expect(mine.postName, 'volcanicKernel');
    expect(repo.saveCallCount, greaterThan(0));
  });
}
