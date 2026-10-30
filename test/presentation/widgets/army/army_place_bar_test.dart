import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/army/army_place_bar.dart';
import 'package:abyss/presentation/widgets/army/army_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  const scout = UnitType.scout;
  const places = ArmyPlaces({
    1: {scout: 96},
    2: {scout: 31},
    3: {scout: 0},
    KernelGarrison.stockKey: {scout: 12},
  });

  Future<List<int?>> show(WidgetTester tester, {int? selected}) async {
    final chosen = <int?>[];
    await tester.pumpWidget(
      guidedApp(
        Align(
          alignment: Alignment.bottomCenter,
          child: ArmyPlaceBar(
            places: places,
            selected: selected,
            onSelected: chosen.add,
          ),
        ),
        null,
      ),
    );
    return chosen;
  }

  testWidgets('lists all, then each place holding units, with its count', (
    tester,
  ) async {
    await show(tester);
    for (final text in [
      'Toutes',
      '139',
      'Niv. 1',
      '96',
      'Niv. 2',
      '31',
      'Noyau',
      '12',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Niv. 3'), findsNothing);
  });

  testWidgets('touching a place selects it, all included', (tester) async {
    final chosen = await show(tester, selected: 2);
    await tester.tap(find.text('Noyau'));
    await tester.tap(find.text('Toutes'));
    expect(chosen, [KernelGarrison.stockKey, ArmyPlaces.all]);
  });

  testWidgets('each place is a selectable button for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await show(tester, selected: 2);
    expect(
      tester.getSemantics(find.text('Niv. 2')),
      matchesSemantics(
        label: 'Niveau 2, 31 unités',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Toutes')),
      matchesSemantics(
        label: 'Toutes, 139 unités',
        isButton: true,
        hasSelectedState: true,
        hasTapAction: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    expect(tester.getSemantics(find.text('Noyau')).label, 'Noyau, 12 unités');
    semantics.dispose();
  });

  testWidgets('names the places in English and Spanish', (tester) async {
    Widget bar() =>
        Scaffold(body: ArmyPlaceBar(places: places, onSelected: (_) {}));
    await tester.pumpWidget(localizedApp(bar(), locale: AbyssLocale.en));
    await tester.pumpAndSettle();
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Lv. 2'), findsOneWidget);
    expect(find.text('Core'), findsOneWidget);
    await tester.pumpWidget(localizedApp(bar(), locale: AbyssLocale.es));
    await tester.pumpAndSettle();
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Núcleo'), findsOneWidget);
  });

  testWidgets('fits the room it keeps at the bottom of a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await show(tester);
    final bar = tester.getRect(find.byType(ArmyPlaceBar));
    expect(bar.height, ArmyPlaceBar.room);
    expect(tester.takeException(), isNull);
  });
}
