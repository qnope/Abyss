import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit.dart';
import 'package:abyss/domain/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/army_list_view.dart';
import '../../helpers/test_svg_helper.dart';

Map<UnitType, Unit> _defaultUnits() =>
    {for (final t in UnitType.values) t: Unit(type: t)};

void main() {
  group('ArmyListView', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget createApp({
      Map<UnitType, Unit>? units,
      int barracksLevel = 1,
      void Function(UnitType)? onUnitTap,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: ArmyListView(
            units: units ?? _defaultUnits(),
            barracksLevel: barracksLevel,
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
      expect(find.text('Siphonneur'), findsOneWidget);
      expect(find.text('Saboteur'), findsOneWidget);
    });

    testWidgets('barracks level 1 unlocks scout and harpoonist',
        (tester) async {
      await tester.pumpWidget(createApp(barracksLevel: 1));
      await tester.pumpAndSettle();
      // 4 locked units show Verrouille (guardian, domeBreaker, siphoner, saboteur)
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
  });
}
