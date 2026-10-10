import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/guide_helpers.dart';
import '../../../helpers/objective_helpers.dart';

void main() {
  group('the guide stays silent', () {
    test('when the tutorial is off', () {
      expect(
        adviceOf(guideGame(ObjectiveId.hqLevel1, tutorial: false)),
        isNull,
      );
    });

    test('once the tutorial chapter is done', () {
      expect(adviceOf(guideGame(ObjectiveId.takeLair)), isNull);
    });
  });

  group('each objective of the tutorial teaches its lesson', () {
    const lessons = {
      ObjectiveId.hqLevel1: ['QG', 'un seul par tour', '« Tour suivant »'],
      ObjectiveId.algaeFarm: ['algues nourrissent ton armée'],
      ObjectiveId.mines: ['Mine de corail', 'Extracteur', 'plus cher'],
      ObjectiveId.solarPanel: ['énergie', 'Extracteur', 'Caserne'],
      ObjectiveId.hqLevel2: ['Caserne', 'Laboratoire', 'jauge', 'bruit'],
      ObjectiveId.barracksAndScouts: ['2 Éclaireurs', 'algues', 'bruit'],
      ObjectiveId.explore: ['brouillard', 'repaires', 'familles', 'coffres'],
      ObjectiveId.laboratoryAndResearch: [
        'Une seule recherche par tour',
        'définitifs',
      ],
      ObjectiveId.firstRaid: ['2 tours', 'Harponneurs', 'Citadelle'],
    };
    for (final MapEntry(key: id, value: words) in lessons.entries) {
      test(id.name, () {
        final text = adviceOf(guideGame(id))!.text;
        for (final word in words) {
          expect(text, contains(word));
        }
        expect('.'.allMatches(text).length, inInclusiveRange(2, 3));
      });
    }
  });

  group('the halo points at what to touch', () {
    GuideTarget targetOn(ObjectiveId id, [void Function(Player)? setUp]) {
      final game = guideGame(id);
      setUp?.call(game.humanPlayer);
      return adviceOf(game)!.target;
    }

    test('a building to raise', () {
      expect(
        targetOn(ObjectiveId.hqLevel1),
        const GuideTarget.building(BuildingType.headquarters),
      );
      expect(
        targetOn(ObjectiveId.algaeFarm),
        const GuideTarget.building(BuildingType.algaeFarm),
      );
      expect(
        targetOn(ObjectiveId.solarPanel),
        const GuideTarget.building(BuildingType.solarPanel),
      );
      expect(
        targetOn(ObjectiveId.hqLevel2),
        const GuideTarget.building(BuildingType.headquarters),
      );
    });

    test('the mine first, then the extractor', () {
      expect(
        targetOn(ObjectiveId.mines),
        const GuideTarget.building(BuildingType.coralMine),
      );
      expect(
        targetOn(
          ObjectiveId.mines,
          (p) => setBuilding(p, BuildingType.coralMine, 1),
        ),
        const GuideTarget.building(BuildingType.oreExtractor),
      );
    });

    test('the barracks first, then the scouts', () {
      expect(
        targetOn(ObjectiveId.barracksAndScouts),
        const GuideTarget.building(BuildingType.barracks),
      );
      expect(
        targetOn(
          ObjectiveId.barracksAndScouts,
          (p) => setBuilding(p, BuildingType.barracks, 1),
        ),
        const GuideTarget.unit(UnitType.scout),
      );
    });

    test('the map to explore', () {
      expect(targetOn(ObjectiveId.explore), const GuideTarget.map());
    });

    test('the laboratory, then a branch, then its first research', () {
      expect(
        targetOn(ObjectiveId.laboratoryAndResearch),
        const GuideTarget.building(BuildingType.laboratory),
      );
      void lab(Player p) => setBuilding(p, BuildingType.laboratory, 1);
      expect(
        targetOn(ObjectiveId.laboratoryAndResearch, lab),
        GuideTarget.unlock(TechBranch.values.toSet()),
      );
      expect(
        targetOn(ObjectiveId.laboratoryAndResearch, (p) {
          lab(p);
          p.techBranches[TechBranch.military]!.unlocked = true;
        }),
        const GuideTarget.research({TechBranch.military}),
      );
    });

    test('the harpoonists against the first raid', () {
      expect(
        targetOn(ObjectiveId.firstRaid),
        const GuideTarget.unit(UnitType.harpoonist),
      );
    });
  });
}
