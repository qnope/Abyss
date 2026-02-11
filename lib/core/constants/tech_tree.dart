import 'package:abysses/domain/models/technology.dart';

/// Static definition of a technology in the tech tree.
class TechDefinition {
  final String techId;
  final String name;
  final TechBranch branch;
  final TechTier tier;
  final String description;
  final Duration researchTime;
  final int pointsRequired;
  final String? prerequisite;

  const TechDefinition({
    required this.techId,
    required this.name,
    required this.branch,
    required this.tier,
    required this.description,
    required this.researchTime,
    required this.pointsRequired,
    this.prerequisite,
  });
}

/// The complete tech tree: 5 branches x 3 tiers = 15 technologies.
class TechTree {
  TechTree._();

  // ---------------------------------------------------------------------------
  // Architecture
  // ---------------------------------------------------------------------------
  static const TechDefinition coralReinforce = TechDefinition(
    techId: 'coralReinforce',
    name: 'Renforcement corallien',
    branch: TechBranch.architecture,
    tier: TechTier.t1,
    description: '+20% durabilité des bâtiments',
    researchTime: Duration(hours: 1),
    pointsRequired: 100,
  );

  static const TechDefinition bioCement = TechDefinition(
    techId: 'bioCement',
    name: 'Bio-ciment',
    branch: TechBranch.architecture,
    tier: TechTier.t2,
    description: '-10% coût de construction',
    researchTime: Duration(hours: 4),
    pointsRequired: 400,
    prerequisite: 'coralReinforce',
  );

  static const TechDefinition livingCoral = TechDefinition(
    techId: 'livingCoral',
    name: 'Corail vivant',
    branch: TechBranch.architecture,
    tier: TechTier.t3,
    description: 'Auto-réparation 1%/h',
    researchTime: Duration(hours: 12),
    pointsRequired: 1200,
    prerequisite: 'bioCement',
  );

  // ---------------------------------------------------------------------------
  // Armament
  // ---------------------------------------------------------------------------
  static const TechDefinition advancedAlloys = TechDefinition(
    techId: 'advancedAlloys',
    name: 'Alliages avancés',
    branch: TechBranch.armament,
    tier: TechTier.t1,
    description: '+10% HP des unités',
    researchTime: Duration(hours: 1),
    pointsRequired: 100,
  );

  static const TechDefinition guidedTorpedoes = TechDefinition(
    techId: 'guidedTorpedoes',
    name: 'Torpilles guidées',
    branch: TechBranch.armament,
    tier: TechTier.t2,
    description: '+20% puissance des torpilles',
    researchTime: Duration(hours: 4),
    pointsRequired: 400,
    prerequisite: 'advancedAlloys',
  );

  static const TechDefinition pulseWeapons = TechDefinition(
    techId: 'pulseWeapons',
    name: 'Armes à impulsion',
    branch: TechBranch.armament,
    tier: TechTier.t3,
    description: 'Dégâts de type EMP',
    researchTime: Duration(hours: 12),
    pointsRequired: 1200,
    prerequisite: 'guidedTorpedoes',
  );

  // ---------------------------------------------------------------------------
  // Life Sciences
  // ---------------------------------------------------------------------------
  static const TechDefinition airRecyclers = TechDefinition(
    techId: 'airRecyclers',
    name: 'Recycleurs d\'air',
    branch: TechBranch.lifeSciences,
    tier: TechTier.t1,
    description: '-15% consommation énergie des bâtiments',
    researchTime: Duration(hours: 1),
    pointsRequired: 100,
  );

  static const TechDefinition resilientPopulation = TechDefinition(
    techId: 'resilientPopulation',
    name: 'Population résiliente',
    branch: TechBranch.lifeSciences,
    tier: TechTier.t2,
    description: 'Alerte rouge 2x plus lente',
    researchTime: Duration(hours: 4),
    pointsRequired: 400,
    prerequisite: 'airRecyclers',
  );

