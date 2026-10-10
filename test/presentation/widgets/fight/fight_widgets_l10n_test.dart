import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/fight/monster_family_traits.dart';
import 'package:abyss/presentation/widgets/fight/monster_preview.dart';
import 'package:abyss/presentation/widgets/fight/selection_summary_card.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

Future<void> _pump(WidgetTester tester, Widget child, Locale locale) =>
    tester.pumpWidget(localizedApp(
      Scaffold(body: SingleChildScrollView(child: child)),
      locale: locale,
    ));

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('the military bonus in each language', (tester) async {
    const card = SelectionSummaryCard(
      totalAtk: 10,
      totalDef: 4,
      boost: UnitBoost(atkPercent: 20, hpPercent: 10),
    );
    await _pump(tester, card, AbyssLocale.fr);
    expect(find.text('Bonus militaire : +20% ATK, +10% PV'), findsOneWidget);
    await _pump(tester, card, AbyssLocale.en);
    expect(find.text('Military bonus: +20% ATK, +10% HP'), findsOneWidget);
    await _pump(tester, card, AbyssLocale.es);
    expect(find.text('Bonificación militar: +20% ATK, +10% PV'),
        findsOneWidget);
  });

  testWidgets('a monster preview in English', (tester) async {
    await _pump(
      tester,
      const MonsterPreview(
        lair: MonsterLair(
          difficulty: MonsterDifficulty.medium,
          unitCount: 3,
          family: MonsterFamily.swarm,
        ),
      ),
      AbyssLocale.en,
    );
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.textContaining('HP: '), findsOneWidget);
    expect(find.textContaining('Weak against: '), findsOneWidget);
  });

  testWidgets('a family weakness in Spanish', (tester) async {
    await _pump(
      tester,
      const MonsterFamilyTraits(family: MonsterFamily.swarm),
      AbyssLocale.es,
    );
    expect(find.textContaining('Débil contra: '), findsOneWidget);
  });

  testWidgets('a unit row shows its stock in Spanish', (tester) async {
    await _pump(
      tester,
      UnitQuantityRow(
        type: UnitType.scout,
        stock: 4,
        value: 0,
        onChanged: (_) {},
      ),
      AbyssLocale.es,
    );
    expect(find.text('Reserva: 4'), findsOneWidget);
  });
}
