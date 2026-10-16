import '../script/strategies/growth_moves.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_option.dart';
import 'faction_personality.dart';

/// What a faction researches, by personality: the plan of a careful
/// player with the Explorer branch in it, deeper and earlier for the
/// personalities that go for the kernel.
///
/// Plans use the encoding of [GrowthMoves.researchPlan]: each entry is
/// the next node of its branch.
abstract final class FactionResearch {
  /// Explorer opens as the third branch, after Military 3, so that the
  /// dearer research that follows does not weaken the armies.
  static const List<TechBranch> defaultPlan = <TechBranch>[
    TechBranch.resources, TechBranch.military, TechBranch.resources,
    TechBranch.military, TechBranch.military, TechBranch.explorer,
    TechBranch.explorer, TechBranch.resources, TechBranch.military,
    TechBranch.resources, TechBranch.military, TechBranch.resources,
  ];

  /// Explorer right after Military 2, and down to node 3 after
  /// Resources 3: the sonar finds the kernel sooner.
  static const List<TechBranch> seekerPlan = <TechBranch>[
    TechBranch.resources, TechBranch.military, TechBranch.resources,
    TechBranch.military, TechBranch.explorer, TechBranch.explorer,
    TechBranch.military, TechBranch.resources, TechBranch.explorer,
    TechBranch.military, TechBranch.resources, TechBranch.military,
    TechBranch.resources,
  ];

  /// The personalities turned towards the kernel.
  static const Set<FactionPersonality> kernelSeekers = <FactionPersonality>{
    FactionPersonality.currentNomads,
    FactionPersonality.krakenFaithful,
    FactionPersonality.magmaSmiths,
  };

  /// Deep Sonar at node 2, Wreck Raiders at node 4.
  static const Map<TechBranch, List<TechOption>> defaultPicks = {
    TechBranch.military: [TechOption.b, TechOption.a],
    TechBranch.resources: [TechOption.a, TechOption.a],
    TechBranch.explorer: [TechOption.a, TechOption.a],
  };

  /// Silent Swim at node 2: less noise, so fewer raids.
  static const Map<TechBranch, List<TechOption>> silentPicks = {
    TechBranch.military: [TechOption.b, TechOption.a],
    TechBranch.resources: [TechOption.a, TechOption.a],
    TechBranch.explorer: [TechOption.b, TechOption.b],
  };

  /// The research plan of [personality].
  static List<TechBranch> planOf(FactionPersonality personality) =>
      kernelSeekers.contains(personality) ? seekerPlan : defaultPlan;

  /// The options [personality] takes at the choice nodes 2 and 4.
  static Map<TechBranch, List<TechOption>> picksOf(
    FactionPersonality personality,
  ) => personality == FactionPersonality.silenceMonks
      ? silentPicks
      : defaultPicks;
}
