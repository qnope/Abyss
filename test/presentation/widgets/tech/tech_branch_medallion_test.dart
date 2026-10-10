import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/tech/tech_branch_medallion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

const _icon = 'assets/icons/buildings/barracks.svg';

void main() {
  group('TechBranchMedallion', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Future<void> pump(WidgetTester t, {required bool unlocked}) {
      return t.pumpWidget(MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Center(
            child: TechBranchMedallion(
              iconPath: _icon,
              label: 'Militaire',
              color: Colors.pink,
              unlocked: unlocked,
            ),
          ),
        ),
      ));
    }

    RasterSvg icon(WidgetTester t) => t.widget<RasterSvg>(find.byType(RasterSvg));

    testWidgets('unlocked branch shows its emblem in colour', (t) async {
      await pump(t, unlocked: true);
      expect(icon(t).assetPath, _icon);
      expect(icon(t).greyscale, isFalse);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('locked branch shows its emblem in greyscale with a padlock',
        (t) async {
      await pump(t, unlocked: false);
      expect(icon(t).greyscale, isTrue);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}
