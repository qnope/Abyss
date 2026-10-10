import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_army_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../domain/action/fight_monster_action_helper.dart';
import '../../../../helpers/fake_game_repository.dart';
import '../../../../helpers/l10n_fixtures.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('an assault on an already captured kernel is refused and '
      'nothing is saved', (tester) async {
    final scenario = createFightScenario(
      stock: const {UnitType.abyssAdmiral: 1},
      content: CellContentType.volcanicKernel,
      withLair: false,
      collectedBy: 'rival',
    );
    final repository = FakeGameRepository();
    var changes = 0;
    await tester.pumpWidget(localizedApp(KernelArmySelectionScreen(
      game: scenario.game,
      repository: repository,
      targetX: 1,
      targetY: 1,
      level: 1,
      onChanged: () => changes++,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    final launch = find.widgetWithText(ElevatedButton, fr.fightLaunchAssault);
    await tester.ensureVisible(launch);
    await tester.pumpAndSettle();
    await tester.tap(launch);
    await tester.pumpAndSettle();

    expect(find.text(fr.actionFailureKernelAlreadyCaptured), findsOneWidget);
    expect(find.byType(KernelArmySelectionScreen), findsOneWidget);
    expect(repository.saveCallCount, 0);
    expect(changes, 0);
    expect(scenario.player.unitsOnLevel(1)[UnitType.abyssAdmiral]!.count, 1);
  });
}
