import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/resource/resource_gains_row.dart';
import 'package:abyss/presentation/widgets/resource/resource_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('shows each gain with its icon, in its color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: const Scaffold(
          body: ResourceGainsRow(
            gains: {
              ResourceType.coral: 30,
              ResourceType.ore: 20,
              ResourceType.algae: 0,
            },
          ),
        ),
      ),
    );

    expect(find.byType(ResourceIcon), findsNWidgets(2));
    expect(
      tester.widget<Text>(find.text('+30')).style?.color,
      AbyssColors.coralPink,
    );
    expect(find.text('+20'), findsOneWidget);
    expect(find.text('+0'), findsNothing);
  });
}
