import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/recruitment_section.dart';
import '../../helpers/test_svg_helper.dart';

void main() {
  group('RecruitmentSection', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget createApp({
      UnitType unitType = UnitType.scout,
      int maxRecruitableCount = 10,
      bool hasRecruitedThisType = false,
      void Function(int)? onRecruit,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: RecruitmentSection(
            unitType: unitType,
            maxRecruitableCount: maxRecruitableCount,
            hasRecruitedThisType: hasRecruitedThisType,
            onRecruit: onRecruit ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('shows slider when available', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('recruit button disabled at slider 0', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows already recruited message', (tester) async {
      await tester.pumpWidget(createApp(hasRecruitedThisType: true));
      await tester.pumpAndSettle();
      expect(
        find.text('Recrutement deja effectue ce tour'),
        findsOneWidget,
      );
    });

    testWidgets('shows insufficient resources message', (tester) async {
      await tester.pumpWidget(createApp(maxRecruitableCount: 0));
      await tester.pumpAndSettle();
      expect(find.text('Ressources insuffisantes'), findsOneWidget);
    });

    testWidgets('moving slider updates quantity', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(find.text('0 unites'), findsNothing);
    });

    testWidgets('tapping recruit calls onRecruit', (tester) async {
      int? recruitedQty;
      await tester.pumpWidget(
        createApp(onRecruit: (q) => recruitedQty = q),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recruter'));
      expect(recruitedQty, isNotNull);
      expect(recruitedQty! > 0, isTrue);
    });
  });
}
