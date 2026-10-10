import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/history/history_entry_card.dart';
import 'package:abyss/presentation/widgets/history/history_sheet_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

Future<void> _show(WidgetTester t, Widget child, Locale locale) =>
    t.pumpWidget(localizedApp(Scaffold(body: child), locale: locale));

void main() {
  testWidgets('an empty history in English', (t) async {
    await _show(t, const HistorySheetBody(entries: []), AbyssLocale.en);
    expect(find.text('No action recorded yet.'), findsOneWidget);
  });

  testWidgets('the filters and an empty filter in Spanish', (t) async {
    final entry = BuildingEntry(
      turn: 3,
      buildingType: BuildingType.algaeFarm,
      newLevel: 2,
    );
    await _show(t, HistorySheetBody(entries: [entry]), AbyssLocale.es);
    expect(find.text('Todos'), findsOneWidget);
    await t.tap(find.text('Combates'));
    await t.pumpAndSettle();
    expect(find.text('Ninguna acción para este filtro.'), findsOneWidget);
  });

  testWidgets('a card tells its turn in Spanish', (t) async {
    final entry = BuildingEntry(
      turn: 3,
      buildingType: BuildingType.algaeFarm,
      newLevel: 2,
    );
    await _show(t, HistoryEntryCard(entry: entry), AbyssLocale.es);
    expect(find.text('Turno 3'), findsOneWidget);
  });
}
