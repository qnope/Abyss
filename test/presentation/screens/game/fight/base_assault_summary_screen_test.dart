import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/history/history_assault_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_svg_helper.dart';
import '../../../../helpers/transition_fight_fixtures.dart';

BaseAssaultEntry _entry({required bool victory, required bool defending}) =>
    BaseAssaultEntry(
      turn: 14,
      victory: victory,
      defending: defending,
      opponentName: 'Nacre',
      fightResult: buildTestFight(playerWins: victory),
      units: const {UnitType.harpoonist: 6},
      survivorsIntact: const {UnitType.harpoonist: 4},
      wounded: const {UnitType.harpoonist: 1},
      dead: const {UnitType.harpoonist: 1},
      rampartBefore: 3,
      rampartAfter: 1,
      headquartersBefore: 5,
      headquartersAfter: 5,
      pillaged: const {ResourceType.coral: 21},
      loot: const {ResourceType.coral: 15},
    );

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> show(WidgetTester tester, BaseAssaultEntry entry) async {
    useTallView(tester);
    await tester.pumpWidget(buildLauncherHost(
      'open',
      (ctx) => openAssaultSummaryFromEntry(ctx, entry),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a won attack tells the damage, the loot and the casualties',
      (tester) async {
    await show(tester, _entry(victory: true, defending: false));

    expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
    expect(find.text('VICTOIRE'), findsOneWidget);
    expect(find.text('Vous avez attaqué Nacre'), findsOneWidget);
    expect(find.text('Rempart : niveau 3 → 1'), findsOneWidget);
    expect(find.textContaining('QG : niveau'), findsNothing);
    expect(find.text('Défenseurs mis hors de combat : 4/4'), findsOneWidget);
    expect(find.textContaining('+15'), findsOneWidget);
  });

  testWidgets('a lost attack shows no damage and no loot', (tester) async {
    await show(tester, _entry(victory: false, defending: false));

    expect(find.text('DÉFAITE'), findsOneWidget);
    expect(find.textContaining('Rempart'), findsNothing);
    expect(find.textContaining('+15'), findsNothing);
  });

  testWidgets('the defender reads the same fight from its side',
      (tester) async {
    await show(tester, _entry(victory: true, defending: true));

    expect(find.text('DÉFAITE'), findsOneWidget);
    expect(find.text('Nacre vous a attaqué'), findsOneWidget);
    expect(find.text('Rempart : niveau 3 → 1'), findsOneWidget);
    expect(find.textContaining('-21'), findsOneWidget);
  });

  testWidgets('a repelled attack is a victory for the defender',
      (tester) async {
    await show(tester, _entry(victory: false, defending: true));

    expect(find.text('VICTOIRE'), findsOneWidget);
  });

  testWidgets('a won attack that broke nothing says the base held',
      (tester) async {
    final intact = _entry(victory: true, defending: false);
    await show(
      tester,
      BaseAssaultEntry(
        turn: intact.turn,
        victory: true,
        defending: false,
        opponentName: 'Nacre',
        fightResult: intact.fightResult,
        units: intact.units,
        survivorsIntact: intact.survivorsIntact,
        wounded: intact.wounded,
        dead: intact.dead,
        rampartBefore: 0,
        rampartAfter: 0,
        headquartersBefore: 1,
        headquartersAfter: 1,
        pillaged: const {},
        loot: const {},
      ),
    );
    expect(find.text('La base tient bon'), findsOneWidget);
  });
}
