import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/ambience/increase_pop.dart';
import 'package:abyss/presentation/widgets/unit/unit_card.dart';
import 'package:abyss/presentation/widgets/unit/unit_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget card(Map<int, int> counts, {bool reduced = false}) => MaterialApp(
    theme: AbyssTheme.create(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: Scaffold(
        body: UnitCard(
          unitType: UnitType.scout,
          countsPerLevel: counts,
          isUnlocked: true,
          onTap: () {},
        ),
      ),
    ),
  );

  testWidgets('stays still when first shown', (tester) async {
    await tester.pumpWidget(card({1: 2}));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.widget<IncreasePop>(find.byType(IncreasePop)).value, 2);
  });

  testWidgets('pops the icon and floats the recruits on arrival', (
    tester,
  ) async {
    await tester.pumpWidget(card({1: 2}));
    await tester.pumpAndSettle();
    await tester.pumpWidget(card({1: 2, 2: 3}));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
    expect(tester.widget<IncreasePop>(find.byType(IncreasePop)).value, 5);
    expect(find.text('+3'), findsOneWidget);
    expect(tester.getRect(find.byType(UnitIcon)).size.width, lessThan(40));
    await tester.pumpAndSettle();
    expect(find.text('+3'), findsNothing);
  });

  testWidgets('a loss floats down without a pop', (tester) async {
    await tester.pumpWidget(card({1: 5}));
    await tester.pumpAndSettle();
    await tester.pumpWidget(card({1: 1}));
    await tester.pump();
    expect(find.text('−4'), findsOneWidget);
  });

  testWidgets('nothing moves when animations are reduced', (tester) async {
    await tester.pumpWidget(card({1: 2}, reduced: true));
    await tester.pumpAndSettle();
    await tester.pumpWidget(card({1: 4}, reduced: true));
    await tester.pump();
    final pop = find.byType(IncreasePop);
    expect(tester.getRect(find.byType(UnitIcon)).size, const Size.square(40));
    expect(tester.getTopLeft(find.byType(UnitIcon)), tester.getTopLeft(pop));
    expect(find.text('+2'), findsNothing);
  });
}
