import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/menu/count_badge.dart';
import 'package:abyss/presentation/widgets/menu/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AbyssTheme.create(),
  home: Scaffold(body: Center(child: child)),
);

BoxDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(MenuButton),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  testWidgets('calls back when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(MenuButton(label: 'JOUER', onPressed: () => taps++)),
    );
    await tester.tap(find.text('JOUER'));
    expect(taps, 1);
  });

  testWidgets('shows its subtitle under the label', (tester) async {
    await tester.pumpWidget(
      _host(MenuButton(label: 'JOUER', subtitle: 'Alice', onPressed: () {})),
    );
    final label = tester.getCenter(find.text('JOUER'));
    final subtitle = tester.getCenter(find.text('Alice'));
    expect(subtitle.dy, greaterThan(label.dy));
  });

  testWidgets('a primary button glows on a gradient', (tester) async {
    await tester.pumpWidget(_host(MenuButton(label: 'A', onPressed: () {})));
    final decoration = _decoration(tester);
    expect(decoration.gradient, isNotNull);
    expect(decoration.boxShadow, isNotEmpty);
    expect(decoration.border, isNull);
  });

  testWidgets('an outlined button has a border and no gradient', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        MenuButton(
          label: 'A',
          variant: MenuButtonVariant.outlined,
          onPressed: () {},
        ),
      ),
    );
    final decoration = _decoration(tester);
    expect(decoration.gradient, isNull);
    expect(decoration.border, isNotNull);
  });

  testWidgets('shows a count badge only when the count is positive', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(MenuButton(label: 'A', badgeCount: 3, onPressed: () {})),
    );
    expect(find.byType(CountBadge), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await tester.pumpWidget(
      _host(MenuButton(label: 'A', badgeCount: 0, onPressed: () {})),
    );
    expect(find.byType(CountBadge), findsNothing);
  });

  testWidgets('stretches to the width it is given', (tester) async {
    await tester.pumpWidget(
      _host(
        SizedBox(width: 300, child: MenuButton(label: 'A', onPressed: () {})),
      ),
    );
    final size = tester.getSize(find.byType(MenuButton));
    expect(size.width, 300);
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
