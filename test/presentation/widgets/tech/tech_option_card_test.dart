import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/tech/tech_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  group('TechOptionCard', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Future<void> pump(WidgetTester t, TechOptionStatus status,
        {VoidCallback? onChoose}) {
      return t.pumpWidget(MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: TechOptionCard(
                iconPath: 'assets/icons/tech/military_2a.svg',
                name: 'Lames de corail',
                effect: '+35 % ATK',
                color: Colors.pink,
                status: status,
                onChoose: onChoose,
              ),
            ),
          ),
        ),
      ));
    }

    testWidgets('shows its icon, name and effect', (t) async {
      await pump(t, TechOptionStatus.open);
      expect(find.text('Lames de corail'), findsOneWidget);
      expect(find.text('+35 % ATK'), findsOneWidget);
      expect(t.widget<RasterSvg>(find.byType(RasterSvg)).assetPath,
          'assets/icons/tech/military_2a.svg');
    });

    testWidgets('an open option is taken with "Choisir"', (t) async {
      var chosen = 0;
      await pump(t, TechOptionStatus.open, onChoose: () => chosen++);
      await t.tap(find.text('Choisir'));
      expect(chosen, 1);
    });

    testWidgets('without callback the button is disabled', (t) async {
      await pump(t, TechOptionStatus.open);
      final button = t.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('a taken option shows "Choisi" and no button', (t) async {
      await pump(t, TechOptionStatus.taken, onChoose: () {});
      expect(find.text('Choisi ✓'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(t.widget<RasterSvg>(find.byType(RasterSvg)).color, isNull);
    });

    testWidgets('a discarded option is greyed and marked "Écarté"',
        (t) async {
      await pump(t, TechOptionStatus.discarded, onChoose: () {});
      expect(find.text('Écarté'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(t.widget<RasterSvg>(find.byType(RasterSvg)).color, isNotNull);
    });
  });
}
