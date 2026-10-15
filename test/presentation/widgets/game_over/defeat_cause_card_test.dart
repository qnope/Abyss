import 'package:abyss/domain/game/defeat_analysis.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/widgets/game_over/defeat_cause_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

void main() {
  const wave = MonsterLair(
    difficulty: MonsterDifficulty.easy,
    family: MonsterFamily.swarm,
    unitCount: 30,
    secondFamily: MonsterFamily.hunter,
    secondCount: 10,
  );

  List<LostRaid> raids(List<int> defenders) => [
    for (var i = 0; i < defenders.length; i++)
      LostRaid(turn: 13 + 15 * i, wave: wave, defenders: defenders[i]),
  ];

  Future<void> pump(WidgetTester tester, DefeatAnalysis analysis) async {
    await tester.pumpWidget(
      localizedApp(Scaffold(body: DefeatCauseCard(analysis: analysis))),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists each lost raid against its defenders', (tester) async {
    await pump(
      tester,
      DefeatAnalysis(
        raids: raids([0, 1, 12]),
        advice: DefeatAdvice.moreDefenders,
        harpoonistsNeeded: 85,
      ),
    );
    expect(find.text("Ce qui s'est passé"), findsOneWidget);
    expect(
      find.text(
        'Tour 13 : 30 Dents-de-verre et 10 Calmars-chasseurs niv. 1 '
        'contre aucun défenseur',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('contre 1 défenseur'), findsOneWidget);
    expect(find.textContaining('contre 12 défenseurs'), findsOneWidget);
    expect(
      find.text(
        'Contre ton dernier raid, il fallait environ 85 Harponneurs. '
        'Tu avais 12 défenseurs.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tells an empty base to raise an army', (tester) async {
    await pump(
      tester,
      DefeatAnalysis(raids: raids([0, 0, 0]), advice: DefeatAdvice.raiseAnArmy),
    );
    expect(
      find.text(
        "Ta base était vide. Construis la Caserne et recrute des "
        "Harponneurs dès qu'un raid est annoncé.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('names the units the waves feared', (tester) async {
    await pump(
      tester,
      DefeatAnalysis(
        raids: raids([0, 0, 200]),
        advice: DefeatAdvice.counterTheFamilies,
        harpoonistsNeeded: 40,
      ),
    );
    expect(
      find.text(
        'Tu avais assez de défenseurs, mais pas les bons. '
        'Faibles contre : Harponneurs, Gardiens',
      ),
      findsOneWidget,
    );
  });

  testWidgets('says when no army the guide advises would hold', (tester) async {
    await pump(
      tester,
      DefeatAnalysis(
        raids: raids([0, 0, 12]),
        advice: DefeatAdvice.moreDefenders,
      ),
    );
    expect(
      find.text(
        'Ton dernier raid demandait plus de 150 Harponneurs : garde '
        'la jauge de bruit plus basse et monte le rempart de la Citadelle.',
      ),
      findsOneWidget,
    );
  });
}
