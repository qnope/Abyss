import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/lore_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Text> _pump(WidgetTester tester, LoreText lore) async {
  await tester.pumpWidget(
    MaterialApp(theme: AbyssTheme.create(), home: Scaffold(body: lore)),
  );
  return tester.widget<Text>(find.text(lore.text));
}

void main() {
  testWidgets('tells the lore in dimmed italics', (tester) async {
    final text = await _pump(tester, const LoreText('Les abysses écoutent.'));

    expect(text.style?.fontStyle, FontStyle.italic);
    expect(text.style?.color, AbyssColors.onSurfaceDim);
    expect(text.textAlign, TextAlign.start);
  });

  testWidgets('can be centered', (tester) async {
    final text = await _pump(
      tester,
      const LoreText('Le Volcan dort.', textAlign: TextAlign.center),
    );

    expect(text.textAlign, TextAlign.center);
  });

  testWidgets('dims and slants the base style it is given', (tester) async {
    final text = await _pump(
      tester,
      const LoreText('La Fosse.', style: TextStyle(fontSize: 11)),
    );

    expect(text.style?.fontSize, 11);
    expect(text.style?.fontStyle, FontStyle.italic);
  });
}
