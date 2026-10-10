import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/descent_dialog.dart';
import 'package:abyss/presentation/screens/game/fight/transition_army_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Game gameWithBase(TransitionBaseType type, {String? capturedBy}) {
    final base = TransitionBase(type: type, name: 'Faille Noire');
    final game = harnessGame(plainMap({
      GridPosition(x: 2, y: 2): MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.transitionBase,
        transitionBase: base,
      ),
    }));
    base.capturedBy = capturedBy == null ? null : game.humanPlayer.id;
    return game;
  }

  Future<void> open(WidgetTester tester, Game game, {int x = 2}) async {
    await tester.pumpWidget(mapTabHost(game));
    await tester.pumpAndSettle();
    await tapMapCell(tester, x, 2);
  }

  group('transition base', () {
    testWidgets('an uncaptured base can be assaulted', (tester) async {
      await open(tester, gameWithBase(TransitionBaseType.faille));
      await tester.tap(find.text('Assaut'));
      await tester.pumpAndSettle();

      expect(find.byType(TransitionArmySelectionScreen), findsOneWidget);
      expect(find.text('Assaut : Faille Noire'), findsOneWidget);
    });

    testWidgets('a captured chimney requires the pressure capsule',
        (tester) async {
      await open(
        tester,
        gameWithBase(TransitionBaseType.cheminee, capturedBy: 'me'),
      );
      expect(find.textContaining('Capsule Pressurisée'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('a captured rift with descent module opens the descent',
        (tester) async {
      final game = gameWithBase(TransitionBaseType.faille, capturedBy: 'me');
      game.humanPlayer.buildings[BuildingType.descentModule] =
          Building(type: BuildingType.descentModule, level: 1);
      await open(tester, game);

      await tester.tap(find.text('Envoyer des unités au Niveau 2'));
      await tester.pumpAndSettle();

      expect(find.byType(DescentDialog), findsOneWidget);
      expect(find.text('Descente vers le Niveau 2'), findsOneWidget);
    });
  });

  group('exploration of a hidden cell', () {
    Game hiddenGame({required int scouts}) => harnessGame(
          plainMap(),
          revealed: [GridPosition(x: 5, y: 5)],
          scouts: scouts,
        );

    testWidgets('sending a scout queues an exploration and saves',
        (tester) async {
      final game = hiddenGame(scouts: 2);
      final repository = FakeGameRepository();
      var changes = 0;
      await tester.pumpWidget(mapTabHost(
        game,
        repository: repository,
        onChanged: () => changes++,
      ));
      await tester.pumpAndSettle();
      await tapMapCell(tester, 6, 6);

      expect(find.text('Explorer (6, 6)'), findsOneWidget);
      await tester.tap(find.text('Envoyer'));
      await tester.pumpAndSettle();

      final human = game.humanPlayer;
      expect(human.pendingExplorations.single.target,
          GridPosition(x: 6, y: 6));
      expect(human.unitsOnLevel(1)[UnitType.scout]!.count, 1);
      expect(changes, 1);
      expect(repository.saveCallCount, 1);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('a far cell cannot be explored', (tester) async {
      await open(tester, hiddenGame(scouts: 1), x: 0);

      expect(find.text('Cellule non éligible'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
