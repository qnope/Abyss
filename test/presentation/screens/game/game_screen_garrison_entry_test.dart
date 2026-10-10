import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/presentation/screens/game/game_screen_actions.dart';
import 'package:abyss/presentation/widgets/volcano/kernel_garrison_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/kernel_garrison_helpers.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> openKernelBuilding(WidgetTester tester, Game game) async {
    useTallView(tester);
    await tester.pumpWidget(buildLauncherHost('go', (ctx) =>
        showBuildingDetailAction(ctx, game, FakeGameRepository(),
            Building(type: BuildingType.volcanicKernel, level: 1), () {})));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  Future<void> openKernelCell(
    WidgetTester tester, Game game, FakeGameRepository repository) async {
    game.levels[1] = plainMap({
      GridPosition(x: 2, y: 2): MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.volcanicKernel,
        collectedBy: game.humanPlayer.id,
      ),
    });
    game.humanPlayer.revealedCellsPerLevel[1] = allPositions();
    await tester.pumpWidget(mapTabHost(game, repository: repository));
    await tester.pumpAndSettle();
    await tapMapCell(tester, 2, 2);
  }

  Future<void> tapAndSettle(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  group('from the kernel building sheet', () {
    testWidgets('sending closes the sheet and opens the send picker',
        (tester) async {
      await openKernelBuilding(tester, kernelGarrisonGame());
      await tapAndSettle(tester, fr.volcanoGarrisonUnits);

      expect(find.byType(KernelGarrisonPanel), findsNothing);
      expect(find.text(fr.screenGarrisonSendInfo), findsOneWidget);
    });

    testWidgets('withdrawing closes the sheet and opens the withdraw '
        'picker', (tester) async {
      await openKernelBuilding(tester, kernelGarrisonGame(garrisoned: 2));
      await tapAndSettle(tester, fr.volcanoWithdraw);

      expect(find.byType(KernelGarrisonPanel), findsNothing);
      expect(find.text(fr.screenGarrisonWithdrawTitle), findsOneWidget);
      expect(find.text(fr.screenGarrisonWithdrawInfo), findsOneWidget);
    });
  });

  group('from the kernel cell on the map', () {
    testWidgets('sending garrisons the picked units and saves',
        (tester) async {
      final game = kernelGarrisonGame(onVolcano: 2);
      final repository = FakeGameRepository();
      await openKernelCell(tester, game, repository);
      await tapAndSettle(tester, fr.volcanoGarrisonUnits);
      expect(find.text(fr.screenGarrisonSendInfo), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tapAndSettle(tester, '${fr.commonSend} (1)');

      expect(KernelGarrison.sizeOf(game.humanPlayer), 1);
      expect(repository.saveCallCount, greaterThan(0));
      expect(find.text(fr.screenGarrisonSize(1)), findsOneWidget);
    });

    testWidgets('withdrawing opens the withdraw picker', (tester) async {
      await openKernelCell(
          tester, kernelGarrisonGame(garrisoned: 2), FakeGameRepository());
      await tapAndSettle(tester, fr.volcanoWithdraw);

      expect(find.byType(KernelGarrisonPanel), findsNothing);
      expect(find.text(fr.screenGarrisonWithdrawInfo), findsOneWidget);
    });
  });
}
