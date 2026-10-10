import '../resource/resource_type.dart';
import 'objective_chapter.dart';

/// Resources each objective pays, by chapter. Starting values, to retune
/// with the simulator.
class ObjectiveRewards {
  const ObjectiveRewards._();

  /// What each objective of [chapter] pays, the victory aside.
  static Map<ResourceType, int> ofChapter(ObjectiveChapter chapter) =>
      switch (chapter) {
        ObjectiveChapter.installation => installation,
        ObjectiveChapter.reef => reef,
        ObjectiveChapter.rift => rift,
        ObjectiveChapter.chimney => chimney,
        ObjectiveChapter.kernel => kernel,
        ObjectiveChapter.awakening => awakening,
      };

  static const Map<ResourceType, int> installation = {
    ResourceType.coral: 30,
    ResourceType.ore: 20,
  };

  static const Map<ResourceType, int> reef = {
    ResourceType.coral: 60,
    ResourceType.ore: 40,
    ResourceType.algae: 40,
  };

  static const Map<ResourceType, int> rift = {
    ResourceType.coral: 100,
    ResourceType.ore: 70,
    ResourceType.algae: 60,
  };

  static const Map<ResourceType, int> chimney = {
    ResourceType.coral: 150,
    ResourceType.ore: 100,
    ResourceType.algae: 90,
  };

  static const Map<ResourceType, int> kernel = {
    ResourceType.coral: 200,
    ResourceType.ore: 140,
    ResourceType.algae: 120,
  };

  static const Map<ResourceType, int> awakening = {
    ResourceType.coral: 250,
    ResourceType.ore: 170,
    ResourceType.algae: 150,
  };

  /// The last objective wins the game: nothing more to pay.
  static const Map<ResourceType, int> victory = {};
}
