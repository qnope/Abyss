import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_state.dart';
import 'package:abyss/presentation/widgets/raid/raid_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows the noise gauge when no raid is coming', (tester) async {
    final state = RaidState()..addNoise(12);
    await tester.pumpWidget(
        _wrap(RaidStatusBar(state: state, currentTurn: 5)));
    expect(find.text('12/40'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the alert while a raid is coming', (tester) async {
    final state = RaidState()
      ..announce(
        const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 22),
        14,
      );
    await tester.pumpWidget(
        _wrap(RaidStatusBar(state: state, currentTurn: 13)));
    expect(
      find.text('Raid à la fin du tour 14 : 22 monstres niv. 1'),
      findsOneWidget,
    );
  });

  testWidgets('says the raid hits this turn on its arrival turn',
      (tester) async {
    final state = RaidState()
      ..announce(
        const MonsterLair(difficulty: MonsterDifficulty.medium, unitCount: 1),
        14,
      );
    await tester.pumpWidget(
        _wrap(RaidStatusBar(state: state, currentTurn: 14)));
    expect(
      find.text('Raid à la fin de ce tour : 1 monstre niv. 2'),
      findsOneWidget,
    );
  });

  testWidgets('shows the lost raid streak once a raid is lost',
      (tester) async {
    final state = RaidState()..recordOutcome(victory: false);
    await tester.pumpWidget(
        _wrap(RaidStatusBar(state: state, currentTurn: 15)));
    expect(find.text("Raids perdus d'affilée : 1/3"), findsOneWidget);
  });

  testWidgets('hides the streak while no raid is lost', (tester) async {
    await tester.pumpWidget(
        _wrap(RaidStatusBar(state: RaidState(), currentTurn: 15)));
    expect(find.textContaining("Raids perdus"), findsNothing);
  });
}
