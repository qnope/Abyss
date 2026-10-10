import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/base_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:abyss/presentation/widgets/map/rival_post_sheet.dart';
import 'package:abyss/presentation/widgets/map/transition_base_captured_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/faction_attack_harness.dart';
import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/post_map_harness.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart' show useTallView;

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('tapping a post held by a rival offers to attack it', (
    tester,
  ) async {
    final s = postGame();
    await tester.pumpWidget(factionMapHost(s.game));
    useTallView(tester);
    await tapMapCell(tester, s.at.x, s.at.y);

    expect(find.byType(RivalPostSheet), findsOneWidget);
    expect(find.byType(TransitionBaseCapturedSection), findsNothing);
    expect(find.text('Tenue par ${s.owner.name}'), findsOneWidget);
    final attack = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Attaquer'),
    );
    expect(attack.onPressed, isNotNull);
  });

  testWidgets(
    'before turn 10 the attack on a post is refused with the reason',
    (tester) async {
      final s = postGame(turn: 5);
      await tester.pumpWidget(factionMapHost(s.game));
      useTallView(tester);
      await tapMapCell(tester, s.at.x, s.at.y);

      expect(find.text('Trop tôt pour attaquer une base'), findsOneWidget);
      final attack = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Attaquer'),
      );
      expect(attack.onPressed, isNull);
    },
  );

  testWidgets('a post of the human keeps the descent sheet', (tester) async {
    final s = postGame();
    s.post.capturedBy = s.game.humanPlayer.id;
    await tester.pumpWidget(factionMapHost(s.game));
    useTallView(tester);
    await tapMapCell(tester, s.at.x, s.at.y);

    expect(find.byType(RivalPostSheet), findsNothing);
    expect(find.byType(TransitionBaseCapturedSection), findsOneWidget);
  });

  testWidgets('launching takes the post, saves and shows the report', (
    tester,
  ) async {
    final s = postGame();
    final repo = FakeGameRepository();
    var changed = 0;
    await tester.pumpWidget(
      factionMapHost(s.game, repository: repo, onChanged: () => changed++),
    );
    useTallView(tester);
    await tapMapCell(tester, s.at.x, s.at.y);
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
    expect(s.post.capturedBy, s.game.humanPlayer.id);
    expect(s.owner.buildings[BuildingType.descentModule]!.level, 0);
    final mine =
        s.game.humanPlayer.historyEntries.whereType<BaseAssaultEntry>().single;
    expect(mine.postName, s.post.name);
    expect(s.owner.historyEntries.whereType<BaseAssaultEntry>(), hasLength(1));
    expect(repo.saveCallCount, greaterThan(0));
    expect(changed, 1);
  });
}
