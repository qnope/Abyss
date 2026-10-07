import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/building/base_shield_badge.dart';

Map<BuildingType, Building> _buildings(int citadelLevel) => {
      BuildingType.coralCitadel:
          Building(type: BuildingType.coralCitadel, level: citadelLevel),
    };

Widget _wrap(Widget child) => MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(body: child),
    );

void main() {
  group('BaseShieldBadge', () {
    testWidgets('renders SizedBox.shrink at level 0', (tester) async {
      await tester.pumpWidget(
        _wrap(BaseShieldBadge(buildings: _buildings(0))),
      );
      expect(find.byIcon(Icons.shield), findsNothing);
      expect(find.textContaining('Rempart de la base'), findsNothing);
    });

    testWidgets('renders the level 3 rampart', (tester) async {
      await tester.pumpWidget(
        _wrap(BaseShieldBadge(buildings: _buildings(3))),
      );
      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.text('Rempart de la base : 120 PV, DEF 7'), findsOneWidget);
    });

    testWidgets('renders the level 5 rampart', (tester) async {
      await tester.pumpWidget(
        _wrap(BaseShieldBadge(buildings: _buildings(5))),
      );
      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.text('Rempart de la base : 200 PV, DEF 9'), findsOneWidget);
    });

    testWidgets('hidden when citadel absent from map', (tester) async {
      await tester.pumpWidget(
        _wrap(const BaseShieldBadge(buildings: {})),
      );
      expect(find.byIcon(Icons.shield), findsNothing);
      expect(find.textContaining('Rempart de la base'), findsNothing);
    });
  });
}
