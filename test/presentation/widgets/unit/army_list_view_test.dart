import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/building/base_shield_badge.dart';
import 'package:abyss/presentation/widgets/unit/army_list_view.dart';
import '../../../helpers/test_svg_helper.dart';

Map<UnitType, Unit> _defaultUnits() =>
    {for (final t in UnitType.values) t: Unit(type: t)};

Map<BuildingType, Building> _buildings({int citadelLevel = 0}) => {
      BuildingType.coralCitadel:
          Building(type: BuildingType.coralCitadel, level: citadelLevel),
    };

void main() {
  group('ArmyListView', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget createApp({
      Map<int, Map<UnitType, Unit>>? unitsPerLevel,
      int barracksLevel = 1,
      Map<BuildingType, Building>? buildings,
      void Function(UnitType)? onUnitTap,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: ArmyListView(
            unitsPerLevel: unitsPerLevel ?? {1: _defaultUnits()},
            barracksLevel: barracksLevel,
            buildings: buildings ?? _buildings(),
            onUnitTap: onUnitTap ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('shows 6 unit names', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      expect(find.text('Eclaireur'), findsOneWidget);
      expect(find.text('Harponneur'), findsOneWidget);
      expect(find.text('Gardien'), findsOneWidget);
      expect(find.text('Briseur'), findsOneWidget);
      expect(find.text('Amiral des Abysses'), findsOneWidget);
      expect(find.text('Saboteur'), findsOneWidget);
    });

    testWidgets('barracks level 1 unlocks scout and harpoonist',
        (tester) async {
      await tester.pumpWidget(createApp(barracksLevel: 1));
      await tester.pumpAndSettle();
      // 4 locked units show Verrouille (guardian, domeBreaker, abyssAdmiral, saboteur)
      expect(find.text('Verrouille'), findsNWidgets(4));
    });

    testWidgets('barracks level 5 unlocks all units', (tester) async {
      await tester.pumpWidget(createApp(barracksLevel: 5));
      await tester.pumpAndSettle();
      expect(find.text('Verrouille'), findsNothing);
    });

    testWidgets('barracks level 0 locks all units', (tester) async {
      await tester.pumpWidget(createApp(barracksLevel: 0));
      await tester.pumpAndSettle();
      expect(find.text('Verrouille'), findsNWidgets(6));
    });

    testWidgets('tap fires with correct UnitType', (tester) async {
      UnitType? tappedType;
      await tester.pumpWidget(
        createApp(onUnitTap: (t) => tappedType = t),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eclaireur'));
      expect(tappedType, UnitType.scout);
    });

    testWidgets('citadel level 0 shows no shield badge', (tester) async {
      await tester.pumpWidget(
        createApp(buildings: _buildings(citadelLevel: 0)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BaseShieldBadge), findsOneWidget);
      expect(find.textContaining('Bouclier de la base'), findsNothing);
    });

    testWidgets('citadel level 2 shows shield badge above unit cards',
        (tester) async {
      await tester.pumpWidget(
        createApp(buildings: _buildings(citadelLevel: 2)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BaseShieldBadge), findsOneWidget);
      expect(find.text('Bouclier de la base : +40%'), findsOneWidget);
    });
  });
}