  static const TechDefinition abyssalMedicine = TechDefinition(
    techId: 'abyssalMedicine',
    name: 'Médecine abyssale',
    branch: TechBranch.lifeSciences,
    tier: TechTier.t3,
    description: '+50% régénération des troupes',
    researchTime: Duration(hours: 12),
    pointsRequired: 1200,
    prerequisite: 'resilientPopulation',
  );

  // ---------------------------------------------------------------------------
  // Energy
  // ---------------------------------------------------------------------------
  static const TechDefinition capacitors = TechDefinition(
    techId: 'capacitors',
    name: 'Condensateurs',
    branch: TechBranch.energy,
    tier: TechTier.t1,
    description: '+20% stockage énergie',
    researchTime: Duration(hours: 1),
    pointsRequired: 100,
  );

  static const TechDefinition energyShields = TechDefinition(
    techId: 'energyShields',
    name: 'Boucliers énergétiques',
    branch: TechBranch.energy,
    tier: TechTier.t2,
    description: 'Boucliers sur les unités',
    researchTime: Duration(hours: 4),
    pointsRequired: 400,
    prerequisite: 'capacitors',
  );

  static const TechDefinition photonicDecoys = TechDefinition(
    techId: 'photonicDecoys',
    name: 'Leurres photoniques',
    branch: TechBranch.energy,
    tier: TechTier.t3,
    description: 'Leurres défensifs',
    researchTime: Duration(hours: 12),
    pointsRequired: 1200,
    prerequisite: 'energyShields',
  );

  // ---------------------------------------------------------------------------
  // Central
  // ---------------------------------------------------------------------------
  static const TechDefinition advancedCartography = TechDefinition(
    techId: 'advancedCartography',
    name: 'Cartographie avancée',
    branch: TechBranch.central,
    tier: TechTier.t1,
    description: '+30% carte révélée',
    researchTime: Duration(hours: 1),
    pointsRequired: 100,
  );

  static const TechDefinition advancedDiplomacy = TechDefinition(
    techId: 'advancedDiplomacy',
    name: 'Diplomatie avancée',
    branch: TechBranch.central,
    tier: TechTier.t2,
    description: 'Débloque les pactes de non-agression',
    researchTime: Duration(hours: 4),
    pointsRequired: 400,
    prerequisite: 'advancedCartography',
  );

  static const TechDefinition deepNavigation = TechDefinition(
    techId: 'deepNavigation',
    name: 'Navigation profonde',
    branch: TechBranch.central,
    tier: TechTier.t3,
    description: '+20% vitesse des unités',
    researchTime: Duration(hours: 12),
    pointsRequired: 1200,
    prerequisite: 'advancedDiplomacy',
  );

  // ---------------------------------------------------------------------------
  // Full catalog
  // ---------------------------------------------------------------------------

  /// All 15 technologies, keyed by their techId.
  static const Map<String, TechDefinition> all = {
    'coralReinforce': coralReinforce,
    'bioCement': bioCement,
    'livingCoral': livingCoral,
    'advancedAlloys': advancedAlloys,
    'guidedTorpedoes': guidedTorpedoes,
    'pulseWeapons': pulseWeapons,
    'airRecyclers': airRecyclers,
    'resilientPopulation': resilientPopulation,
    'abyssalMedicine': abyssalMedicine,
    'capacitors': capacitors,
    'energyShields': energyShields,
    'photonicDecoys': photonicDecoys,
    'advancedCartography': advancedCartography,
    'advancedDiplomacy': advancedDiplomacy,
    'deepNavigation': deepNavigation,
  };

  /// Technologies grouped by branch.
  static const Map<TechBranch, List<TechDefinition>> byBranch = {
    TechBranch.architecture: [coralReinforce, bioCement, livingCoral],
    TechBranch.armament: [advancedAlloys, guidedTorpedoes, pulseWeapons],
    TechBranch.lifeSciences: [airRecyclers, resilientPopulation, abyssalMedicine],
    TechBranch.energy: [capacitors, energyShields, photonicDecoys],
    TechBranch.central: [advancedCartography, advancedDiplomacy, deepNavigation],
  };
}
