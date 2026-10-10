import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/building/building_card.dart';
import 'package:abyss/presentation/widgets/building/degraded_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import 'building_detail_sheet_harness.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget card({int? missing, Locale locale = AbyssLocale.fr}) => localizedApp(
    locale: locale,
    Scaffold(
      body: BuildingCard(
        building: Building(type: BuildingType.barracks, level: 2),
        onTap: () {},
        missingHeadquarters: missing,
      ),
    ),
  );

  testWidgets('the card shows Dégradé when the QG is too low', (t) async {
    await t.pumpWidget(card(missing: 4));
    await t.pumpAndSettle();
    expect(find.text('Dégradé'), findsOneWidget);
    expect(find.byType(DegradedBadge), findsOneWidget);
  });

  testWidgets('the card shows nothing when not degraded', (t) async {
    await t.pumpWidget(card());
    await t.pumpAndSettle();
    expect(find.byType(DegradedBadge), findsNothing);
  });

  testWidgets('the card is worded in English', (t) async {
    await t.pumpWidget(card(missing: 4, locale: AbyssLocale.en));
    await t.pumpAndSettle();
    expect(find.text('Degraded'), findsOneWidget);
  });

  testWidgets('the detail sheet says which QG level and what it costs', (
    t,
  ) async {
    useTallSurface(t);
    final barracks = Building(type: BuildingType.barracks, level: 2);
    await t.pumpWidget(
      buildSheetApp(
        building: barracks,
        allBuildings: {
          BuildingType.headquarters: hq(3),
          BuildingType.barracks: barracks,
        },
      ),
    );
    await openSheet(t);
    expect(find.text('Dégradé : le QG doit être au niveau 4'), findsOneWidget);
    expect(find.text('Les unités coûtent deux fois plus cher'), findsOneWidget);
  });

  testWidgets('the detail sheet shows nothing once the QG is raised', (
    t,
  ) async {
    useTallSurface(t);
    final barracks = Building(type: BuildingType.barracks, level: 2);
    await t.pumpWidget(
      buildSheetApp(
        building: barracks,
        allBuildings: {
          BuildingType.headquarters: hq(4),
          BuildingType.barracks: barracks,
        },
      ),
    );
    await openSheet(t);
    expect(find.byType(DegradedBadge), findsNothing);
  });
}
