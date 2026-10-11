import '../building/building_type.dart';
import '../fight/army_planner.dart';
import '../unit/unit_type.dart';
import 'faction_personality.dart';

/// How a personality plays, as numbers the brain reads: how often and how
/// boldly it attacks, what it arms with and what it builds first. All of
/// them still run for the kernel; a trait only bends the road.
class FactionTraits {
  /// Turns between two war slots of the faction.
  final int cadence;

  /// Share of rehearsals the faction must win before it attacks.
  final double confidence;

  /// What it recruits for war, in this ratio.
  final Map<UnitType, int> warMix;

  /// Share of the stocks it puts into [warMix] each turn.
  final double warShare;

  /// Share of the stocks the conquest of the road to the kernel may spend.
  final double conquestShare;

  /// Whether it recruits to hold the announced raids.
  final bool defends;

  /// Whether it looks at the posts of the others before their bases.
  final bool postsFirst;

  ArmyPlanner get planner => ArmyPlanner(confidence: confidence);

  /// The order in which it grows its base.
  final List<BuildingType> growth;

  const FactionTraits({
    this.cadence = 6,
    this.confidence = 0.85,
    this.warMix = const <UnitType, int>{},
    this.warShare = 0,
    this.conquestShare = 0.5,
    this.defends = true,
    this.postsFirst = false,
    this.growth = defaultGrowth,
  });

  static const List<BuildingType> defaultGrowth = <BuildingType>[
    BuildingType.headquarters,
    BuildingType.solarPanel,
    BuildingType.algaeFarm,
    BuildingType.coralMine,
    BuildingType.oreExtractor,
    BuildingType.barracks,
    BuildingType.laboratory,
    BuildingType.coralCitadel,
  ];

  /// Raiders: they pay for the race with what they take.
  static const FactionTraits _pillagers = FactionTraits(
    cadence: 5,
    confidence: 0.8,
    warMix: <UnitType, int>{UnitType.harpoonist: 2, UnitType.saboteur: 1},
    warShare: 0.1,
    defends: true,
  );

  /// A timer: economy and walls first, few and heavy attacks.
  static const FactionTraits _order = FactionTraits(
    cadence: 9,
    confidence: 0.9,
    warMix: <UnitType, int>{UnitType.guardian: 1, UnitType.domeBreaker: 1},
    warShare: 0.1,
    growth: <BuildingType>[
      BuildingType.solarPanel,
      BuildingType.algaeFarm,
      BuildingType.coralMine,
      BuildingType.oreExtractor,
      BuildingType.headquarters,
      BuildingType.coralCitadel,
      BuildingType.laboratory,
      BuildingType.barracks,
    ],
  );

  /// Holds posts: it takes the others' before their bases.
  static const FactionTraits _cult = FactionTraits(
    cadence: 5,
    confidence: 0.8,
    warMix: <UnitType, int>{UnitType.guardian: 1, UnitType.harpoonist: 1},
    warShare: 0.2,
    postsFirst: true,
  );

  static FactionTraits of(FactionPersonality personality) =>
      switch (personality) {
        FactionPersonality.wreckPillagers => _pillagers,
        FactionPersonality.pearlOrder => _order,
        FactionPersonality.anglerCult => _cult,
        _ => const FactionTraits(),
      };
}
