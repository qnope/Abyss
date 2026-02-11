/// Core game balance constants from the GDD.
class GameConstants {
  GameConstants._();

  // ---------------------------------------------------------------------------
  // Resource caps
  // ---------------------------------------------------------------------------
  static const int maxCredits = 500000;
  static const int maxBiomass = 300000;
  static const int maxMinerals = 200000;
  static const int maxEnergy = 150000;

  // ---------------------------------------------------------------------------
  // Initial player resources
  // ---------------------------------------------------------------------------
  static const int initialCredits = 5000;
  static const int initialBiomass = 3000;
  static const int initialMinerals = 2000;
  static const int initialEnergy = 1500;

  // ---------------------------------------------------------------------------
  // Initial AI colony resources
  // ---------------------------------------------------------------------------
  static const int aiInitialCredits = 1000;
  static const int aiInitialBiomass = 800;
  static const int aiInitialMinerals = 500;
  static const int aiInitialEnergy = 300;

  // ---------------------------------------------------------------------------
  // Production base rates (per hour)
  // ---------------------------------------------------------------------------
  static const double biomassFarmBaseRate = 100.0;
  static const double mineralMineBaseRate = 80.0;
  static const double energyPlantBaseRate = 120.0;
  static const double tradingPostBaseRate = 60.0;

  /// Level multiplier: production * (1 + (level - 1) * levelMultiplier)
  static const double levelMultiplier = 0.15;

  // ---------------------------------------------------------------------------
  // Construction time formula: base * constructionTimeExponent^(level-1)
  // ---------------------------------------------------------------------------
  static const double constructionTimeExponent = 1.3;

  /// Base construction times in seconds, by building category.
  static const int productionBuildTimeBase = 30;
  static const int militaryBuildTimeBase = 60;
  static const int utilityBuildTimeBase = 45;

  // ---------------------------------------------------------------------------
  // Dome
  // ---------------------------------------------------------------------------
  static const int maxDomeLevel = 15;

  /// Building slots available per dome level (index 0 = level 1).
  static const List<int> domeLevelSlots = [
    4, 5, 6, //     levels 1-3
    7, 8, 9, //     levels 4-6
    10, 11, 12, //  levels 7-9
    13, 14, 15, //  levels 10-12
    16, 17, 18, //  levels 13-15
  ];

  /// Population cap per dome level (index 0 = level 1).
  static const List<int> domeLevelPopulation = [
    50, 100, 150, //       levels 1-3
    200, 300, 400, //      levels 4-6
    500, 650, 800, //      levels 7-9
    1000, 1250, 1500, //   levels 10-12
    2000, 2500, 3000, //   levels 13-15
  ];

  // ---------------------------------------------------------------------------
  // Tick intervals
  // ---------------------------------------------------------------------------
  static const Duration activeTickInterval = Duration(seconds: 5);
  static const Duration semiActiveTickInterval = Duration(seconds: 30);
  static const Duration dormantTickInterval = Duration(minutes: 5);
  static const Duration dbSyncInterval = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Activity tier radii (map units)
  // ---------------------------------------------------------------------------
  static const double activeRadius = 200.0;
  static const double activeBuffer = 50.0;
  static const double semiActiveRadius = 500.0;
  static const double semiActiveBuffer = 100.0;

  // ---------------------------------------------------------------------------
  // Early game accelerator (first 72 hours)
  // ---------------------------------------------------------------------------
  static const Duration earlyGameDuration = Duration(hours: 72);
  static const double earlyGameConstructionMultiplier = 0.5;
  static const double earlyGameProductionMultiplier = 1.25;

  // ---------------------------------------------------------------------------
  // Diplomacy
  // ---------------------------------------------------------------------------
  static const Duration tradeCooldown = Duration(hours: 6);
  static const Duration messageCooldown = Duration(hours: 6);
  static const int maxMessagesPerDay = 15;

  /// Minimum disposition thresholds required for each pact type.
  static const int nonAggressionDisposition = 0;
  static const int tradeDisposition = 20;
  static const int mutualDefenseDisposition = 50;
  static const int allianceDisposition = 75;

  // ---------------------------------------------------------------------------
  // Combat
  // ---------------------------------------------------------------------------
  static const int maxCombatRounds = 15;
  static const double triangleDamageBonus = 1.40;
  static const double triangleArmorMalus = 0.80;
  static const double diversityBonusTri = 1.05;
  static const double diversityMalusMono = 0.90;
  static const double spoilsCap = 0.20;
  static const double spoilsBaseEfficiency = 0.60;
  static const double combatVariance = 0.15;

  // ---------------------------------------------------------------------------
  // World
  // ---------------------------------------------------------------------------
  static const int totalAIColonies = 100;
  static const int initialPopulation = 100;
  static const int aiInitialPopulation = 100;
}
