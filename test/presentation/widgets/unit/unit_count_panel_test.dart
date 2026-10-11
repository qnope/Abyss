import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/unit/unit_count_panel.dart';
import 'package:abyss/presentation/widgets/unit/unit_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<UnitType, int> units, {
  String? emptyMessage,
}) =>
    tester.pumpWidget(localizedApp(Scaffold(
      body: UnitCountPanel(
        title: 'Défenseurs au Niveau 2',
        units: units,
        emptyMessage: emptyMessage,
      ),
    )));

void main() {
  testWidgets('shows the title, the total and a row per type', (tester) async {
    await _pump(tester, {UnitType.harpoonist: 12, UnitType.guardian: 6});
    expect(find.text('Défenseurs au Niveau 2'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Harponneur'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Gardien'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('sorts the biggest group first', (tester) async {
    await _pump(tester, {UnitType.scout: 2, UnitType.domeBreaker: 9});
    expect(
      tester.getTopLeft(find.text('Briseur')).dy,
      lessThan(tester.getTopLeft(find.text('Éclaireur')).dy),
    );
  });

  testWidgets('leaves out the types without unit', (tester) async {
    await _pump(tester, {UnitType.scout: 0, UnitType.guardian: 4});
    expect(find.text('Éclaireur'), findsNothing);
    expect(find.text('Gardien'), findsOneWidget);
  });

  testWidgets('says so when nobody is there', (tester) async {
    await _pump(tester, const {}, emptyMessage: 'Aucune unité.');
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Aucune unité.'), findsOneWidget);
  });

  testWidgets('draws the unit illustrations', (tester) async {
    await _pump(tester, {UnitType.harpoonist: 1, UnitType.guardian: 1});
    expect(find.byType(UnitIcon), findsNWidgets(2));
  });
}
