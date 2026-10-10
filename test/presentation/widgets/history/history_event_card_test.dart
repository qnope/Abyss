import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/presentation/extensions/history_entry_category_extensions.dart';
import 'package:abyss/presentation/extensions/history_entry_extensions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/history/history_entry_card.dart';
import 'package:abyss/presentation/widgets/history/history_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

EventEntry _wreck() => EventEntry(
  turn: 6,
  type: RandomEventType.wreck,
  accepted: false,
  defaulted: true,
);

void main() {
  final theme = AbyssTheme.create();

  test('an event entry is titled after its event', () {
    expect(_wreck().displayTitle, 'Épave');
  });

  test('other entries keep their own title', () {
    final entry = ExploreEntry(turn: 1, targetX: 3, targetY: 4);
    expect(entry.displayTitle, entry.title);
  });

  test('an event entry takes its category color and is not tappable', () {
    final entry = _wreck();
    expect(entry.accentColor(theme), entry.category.backgroundColor(theme));
    expect(entry.isTappable, isFalse);
  });

  test('the « other » filter keeps the events', () {
    final entries = <HistoryEntry>[_wreck()];
    expect(applyHistoryFilter(entries, HistoryFilter.other), entries);
    expect(applyHistoryFilter(entries, HistoryFilter.combat), isEmpty);
  });

  testWidgets('the card shows the event name and the choice', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(body: HistoryEntryCard(entry: _wreck())),
      ),
    );

    expect(find.text('Épave'), findsOneWidget);
    expect(find.text('Option prudente, sans choix'), findsOneWidget);
    expect(find.text('Tour 6'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });
}
