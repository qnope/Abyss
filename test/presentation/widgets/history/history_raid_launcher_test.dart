import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/raid/raid_summary_screen.dart';
import 'package:abyss/presentation/widgets/history/history_raid_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  RaidEntry buildEntry({required bool victory, int rampartLevel = 2}) {
    return RaidEntry(
      turn: 7,
      victory: victory,
      wave: const MonsterLair(
        difficulty: MonsterDifficulty.medium,
        unitCount: 4,
      ),
      fightResult: buildTestFight(playerWins: victory),
      loot: const {ResourceType.algae: 30},
      pillaged: const {ResourceType.coral: 15},
      defenders: const {UnitType.harpoonist: 3},
      survivorsIntact: const {UnitType.harpoonist: 2},
      wounded: const {UnitType.harpoonist: 1},
      dead: const {},
      rampartLevel: rampartLevel,
    );
  }

  Future<void> launch(WidgetTester tester, RaidEntry entry) async {
    useTallView(tester);
    await tester.pumpWidget(buildLauncherHost(
      'open',
      (ctx) => openRaidSummaryFromEntry(ctx, entry),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('openRaidSummaryFromEntry', () {
    testWidgets('opens the raid report for the entry turn', (tester) async {
      await launch(tester, buildEntry(victory: true));
      final screen =
          tester.widget<RaidSummaryScreen>(find.byType(RaidSummaryScreen));
      expect(find.text('Raid sur la base (tour 7)'), findsOneWidget);
      expect(screen.report.turn, 7);
      expect(screen.report.victory, isTrue);
      expect(screen.report.wave.unitCount, 4);
      expect(screen.report.loot, {ResourceType.algae: 30});
    });

    testWidgets('carries over every persisted field', (tester) async {
      final entry = buildEntry(victory: false, rampartLevel: 3);
      await launch(tester, entry);
      final report =
          tester.widget<RaidSummaryScreen>(find.byType(RaidSummaryScreen))
              .report;
      expect(report.victory, isFalse);
      expect(report.fight, same(entry.fightResult));
      expect(report.rampartLevel, 3);
      expect(report.defenders, entry.defenders);
      expect(report.survivorsIntact, entry.survivorsIntact);
      expect(report.wounded, entry.wounded);
      expect(report.dead, entry.dead);
      expect(report.pillaged, entry.pillaged);
      expect(find.text('Rempart de la Citadelle niv. 3'), findsOneWidget);
    });

    testWidgets('returned future completes when the report is closed',
        (tester) async {
      var closed = false;
      useTallView(tester);
      await tester.pumpWidget(buildLauncherHost('open', (ctx) {
        openRaidSummaryFromEntry(ctx, buildEntry(victory: true))
            .then((_) => closed = true);
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(closed, isFalse);

      await tester.tap(find.text('Retour à la base'));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      expect(find.byType(RaidSummaryScreen), findsNothing);
    });
  });
}
