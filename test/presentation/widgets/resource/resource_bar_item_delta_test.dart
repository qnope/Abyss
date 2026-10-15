import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/ambience/delta_float.dart';
import 'package:abyss/presentation/widgets/resource/resource_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget item(int amount) => MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: ResourceBarItem(
        resource: Resource(type: ResourceType.algae, amount: amount),
      ),
    ),
  );

  testWidgets('floats the change of the amount above it', (tester) async {
    await tester.pumpWidget(item(100));
    await tester.pumpAndSettle();
    expect(find.byType(DeltaFloat), findsOneWidget);
    await tester.pumpWidget(item(120));
    await tester.pump();
    expect(find.text('+20'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('+20'), findsNothing);
  });

  testWidgets('floats a spending as a loss', (tester) async {
    await tester.pumpWidget(item(100));
    await tester.pumpWidget(item(60));
    await tester.pump();
    expect(find.text('−40'), findsOneWidget);
  });
}
