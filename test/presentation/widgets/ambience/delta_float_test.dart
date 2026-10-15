import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/ambience/delta_float.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget float(int value, {bool reduced = false}) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: DeltaFloat(value: value, child: Text('$value')),
      ),
    ),
  );

  Color colorOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!.color!;

  testWidgets('shows nothing when first shown', (tester) async {
    await tester.pumpWidget(float(10));
    expect(find.textContaining('+'), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('floats a gain up in the success colour', (tester) async {
    await tester.pumpWidget(float(10));
    await tester.pumpWidget(float(15));
    expect(find.text('+5'), findsOneWidget);
    expect(colorOf(tester, '+5').withValues(alpha: 1), AbyssColors.success);
    final start = tester.getTopLeft(find.text('+5')).dy;
    await tester.pump(AbyssMotion.deltaFloat ~/ 2);
    expect(tester.getTopLeft(find.text('+5')).dy, lessThan(start));
    expect(colorOf(tester, '+5').a, lessThan(1));
  });

  testWidgets('floats a loss in the error colour', (tester) async {
    await tester.pumpWidget(float(10));
    await tester.pumpWidget(float(7));
    expect(find.text('−3'), findsOneWidget);
    expect(
      colorOf(tester, '−3').withValues(alpha: 1),
      AbyssColors.error,
    );
  });

  testWidgets('disappears once the float is over', (tester) async {
    await tester.pumpWidget(float(10));
    await tester.pumpWidget(float(15));
    await tester.pumpAndSettle();
    expect(find.text('+5'), findsNothing);
    expect(find.text('15'), findsOneWidget);
  });

  testWidgets('a new change replaces the float', (tester) async {
    await tester.pumpWidget(float(10));
    await tester.pumpWidget(float(15));
    await tester.pump(AbyssMotion.deltaFloat * 0.8);
    await tester.pumpWidget(float(12));
    expect(find.text('+5'), findsNothing);
    expect(find.text('−3'), findsOneWidget);
    await tester.pump(AbyssMotion.deltaFloat * 0.5);
    expect(find.text('−3'), findsOneWidget);
  });

  testWidgets('shows nothing when animations are reduced', (tester) async {
    await tester.pumpWidget(float(10, reduced: true));
    await tester.pumpWidget(float(15, reduced: true));
    expect(find.text('+5'), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('does not change the size of its child', (tester) async {
    await tester.pumpWidget(float(10));
    final size = tester.getSize(find.byType(DeltaFloat));
    await tester.pumpWidget(float(15));
    expect(tester.getSize(find.byType(DeltaFloat)), size);
  });
}
