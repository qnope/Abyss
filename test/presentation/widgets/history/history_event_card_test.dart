import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/extensions/history_entry_category_extensions.dart';
import 'package:abyss/presentation/extensions/history_entry_extensions.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/history/history_entry_card.dart';
import 'package:abyss/presentation/widgets/history/history_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

EventEntry _caravan() => EventEntry(
  turn: 6,
  type: RandomEventType.caravan,
  accepted: false,
  defaulted: true,
);

RaidEntry _raid({required bool surprise}) => RaidEntry(
  turn: 12,
  victory: true,
  wave: const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 4),
  fightResult: buildTestFight(playerWins: true),
  loot: const {},
  pillaged: const {},
  defenders: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
  rampartLevel: 0,
  surprise: surprise,
);

void main() {
  final theme = AbyssTheme.create();

  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> showCard(WidgetTester tester, HistoryEntry entry) =>
      tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(body: HistoryEntryCard(entry: entry)),
      ));

  String? artOf(WidgetTester tester) {
    final art = find.byType(RasterSvg);
    if (art.evaluate().isEmpty) return null;
    return tester.widget<RasterSvg>(art).assetPath;
  }

  test('an event entry is titled after its event', () {
    expect(_caravan().displayTitle(fr), 'Caravane de tortues');
    expect(_caravan().displayTitle(en), 'Turtle Caravan');
  });

  test('other entries keep their own title', () {
    final entry = ExploreEntry(turn: 1, targetX: 3, targetY: 4);
    expect(entry.displayTitle(en), entry.title);
  });

  test('an event entry takes its category color and is not tappable', () {
    final entry = _caravan();
    expect(entry.accentColor(theme), entry.category.backgroundColor(theme));
    expect(entry.isTappable, isFalse);
  });

  test('the « Événements » filter keeps the events and the predators', () {
    final raid = _raid(surprise: false);
    final predators = _raid(surprise: true);
    final entries = <HistoryEntry>[_caravan(), raid, predators];
    expect(HistoryFilter.event.label, 'Événements');
    expect(applyHistoryFilter(entries, HistoryFilter.event), [
      entries.first,
      predators,
    ]);
    expect(applyHistoryFilter(entries, HistoryFilter.other), isEmpty);
    expect(applyHistoryFilter(entries, HistoryFilter.combat), [
      raid,
      predators,
    ]);
  });

  testWidgets('the card shows the event art, name and choice', (
    tester,
  ) async {
    await showCard(tester, _caravan());
    expect(find.text('Caravane de tortues'), findsOneWidget);
    expect(find.text('Option prudente, sans choix'), findsOneWidget);
    expect(find.text('Tour 6'), findsOneWidget);
    expect(artOf(tester), RandomEventType.caravan.illustration);
    expect(find.byIcon(Icons.auto_awesome), findsNothing);
  });

  testWidgets('a predators fight shows the predators art', (tester) async {
    await showCard(tester, _raid(surprise: true));
    expect(find.text('Banc de prédateurs repoussé'), findsOneWidget);
    expect(artOf(tester), RandomEventType.predators.illustration);
  });

  testWidgets('a plain raid keeps its category icon', (tester) async {
    await showCard(tester, _raid(surprise: false));
    expect(artOf(tester), isNull);
    expect(find.byIcon(Icons.warning_amber), findsOneWidget);
  });
}
