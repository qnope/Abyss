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

  /// Share of the stocks it puts into war on [turn].
  double shareOn(int turn) => turn < rushUntil ? rushShare : warShare;

  ArmyPlanner get planner => ArmyPlanner(confidence: confidence);

  /// Turn before which [rushShare] replaces [warShare]: an early striker.
  final int rushUntil;

  /// Share of the stocks put into war while the rush lasts.
  final double rushShare;

  /// Whether it looks at the kernel others hold before their bases.
  final bool kernelFirst;

  /// Share of the home fighters sent down to reinforce the kernel it holds.
  final double guardShare;

  /// Scouts it keeps exploring the level while it is not fully known.
  final int explorers;

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
    this.rushUntil = 0,
    this.rushShare = 0,
    this.kernelFirst = false,
    this.guardShare = 0.5,
    this.explorers = 2,
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

  /// Strikes first and early, then thins out: the mass eats the algae.
  static const FactionTraits _horde = FactionTraits(
    cadence: 4,
    confidence: 0.7,
    warMix: <UnitType, int>{UnitType.harpoonist: 3},
    warShare: 0.05,
    rushUntil: 30,
    rushShare: 0.2,
  );

  /// Slow start, solid rampart, attacks only when sure.
  static const FactionTraits _guild = FactionTraits(
    cadence: 12,
    confidence: 0.95,
    warMix: <UnitType, int>{UnitType.guardian: 1},
    warShare: 0.08,
    growth: <BuildingType>[
      BuildingType.solarPanel,
      BuildingType.algaeFarm,
      BuildingType.coralMine,
      BuildingType.coralCitadel,
      BuildingType.oreExtractor,
      BuildingType.headquarters,
      BuildingType.laboratory,
      BuildingType.barracks,
    ],
  );

  /// Unseen and small: rare strikes by a handful of saboteurs.
  static const FactionTraits _monks = FactionTraits(
    cadence: 12,
    confidence: 0.9,
    warMix: <UnitType, int>{UnitType.saboteur: 1},
    warShare: 0.04,
  );

  /// Gatherers: they roam, raise the Citadel last and hit the unguarded.
  static const FactionTraits _nomads = FactionTraits(
    cadence: 7,
    confidence: 0.75,
    warMix: <UnitType, int>{UnitType.harpoonist: 1},
    warShare: 0.06,
    explorers: 3,
    conquestShare: 0.65,
    guardShare: 0.7,
    growth: <BuildingType>[
      BuildingType.headquarters,
      BuildingType.solarPanel,
      BuildingType.algaeFarm,
      BuildingType.coralMine,
      BuildingType.oreExtractor,
      BuildingType.barracks,
      BuildingType.laboratory,
      BuildingType.coralCitadel,
    ],
  );

  /// Numbers: farms and barracks before anything.
  static const FactionTraits _hive = FactionTraits(
    cadence: 8,
    confidence: 0.8,
    warMix: <UnitType, int>{UnitType.harpoonist: 1},
    warShare: 0.12,
    growth: <BuildingType>[
      BuildingType.algaeFarm,
      BuildingType.barracks,
      BuildingType.solarPanel,
      BuildingType.headquarters,
      BuildingType.coralMine,
      BuildingType.oreExtractor,
      BuildingType.laboratory,
      BuildingType.coralCitadel,
    ],
  );

  /// Race down, over the posts of the others.
  static const FactionTraits _smiths = FactionTraits(
    cadence: 8,
    confidence: 0.8,
    warMix: <UnitType, int>{UnitType.guardian: 1, UnitType.domeBreaker: 1},
    warShare: 0.1,
    conquestShare: 0.65,
    postsFirst: true,
  );

  /// Hold the kernel, and take it back from whoever holds it.
  static const FactionTraits _faithful = FactionTraits(
    cadence: 5,
    confidence: 0.85,
    warMix: <UnitType, int>{UnitType.domeBreaker: 1, UnitType.guardian: 1},
    warShare: 0.1,
    kernelFirst: true,
    guardShare: 0.8,
  );

  static FactionTraits of(FactionPersonality personality) =>
      switch (personality) {
        FactionPersonality.wreckPillagers => _pillagers,
        FactionPersonality.pearlOrder => _order,
        FactionPersonality.anglerCult => _cult,
        FactionPersonality.murenaHorde => _horde,
        FactionPersonality.siphonophoreGuild => _guild,
        FactionPersonality.silenceMonks => _monks,
        FactionPersonality.currentNomads => _nomads,
        FactionPersonality.pyrosomeHive => _hive,
        FactionPersonality.magmaSmiths => _smiths,
        FactionPersonality.krakenFaithful => _faithful,
      };
}
