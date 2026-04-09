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
    testWidgets('level 0 shows "aucun", next +20% and dormant notice',
        (t) async {
      await t.pumpWidget(
        _wrap(CoralCitadelInfoSection(building: _citadel(0))),
      );
      expect(find.text('Bonus DEF actuel : aucun'), findsOneWidget);
      expect(find.text('Prochain niveau : +20%'), findsOneWidget);
      expect(
        find.textContaining("Effet dormant"),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('level 3 shows +60% current and +80% next', (t) async {
      await t.pumpWidget(
        _wrap(CoralCitadelInfoSection(building: _citadel(3))),
      );
      expect(find.text('Bonus DEF actuel : +60%'), findsOneWidget);
      expect(find.text('Prochain niveau : +80%'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('level 5 (max) shows +100% and apogee message', (t) async {
      await t.pumpWidget(
        _wrap(CoralCitadelInfoSection(building: _citadel(5))),
      );
      expect(find.text('Bonus DEF actuel : +100%'), findsOneWidget);
      expect(find.text('Bouclier à son apogée'), findsOneWidget);
      expect(find.textContaining('Prochain niveau'), findsNothing);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(
        find.textContaining("Effet dormant"),
        findsOneWidget,
      );
    });

    testWidgets('dormant notice present at every level', (t) async {
      for (final level in [0, 1, 2, 3, 4, 5]) {
        await t.pumpWidget(
          _wrap(CoralCitadelInfoSection(building: _citadel(level))),
        );
        expect(
          find.byIcon(Icons.schedule),
          findsOneWidget,
          reason: 'level $level should show the dormant schedule icon',
        );
      }
    });
  });
}
