import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/building/coral_citadel_info_section.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(body: child),
    );

Building _citadel(int level) =>
    Building(type: BuildingType.coralCitadel, level: level);

void main() {
  group('CoralCitadelInfoSection', () {
    testWidgets('level 0 shows "aucun" and the level 1 rampart', (t) async {
      await t.pumpWidget(
        _wrap(CoralCitadelInfoSection(building: _citadel(0))),
      );
      expect(find.text('Rempart actuel : aucun'), findsOneWidget);
      expect(find.text('Prochain niveau : 40 PV, DEF 5'), findsOneWidget);
    });

    testWidgets('level 3 shows current and next rampart', (t) async {
      await t.pumpWidget(
        _wrap(CoralCitadelInfoSection(building: _citadel(3))),
      );
      expect(find.text('Rempart actuel : 120 PV, DEF 7'), findsOneWidget);
      expect(find.text('Prochain niveau : 160 PV, DEF 8'), findsOneWidget);
    });

    testWidgets('level 5 (max) shows the apogee message', (t) async {
      await t.pumpWidget(
        _wrap(CoralCitadelInfoSection(building: _citadel(5))),
      );
      expect(find.text('Rempart actuel : 200 PV, DEF 9'), findsOneWidget);
      expect(find.text('Rempart à son apogée'), findsOneWidget);
      expect(find.textContaining('Prochain niveau'), findsNothing);
    });

    testWidgets('explains the raid role at every level', (t) async {
      for (final level in [0, 1, 2, 3, 4, 5]) {
        await t.pumpWidget(
          _wrap(CoralCitadelInfoSection(building: _citadel(level))),
        );
        expect(find.byIcon(Icons.fort), findsOneWidget);
        expect(find.textContaining('Pendant un raid'), findsOneWidget);
      }
    });
  });
}
