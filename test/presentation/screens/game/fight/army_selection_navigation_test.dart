import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen_fight_actions.dart';

import '../../../../domain/action/fight_monster_action_helper.dart';
import '../../../../helpers/fake_game_repository.dart';
import '../../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const MonsterLair lair = MonsterLair(
    difficulty: MonsterDifficulty.easy,
    unitCount: 1,
  );

  testWidgets('openArmySelection pushes ArmySelectionScreen on the navigator',
      (tester) async {
    final scenario = createFightScenario(
      stock: const {UnitType.scout: 2},
    );
    final repository = FakeGameRepository();

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => openArmySelection(
                context,
                scenario.game,
                repository,
                1,
                1,
                lair,
                () {},
                level: 1,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    expect(find.byType(ArmySelectionScreen), findsNothing);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ArmySelectionScreen), findsOneWidget);
  });
}
