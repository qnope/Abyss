import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/menu/glow_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AbyssTheme.create(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('draws a glowing cyan title above its subtitle', (tester) async {
    await tester.pumpWidget(
      _host(const GlowTitle(title: 'ABYSSES', subtitle: 'Les profondeurs')),
    );
    final title = tester.widget<Text>(find.text('ABYSSES'));
    expect(title.style!.color, AbyssColors.biolumCyan);
    expect(title.style!.fontFamily, 'Rajdhani');
    expect(title.style!.shadows, isNotEmpty);
    expect(title.style!.letterSpacing, greaterThanOrEqualTo(8));
    expect(find.text('LES PROFONDEURS'), findsOneWidget);
    expect(
      tester.getCenter(find.text('LES PROFONDEURS')).dy,
      greaterThan(tester.getCenter(find.text('ABYSSES')).dy),
    );
  });

  testWidgets('shrinks to fit a narrow box', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 200,
          child: GlowTitle(title: 'ABYSSES', subtitle: 'Les profondeurs'),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(GlowTitle)).width, 200);
  });
}
