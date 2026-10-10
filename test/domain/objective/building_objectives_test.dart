import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/objective_helpers.dart';

void main() {
  /// Checks that [id] asks [type] at [level]: one level short counts
  /// `level - 1`, [level] completes it.
  void expectBuildingGoal(ObjectiveId id, BuildingType type, int level) {
    final game = objectiveGame();
    expectProgress(game, id, 0, level);
    setBuilding(game.humanPlayer, type, level - 1);
    expectProgress(game, id, level - 1, level);
    setBuilding(game.humanPlayer, type, level);
    expectProgress(game, id, level, level);
  }

  group('Building objectives', () {
    test('hqLevel5: QG au niveau 5', () {
      expectBuildingGoal(ObjectiveId.hqLevel5, BuildingType.headquarters, 5);
    });

    test('coralCitadel: Citadelle construite', () {
      expectBuildingGoal(
        ObjectiveId.coralCitadel,
        BuildingType.coralCitadel,
        1,
      );
    });

    test('descentModule: Module de descente construit', () {
      expectBuildingGoal(
        ObjectiveId.descentModule,
        BuildingType.descentModule,
        1,
      );
    });

    test('hqLevel8: QG au niveau 8', () {
      expectBuildingGoal(ObjectiveId.hqLevel8, BuildingType.headquarters, 8);
    });

    test('pressureCapsule: Capsule construite', () {
      expectBuildingGoal(
        ObjectiveId.pressureCapsule,
        BuildingType.pressureCapsule,
        1,
      );
    });

    test('hqLevel10: QG au niveau 10', () {
      expectBuildingGoal(ObjectiveId.hqLevel10, BuildingType.headquarters, 10);
    });

    test('kernelLevel1: Noyau au niveau 1', () {
      expectBuildingGoal(
        ObjectiveId.kernelLevel1,
        BuildingType.volcanicKernel,
        1,
      );
    });

    test('kernelLevel5: Noyau au niveau 5', () {
      expectBuildingGoal(
        ObjectiveId.kernelLevel5,
        BuildingType.volcanicKernel,
        5,
      );
    });

    test('kernelLevel10: Noyau au niveau 10', () {
      expectBuildingGoal(
        ObjectiveId.kernelLevel10,
        BuildingType.volcanicKernel,
        10,
      );
    });

    test('a higher level stays capped at the target', () {
      final game = objectiveGame();
      setBuilding(game.humanPlayer, BuildingType.headquarters, 9);
      expectProgress(game, ObjectiveId.hqLevel5, 5, 5);
    });
  });
}
