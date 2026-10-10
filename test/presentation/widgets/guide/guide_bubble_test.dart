import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/guide/guide_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const first = GuideAdvice('Construis la Ferme.', GuideTarget.endTurn());
  const second = GuideAdvice('Construis la Mine.', GuideTarget.endTurn());

  Widget bubble(GuideAdvice? advice) => MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(body: GuideBubble(advice: advice)),
  );

  testWidgets('shows nothing without advice', (tester) async {
    await tester.pumpWidget(bubble(null));

    expect(find.text('Compris'), findsNothing);
    expect(find.byType(RasterSvg), findsNothing);
  });

  testWidgets('shows the portrait of the guide, its advice and « Compris »', (
    tester,
  ) async {
    await tester.pumpWidget(bubble(first));

    expect(find.text(first.text), findsOneWidget);
    expect(find.text('Compris'), findsOneWidget);
    final portrait = tester.widget<RasterSvg>(find.byType(RasterSvg));
    expect(portrait.assetPath, GuideBubble.portraitPath);
    expect(portrait.size, 64);
  });

  testWidgets('« Compris » hides it until the advice changes', (tester) async {
    await tester.pumpWidget(bubble(first));
    await tester.tap(find.text('Compris'));
    await tester.pump();

    expect(find.text(first.text), findsNothing);

    await tester.pumpWidget(bubble(first));
    expect(find.text(first.text), findsNothing);

    await tester.pumpWidget(bubble(second));
    expect(find.text(second.text), findsOneWidget);

    await tester.pumpWidget(bubble(first));
    expect(find.text(first.text), findsOneWidget);
  });
}
