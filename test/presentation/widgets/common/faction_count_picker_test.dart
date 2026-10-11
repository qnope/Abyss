import 'package:abyss/presentation/widgets/common/faction_count_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

void main() {
  Future<List<int>> pump(
    WidgetTester tester,
    int count, {
    String lang = 'fr',
  }) async {
    final changes = <int>[];
    await tester.pumpWidget(
      localizedApp(
        locale: Locale(lang),
        Scaffold(
          body: FactionCountPicker(count: count, onChanged: changes.add),
        ),
      ),
    );
    return changes;
  }

  testWidgets('shows the title, the count and what it means', (tester) async {
    await pump(tester, 3);
    expect(find.text('Factions rivales'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.textContaining('3 factions'), findsOneWidget);
  });

  testWidgets('says so when there is none', (tester) async {
    await pump(tester, 0);
    expect(find.textContaining('Aucune'), findsOneWidget);
  });

  testWidgets('adds and removes one faction at a time', (tester) async {
    final changes = await pump(tester, 3);
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.remove));
    expect(changes, [4, 2]);
  });

  testWidgets('stops at 10 and at 0', (tester) async {
    var changes = await pump(tester, 10);
    await tester.tap(find.byIcon(Icons.add));
    expect(changes, isEmpty);
    changes = await pump(tester, 0);
    await tester.tap(find.byIcon(Icons.remove));
    expect(changes, isEmpty);
  });

  testWidgets('speaks english', (tester) async {
    await pump(tester, 1, lang: 'en');
    expect(find.text('Rival factions'), findsOneWidget);
    expect(find.textContaining('1 faction'), findsOneWidget);
  });
}
