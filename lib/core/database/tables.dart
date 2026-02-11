import 'package:drift/drift.dart';

class PlayerTable extends Table {
  @override
  String get tableName => 'player';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get experience => integer().withDefault(const Constant(0))();
  IntColumn get credits => integer().withDefault(const Constant(5000))();
  IntColumn get biomass => integer().withDefault(const Constant(3000))();
  IntColumn get minerals => integer().withDefault(const Constant(2000))();
  IntColumn get energy => integer().withDefault(const Constant(1500))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastPlayedAt => dateTime()();
  RealColumn get gameSpeedMultiplier =>
      real().withDefault(const Constant(1.0))();
  BoolColumn get tutorialCompleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get talentsUnlocked =>
      text().withDefault(const Constant('[]'))();
  TextColumn get playstylePreference =>
      text().withDefault(const Constant('balanced'))();
}

class ColoniesTable extends Table {
  @override
  String get tableName => 'colonies';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get ownerType => text()(); // 'player' or 'ai'
  TextColumn get name => text()();
  TextColumn get typePersonnalite => text()();
  IntColumn get positionX => integer()();
  IntColumn get positionY => integer()();
  TextColumn get faction =>
      text().withDefault(const Constant('independent'))();
  IntColumn get population => integer().withDefault(const Constant(100))();
  IntColumn get niveauDome => integer().withDefault(const Constant(1))();
  IntColumn get healthDome => integer().withDefault(const Constant(100))();
  IntColumn get credits => integer().withDefault(const Constant(1000))();
  IntColumn get biomass => integer().withDefault(const Constant(800))();
  IntColumn get minerals => integer().withDefault(const Constant(500))();
  IntColumn get energy => integer().withDefault(const Constant(300))();
  IntColumn get loyalty => integer().withDefault(const Constant(50))();
  TextColumn get aiPersonalityTraits =>
      text().withDefault(const Constant('{}'))();
  TextColumn get aiBehaviorState =>
      text().withDefault(const Constant('expansion')).nullable()();
  IntColumn get aiThreatLevel =>
      integer().withDefault(const Constant(0)).nullable()();
  BoolColumn get discoveredByPlayer =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastActivityAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [
        {positionX, positionY}
      ];
}

class BuildingsTable extends Table {
  @override
  String get tableName => 'buildings';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get colonyId => integer().references(ColoniesTable, #id)();
  TextColumn get buildingType => text()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  DateTimeColumn get constructionEndTime => dateTime().nullable()();
  IntColumn get damageLevel => integer().withDefault(const Constant(0))();
  RealColumn get productionRate =>
      real().withDefault(const Constant(1.0))();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get builtAt => dateTime()();
}

class TroopsTable extends Table {
  @override
  String get tableName => 'troops';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get colonyId => integer().references(ColoniesTable, #id)();
  TextColumn get troopType => text()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  IntColumn get healthPerUnit =>
      integer().withDefault(const Constant(100))();
  TextColumn get status =>
      text().withDefault(const Constant('idle'))();
  IntColumn get targetX => integer().nullable()();
  IntColumn get targetY => integer().nullable()();
  DateTimeColumn get etaArrival => dateTime().nullable()();
  IntColumn get morale => integer().withDefault(const Constant(75))();
  DateTimeColumn get trainedAt => dateTime()();
}

class WorldMapTable extends Table {
  @override
  String get tableName => 'world_map';

  IntColumn get zoneId => integer().autoIncrement()();
  IntColumn get chunkX => integer()();
  IntColumn get chunkY => integer()();
  TextColumn get terrainType =>
      text().withDefault(const Constant('plaine_abyssale'))();
  IntColumn get depthLevel => integer()();
  TextColumn get specialResource => text().nullable()();
  RealColumn get resourceAbundance =>
      real().withDefault(const Constant(1.0))();
  IntColumn get explorationLevel =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get discoveredAt => dateTime().nullable()();

  @override
  List<Set<Column>>? get uniqueKeys => [
        {chunkX, chunkY}
      ];
}

class CombatLogTable extends Table {
  @override
  String get tableName => 'combat_log';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get attackerId => integer().references(ColoniesTable, #id)();
  IntColumn get defenderId => integer().references(ColoniesTable, #id)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get combatType =>
      text().withDefault(const Constant('raid'))();
  TextColumn get result => text()();
  TextColumn get attackerLossesJson => text()();
  TextColumn get defenderLossesJson => text()();
  TextColumn get spoilsJson => text().nullable()();
  TextColumn get battleLogJson => text().nullable()();
}

class MessagesTable extends Table {
  @override
  String get tableName => 'messages';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get fromColonyId =>
      integer().references(ColoniesTable, #id)();
  IntColumn get toColonyId =>
      integer().references(ColoniesTable, #id)();
  TextColumn get messageType => text()();
  TextColumn get contentTemplateId => text()();
  TextColumn get variablesJson =>
      text().withDefault(const Constant('{}'))();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isRead =>
      boolean().withDefault(const Constant(false))();
  TextColumn get responseType => text().nullable()();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
}

class DiplomacyTable extends Table {
  @override
  String get tableName => 'diplomacy';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get colony1Id => integer().references(ColoniesTable, #id)();
  IntColumn get colony2Id => integer().references(ColoniesTable, #id)();
  TextColumn get relationType =>
      text().withDefault(const Constant('neutral'))();
  IntColumn get disposition =>
      integer().withDefault(const Constant(0))();
  IntColumn get trustLevel =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastInteraction => dateTime().nullable()();
  TextColumn get pactType => text().nullable()();
  DateTimeColumn get pactExpiryTime => dateTime().nullable()();
  BoolColumn get treatyViolated =>
      boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>>? get uniqueKeys => [
        {colony1Id, colony2Id}
      ];
}

class ResearchTable extends Table {
  @override
  String get tableName => 'research';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get techId => text().unique()();
  TextColumn get techName => text()();
  IntColumn get techTier => integer()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get completionPercentage =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get pointsRequired => integer()();
  IntColumn get pointsInvested =>
      integer().withDefault(const Constant(0))();
  TextColumn get prerequisitesJson =>
      text().withDefault(const Constant('[]'))();
}

class QuestsTable extends Table {
  @override
  String get tableName => 'quests';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get questId => text().unique()();
  TextColumn get questName => text()();
  TextColumn get questType => text()();
  TextColumn get description => text().nullable()();
  TextColumn get progressJson =>
      text().withDefault(const Constant('{}'))();
  IntColumn get progressPercentage =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get rewardXp =>
      integer().withDefault(const Constant(0))();
  IntColumn get rewardCredits =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
}
