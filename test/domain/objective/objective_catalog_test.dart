import 'package:abyss/domain/objective/objective_catalog.dart';
import 'package:abyss/domain/objective/objective_chapter.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_rewards.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ObjectiveChapter', () {
    test('six chapters in order with their French titles', () {
      expect(ObjectiveChapter.values.map((c) => c.title), [
        'Installation',
        'Le récif',
        'La Faille',
        'La Cheminée',
        'Le Noyau',
        'Le réveil',
      ]);
    });
  });

  group('ObjectiveId', () {
    test('is saved by a Hive adapter of type 53', () {
      expect(ObjectiveIdAdapter().typeId, 53);
    });
  });

  group('ObjectiveCatalog', () {
    test('holds every ObjectiveId exactly once, in enum order', () {
      expect(ObjectiveCatalog.all.map((o) => o.id), ObjectiveId.values);
    });

    test('chapters follow each other in order', () {
      final chapters = ObjectiveCatalog.all.map((o) => o.chapter).toList();
      final sorted = [...chapters]..sort((a, b) => a.index - b.index);
      expect(chapters, sorted);
      expect(chapters.toSet(), ObjectiveChapter.values.toSet());
    });

    test('objectives per chapter', () {
      expect(
        ObjectiveChapter.values.map(
          (c) => ObjectiveCatalog.ofChapter(c).length,
        ),
        [9, 3, 3, 4, 3, 2],
      );
      expect(
        ObjectiveCatalog.ofChapter(ObjectiveChapter.rift).map((o) => o.id),
        [
          ObjectiveId.takeFaille,
          ObjectiveId.descentModule,
          ObjectiveId.descendLevel2,
        ],
      );
    });

    test('byId finds the objective with its title', () {
      final objective = ObjectiveCatalog.byId(ObjectiveId.mines);
      expect(objective.id, ObjectiveId.mines);
      expect(objective.chapter, ObjectiveChapter.installation);
      expect(
        objective.title,
        'Construis la Mine de corail et l\'Extracteur de minerai',
      );
      expect(
        ObjectiveCatalog.byId(ObjectiveId.kernelLevel10).title,
        'Monte le Noyau au niveau 10',
      );
    });

    test('firstNotDone skips the completed ids in catalog order', () {
      expect(ObjectiveCatalog.firstNotDone({})!.id, ObjectiveId.hqLevel1);
      expect(
        ObjectiveCatalog.firstNotDone({
          ObjectiveId.hqLevel1,
          ObjectiveId.mines,
        })!.id,
        ObjectiveId.algaeFarm,
      );
      expect(ObjectiveCatalog.firstNotDone(ObjectiveId.values.toSet()), isNull);
    });

    test('every title is unique and non-empty', () {
      final titles = ObjectiveCatalog.all.map((o) => o.title).toList();
      expect(titles.toSet().length, titles.length);
      expect(titles.every((t) => t.isNotEmpty), isTrue);
    });
  });

  group('ObjectiveRewards', () {
    test('each chapter pays its reward, the victory nothing', () {
      Map<ResourceType, int> rewardOf(ObjectiveId id) =>
          ObjectiveCatalog.byId(id).reward;
      expect(rewardOf(ObjectiveId.hqLevel1), {
        ResourceType.coral: 30,
        ResourceType.ore: 20,
      });
      expect(rewardOf(ObjectiveId.coralCitadel), ObjectiveRewards.reef);
      expect(rewardOf(ObjectiveId.takeFaille), ObjectiveRewards.rift);
      expect(rewardOf(ObjectiveId.hqLevel8), ObjectiveRewards.chimney);
      expect(rewardOf(ObjectiveId.takeKernel), ObjectiveRewards.kernel);
      expect(rewardOf(ObjectiveId.kernelLevel5), {
        ResourceType.coral: 250,
        ResourceType.ore: 170,
        ResourceType.algae: 150,
      });
      expect(rewardOf(ObjectiveId.kernelLevel10), isEmpty);
      expect(
        ObjectiveRewards.ofChapter(ObjectiveChapter.installation),
        ObjectiveRewards.installation,
      );
    });

    test('every objective of a chapter but the victory pays something', () {
      for (final o in ObjectiveCatalog.all) {
        if (o.id == ObjectiveId.kernelLevel10) continue;
        expect(o.reward, isNotEmpty, reason: o.id.name);
      }
    });
  });
}
