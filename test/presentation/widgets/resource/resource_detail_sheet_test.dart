import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/extensions/resource_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/resource/resource_detail_sheet.dart';
import 'package:abyss/presentation/widgets/resource/resource_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> openSheet(WidgetTester tester, {required int production}) async {
    final resource =
        Resource(type: ResourceType.coral, amount: 42, maxStorage: 300);
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showResourceDetailSheet(
              context,
              resource,
              production: production,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('describes the resource and its stock', (tester) async {
    await openSheet(tester, production: 0);

    expect(find.byType(ResourceIcon), findsOneWidget);
    expect(find.text(ResourceType.coral.displayName), findsOneWidget);
    expect(find.text(ResourceType.coral.flavorText), findsOneWidget);
    expect(find.text('42 / 300'), findsOneWidget);
    expect(find.text('Production'), findsNothing);
  });

  testWidgets('shows the production per turn when positive',
      (tester) async {
    await openSheet(tester, production: 12);

    expect(find.text('Production'), findsOneWidget);
    expect(find.text('Bâtiment principal'), findsOneWidget);
    expect(find.text('+12/t'), findsOneWidget);
  });
}
