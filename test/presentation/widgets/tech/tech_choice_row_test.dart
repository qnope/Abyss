import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tech/tech_choice_row.dart';
import 'package:abyss/presentation/widgets/tech/tech_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  group('TechChoiceRow', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Future<void> pump(WidgetTester t,
        {TechOption? taken, ValueChanged<TechOption>? onChoose}) {
      t.view.physicalSize = const Size(600, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      return t.pumpWidget(MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: TechChoiceRow(
              branch: TechBranch.resources,
              level: 4,
              taken: taken,
              onChoose: onChoose,
            ),
          ),
        ),
      ));
    }

    List<TechOptionStatus> statuses(WidgetTester t) => t
        .widgetList<TechOptionCard>(find.byType(TechOptionCard))
        .map((c) => c.status)
        .toList();

    testWidgets('shows both options of the node, A then B', (t) async {
      await pump(t);
      expect(find.text('Coffres scellés'), findsOneWidget);
      expect(find.text('Chantiers économes'), findsOneWidget);
      expect(find.text('ou'), findsOneWidget);
      final cards = t.widgetList<TechOptionCard>(find.byType(TechOptionCard));
      expect(cards.map((c) => c.iconPath), [
        'assets/icons/tech/resources_4a.svg',
        'assets/icons/tech/resources_4b.svg',
      ]);
    });

    testWidgets('tapping an option reports it', (t) async {
      final chosen = <TechOption>[];
      await pump(t, onChoose: chosen.add);
      expect(statuses(t), [TechOptionStatus.open, TechOptionStatus.open]);
      await t.tap(find.text('Choisir').last);
      await t.tap(find.text('Choisir').first);
      expect(chosen, [TechOption.b, TechOption.a]);
    });

    testWidgets('without callback both buttons are disabled', (t) async {
      await pump(t);
      final buttons =
          t.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttons, hasLength(2));
      expect(buttons.every((b) => b.onPressed == null), isTrue);
    });

    testWidgets('once taken, one option is chosen and the other discarded',
        (t) async {
      await pump(t, taken: TechOption.b);
      expect(statuses(t),
          [TechOptionStatus.discarded, TechOptionStatus.taken]);
      expect(find.text('Choisir'), findsNothing);
    });
  });
}
