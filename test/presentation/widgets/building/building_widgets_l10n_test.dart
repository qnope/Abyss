import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/worksite/worksite.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/building/base_shield_badge.dart';
import 'package:abyss/presentation/widgets/building/building_card.dart';
import 'package:abyss/presentation/widgets/building/coral_citadel_info_section.dart';
import 'package:abyss/presentation/widgets/building/worksite_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import 'building_detail_sheet_harness.dart';

Building _citadel(int level) =>
    Building(type: BuildingType.coralCitadel, level: level);

Future<void> _show(WidgetTester t, Widget child, Locale locale) =>
    t.pumpWidget(localizedApp(Scaffold(body: child), locale: locale));

Map<ResourceType, Resource> _rich() => {
  for (final t in ResourceType.values) t: Resource(type: t, amount: 99999),
};

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a building card tells its level in English', (t) async {
    await _show(t, BuildingCard(building: _citadel(2), onTap: () {}),
        AbyssLocale.en);
    expect(find.text('Level 2'), findsOneWidget);
    await _show(t, BuildingCard(building: _citadel(0), onTap: () {}),
        AbyssLocale.es);
    expect(find.text('Sin construir'), findsOneWidget);
  });

  testWidgets('the rampart badge in English and Spanish', (t) async {
    final buildings = {BuildingType.coralCitadel: _citadel(3)};
    await _show(t, BaseShieldBadge(buildings: buildings), AbyssLocale.en);
    expect(find.text('Base rampart: 120 HP, DEF 7'), findsOneWidget);
    await _show(t, BaseShieldBadge(buildings: buildings), AbyssLocale.es);
    expect(find.text('Muralla de la base: 120 PV, DEF 7'), findsOneWidget);
  });

  testWidgets('the citadel section in English', (t) async {
    await _show(t, CoralCitadelInfoSection(building: _citadel(0)),
        AbyssLocale.en);
    expect(find.text('Current rampart: none'), findsOneWidget);
    expect(find.text('Next level: 40 HP, DEF 5'), findsOneWidget);
    expect(find.textContaining('During a raid, the rampart'), findsOneWidget);
    await _show(t, CoralCitadelInfoSection(building: _citadel(5)),
        AbyssLocale.es);
    expect(find.text('Muralla en su apogeo'), findsOneWidget);
  });

  testWidgets('the worksites in English and Spanish', (t) async {
    final buildings = {BuildingType.headquarters: hq(1)};
    await _show(
      t,
      WorksiteBadge(worksite: Worksite(), buildings: buildings),
      AbyssLocale.en,
    );
    expect(find.text('Free worksites this turn: 1/1'), findsOneWidget);
    await _show(
      t,
      WorksiteBadge(
        worksite: Worksite(),
        buildings: buildings,
        showNext: true,
      ),
      AbyssLocale.es,
    );
    expect(find.textContaining('Obras libres este turno: 1/1 · +1 en el CG'),
        findsOneWidget);
  });

  testWidgets('the upgrade section in English', (t) async {
    useTallSurface(t);
    final farm = Building(type: BuildingType.algaeFarm, level: 1);
    await t.pumpWidget(buildSheetApp(
      building: farm,
      resources: _rich(),
      allBuildings: {BuildingType.headquarters: hq(1), farm.type: farm},
      worksite: Worksite(upgrades: 1),
      locale: AbyssLocale.en,
    ));
    await openSheet(t);
    expect(find.text('Level 1 → 2'), findsOneWidget);
    expect(find.text('Worksites busy this turn'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
  });

  testWidgets('a locked kernel in Spanish', (t) async {
    useTallSurface(t);
    final kernel = Building(type: BuildingType.volcanicKernel, level: 0);
    await t.pumpWidget(buildSheetApp(
      building: kernel,
      resources: _rich(),
      allBuildings: {BuildingType.headquarters: hq(10), kernel.type: kernel},
      locale: AbyssLocale.es,
    ));
    await openSheet(t);
    expect(find.text('Núcleo Volcánico capturado requerido'), findsOneWidget);
    expect(find.text('Construir'), findsOneWidget);
  });
}
