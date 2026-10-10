import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/history_entry_texts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';
import '../../helpers/history_entry_samples.dart';

RecruitEntry _recruit(UnitType type, int quantity) =>
    RecruitEntry(turn: 1, unitType: type, quantity: quantity);

void main() {
  test('titles a recruitment with the plural of its units', () {
    expect(_recruit(UnitType.scout, 1).displayTitle(fr), '1 éclaireur recruté');
    expect(
      _recruit(UnitType.scout, 3).displayTitle(fr),
      '3 éclaireurs recrutés',
    );
    expect(_recruit(UnitType.scout, 1).displayTitle(en), '1 scout recruited');
    expect(_recruit(UnitType.scout, 3).displayTitle(en), '3 scouts recruited');
    expect(
      _recruit(UnitType.scout, 1).displayTitle(es),
      '1 explorador reclutado',
    );
    expect(
      _recruit(UnitType.scout, 3).displayTitle(es),
      '3 exploradores reclutados',
    );
    expect(
      _recruit(UnitType.abyssAdmiral, 2).displayTitle(fr),
      '2 amiraux des abysses recrutés',
    );
  });

  test('titles buildings, research and coordinates in each language', () {
    final building = BuildingEntry(
      turn: 1,
      buildingType: BuildingType.barracks,
      newLevel: 2,
    );
    expect(building.displayTitle(fr), 'Caserne niv. 2');
    expect(building.displayTitle(en), 'Barracks lv. 2');
    final unlock = ResearchEntry(
      turn: 1,
      branch: TechBranch.military,
      isUnlock: true,
    );
    expect(unlock.displayTitle(fr), 'Militaire débloquée');
    expect(unlock.displayTitle(es), 'Militar desbloqueada');
    final research = ResearchEntry(
      turn: 1,
      branch: TechBranch.resources,
      isUnlock: false,
      newLevel: 3,
    );
    expect(research.displayTitle(en), 'Resources lv. 3');
    final explore = ExploreEntry(turn: 1, targetX: 5, targetY: 7);
    expect(explore.displayTitle(fr), 'Exploration (5, 7)');
    expect(explore.displayTitle(es), 'Exploración (5, 7)');
    final collect = CollectEntry(
      turn: 1,
      targetX: 2,
      targetY: 4,
      gains: const {},
    );
    expect(collect.displayTitle(fr), 'Trésor collecté (2, 4)');
    expect(collect.displayTitle(en), 'Treasure collected (2, 4)');
    expect(turnEndEntry(12).displayTitle(fr), 'Tour 12 terminé');
    expect(turnEndEntry(12).displayTitle(en), 'Turn 12 ended');
  });

  test('entries without details have no subtitle', () {
    expect(combatEntry(victory: true).displaySubtitle(fr), isNull);
    expect(_recruit(UnitType.guardian, 2).displaySubtitle(en), isNull);
  });
}
