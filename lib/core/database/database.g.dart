// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayerTableTable extends PlayerTable
    with TableInfo<$PlayerTableTable, PlayerTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _experienceMeta = const VerificationMeta(
    'experience',
  );
  @override
  late final GeneratedColumn<int> experience = GeneratedColumn<int>(
    'experience',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<int> credits = GeneratedColumn<int>(
    'credits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5000),
  );
  static const VerificationMeta _biomassMeta = const VerificationMeta(
    'biomass',
  );
  @override
  late final GeneratedColumn<int> biomass = GeneratedColumn<int>(
    'biomass',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3000),
  );
  static const VerificationMeta _mineralsMeta = const VerificationMeta(
    'minerals',
  );
  @override
  late final GeneratedColumn<int> minerals = GeneratedColumn<int>(
    'minerals',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2000),
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1500),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameSpeedMultiplierMeta =
      const VerificationMeta('gameSpeedMultiplier');
  @override
  late final GeneratedColumn<double> gameSpeedMultiplier =
      GeneratedColumn<double>(
        'game_speed_multiplier',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _tutorialCompletedMeta = const VerificationMeta(
    'tutorialCompleted',
  );
  @override
  late final GeneratedColumn<bool> tutorialCompleted = GeneratedColumn<bool>(
    'tutorial_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tutorial_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _talentsUnlockedMeta = const VerificationMeta(
    'talentsUnlocked',
  );
  @override
  late final GeneratedColumn<String> talentsUnlocked = GeneratedColumn<String>(
    'talents_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _playstylePreferenceMeta =
      const VerificationMeta('playstylePreference');
  @override
  late final GeneratedColumn<String> playstylePreference =
      GeneratedColumn<String>(
        'playstyle_preference',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('balanced'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    level,
    experience,
    credits,
    biomass,
    minerals,
    energy,
    createdAt,
    lastPlayedAt,
    gameSpeedMultiplier,
    tutorialCompleted,
    talentsUnlocked,
    playstylePreference,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('experience')) {
      context.handle(
        _experienceMeta,
        experience.isAcceptableOrUnknown(data['experience']!, _experienceMeta),
      );
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    }
    if (data.containsKey('biomass')) {
      context.handle(
        _biomassMeta,
        biomass.isAcceptableOrUnknown(data['biomass']!, _biomassMeta),
      );
    }
    if (data.containsKey('minerals')) {
      context.handle(
        _mineralsMeta,
        minerals.isAcceptableOrUnknown(data['minerals']!, _mineralsMeta),
      );
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPlayedAtMeta);
    }
    if (data.containsKey('game_speed_multiplier')) {
      context.handle(
        _gameSpeedMultiplierMeta,
        gameSpeedMultiplier.isAcceptableOrUnknown(
          data['game_speed_multiplier']!,
          _gameSpeedMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('tutorial_completed')) {
      context.handle(
        _tutorialCompletedMeta,
        tutorialCompleted.isAcceptableOrUnknown(
          data['tutorial_completed']!,
          _tutorialCompletedMeta,
        ),
      );
    }
    if (data.containsKey('talents_unlocked')) {
      context.handle(
        _talentsUnlockedMeta,
        talentsUnlocked.isAcceptableOrUnknown(
          data['talents_unlocked']!,
          _talentsUnlockedMeta,
        ),
      );
    }
    if (data.containsKey('playstyle_preference')) {
      context.handle(
        _playstylePreferenceMeta,
        playstylePreference.isAcceptableOrUnknown(
          data['playstyle_preference']!,
          _playstylePreferenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      experience: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}experience'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credits'],
      )!,
      biomass: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}biomass'],
      )!,
      minerals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minerals'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      )!,
      gameSpeedMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}game_speed_multiplier'],
      )!,
      tutorialCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tutorial_completed'],
      )!,
      talentsUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}talents_unlocked'],
      )!,
      playstylePreference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playstyle_preference'],
      )!,
    );
  }

  @override
  $PlayerTableTable createAlias(String alias) {
    return $PlayerTableTable(attachedDatabase, alias);
  }
}

class PlayerTableData extends DataClass implements Insertable<PlayerTableData> {
  final int id;
  final String username;
  final int level;
  final int experience;
  final int credits;
  final int biomass;
  final int minerals;
  final int energy;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final double gameSpeedMultiplier;
  final bool tutorialCompleted;
  final String talentsUnlocked;
  final String playstylePreference;
  const PlayerTableData({
    required this.id,
    required this.username,
    required this.level,
    required this.experience,
    required this.credits,
    required this.biomass,
    required this.minerals,
    required this.energy,
    required this.createdAt,
    required this.lastPlayedAt,
    required this.gameSpeedMultiplier,
    required this.tutorialCompleted,
    required this.talentsUnlocked,
    required this.playstylePreference,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['level'] = Variable<int>(level);
    map['experience'] = Variable<int>(experience);
    map['credits'] = Variable<int>(credits);
    map['biomass'] = Variable<int>(biomass);
    map['minerals'] = Variable<int>(minerals);
    map['energy'] = Variable<int>(energy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    map['game_speed_multiplier'] = Variable<double>(gameSpeedMultiplier);
    map['tutorial_completed'] = Variable<bool>(tutorialCompleted);
    map['talents_unlocked'] = Variable<String>(talentsUnlocked);
    map['playstyle_preference'] = Variable<String>(playstylePreference);
    return map;
  }

  PlayerTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerTableCompanion(
      id: Value(id),
      username: Value(username),
      level: Value(level),
      experience: Value(experience),
      credits: Value(credits),
      biomass: Value(biomass),
      minerals: Value(minerals),
      energy: Value(energy),
      createdAt: Value(createdAt),
      lastPlayedAt: Value(lastPlayedAt),
      gameSpeedMultiplier: Value(gameSpeedMultiplier),
      tutorialCompleted: Value(tutorialCompleted),
      talentsUnlocked: Value(talentsUnlocked),
      playstylePreference: Value(playstylePreference),
    );
  }

  factory PlayerTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerTableData(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      level: serializer.fromJson<int>(json['level']),
      experience: serializer.fromJson<int>(json['experience']),
      credits: serializer.fromJson<int>(json['credits']),
      biomass: serializer.fromJson<int>(json['biomass']),
      minerals: serializer.fromJson<int>(json['minerals']),
      energy: serializer.fromJson<int>(json['energy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastPlayedAt: serializer.fromJson<DateTime>(json['lastPlayedAt']),
      gameSpeedMultiplier: serializer.fromJson<double>(
        json['gameSpeedMultiplier'],
      ),
      tutorialCompleted: serializer.fromJson<bool>(json['tutorialCompleted']),
      talentsUnlocked: serializer.fromJson<String>(json['talentsUnlocked']),
      playstylePreference: serializer.fromJson<String>(
        json['playstylePreference'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'level': serializer.toJson<int>(level),
      'experience': serializer.toJson<int>(experience),
      'credits': serializer.toJson<int>(credits),
      'biomass': serializer.toJson<int>(biomass),
      'minerals': serializer.toJson<int>(minerals),
      'energy': serializer.toJson<int>(energy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastPlayedAt': serializer.toJson<DateTime>(lastPlayedAt),
      'gameSpeedMultiplier': serializer.toJson<double>(gameSpeedMultiplier),
      'tutorialCompleted': serializer.toJson<bool>(tutorialCompleted),
      'talentsUnlocked': serializer.toJson<String>(talentsUnlocked),
      'playstylePreference': serializer.toJson<String>(playstylePreference),
    };
  }

  PlayerTableData copyWith({
    int? id,
    String? username,
    int? level,
    int? experience,
    int? credits,
    int? biomass,
    int? minerals,
    int? energy,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    double? gameSpeedMultiplier,
    bool? tutorialCompleted,
    String? talentsUnlocked,
    String? playstylePreference,
  }) => PlayerTableData(
    id: id ?? this.id,
    username: username ?? this.username,
    level: level ?? this.level,
    experience: experience ?? this.experience,
    credits: credits ?? this.credits,
    biomass: biomass ?? this.biomass,
    minerals: minerals ?? this.minerals,
    energy: energy ?? this.energy,
    createdAt: createdAt ?? this.createdAt,
    lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    gameSpeedMultiplier: gameSpeedMultiplier ?? this.gameSpeedMultiplier,
    tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
    talentsUnlocked: talentsUnlocked ?? this.talentsUnlocked,
    playstylePreference: playstylePreference ?? this.playstylePreference,
  );
  PlayerTableData copyWithCompanion(PlayerTableCompanion data) {
    return PlayerTableData(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      level: data.level.present ? data.level.value : this.level,
      experience: data.experience.present
          ? data.experience.value
          : this.experience,
      credits: data.credits.present ? data.credits.value : this.credits,
      biomass: data.biomass.present ? data.biomass.value : this.biomass,
      minerals: data.minerals.present ? data.minerals.value : this.minerals,
      energy: data.energy.present ? data.energy.value : this.energy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      gameSpeedMultiplier: data.gameSpeedMultiplier.present
          ? data.gameSpeedMultiplier.value
          : this.gameSpeedMultiplier,
      tutorialCompleted: data.tutorialCompleted.present
          ? data.tutorialCompleted.value
          : this.tutorialCompleted,
      talentsUnlocked: data.talentsUnlocked.present
          ? data.talentsUnlocked.value
          : this.talentsUnlocked,
      playstylePreference: data.playstylePreference.present
          ? data.playstylePreference.value
          : this.playstylePreference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerTableData(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('level: $level, ')
          ..write('experience: $experience, ')
          ..write('credits: $credits, ')
          ..write('biomass: $biomass, ')
          ..write('minerals: $minerals, ')
          ..write('energy: $energy, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('gameSpeedMultiplier: $gameSpeedMultiplier, ')
          ..write('tutorialCompleted: $tutorialCompleted, ')
          ..write('talentsUnlocked: $talentsUnlocked, ')
          ..write('playstylePreference: $playstylePreference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    level,
    experience,
    credits,
    biomass,
    minerals,
    energy,
    createdAt,
    lastPlayedAt,
    gameSpeedMultiplier,
    tutorialCompleted,
    talentsUnlocked,
    playstylePreference,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerTableData &&
          other.id == this.id &&
          other.username == this.username &&
          other.level == this.level &&
          other.experience == this.experience &&
          other.credits == this.credits &&
          other.biomass == this.biomass &&
          other.minerals == this.minerals &&
          other.energy == this.energy &&
          other.createdAt == this.createdAt &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.gameSpeedMultiplier == this.gameSpeedMultiplier &&
          other.tutorialCompleted == this.tutorialCompleted &&
          other.talentsUnlocked == this.talentsUnlocked &&
          other.playstylePreference == this.playstylePreference);
}

class PlayerTableCompanion extends UpdateCompanion<PlayerTableData> {
  final Value<int> id;
  final Value<String> username;
  final Value<int> level;
  final Value<int> experience;
  final Value<int> credits;
  final Value<int> biomass;
  final Value<int> minerals;
  final Value<int> energy;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastPlayedAt;
  final Value<double> gameSpeedMultiplier;
  final Value<bool> tutorialCompleted;
  final Value<String> talentsUnlocked;
  final Value<String> playstylePreference;
  const PlayerTableCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.level = const Value.absent(),
    this.experience = const Value.absent(),
    this.credits = const Value.absent(),
    this.biomass = const Value.absent(),
    this.minerals = const Value.absent(),
    this.energy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.gameSpeedMultiplier = const Value.absent(),
    this.tutorialCompleted = const Value.absent(),
    this.talentsUnlocked = const Value.absent(),
    this.playstylePreference = const Value.absent(),
  });
  PlayerTableCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    this.level = const Value.absent(),
    this.experience = const Value.absent(),
    this.credits = const Value.absent(),
    this.biomass = const Value.absent(),
    this.minerals = const Value.absent(),
    this.energy = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastPlayedAt,
    this.gameSpeedMultiplier = const Value.absent(),
    this.tutorialCompleted = const Value.absent(),
    this.talentsUnlocked = const Value.absent(),
    this.playstylePreference = const Value.absent(),
  }) : username = Value(username),
       createdAt = Value(createdAt),
       lastPlayedAt = Value(lastPlayedAt);
  static Insertable<PlayerTableData> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<int>? level,
    Expression<int>? experience,
    Expression<int>? credits,
    Expression<int>? biomass,
    Expression<int>? minerals,
    Expression<int>? energy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastPlayedAt,
    Expression<double>? gameSpeedMultiplier,
    Expression<bool>? tutorialCompleted,
    Expression<String>? talentsUnlocked,
    Expression<String>? playstylePreference,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (level != null) 'level': level,
      if (experience != null) 'experience': experience,
      if (credits != null) 'credits': credits,
      if (biomass != null) 'biomass': biomass,
      if (minerals != null) 'minerals': minerals,
      if (energy != null) 'energy': energy,
      if (createdAt != null) 'created_at': createdAt,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (gameSpeedMultiplier != null)
        'game_speed_multiplier': gameSpeedMultiplier,
      if (tutorialCompleted != null) 'tutorial_completed': tutorialCompleted,
      if (talentsUnlocked != null) 'talents_unlocked': talentsUnlocked,
      if (playstylePreference != null)
        'playstyle_preference': playstylePreference,
    });
  }

  PlayerTableCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<int>? level,
    Value<int>? experience,
    Value<int>? credits,
    Value<int>? biomass,
    Value<int>? minerals,
    Value<int>? energy,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastPlayedAt,
    Value<double>? gameSpeedMultiplier,
    Value<bool>? tutorialCompleted,
    Value<String>? talentsUnlocked,
    Value<String>? playstylePreference,
  }) {
    return PlayerTableCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      credits: credits ?? this.credits,
      biomass: biomass ?? this.biomass,
      minerals: minerals ?? this.minerals,
      energy: energy ?? this.energy,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      gameSpeedMultiplier: gameSpeedMultiplier ?? this.gameSpeedMultiplier,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      talentsUnlocked: talentsUnlocked ?? this.talentsUnlocked,
      playstylePreference: playstylePreference ?? this.playstylePreference,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (experience.present) {
      map['experience'] = Variable<int>(experience.value);
    }
    if (credits.present) {
      map['credits'] = Variable<int>(credits.value);
    }
    if (biomass.present) {
      map['biomass'] = Variable<int>(biomass.value);
    }
    if (minerals.present) {
      map['minerals'] = Variable<int>(minerals.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (gameSpeedMultiplier.present) {
      map['game_speed_multiplier'] = Variable<double>(
        gameSpeedMultiplier.value,
      );
    }
    if (tutorialCompleted.present) {
      map['tutorial_completed'] = Variable<bool>(tutorialCompleted.value);
    }
    if (talentsUnlocked.present) {
      map['talents_unlocked'] = Variable<String>(talentsUnlocked.value);
    }
    if (playstylePreference.present) {
      map['playstyle_preference'] = Variable<String>(playstylePreference.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerTableCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('level: $level, ')
          ..write('experience: $experience, ')
          ..write('credits: $credits, ')
          ..write('biomass: $biomass, ')
          ..write('minerals: $minerals, ')
          ..write('energy: $energy, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('gameSpeedMultiplier: $gameSpeedMultiplier, ')
          ..write('tutorialCompleted: $tutorialCompleted, ')
          ..write('talentsUnlocked: $talentsUnlocked, ')
          ..write('playstylePreference: $playstylePreference')
          ..write(')'))
        .toString();
  }
}

class $ColoniesTableTable extends ColoniesTable
    with TableInfo<$ColoniesTableTable, ColoniesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColoniesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ownerTypeMeta = const VerificationMeta(
    'ownerType',
  );
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typePersonnaliteMeta = const VerificationMeta(
    'typePersonnalite',
  );
  @override
  late final GeneratedColumn<String> typePersonnalite = GeneratedColumn<String>(
    'type_personnalite',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionXMeta = const VerificationMeta(
    'positionX',
  );
  @override
  late final GeneratedColumn<int> positionX = GeneratedColumn<int>(
    'position_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionYMeta = const VerificationMeta(
    'positionY',
  );
  @override
  late final GeneratedColumn<int> positionY = GeneratedColumn<int>(
    'position_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factionMeta = const VerificationMeta(
    'faction',
  );
  @override
  late final GeneratedColumn<String> faction = GeneratedColumn<String>(
    'faction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('independent'),
  );
  static const VerificationMeta _populationMeta = const VerificationMeta(
    'population',
  );
  @override
  late final GeneratedColumn<int> population = GeneratedColumn<int>(
    'population',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _niveauDomeMeta = const VerificationMeta(
    'niveauDome',
  );
  @override
  late final GeneratedColumn<int> niveauDome = GeneratedColumn<int>(
    'niveau_dome',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _healthDomeMeta = const VerificationMeta(
    'healthDome',
  );
  @override
  late final GeneratedColumn<int> healthDome = GeneratedColumn<int>(
    'health_dome',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<int> credits = GeneratedColumn<int>(
    'credits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  static const VerificationMeta _biomassMeta = const VerificationMeta(
    'biomass',
  );
  @override
  late final GeneratedColumn<int> biomass = GeneratedColumn<int>(
    'biomass',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(800),
  );
  static const VerificationMeta _mineralsMeta = const VerificationMeta(
    'minerals',
  );
  @override
  late final GeneratedColumn<int> minerals = GeneratedColumn<int>(
    'minerals',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(500),
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(300),
  );
  static const VerificationMeta _loyaltyMeta = const VerificationMeta(
    'loyalty',
  );
  @override
  late final GeneratedColumn<int> loyalty = GeneratedColumn<int>(
    'loyalty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(50),
  );
  static const VerificationMeta _aiPersonalityTraitsMeta =
      const VerificationMeta('aiPersonalityTraits');
  @override
  late final GeneratedColumn<String> aiPersonalityTraits =
      GeneratedColumn<String>(
        'ai_personality_traits',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _aiBehaviorStateMeta = const VerificationMeta(
    'aiBehaviorState',
  );
  @override
  late final GeneratedColumn<String> aiBehaviorState = GeneratedColumn<String>(
    'ai_behavior_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('expansion'),
  );
  static const VerificationMeta _aiThreatLevelMeta = const VerificationMeta(
    'aiThreatLevel',
  );
  @override
  late final GeneratedColumn<int> aiThreatLevel = GeneratedColumn<int>(
    'ai_threat_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discoveredByPlayerMeta =
      const VerificationMeta('discoveredByPlayer');
  @override
  late final GeneratedColumn<bool> discoveredByPlayer = GeneratedColumn<bool>(
    'discovered_by_player',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("discovered_by_player" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastActivityAtMeta = const VerificationMeta(
    'lastActivityAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivityAt =
      GeneratedColumn<DateTime>(
        'last_activity_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerType,
    name,
    typePersonnalite,
    positionX,
    positionY,
    faction,
    population,
    niveauDome,
    healthDome,
    credits,
    biomass,
    minerals,
    energy,
    loyalty,
    aiPersonalityTraits,
    aiBehaviorState,
    aiThreatLevel,
    discoveredByPlayer,
    lastActivityAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'colonies';
  @override
  VerificationContext validateIntegrity(
    Insertable<ColoniesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_type')) {
      context.handle(
        _ownerTypeMeta,
        ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type_personnalite')) {
      context.handle(
        _typePersonnaliteMeta,
        typePersonnalite.isAcceptableOrUnknown(
          data['type_personnalite']!,
          _typePersonnaliteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_typePersonnaliteMeta);
    }
    if (data.containsKey('position_x')) {
      context.handle(
        _positionXMeta,
        positionX.isAcceptableOrUnknown(data['position_x']!, _positionXMeta),
      );
    } else if (isInserting) {
      context.missing(_positionXMeta);
    }
    if (data.containsKey('position_y')) {
      context.handle(
        _positionYMeta,
        positionY.isAcceptableOrUnknown(data['position_y']!, _positionYMeta),
      );
    } else if (isInserting) {
      context.missing(_positionYMeta);
    }
    if (data.containsKey('faction')) {
      context.handle(
        _factionMeta,
        faction.isAcceptableOrUnknown(data['faction']!, _factionMeta),
      );
    }
    if (data.containsKey('population')) {
      context.handle(
        _populationMeta,
        population.isAcceptableOrUnknown(data['population']!, _populationMeta),
      );
    }
    if (data.containsKey('niveau_dome')) {
      context.handle(
        _niveauDomeMeta,
        niveauDome.isAcceptableOrUnknown(data['niveau_dome']!, _niveauDomeMeta),
      );
    }
    if (data.containsKey('health_dome')) {
      context.handle(
        _healthDomeMeta,
        healthDome.isAcceptableOrUnknown(data['health_dome']!, _healthDomeMeta),
      );
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    }
    if (data.containsKey('biomass')) {
      context.handle(
        _biomassMeta,
        biomass.isAcceptableOrUnknown(data['biomass']!, _biomassMeta),
      );
    }
    if (data.containsKey('minerals')) {
      context.handle(
        _mineralsMeta,
        minerals.isAcceptableOrUnknown(data['minerals']!, _mineralsMeta),
      );
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    if (data.containsKey('loyalty')) {
      context.handle(
        _loyaltyMeta,
        loyalty.isAcceptableOrUnknown(data['loyalty']!, _loyaltyMeta),
      );
    }
    if (data.containsKey('ai_personality_traits')) {
      context.handle(
        _aiPersonalityTraitsMeta,
        aiPersonalityTraits.isAcceptableOrUnknown(
          data['ai_personality_traits']!,
          _aiPersonalityTraitsMeta,
        ),
      );
    }
    if (data.containsKey('ai_behavior_state')) {
      context.handle(
        _aiBehaviorStateMeta,
        aiBehaviorState.isAcceptableOrUnknown(
          data['ai_behavior_state']!,
          _aiBehaviorStateMeta,
        ),
      );
    }
    if (data.containsKey('ai_threat_level')) {
      context.handle(
        _aiThreatLevelMeta,
        aiThreatLevel.isAcceptableOrUnknown(
          data['ai_threat_level']!,
          _aiThreatLevelMeta,
        ),
      );
    }
    if (data.containsKey('discovered_by_player')) {
      context.handle(
        _discoveredByPlayerMeta,
        discoveredByPlayer.isAcceptableOrUnknown(
          data['discovered_by_player']!,
          _discoveredByPlayerMeta,
        ),
      );
    }
    if (data.containsKey('last_activity_at')) {
      context.handle(
        _lastActivityAtMeta,
        lastActivityAt.isAcceptableOrUnknown(
          data['last_activity_at']!,
          _lastActivityAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActivityAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {positionX, positionY},
  ];
  @override
  ColoniesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColoniesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ownerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      typePersonnalite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_personnalite'],
      )!,
      positionX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_x'],
      )!,
      positionY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_y'],
      )!,
      faction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}faction'],
      )!,
      population: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}population'],
      )!,
      niveauDome: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}niveau_dome'],
      )!,
      healthDome: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}health_dome'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credits'],
      )!,
      biomass: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}biomass'],
      )!,
      minerals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minerals'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      )!,
      loyalty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loyalty'],
      )!,
      aiPersonalityTraits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_personality_traits'],
      )!,
      aiBehaviorState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_behavior_state'],
      ),
      aiThreatLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ai_threat_level'],
      ),
      discoveredByPlayer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}discovered_by_player'],
      )!,
      lastActivityAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_activity_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ColoniesTableTable createAlias(String alias) {
    return $ColoniesTableTable(attachedDatabase, alias);
  }
}

class ColoniesTableData extends DataClass
    implements Insertable<ColoniesTableData> {
  final int id;
  final String ownerType;
  final String name;
  final String typePersonnalite;
  final int positionX;
  final int positionY;
  final String faction;
  final int population;
  final int niveauDome;
  final int healthDome;
  final int credits;
  final int biomass;
  final int minerals;
  final int energy;
  final int loyalty;
  final String aiPersonalityTraits;
  final String? aiBehaviorState;
  final int? aiThreatLevel;
  final bool discoveredByPlayer;
  final DateTime lastActivityAt;
  final DateTime createdAt;
  const ColoniesTableData({
    required this.id,
    required this.ownerType,
    required this.name,
    required this.typePersonnalite,
    required this.positionX,
    required this.positionY,
    required this.faction,
    required this.population,
    required this.niveauDome,
    required this.healthDome,
    required this.credits,
    required this.biomass,
    required this.minerals,
    required this.energy,
    required this.loyalty,
    required this.aiPersonalityTraits,
    this.aiBehaviorState,
    this.aiThreatLevel,
    required this.discoveredByPlayer,
    required this.lastActivityAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['owner_type'] = Variable<String>(ownerType);
    map['name'] = Variable<String>(name);
    map['type_personnalite'] = Variable<String>(typePersonnalite);
    map['position_x'] = Variable<int>(positionX);
    map['position_y'] = Variable<int>(positionY);
    map['faction'] = Variable<String>(faction);
    map['population'] = Variable<int>(population);
    map['niveau_dome'] = Variable<int>(niveauDome);
    map['health_dome'] = Variable<int>(healthDome);
    map['credits'] = Variable<int>(credits);
    map['biomass'] = Variable<int>(biomass);
    map['minerals'] = Variable<int>(minerals);
    map['energy'] = Variable<int>(energy);
    map['loyalty'] = Variable<int>(loyalty);
    map['ai_personality_traits'] = Variable<String>(aiPersonalityTraits);
    if (!nullToAbsent || aiBehaviorState != null) {
      map['ai_behavior_state'] = Variable<String>(aiBehaviorState);
    }
    if (!nullToAbsent || aiThreatLevel != null) {
      map['ai_threat_level'] = Variable<int>(aiThreatLevel);
    }
    map['discovered_by_player'] = Variable<bool>(discoveredByPlayer);
    map['last_activity_at'] = Variable<DateTime>(lastActivityAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ColoniesTableCompanion toCompanion(bool nullToAbsent) {
    return ColoniesTableCompanion(
      id: Value(id),
      ownerType: Value(ownerType),
      name: Value(name),
      typePersonnalite: Value(typePersonnalite),
      positionX: Value(positionX),
      positionY: Value(positionY),
      faction: Value(faction),
      population: Value(population),
      niveauDome: Value(niveauDome),
      healthDome: Value(healthDome),
      credits: Value(credits),
      biomass: Value(biomass),
      minerals: Value(minerals),
      energy: Value(energy),
      loyalty: Value(loyalty),
      aiPersonalityTraits: Value(aiPersonalityTraits),
      aiBehaviorState: aiBehaviorState == null && nullToAbsent
          ? const Value.absent()
          : Value(aiBehaviorState),
      aiThreatLevel: aiThreatLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(aiThreatLevel),
      discoveredByPlayer: Value(discoveredByPlayer),
      lastActivityAt: Value(lastActivityAt),
      createdAt: Value(createdAt),
    );
  }

  factory ColoniesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColoniesTableData(
      id: serializer.fromJson<int>(json['id']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      name: serializer.fromJson<String>(json['name']),
      typePersonnalite: serializer.fromJson<String>(json['typePersonnalite']),
      positionX: serializer.fromJson<int>(json['positionX']),
      positionY: serializer.fromJson<int>(json['positionY']),
      faction: serializer.fromJson<String>(json['faction']),
      population: serializer.fromJson<int>(json['population']),
      niveauDome: serializer.fromJson<int>(json['niveauDome']),
      healthDome: serializer.fromJson<int>(json['healthDome']),
      credits: serializer.fromJson<int>(json['credits']),
      biomass: serializer.fromJson<int>(json['biomass']),
      minerals: serializer.fromJson<int>(json['minerals']),
      energy: serializer.fromJson<int>(json['energy']),
      loyalty: serializer.fromJson<int>(json['loyalty']),
      aiPersonalityTraits: serializer.fromJson<String>(
        json['aiPersonalityTraits'],
      ),
      aiBehaviorState: serializer.fromJson<String?>(json['aiBehaviorState']),
      aiThreatLevel: serializer.fromJson<int?>(json['aiThreatLevel']),
      discoveredByPlayer: serializer.fromJson<bool>(json['discoveredByPlayer']),
      lastActivityAt: serializer.fromJson<DateTime>(json['lastActivityAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ownerType': serializer.toJson<String>(ownerType),
      'name': serializer.toJson<String>(name),
      'typePersonnalite': serializer.toJson<String>(typePersonnalite),
      'positionX': serializer.toJson<int>(positionX),
      'positionY': serializer.toJson<int>(positionY),
      'faction': serializer.toJson<String>(faction),
      'population': serializer.toJson<int>(population),
      'niveauDome': serializer.toJson<int>(niveauDome),
      'healthDome': serializer.toJson<int>(healthDome),
      'credits': serializer.toJson<int>(credits),
      'biomass': serializer.toJson<int>(biomass),
      'minerals': serializer.toJson<int>(minerals),
      'energy': serializer.toJson<int>(energy),
      'loyalty': serializer.toJson<int>(loyalty),
      'aiPersonalityTraits': serializer.toJson<String>(aiPersonalityTraits),
      'aiBehaviorState': serializer.toJson<String?>(aiBehaviorState),
      'aiThreatLevel': serializer.toJson<int?>(aiThreatLevel),
      'discoveredByPlayer': serializer.toJson<bool>(discoveredByPlayer),
      'lastActivityAt': serializer.toJson<DateTime>(lastActivityAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ColoniesTableData copyWith({
    int? id,
    String? ownerType,
    String? name,
    String? typePersonnalite,
    int? positionX,
    int? positionY,
    String? faction,
    int? population,
    int? niveauDome,
    int? healthDome,
    int? credits,
    int? biomass,
    int? minerals,
    int? energy,
    int? loyalty,
    String? aiPersonalityTraits,
    Value<String?> aiBehaviorState = const Value.absent(),
    Value<int?> aiThreatLevel = const Value.absent(),
    bool? discoveredByPlayer,
    DateTime? lastActivityAt,
    DateTime? createdAt,
  }) => ColoniesTableData(
    id: id ?? this.id,
    ownerType: ownerType ?? this.ownerType,
    name: name ?? this.name,
    typePersonnalite: typePersonnalite ?? this.typePersonnalite,
    positionX: positionX ?? this.positionX,
    positionY: positionY ?? this.positionY,
    faction: faction ?? this.faction,
    population: population ?? this.population,
    niveauDome: niveauDome ?? this.niveauDome,
    healthDome: healthDome ?? this.healthDome,
    credits: credits ?? this.credits,
    biomass: biomass ?? this.biomass,
    minerals: minerals ?? this.minerals,
    energy: energy ?? this.energy,
    loyalty: loyalty ?? this.loyalty,
    aiPersonalityTraits: aiPersonalityTraits ?? this.aiPersonalityTraits,
    aiBehaviorState: aiBehaviorState.present
        ? aiBehaviorState.value
        : this.aiBehaviorState,
    aiThreatLevel: aiThreatLevel.present
        ? aiThreatLevel.value
        : this.aiThreatLevel,
    discoveredByPlayer: discoveredByPlayer ?? this.discoveredByPlayer,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    createdAt: createdAt ?? this.createdAt,
  );
  ColoniesTableData copyWithCompanion(ColoniesTableCompanion data) {
    return ColoniesTableData(
      id: data.id.present ? data.id.value : this.id,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      name: data.name.present ? data.name.value : this.name,
      typePersonnalite: data.typePersonnalite.present
          ? data.typePersonnalite.value
          : this.typePersonnalite,
      positionX: data.positionX.present ? data.positionX.value : this.positionX,
      positionY: data.positionY.present ? data.positionY.value : this.positionY,
      faction: data.faction.present ? data.faction.value : this.faction,
      population: data.population.present
          ? data.population.value
          : this.population,
      niveauDome: data.niveauDome.present
          ? data.niveauDome.value
          : this.niveauDome,
      healthDome: data.healthDome.present
          ? data.healthDome.value
          : this.healthDome,
      credits: data.credits.present ? data.credits.value : this.credits,
      biomass: data.biomass.present ? data.biomass.value : this.biomass,
      minerals: data.minerals.present ? data.minerals.value : this.minerals,
      energy: data.energy.present ? data.energy.value : this.energy,
      loyalty: data.loyalty.present ? data.loyalty.value : this.loyalty,
      aiPersonalityTraits: data.aiPersonalityTraits.present
          ? data.aiPersonalityTraits.value
          : this.aiPersonalityTraits,
      aiBehaviorState: data.aiBehaviorState.present
          ? data.aiBehaviorState.value
          : this.aiBehaviorState,
      aiThreatLevel: data.aiThreatLevel.present
          ? data.aiThreatLevel.value
          : this.aiThreatLevel,
      discoveredByPlayer: data.discoveredByPlayer.present
          ? data.discoveredByPlayer.value
          : this.discoveredByPlayer,
      lastActivityAt: data.lastActivityAt.present
          ? data.lastActivityAt.value
          : this.lastActivityAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColoniesTableData(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('name: $name, ')
          ..write('typePersonnalite: $typePersonnalite, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('faction: $faction, ')
          ..write('population: $population, ')
          ..write('niveauDome: $niveauDome, ')
          ..write('healthDome: $healthDome, ')
          ..write('credits: $credits, ')
          ..write('biomass: $biomass, ')
          ..write('minerals: $minerals, ')
          ..write('energy: $energy, ')
          ..write('loyalty: $loyalty, ')
          ..write('aiPersonalityTraits: $aiPersonalityTraits, ')
          ..write('aiBehaviorState: $aiBehaviorState, ')
          ..write('aiThreatLevel: $aiThreatLevel, ')
          ..write('discoveredByPlayer: $discoveredByPlayer, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerType,
    name,
    typePersonnalite,
    positionX,
    positionY,
    faction,
    population,
    niveauDome,
    healthDome,
    credits,
    biomass,
    minerals,
    energy,
    loyalty,
    aiPersonalityTraits,
    aiBehaviorState,
    aiThreatLevel,
    discoveredByPlayer,
    lastActivityAt,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColoniesTableData &&
          other.id == this.id &&
          other.ownerType == this.ownerType &&
          other.name == this.name &&
          other.typePersonnalite == this.typePersonnalite &&
          other.positionX == this.positionX &&
          other.positionY == this.positionY &&
          other.faction == this.faction &&
          other.population == this.population &&
          other.niveauDome == this.niveauDome &&
          other.healthDome == this.healthDome &&
          other.credits == this.credits &&
          other.biomass == this.biomass &&
          other.minerals == this.minerals &&
          other.energy == this.energy &&
          other.loyalty == this.loyalty &&
          other.aiPersonalityTraits == this.aiPersonalityTraits &&
          other.aiBehaviorState == this.aiBehaviorState &&
          other.aiThreatLevel == this.aiThreatLevel &&
          other.discoveredByPlayer == this.discoveredByPlayer &&
          other.lastActivityAt == this.lastActivityAt &&
          other.createdAt == this.createdAt);
}

class ColoniesTableCompanion extends UpdateCompanion<ColoniesTableData> {
  final Value<int> id;
  final Value<String> ownerType;
  final Value<String> name;
  final Value<String> typePersonnalite;
  final Value<int> positionX;
  final Value<int> positionY;
  final Value<String> faction;
  final Value<int> population;
  final Value<int> niveauDome;
  final Value<int> healthDome;
  final Value<int> credits;
  final Value<int> biomass;
  final Value<int> minerals;
  final Value<int> energy;
  final Value<int> loyalty;
  final Value<String> aiPersonalityTraits;
  final Value<String?> aiBehaviorState;
  final Value<int?> aiThreatLevel;
  final Value<bool> discoveredByPlayer;
  final Value<DateTime> lastActivityAt;
  final Value<DateTime> createdAt;
  const ColoniesTableCompanion({
    this.id = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.name = const Value.absent(),
    this.typePersonnalite = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.faction = const Value.absent(),
    this.population = const Value.absent(),
    this.niveauDome = const Value.absent(),
    this.healthDome = const Value.absent(),
    this.credits = const Value.absent(),
    this.biomass = const Value.absent(),
    this.minerals = const Value.absent(),
    this.energy = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.aiPersonalityTraits = const Value.absent(),
    this.aiBehaviorState = const Value.absent(),
    this.aiThreatLevel = const Value.absent(),
    this.discoveredByPlayer = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ColoniesTableCompanion.insert({
    this.id = const Value.absent(),
    required String ownerType,
    required String name,
    required String typePersonnalite,
    required int positionX,
    required int positionY,
    this.faction = const Value.absent(),
    this.population = const Value.absent(),
    this.niveauDome = const Value.absent(),
    this.healthDome = const Value.absent(),
    this.credits = const Value.absent(),
    this.biomass = const Value.absent(),
    this.minerals = const Value.absent(),
    this.energy = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.aiPersonalityTraits = const Value.absent(),
    this.aiBehaviorState = const Value.absent(),
    this.aiThreatLevel = const Value.absent(),
    this.discoveredByPlayer = const Value.absent(),
    required DateTime lastActivityAt,
    required DateTime createdAt,
  }) : ownerType = Value(ownerType),
       name = Value(name),
       typePersonnalite = Value(typePersonnalite),
       positionX = Value(positionX),
       positionY = Value(positionY),
       lastActivityAt = Value(lastActivityAt),
       createdAt = Value(createdAt);
  static Insertable<ColoniesTableData> custom({
    Expression<int>? id,
    Expression<String>? ownerType,
    Expression<String>? name,
    Expression<String>? typePersonnalite,
    Expression<int>? positionX,
    Expression<int>? positionY,
    Expression<String>? faction,
    Expression<int>? population,
    Expression<int>? niveauDome,
    Expression<int>? healthDome,
    Expression<int>? credits,
    Expression<int>? biomass,
    Expression<int>? minerals,
    Expression<int>? energy,
    Expression<int>? loyalty,
    Expression<String>? aiPersonalityTraits,
    Expression<String>? aiBehaviorState,
    Expression<int>? aiThreatLevel,
    Expression<bool>? discoveredByPlayer,
    Expression<DateTime>? lastActivityAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerType != null) 'owner_type': ownerType,
      if (name != null) 'name': name,
      if (typePersonnalite != null) 'type_personnalite': typePersonnalite,
      if (positionX != null) 'position_x': positionX,
      if (positionY != null) 'position_y': positionY,
      if (faction != null) 'faction': faction,
      if (population != null) 'population': population,
      if (niveauDome != null) 'niveau_dome': niveauDome,
      if (healthDome != null) 'health_dome': healthDome,
      if (credits != null) 'credits': credits,
      if (biomass != null) 'biomass': biomass,
      if (minerals != null) 'minerals': minerals,
      if (energy != null) 'energy': energy,
      if (loyalty != null) 'loyalty': loyalty,
      if (aiPersonalityTraits != null)
        'ai_personality_traits': aiPersonalityTraits,
      if (aiBehaviorState != null) 'ai_behavior_state': aiBehaviorState,
      if (aiThreatLevel != null) 'ai_threat_level': aiThreatLevel,
      if (discoveredByPlayer != null)
        'discovered_by_player': discoveredByPlayer,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ColoniesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? ownerType,
    Value<String>? name,
    Value<String>? typePersonnalite,
    Value<int>? positionX,
    Value<int>? positionY,
    Value<String>? faction,
    Value<int>? population,
    Value<int>? niveauDome,
    Value<int>? healthDome,
    Value<int>? credits,
    Value<int>? biomass,
    Value<int>? minerals,
    Value<int>? energy,
    Value<int>? loyalty,
    Value<String>? aiPersonalityTraits,
    Value<String?>? aiBehaviorState,
    Value<int?>? aiThreatLevel,
    Value<bool>? discoveredByPlayer,
    Value<DateTime>? lastActivityAt,
    Value<DateTime>? createdAt,
  }) {
    return ColoniesTableCompanion(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      name: name ?? this.name,
      typePersonnalite: typePersonnalite ?? this.typePersonnalite,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      faction: faction ?? this.faction,
      population: population ?? this.population,
      niveauDome: niveauDome ?? this.niveauDome,
      healthDome: healthDome ?? this.healthDome,
      credits: credits ?? this.credits,
      biomass: biomass ?? this.biomass,
      minerals: minerals ?? this.minerals,
      energy: energy ?? this.energy,
      loyalty: loyalty ?? this.loyalty,
      aiPersonalityTraits: aiPersonalityTraits ?? this.aiPersonalityTraits,
      aiBehaviorState: aiBehaviorState ?? this.aiBehaviorState,
      aiThreatLevel: aiThreatLevel ?? this.aiThreatLevel,
      discoveredByPlayer: discoveredByPlayer ?? this.discoveredByPlayer,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (typePersonnalite.present) {
      map['type_personnalite'] = Variable<String>(typePersonnalite.value);
    }
    if (positionX.present) {
      map['position_x'] = Variable<int>(positionX.value);
    }
    if (positionY.present) {
      map['position_y'] = Variable<int>(positionY.value);
    }
    if (faction.present) {
      map['faction'] = Variable<String>(faction.value);
    }
    if (population.present) {
      map['population'] = Variable<int>(population.value);
    }
    if (niveauDome.present) {
      map['niveau_dome'] = Variable<int>(niveauDome.value);
    }
    if (healthDome.present) {
      map['health_dome'] = Variable<int>(healthDome.value);
    }
    if (credits.present) {
      map['credits'] = Variable<int>(credits.value);
    }
    if (biomass.present) {
      map['biomass'] = Variable<int>(biomass.value);
    }
    if (minerals.present) {
      map['minerals'] = Variable<int>(minerals.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (loyalty.present) {
      map['loyalty'] = Variable<int>(loyalty.value);
    }
    if (aiPersonalityTraits.present) {
      map['ai_personality_traits'] = Variable<String>(
        aiPersonalityTraits.value,
      );
    }
    if (aiBehaviorState.present) {
      map['ai_behavior_state'] = Variable<String>(aiBehaviorState.value);
    }
    if (aiThreatLevel.present) {
      map['ai_threat_level'] = Variable<int>(aiThreatLevel.value);
    }
    if (discoveredByPlayer.present) {
      map['discovered_by_player'] = Variable<bool>(discoveredByPlayer.value);
    }
    if (lastActivityAt.present) {
      map['last_activity_at'] = Variable<DateTime>(lastActivityAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColoniesTableCompanion(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('name: $name, ')
          ..write('typePersonnalite: $typePersonnalite, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('faction: $faction, ')
          ..write('population: $population, ')
          ..write('niveauDome: $niveauDome, ')
          ..write('healthDome: $healthDome, ')
          ..write('credits: $credits, ')
          ..write('biomass: $biomass, ')
          ..write('minerals: $minerals, ')
          ..write('energy: $energy, ')
          ..write('loyalty: $loyalty, ')
          ..write('aiPersonalityTraits: $aiPersonalityTraits, ')
          ..write('aiBehaviorState: $aiBehaviorState, ')
          ..write('aiThreatLevel: $aiThreatLevel, ')
          ..write('discoveredByPlayer: $discoveredByPlayer, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BuildingsTableTable extends BuildingsTable
    with TableInfo<$BuildingsTableTable, BuildingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _colonyIdMeta = const VerificationMeta(
    'colonyId',
  );
  @override
  late final GeneratedColumn<int> colonyId = GeneratedColumn<int>(
    'colony_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colonies (id)',
    ),
  );
  static const VerificationMeta _buildingTypeMeta = const VerificationMeta(
    'buildingType',
  );
  @override
  late final GeneratedColumn<String> buildingType = GeneratedColumn<String>(
    'building_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _constructionEndTimeMeta =
      const VerificationMeta('constructionEndTime');
  @override
  late final GeneratedColumn<DateTime> constructionEndTime =
      GeneratedColumn<DateTime>(
        'construction_end_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _damageLevelMeta = const VerificationMeta(
    'damageLevel',
  );
  @override
  late final GeneratedColumn<int> damageLevel = GeneratedColumn<int>(
    'damage_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _productionRateMeta = const VerificationMeta(
    'productionRate',
  );
  @override
  late final GeneratedColumn<double> productionRate = GeneratedColumn<double>(
    'production_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _builtAtMeta = const VerificationMeta(
    'builtAt',
  );
  @override
  late final GeneratedColumn<DateTime> builtAt = GeneratedColumn<DateTime>(
    'built_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    colonyId,
    buildingType,
    level,
    constructionEndTime,
    damageLevel,
    productionRate,
    isActive,
    builtAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buildings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BuildingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('colony_id')) {
      context.handle(
        _colonyIdMeta,
        colonyId.isAcceptableOrUnknown(data['colony_id']!, _colonyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_colonyIdMeta);
    }
    if (data.containsKey('building_type')) {
      context.handle(
        _buildingTypeMeta,
        buildingType.isAcceptableOrUnknown(
          data['building_type']!,
          _buildingTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_buildingTypeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('construction_end_time')) {
      context.handle(
        _constructionEndTimeMeta,
        constructionEndTime.isAcceptableOrUnknown(
          data['construction_end_time']!,
          _constructionEndTimeMeta,
        ),
      );
    }
    if (data.containsKey('damage_level')) {
      context.handle(
        _damageLevelMeta,
        damageLevel.isAcceptableOrUnknown(
          data['damage_level']!,
          _damageLevelMeta,
        ),
      );
    }
    if (data.containsKey('production_rate')) {
      context.handle(
        _productionRateMeta,
        productionRate.isAcceptableOrUnknown(
          data['production_rate']!,
          _productionRateMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('built_at')) {
      context.handle(
        _builtAtMeta,
        builtAt.isAcceptableOrUnknown(data['built_at']!, _builtAtMeta),
      );
    } else if (isInserting) {
      context.missing(_builtAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuildingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuildingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      colonyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colony_id'],
      )!,
      buildingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_type'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      constructionEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}construction_end_time'],
      ),
      damageLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}damage_level'],
      )!,
      productionRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}production_rate'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      builtAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}built_at'],
      )!,
    );
  }

  @override
  $BuildingsTableTable createAlias(String alias) {
    return $BuildingsTableTable(attachedDatabase, alias);
  }
}

class BuildingsTableData extends DataClass
    implements Insertable<BuildingsTableData> {
  final int id;
  final int colonyId;
  final String buildingType;
  final int level;
  final DateTime? constructionEndTime;
  final int damageLevel;
  final double productionRate;
  final bool isActive;
  final DateTime builtAt;
  const BuildingsTableData({
    required this.id,
    required this.colonyId,
    required this.buildingType,
    required this.level,
    this.constructionEndTime,
    required this.damageLevel,
    required this.productionRate,
    required this.isActive,
    required this.builtAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['colony_id'] = Variable<int>(colonyId);
    map['building_type'] = Variable<String>(buildingType);
    map['level'] = Variable<int>(level);
    if (!nullToAbsent || constructionEndTime != null) {
      map['construction_end_time'] = Variable<DateTime>(constructionEndTime);
    }
    map['damage_level'] = Variable<int>(damageLevel);
    map['production_rate'] = Variable<double>(productionRate);
    map['is_active'] = Variable<bool>(isActive);
    map['built_at'] = Variable<DateTime>(builtAt);
    return map;
  }

  BuildingsTableCompanion toCompanion(bool nullToAbsent) {
    return BuildingsTableCompanion(
      id: Value(id),
      colonyId: Value(colonyId),
      buildingType: Value(buildingType),
      level: Value(level),
      constructionEndTime: constructionEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(constructionEndTime),
      damageLevel: Value(damageLevel),
      productionRate: Value(productionRate),
      isActive: Value(isActive),
      builtAt: Value(builtAt),
    );
  }

  factory BuildingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuildingsTableData(
      id: serializer.fromJson<int>(json['id']),
      colonyId: serializer.fromJson<int>(json['colonyId']),
      buildingType: serializer.fromJson<String>(json['buildingType']),
      level: serializer.fromJson<int>(json['level']),
      constructionEndTime: serializer.fromJson<DateTime?>(
        json['constructionEndTime'],
      ),
      damageLevel: serializer.fromJson<int>(json['damageLevel']),
      productionRate: serializer.fromJson<double>(json['productionRate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      builtAt: serializer.fromJson<DateTime>(json['builtAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'colonyId': serializer.toJson<int>(colonyId),
      'buildingType': serializer.toJson<String>(buildingType),
      'level': serializer.toJson<int>(level),
      'constructionEndTime': serializer.toJson<DateTime?>(constructionEndTime),
      'damageLevel': serializer.toJson<int>(damageLevel),
      'productionRate': serializer.toJson<double>(productionRate),
      'isActive': serializer.toJson<bool>(isActive),
      'builtAt': serializer.toJson<DateTime>(builtAt),
    };
  }

  BuildingsTableData copyWith({
    int? id,
    int? colonyId,
    String? buildingType,
    int? level,
    Value<DateTime?> constructionEndTime = const Value.absent(),
    int? damageLevel,
    double? productionRate,
    bool? isActive,
    DateTime? builtAt,
  }) => BuildingsTableData(
    id: id ?? this.id,
    colonyId: colonyId ?? this.colonyId,
    buildingType: buildingType ?? this.buildingType,
    level: level ?? this.level,
    constructionEndTime: constructionEndTime.present
        ? constructionEndTime.value
        : this.constructionEndTime,
    damageLevel: damageLevel ?? this.damageLevel,
    productionRate: productionRate ?? this.productionRate,
    isActive: isActive ?? this.isActive,
    builtAt: builtAt ?? this.builtAt,
  );
  BuildingsTableData copyWithCompanion(BuildingsTableCompanion data) {
    return BuildingsTableData(
      id: data.id.present ? data.id.value : this.id,
      colonyId: data.colonyId.present ? data.colonyId.value : this.colonyId,
      buildingType: data.buildingType.present
          ? data.buildingType.value
          : this.buildingType,
      level: data.level.present ? data.level.value : this.level,
      constructionEndTime: data.constructionEndTime.present
          ? data.constructionEndTime.value
          : this.constructionEndTime,
      damageLevel: data.damageLevel.present
          ? data.damageLevel.value
          : this.damageLevel,
      productionRate: data.productionRate.present
          ? data.productionRate.value
          : this.productionRate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      builtAt: data.builtAt.present ? data.builtAt.value : this.builtAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuildingsTableData(')
          ..write('id: $id, ')
          ..write('colonyId: $colonyId, ')
          ..write('buildingType: $buildingType, ')
          ..write('level: $level, ')
          ..write('constructionEndTime: $constructionEndTime, ')
          ..write('damageLevel: $damageLevel, ')
          ..write('productionRate: $productionRate, ')
          ..write('isActive: $isActive, ')
          ..write('builtAt: $builtAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    colonyId,
    buildingType,
    level,
    constructionEndTime,
    damageLevel,
    productionRate,
    isActive,
    builtAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuildingsTableData &&
          other.id == this.id &&
          other.colonyId == this.colonyId &&
          other.buildingType == this.buildingType &&
          other.level == this.level &&
          other.constructionEndTime == this.constructionEndTime &&
          other.damageLevel == this.damageLevel &&
          other.productionRate == this.productionRate &&
          other.isActive == this.isActive &&
          other.builtAt == this.builtAt);
}

class BuildingsTableCompanion extends UpdateCompanion<BuildingsTableData> {
  final Value<int> id;
  final Value<int> colonyId;
  final Value<String> buildingType;
  final Value<int> level;
  final Value<DateTime?> constructionEndTime;
  final Value<int> damageLevel;
  final Value<double> productionRate;
  final Value<bool> isActive;
  final Value<DateTime> builtAt;
  const BuildingsTableCompanion({
    this.id = const Value.absent(),
    this.colonyId = const Value.absent(),
    this.buildingType = const Value.absent(),
    this.level = const Value.absent(),
    this.constructionEndTime = const Value.absent(),
    this.damageLevel = const Value.absent(),
    this.productionRate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.builtAt = const Value.absent(),
  });
  BuildingsTableCompanion.insert({
    this.id = const Value.absent(),
    required int colonyId,
    required String buildingType,
    this.level = const Value.absent(),
    this.constructionEndTime = const Value.absent(),
    this.damageLevel = const Value.absent(),
    this.productionRate = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime builtAt,
  }) : colonyId = Value(colonyId),
       buildingType = Value(buildingType),
       builtAt = Value(builtAt);
  static Insertable<BuildingsTableData> custom({
    Expression<int>? id,
    Expression<int>? colonyId,
    Expression<String>? buildingType,
    Expression<int>? level,
    Expression<DateTime>? constructionEndTime,
    Expression<int>? damageLevel,
    Expression<double>? productionRate,
    Expression<bool>? isActive,
    Expression<DateTime>? builtAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (colonyId != null) 'colony_id': colonyId,
      if (buildingType != null) 'building_type': buildingType,
      if (level != null) 'level': level,
      if (constructionEndTime != null)
        'construction_end_time': constructionEndTime,
      if (damageLevel != null) 'damage_level': damageLevel,
      if (productionRate != null) 'production_rate': productionRate,
      if (isActive != null) 'is_active': isActive,
      if (builtAt != null) 'built_at': builtAt,
    });
  }

  BuildingsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? colonyId,
    Value<String>? buildingType,
    Value<int>? level,
    Value<DateTime?>? constructionEndTime,
    Value<int>? damageLevel,
    Value<double>? productionRate,
    Value<bool>? isActive,
    Value<DateTime>? builtAt,
  }) {
    return BuildingsTableCompanion(
      id: id ?? this.id,
      colonyId: colonyId ?? this.colonyId,
      buildingType: buildingType ?? this.buildingType,
      level: level ?? this.level,
      constructionEndTime: constructionEndTime ?? this.constructionEndTime,
      damageLevel: damageLevel ?? this.damageLevel,
      productionRate: productionRate ?? this.productionRate,
      isActive: isActive ?? this.isActive,
      builtAt: builtAt ?? this.builtAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (colonyId.present) {
      map['colony_id'] = Variable<int>(colonyId.value);
    }
    if (buildingType.present) {
      map['building_type'] = Variable<String>(buildingType.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (constructionEndTime.present) {
      map['construction_end_time'] = Variable<DateTime>(
        constructionEndTime.value,
      );
    }
    if (damageLevel.present) {
      map['damage_level'] = Variable<int>(damageLevel.value);
    }
    if (productionRate.present) {
      map['production_rate'] = Variable<double>(productionRate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (builtAt.present) {
      map['built_at'] = Variable<DateTime>(builtAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingsTableCompanion(')
          ..write('id: $id, ')
          ..write('colonyId: $colonyId, ')
          ..write('buildingType: $buildingType, ')
          ..write('level: $level, ')
          ..write('constructionEndTime: $constructionEndTime, ')
          ..write('damageLevel: $damageLevel, ')
          ..write('productionRate: $productionRate, ')
          ..write('isActive: $isActive, ')
          ..write('builtAt: $builtAt')
          ..write(')'))
        .toString();
  }
}

class $TroopsTableTable extends TroopsTable
    with TableInfo<$TroopsTableTable, TroopsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TroopsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _colonyIdMeta = const VerificationMeta(
    'colonyId',
  );
  @override
  late final GeneratedColumn<int> colonyId = GeneratedColumn<int>(
    'colony_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colonies (id)',
    ),
  );
  static const VerificationMeta _troopTypeMeta = const VerificationMeta(
    'troopType',
  );
  @override
  late final GeneratedColumn<String> troopType = GeneratedColumn<String>(
    'troop_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _healthPerUnitMeta = const VerificationMeta(
    'healthPerUnit',
  );
  @override
  late final GeneratedColumn<int> healthPerUnit = GeneratedColumn<int>(
    'health_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('idle'),
  );
  static const VerificationMeta _targetXMeta = const VerificationMeta(
    'targetX',
  );
  @override
  late final GeneratedColumn<int> targetX = GeneratedColumn<int>(
    'target_x',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetYMeta = const VerificationMeta(
    'targetY',
  );
  @override
  late final GeneratedColumn<int> targetY = GeneratedColumn<int>(
    'target_y',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _etaArrivalMeta = const VerificationMeta(
    'etaArrival',
  );
  @override
  late final GeneratedColumn<DateTime> etaArrival = GeneratedColumn<DateTime>(
    'eta_arrival',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moraleMeta = const VerificationMeta('morale');
  @override
  late final GeneratedColumn<int> morale = GeneratedColumn<int>(
    'morale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(75),
  );
  static const VerificationMeta _trainedAtMeta = const VerificationMeta(
    'trainedAt',
  );
  @override
  late final GeneratedColumn<DateTime> trainedAt = GeneratedColumn<DateTime>(
    'trained_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    colonyId,
    troopType,
    count,
    healthPerUnit,
    status,
    targetX,
    targetY,
    etaArrival,
    morale,
    trainedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'troops';
  @override
  VerificationContext validateIntegrity(
    Insertable<TroopsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('colony_id')) {
      context.handle(
        _colonyIdMeta,
        colonyId.isAcceptableOrUnknown(data['colony_id']!, _colonyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_colonyIdMeta);
    }
    if (data.containsKey('troop_type')) {
      context.handle(
        _troopTypeMeta,
        troopType.isAcceptableOrUnknown(data['troop_type']!, _troopTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_troopTypeMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('health_per_unit')) {
      context.handle(
        _healthPerUnitMeta,
        healthPerUnit.isAcceptableOrUnknown(
          data['health_per_unit']!,
          _healthPerUnitMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('target_x')) {
      context.handle(
        _targetXMeta,
        targetX.isAcceptableOrUnknown(data['target_x']!, _targetXMeta),
      );
    }
    if (data.containsKey('target_y')) {
      context.handle(
        _targetYMeta,
        targetY.isAcceptableOrUnknown(data['target_y']!, _targetYMeta),
      );
    }
    if (data.containsKey('eta_arrival')) {
      context.handle(
        _etaArrivalMeta,
        etaArrival.isAcceptableOrUnknown(data['eta_arrival']!, _etaArrivalMeta),
      );
    }
    if (data.containsKey('morale')) {
      context.handle(
        _moraleMeta,
        morale.isAcceptableOrUnknown(data['morale']!, _moraleMeta),
      );
    }
    if (data.containsKey('trained_at')) {
      context.handle(
        _trainedAtMeta,
        trainedAt.isAcceptableOrUnknown(data['trained_at']!, _trainedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_trainedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TroopsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TroopsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      colonyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colony_id'],
      )!,
      troopType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}troop_type'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      healthPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}health_per_unit'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      targetX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_x'],
      ),
      targetY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_y'],
      ),
      etaArrival: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eta_arrival'],
      ),
      morale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}morale'],
      )!,
      trainedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trained_at'],
      )!,
    );
  }

  @override
  $TroopsTableTable createAlias(String alias) {
    return $TroopsTableTable(attachedDatabase, alias);
  }
}

class TroopsTableData extends DataClass implements Insertable<TroopsTableData> {
  final int id;
  final int colonyId;
  final String troopType;
  final int count;
  final int healthPerUnit;
  final String status;
  final int? targetX;
  final int? targetY;
  final DateTime? etaArrival;
  final int morale;
  final DateTime trainedAt;
  const TroopsTableData({
    required this.id,
    required this.colonyId,
    required this.troopType,
    required this.count,
    required this.healthPerUnit,
    required this.status,
    this.targetX,
    this.targetY,
    this.etaArrival,
    required this.morale,
    required this.trainedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['colony_id'] = Variable<int>(colonyId);
    map['troop_type'] = Variable<String>(troopType);
    map['count'] = Variable<int>(count);
    map['health_per_unit'] = Variable<int>(healthPerUnit);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || targetX != null) {
      map['target_x'] = Variable<int>(targetX);
    }
    if (!nullToAbsent || targetY != null) {
      map['target_y'] = Variable<int>(targetY);
    }
    if (!nullToAbsent || etaArrival != null) {
      map['eta_arrival'] = Variable<DateTime>(etaArrival);
    }
    map['morale'] = Variable<int>(morale);
    map['trained_at'] = Variable<DateTime>(trainedAt);
    return map;
  }

  TroopsTableCompanion toCompanion(bool nullToAbsent) {
    return TroopsTableCompanion(
      id: Value(id),
      colonyId: Value(colonyId),
      troopType: Value(troopType),
      count: Value(count),
      healthPerUnit: Value(healthPerUnit),
      status: Value(status),
      targetX: targetX == null && nullToAbsent
          ? const Value.absent()
          : Value(targetX),
      targetY: targetY == null && nullToAbsent
          ? const Value.absent()
          : Value(targetY),
      etaArrival: etaArrival == null && nullToAbsent
          ? const Value.absent()
          : Value(etaArrival),
      morale: Value(morale),
      trainedAt: Value(trainedAt),
    );
  }

  factory TroopsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TroopsTableData(
      id: serializer.fromJson<int>(json['id']),
      colonyId: serializer.fromJson<int>(json['colonyId']),
      troopType: serializer.fromJson<String>(json['troopType']),
      count: serializer.fromJson<int>(json['count']),
      healthPerUnit: serializer.fromJson<int>(json['healthPerUnit']),
      status: serializer.fromJson<String>(json['status']),
      targetX: serializer.fromJson<int?>(json['targetX']),
      targetY: serializer.fromJson<int?>(json['targetY']),
      etaArrival: serializer.fromJson<DateTime?>(json['etaArrival']),
      morale: serializer.fromJson<int>(json['morale']),
      trainedAt: serializer.fromJson<DateTime>(json['trainedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'colonyId': serializer.toJson<int>(colonyId),
      'troopType': serializer.toJson<String>(troopType),
      'count': serializer.toJson<int>(count),
      'healthPerUnit': serializer.toJson<int>(healthPerUnit),
      'status': serializer.toJson<String>(status),
      'targetX': serializer.toJson<int?>(targetX),
      'targetY': serializer.toJson<int?>(targetY),
      'etaArrival': serializer.toJson<DateTime?>(etaArrival),
      'morale': serializer.toJson<int>(morale),
      'trainedAt': serializer.toJson<DateTime>(trainedAt),
    };
  }

  TroopsTableData copyWith({
    int? id,
    int? colonyId,
    String? troopType,
    int? count,
    int? healthPerUnit,
    String? status,
    Value<int?> targetX = const Value.absent(),
    Value<int?> targetY = const Value.absent(),
    Value<DateTime?> etaArrival = const Value.absent(),
    int? morale,
    DateTime? trainedAt,
  }) => TroopsTableData(
    id: id ?? this.id,
    colonyId: colonyId ?? this.colonyId,
    troopType: troopType ?? this.troopType,
    count: count ?? this.count,
    healthPerUnit: healthPerUnit ?? this.healthPerUnit,
    status: status ?? this.status,
    targetX: targetX.present ? targetX.value : this.targetX,
    targetY: targetY.present ? targetY.value : this.targetY,
    etaArrival: etaArrival.present ? etaArrival.value : this.etaArrival,
    morale: morale ?? this.morale,
    trainedAt: trainedAt ?? this.trainedAt,
  );
  TroopsTableData copyWithCompanion(TroopsTableCompanion data) {
    return TroopsTableData(
      id: data.id.present ? data.id.value : this.id,
      colonyId: data.colonyId.present ? data.colonyId.value : this.colonyId,
      troopType: data.troopType.present ? data.troopType.value : this.troopType,
      count: data.count.present ? data.count.value : this.count,
      healthPerUnit: data.healthPerUnit.present
          ? data.healthPerUnit.value
          : this.healthPerUnit,
      status: data.status.present ? data.status.value : this.status,
      targetX: data.targetX.present ? data.targetX.value : this.targetX,
      targetY: data.targetY.present ? data.targetY.value : this.targetY,
      etaArrival: data.etaArrival.present
          ? data.etaArrival.value
          : this.etaArrival,
      morale: data.morale.present ? data.morale.value : this.morale,
      trainedAt: data.trainedAt.present ? data.trainedAt.value : this.trainedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TroopsTableData(')
          ..write('id: $id, ')
          ..write('colonyId: $colonyId, ')
          ..write('troopType: $troopType, ')
          ..write('count: $count, ')
          ..write('healthPerUnit: $healthPerUnit, ')
          ..write('status: $status, ')
          ..write('targetX: $targetX, ')
          ..write('targetY: $targetY, ')
          ..write('etaArrival: $etaArrival, ')
          ..write('morale: $morale, ')
          ..write('trainedAt: $trainedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    colonyId,
    troopType,
    count,
    healthPerUnit,
    status,
    targetX,
    targetY,
    etaArrival,
    morale,
    trainedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TroopsTableData &&
          other.id == this.id &&
          other.colonyId == this.colonyId &&
          other.troopType == this.troopType &&
          other.count == this.count &&
          other.healthPerUnit == this.healthPerUnit &&
          other.status == this.status &&
          other.targetX == this.targetX &&
          other.targetY == this.targetY &&
          other.etaArrival == this.etaArrival &&
          other.morale == this.morale &&
          other.trainedAt == this.trainedAt);
}

class TroopsTableCompanion extends UpdateCompanion<TroopsTableData> {
  final Value<int> id;
  final Value<int> colonyId;
  final Value<String> troopType;
  final Value<int> count;
  final Value<int> healthPerUnit;
  final Value<String> status;
  final Value<int?> targetX;
  final Value<int?> targetY;
  final Value<DateTime?> etaArrival;
  final Value<int> morale;
  final Value<DateTime> trainedAt;
  const TroopsTableCompanion({
    this.id = const Value.absent(),
    this.colonyId = const Value.absent(),
    this.troopType = const Value.absent(),
    this.count = const Value.absent(),
    this.healthPerUnit = const Value.absent(),
    this.status = const Value.absent(),
    this.targetX = const Value.absent(),
    this.targetY = const Value.absent(),
    this.etaArrival = const Value.absent(),
    this.morale = const Value.absent(),
    this.trainedAt = const Value.absent(),
  });
  TroopsTableCompanion.insert({
    this.id = const Value.absent(),
    required int colonyId,
    required String troopType,
    this.count = const Value.absent(),
    this.healthPerUnit = const Value.absent(),
    this.status = const Value.absent(),
    this.targetX = const Value.absent(),
    this.targetY = const Value.absent(),
    this.etaArrival = const Value.absent(),
    this.morale = const Value.absent(),
    required DateTime trainedAt,
  }) : colonyId = Value(colonyId),
       troopType = Value(troopType),
       trainedAt = Value(trainedAt);
  static Insertable<TroopsTableData> custom({
    Expression<int>? id,
    Expression<int>? colonyId,
    Expression<String>? troopType,
    Expression<int>? count,
    Expression<int>? healthPerUnit,
    Expression<String>? status,
    Expression<int>? targetX,
    Expression<int>? targetY,
    Expression<DateTime>? etaArrival,
    Expression<int>? morale,
    Expression<DateTime>? trainedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (colonyId != null) 'colony_id': colonyId,
      if (troopType != null) 'troop_type': troopType,
      if (count != null) 'count': count,
      if (healthPerUnit != null) 'health_per_unit': healthPerUnit,
      if (status != null) 'status': status,
      if (targetX != null) 'target_x': targetX,
      if (targetY != null) 'target_y': targetY,
      if (etaArrival != null) 'eta_arrival': etaArrival,
      if (morale != null) 'morale': morale,
      if (trainedAt != null) 'trained_at': trainedAt,
    });
  }

  TroopsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? colonyId,
    Value<String>? troopType,
    Value<int>? count,
    Value<int>? healthPerUnit,
    Value<String>? status,
    Value<int?>? targetX,
    Value<int?>? targetY,
    Value<DateTime?>? etaArrival,
    Value<int>? morale,
    Value<DateTime>? trainedAt,
  }) {
    return TroopsTableCompanion(
      id: id ?? this.id,
      colonyId: colonyId ?? this.colonyId,
      troopType: troopType ?? this.troopType,
      count: count ?? this.count,
      healthPerUnit: healthPerUnit ?? this.healthPerUnit,
      status: status ?? this.status,
      targetX: targetX ?? this.targetX,
      targetY: targetY ?? this.targetY,
      etaArrival: etaArrival ?? this.etaArrival,
      morale: morale ?? this.morale,
      trainedAt: trainedAt ?? this.trainedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (colonyId.present) {
      map['colony_id'] = Variable<int>(colonyId.value);
    }
    if (troopType.present) {
      map['troop_type'] = Variable<String>(troopType.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (healthPerUnit.present) {
      map['health_per_unit'] = Variable<int>(healthPerUnit.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (targetX.present) {
      map['target_x'] = Variable<int>(targetX.value);
    }
    if (targetY.present) {
      map['target_y'] = Variable<int>(targetY.value);
    }
    if (etaArrival.present) {
      map['eta_arrival'] = Variable<DateTime>(etaArrival.value);
    }
    if (morale.present) {
      map['morale'] = Variable<int>(morale.value);
    }
    if (trainedAt.present) {
      map['trained_at'] = Variable<DateTime>(trainedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TroopsTableCompanion(')
          ..write('id: $id, ')
          ..write('colonyId: $colonyId, ')
          ..write('troopType: $troopType, ')
          ..write('count: $count, ')
          ..write('healthPerUnit: $healthPerUnit, ')
          ..write('status: $status, ')
          ..write('targetX: $targetX, ')
          ..write('targetY: $targetY, ')
          ..write('etaArrival: $etaArrival, ')
          ..write('morale: $morale, ')
          ..write('trainedAt: $trainedAt')
          ..write(')'))
        .toString();
  }
}

class $WorldMapTableTable extends WorldMapTable
    with TableInfo<$WorldMapTableTable, WorldMapTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorldMapTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<int> zoneId = GeneratedColumn<int>(
    'zone_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chunkXMeta = const VerificationMeta('chunkX');
  @override
  late final GeneratedColumn<int> chunkX = GeneratedColumn<int>(
    'chunk_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkYMeta = const VerificationMeta('chunkY');
  @override
  late final GeneratedColumn<int> chunkY = GeneratedColumn<int>(
    'chunk_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _terrainTypeMeta = const VerificationMeta(
    'terrainType',
  );
  @override
  late final GeneratedColumn<String> terrainType = GeneratedColumn<String>(
    'terrain_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('plaine_abyssale'),
  );
  static const VerificationMeta _depthLevelMeta = const VerificationMeta(
    'depthLevel',
  );
  @override
  late final GeneratedColumn<int> depthLevel = GeneratedColumn<int>(
    'depth_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialResourceMeta = const VerificationMeta(
    'specialResource',
  );
  @override
  late final GeneratedColumn<String> specialResource = GeneratedColumn<String>(
    'special_resource',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceAbundanceMeta = const VerificationMeta(
    'resourceAbundance',
  );
  @override
  late final GeneratedColumn<double> resourceAbundance =
      GeneratedColumn<double>(
        'resource_abundance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _explorationLevelMeta = const VerificationMeta(
    'explorationLevel',
  );
  @override
  late final GeneratedColumn<int> explorationLevel = GeneratedColumn<int>(
    'exploration_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discoveredAtMeta = const VerificationMeta(
    'discoveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> discoveredAt = GeneratedColumn<DateTime>(
    'discovered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    zoneId,
    chunkX,
    chunkY,
    terrainType,
    depthLevel,
    specialResource,
    resourceAbundance,
    explorationLevel,
    discoveredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'world_map';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorldMapTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    }
    if (data.containsKey('chunk_x')) {
      context.handle(
        _chunkXMeta,
        chunkX.isAcceptableOrUnknown(data['chunk_x']!, _chunkXMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkXMeta);
    }
    if (data.containsKey('chunk_y')) {
      context.handle(
        _chunkYMeta,
        chunkY.isAcceptableOrUnknown(data['chunk_y']!, _chunkYMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkYMeta);
    }
    if (data.containsKey('terrain_type')) {
      context.handle(
        _terrainTypeMeta,
        terrainType.isAcceptableOrUnknown(
          data['terrain_type']!,
          _terrainTypeMeta,
        ),
      );
    }
    if (data.containsKey('depth_level')) {
      context.handle(
        _depthLevelMeta,
        depthLevel.isAcceptableOrUnknown(data['depth_level']!, _depthLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_depthLevelMeta);
    }
    if (data.containsKey('special_resource')) {
      context.handle(
        _specialResourceMeta,
        specialResource.isAcceptableOrUnknown(
          data['special_resource']!,
          _specialResourceMeta,
        ),
      );
    }
    if (data.containsKey('resource_abundance')) {
      context.handle(
        _resourceAbundanceMeta,
        resourceAbundance.isAcceptableOrUnknown(
          data['resource_abundance']!,
          _resourceAbundanceMeta,
        ),
      );
    }
    if (data.containsKey('exploration_level')) {
      context.handle(
        _explorationLevelMeta,
        explorationLevel.isAcceptableOrUnknown(
          data['exploration_level']!,
          _explorationLevelMeta,
        ),
      );
    }
    if (data.containsKey('discovered_at')) {
      context.handle(
        _discoveredAtMeta,
        discoveredAt.isAcceptableOrUnknown(
          data['discovered_at']!,
          _discoveredAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {zoneId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {chunkX, chunkY},
  ];
  @override
  WorldMapTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorldMapTableData(
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone_id'],
      )!,
      chunkX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_x'],
      )!,
      chunkY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_y'],
      )!,
      terrainType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terrain_type'],
      )!,
      depthLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}depth_level'],
      )!,
      specialResource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_resource'],
      ),
      resourceAbundance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resource_abundance'],
      )!,
      explorationLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exploration_level'],
      )!,
      discoveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}discovered_at'],
      ),
    );
  }

  @override
  $WorldMapTableTable createAlias(String alias) {
    return $WorldMapTableTable(attachedDatabase, alias);
  }
}

class WorldMapTableData extends DataClass
    implements Insertable<WorldMapTableData> {
  final int zoneId;
  final int chunkX;
  final int chunkY;
  final String terrainType;
  final int depthLevel;
  final String? specialResource;
  final double resourceAbundance;
  final int explorationLevel;
  final DateTime? discoveredAt;
  const WorldMapTableData({
    required this.zoneId,
    required this.chunkX,
    required this.chunkY,
    required this.terrainType,
    required this.depthLevel,
    this.specialResource,
    required this.resourceAbundance,
    required this.explorationLevel,
    this.discoveredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['zone_id'] = Variable<int>(zoneId);
    map['chunk_x'] = Variable<int>(chunkX);
    map['chunk_y'] = Variable<int>(chunkY);
    map['terrain_type'] = Variable<String>(terrainType);
    map['depth_level'] = Variable<int>(depthLevel);
    if (!nullToAbsent || specialResource != null) {
      map['special_resource'] = Variable<String>(specialResource);
    }
    map['resource_abundance'] = Variable<double>(resourceAbundance);
    map['exploration_level'] = Variable<int>(explorationLevel);
    if (!nullToAbsent || discoveredAt != null) {
      map['discovered_at'] = Variable<DateTime>(discoveredAt);
    }
    return map;
  }

  WorldMapTableCompanion toCompanion(bool nullToAbsent) {
    return WorldMapTableCompanion(
      zoneId: Value(zoneId),
      chunkX: Value(chunkX),
      chunkY: Value(chunkY),
      terrainType: Value(terrainType),
      depthLevel: Value(depthLevel),
      specialResource: specialResource == null && nullToAbsent
          ? const Value.absent()
          : Value(specialResource),
      resourceAbundance: Value(resourceAbundance),
      explorationLevel: Value(explorationLevel),
      discoveredAt: discoveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(discoveredAt),
    );
  }

  factory WorldMapTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorldMapTableData(
      zoneId: serializer.fromJson<int>(json['zoneId']),
      chunkX: serializer.fromJson<int>(json['chunkX']),
      chunkY: serializer.fromJson<int>(json['chunkY']),
      terrainType: serializer.fromJson<String>(json['terrainType']),
      depthLevel: serializer.fromJson<int>(json['depthLevel']),
      specialResource: serializer.fromJson<String?>(json['specialResource']),
      resourceAbundance: serializer.fromJson<double>(json['resourceAbundance']),
      explorationLevel: serializer.fromJson<int>(json['explorationLevel']),
      discoveredAt: serializer.fromJson<DateTime?>(json['discoveredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'zoneId': serializer.toJson<int>(zoneId),
      'chunkX': serializer.toJson<int>(chunkX),
      'chunkY': serializer.toJson<int>(chunkY),
      'terrainType': serializer.toJson<String>(terrainType),
      'depthLevel': serializer.toJson<int>(depthLevel),
      'specialResource': serializer.toJson<String?>(specialResource),
      'resourceAbundance': serializer.toJson<double>(resourceAbundance),
      'explorationLevel': serializer.toJson<int>(explorationLevel),
      'discoveredAt': serializer.toJson<DateTime?>(discoveredAt),
    };
  }

  WorldMapTableData copyWith({
    int? zoneId,
    int? chunkX,
    int? chunkY,
    String? terrainType,
    int? depthLevel,
    Value<String?> specialResource = const Value.absent(),
    double? resourceAbundance,
    int? explorationLevel,
    Value<DateTime?> discoveredAt = const Value.absent(),
  }) => WorldMapTableData(
    zoneId: zoneId ?? this.zoneId,
    chunkX: chunkX ?? this.chunkX,
    chunkY: chunkY ?? this.chunkY,
    terrainType: terrainType ?? this.terrainType,
    depthLevel: depthLevel ?? this.depthLevel,
    specialResource: specialResource.present
        ? specialResource.value
        : this.specialResource,
    resourceAbundance: resourceAbundance ?? this.resourceAbundance,
    explorationLevel: explorationLevel ?? this.explorationLevel,
    discoveredAt: discoveredAt.present ? discoveredAt.value : this.discoveredAt,
  );
  WorldMapTableData copyWithCompanion(WorldMapTableCompanion data) {
    return WorldMapTableData(
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      chunkX: data.chunkX.present ? data.chunkX.value : this.chunkX,
      chunkY: data.chunkY.present ? data.chunkY.value : this.chunkY,
      terrainType: data.terrainType.present
          ? data.terrainType.value
          : this.terrainType,
      depthLevel: data.depthLevel.present
          ? data.depthLevel.value
          : this.depthLevel,
      specialResource: data.specialResource.present
          ? data.specialResource.value
          : this.specialResource,
      resourceAbundance: data.resourceAbundance.present
          ? data.resourceAbundance.value
          : this.resourceAbundance,
      explorationLevel: data.explorationLevel.present
          ? data.explorationLevel.value
          : this.explorationLevel,
      discoveredAt: data.discoveredAt.present
          ? data.discoveredAt.value
          : this.discoveredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorldMapTableData(')
          ..write('zoneId: $zoneId, ')
          ..write('chunkX: $chunkX, ')
          ..write('chunkY: $chunkY, ')
          ..write('terrainType: $terrainType, ')
          ..write('depthLevel: $depthLevel, ')
          ..write('specialResource: $specialResource, ')
          ..write('resourceAbundance: $resourceAbundance, ')
          ..write('explorationLevel: $explorationLevel, ')
          ..write('discoveredAt: $discoveredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    zoneId,
    chunkX,
    chunkY,
    terrainType,
    depthLevel,
    specialResource,
    resourceAbundance,
    explorationLevel,
    discoveredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorldMapTableData &&
          other.zoneId == this.zoneId &&
          other.chunkX == this.chunkX &&
          other.chunkY == this.chunkY &&
          other.terrainType == this.terrainType &&
          other.depthLevel == this.depthLevel &&
          other.specialResource == this.specialResource &&
          other.resourceAbundance == this.resourceAbundance &&
          other.explorationLevel == this.explorationLevel &&
          other.discoveredAt == this.discoveredAt);
}

class WorldMapTableCompanion extends UpdateCompanion<WorldMapTableData> {
  final Value<int> zoneId;
  final Value<int> chunkX;
  final Value<int> chunkY;
  final Value<String> terrainType;
  final Value<int> depthLevel;
  final Value<String?> specialResource;
  final Value<double> resourceAbundance;
  final Value<int> explorationLevel;
  final Value<DateTime?> discoveredAt;
  const WorldMapTableCompanion({
    this.zoneId = const Value.absent(),
    this.chunkX = const Value.absent(),
    this.chunkY = const Value.absent(),
    this.terrainType = const Value.absent(),
    this.depthLevel = const Value.absent(),
    this.specialResource = const Value.absent(),
    this.resourceAbundance = const Value.absent(),
    this.explorationLevel = const Value.absent(),
    this.discoveredAt = const Value.absent(),
  });
  WorldMapTableCompanion.insert({
    this.zoneId = const Value.absent(),
    required int chunkX,
    required int chunkY,
    this.terrainType = const Value.absent(),
    required int depthLevel,
    this.specialResource = const Value.absent(),
    this.resourceAbundance = const Value.absent(),
    this.explorationLevel = const Value.absent(),
    this.discoveredAt = const Value.absent(),
  }) : chunkX = Value(chunkX),
       chunkY = Value(chunkY),
       depthLevel = Value(depthLevel);
  static Insertable<WorldMapTableData> custom({
    Expression<int>? zoneId,
    Expression<int>? chunkX,
    Expression<int>? chunkY,
    Expression<String>? terrainType,
    Expression<int>? depthLevel,
    Expression<String>? specialResource,
    Expression<double>? resourceAbundance,
    Expression<int>? explorationLevel,
    Expression<DateTime>? discoveredAt,
  }) {
    return RawValuesInsertable({
      if (zoneId != null) 'zone_id': zoneId,
      if (chunkX != null) 'chunk_x': chunkX,
      if (chunkY != null) 'chunk_y': chunkY,
      if (terrainType != null) 'terrain_type': terrainType,
      if (depthLevel != null) 'depth_level': depthLevel,
      if (specialResource != null) 'special_resource': specialResource,
      if (resourceAbundance != null) 'resource_abundance': resourceAbundance,
      if (explorationLevel != null) 'exploration_level': explorationLevel,
      if (discoveredAt != null) 'discovered_at': discoveredAt,
    });
  }

  WorldMapTableCompanion copyWith({
    Value<int>? zoneId,
    Value<int>? chunkX,
    Value<int>? chunkY,
    Value<String>? terrainType,
    Value<int>? depthLevel,
    Value<String?>? specialResource,
    Value<double>? resourceAbundance,
    Value<int>? explorationLevel,
    Value<DateTime?>? discoveredAt,
  }) {
    return WorldMapTableCompanion(
      zoneId: zoneId ?? this.zoneId,
      chunkX: chunkX ?? this.chunkX,
      chunkY: chunkY ?? this.chunkY,
      terrainType: terrainType ?? this.terrainType,
      depthLevel: depthLevel ?? this.depthLevel,
      specialResource: specialResource ?? this.specialResource,
      resourceAbundance: resourceAbundance ?? this.resourceAbundance,
      explorationLevel: explorationLevel ?? this.explorationLevel,
      discoveredAt: discoveredAt ?? this.discoveredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (zoneId.present) {
      map['zone_id'] = Variable<int>(zoneId.value);
    }
    if (chunkX.present) {
      map['chunk_x'] = Variable<int>(chunkX.value);
    }
    if (chunkY.present) {
      map['chunk_y'] = Variable<int>(chunkY.value);
    }
    if (terrainType.present) {
      map['terrain_type'] = Variable<String>(terrainType.value);
    }
    if (depthLevel.present) {
      map['depth_level'] = Variable<int>(depthLevel.value);
    }
    if (specialResource.present) {
      map['special_resource'] = Variable<String>(specialResource.value);
    }
    if (resourceAbundance.present) {
      map['resource_abundance'] = Variable<double>(resourceAbundance.value);
    }
    if (explorationLevel.present) {
      map['exploration_level'] = Variable<int>(explorationLevel.value);
    }
    if (discoveredAt.present) {
      map['discovered_at'] = Variable<DateTime>(discoveredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorldMapTableCompanion(')
          ..write('zoneId: $zoneId, ')
          ..write('chunkX: $chunkX, ')
          ..write('chunkY: $chunkY, ')
          ..write('terrainType: $terrainType, ')
          ..write('depthLevel: $depthLevel, ')
          ..write('specialResource: $specialResource, ')
          ..write('resourceAbundance: $resourceAbundance, ')
          ..write('explorationLevel: $explorationLevel, ')
          ..write('discoveredAt: $discoveredAt')
          ..write(')'))
        .toString();
  }
}

class $CombatLogTableTable extends CombatLogTable
    with TableInfo<$CombatLogTableTable, CombatLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CombatLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _attackerIdMeta = const VerificationMeta(
    'attackerId',
  );
  @override
  late final GeneratedColumn<int> attackerId = GeneratedColumn<int>(
    'attacker_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colonies (id)',
    ),
  );
  static const VerificationMeta _defenderIdMeta = const VerificationMeta(
    'defenderId',
  );
  @override
  late final GeneratedColumn<int> defenderId = GeneratedColumn<int>(
    'defender_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colonies (id)',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _combatTypeMeta = const VerificationMeta(
    'combatType',
  );
  @override
  late final GeneratedColumn<String> combatType = GeneratedColumn<String>(
    'combat_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('raid'),
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attackerLossesJsonMeta =
      const VerificationMeta('attackerLossesJson');
  @override
  late final GeneratedColumn<String> attackerLossesJson =
      GeneratedColumn<String>(
        'attacker_losses_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _defenderLossesJsonMeta =
      const VerificationMeta('defenderLossesJson');
  @override
  late final GeneratedColumn<String> defenderLossesJson =
      GeneratedColumn<String>(
        'defender_losses_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _spoilsJsonMeta = const VerificationMeta(
    'spoilsJson',
  );
  @override
  late final GeneratedColumn<String> spoilsJson = GeneratedColumn<String>(
    'spoils_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _battleLogJsonMeta = const VerificationMeta(
    'battleLogJson',
  );
  @override
  late final GeneratedColumn<String> battleLogJson = GeneratedColumn<String>(
    'battle_log_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attackerId,
    defenderId,
    timestamp,
    combatType,
    result,
    attackerLossesJson,
    defenderLossesJson,
    spoilsJson,
    battleLogJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'combat_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<CombatLogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attacker_id')) {
      context.handle(
        _attackerIdMeta,
        attackerId.isAcceptableOrUnknown(data['attacker_id']!, _attackerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attackerIdMeta);
    }
    if (data.containsKey('defender_id')) {
      context.handle(
        _defenderIdMeta,
        defenderId.isAcceptableOrUnknown(data['defender_id']!, _defenderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_defenderIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('combat_type')) {
      context.handle(
        _combatTypeMeta,
        combatType.isAcceptableOrUnknown(data['combat_type']!, _combatTypeMeta),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('attacker_losses_json')) {
      context.handle(
        _attackerLossesJsonMeta,
        attackerLossesJson.isAcceptableOrUnknown(
          data['attacker_losses_json']!,
          _attackerLossesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attackerLossesJsonMeta);
    }
    if (data.containsKey('defender_losses_json')) {
      context.handle(
        _defenderLossesJsonMeta,
        defenderLossesJson.isAcceptableOrUnknown(
          data['defender_losses_json']!,
          _defenderLossesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defenderLossesJsonMeta);
    }
    if (data.containsKey('spoils_json')) {
      context.handle(
        _spoilsJsonMeta,
        spoilsJson.isAcceptableOrUnknown(data['spoils_json']!, _spoilsJsonMeta),
      );
    }
    if (data.containsKey('battle_log_json')) {
      context.handle(
        _battleLogJsonMeta,
        battleLogJson.isAcceptableOrUnknown(
          data['battle_log_json']!,
          _battleLogJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CombatLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CombatLogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attackerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attacker_id'],
      )!,
      defenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}defender_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      combatType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}combat_type'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      attackerLossesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attacker_losses_json'],
      )!,
      defenderLossesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}defender_losses_json'],
      )!,
      spoilsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spoils_json'],
      ),
      battleLogJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}battle_log_json'],
      ),
    );
  }

  @override
  $CombatLogTableTable createAlias(String alias) {
    return $CombatLogTableTable(attachedDatabase, alias);
  }
}

class CombatLogTableData extends DataClass
    implements Insertable<CombatLogTableData> {
  final int id;
  final int attackerId;
  final int defenderId;
  final DateTime timestamp;
  final String combatType;
  final String result;
  final String attackerLossesJson;
  final String defenderLossesJson;
  final String? spoilsJson;
  final String? battleLogJson;
  const CombatLogTableData({
    required this.id,
    required this.attackerId,
    required this.defenderId,
    required this.timestamp,
    required this.combatType,
    required this.result,
    required this.attackerLossesJson,
    required this.defenderLossesJson,
    this.spoilsJson,
    this.battleLogJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attacker_id'] = Variable<int>(attackerId);
    map['defender_id'] = Variable<int>(defenderId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['combat_type'] = Variable<String>(combatType);
    map['result'] = Variable<String>(result);
    map['attacker_losses_json'] = Variable<String>(attackerLossesJson);
    map['defender_losses_json'] = Variable<String>(defenderLossesJson);
    if (!nullToAbsent || spoilsJson != null) {
      map['spoils_json'] = Variable<String>(spoilsJson);
    }
    if (!nullToAbsent || battleLogJson != null) {
      map['battle_log_json'] = Variable<String>(battleLogJson);
    }
    return map;
  }

  CombatLogTableCompanion toCompanion(bool nullToAbsent) {
    return CombatLogTableCompanion(
      id: Value(id),
      attackerId: Value(attackerId),
      defenderId: Value(defenderId),
      timestamp: Value(timestamp),
      combatType: Value(combatType),
      result: Value(result),
      attackerLossesJson: Value(attackerLossesJson),
      defenderLossesJson: Value(defenderLossesJson),
      spoilsJson: spoilsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(spoilsJson),
      battleLogJson: battleLogJson == null && nullToAbsent
          ? const Value.absent()
          : Value(battleLogJson),
    );
  }

  factory CombatLogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CombatLogTableData(
      id: serializer.fromJson<int>(json['id']),
      attackerId: serializer.fromJson<int>(json['attackerId']),
      defenderId: serializer.fromJson<int>(json['defenderId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      combatType: serializer.fromJson<String>(json['combatType']),
      result: serializer.fromJson<String>(json['result']),
      attackerLossesJson: serializer.fromJson<String>(
        json['attackerLossesJson'],
      ),
      defenderLossesJson: serializer.fromJson<String>(
        json['defenderLossesJson'],
      ),
      spoilsJson: serializer.fromJson<String?>(json['spoilsJson']),
      battleLogJson: serializer.fromJson<String?>(json['battleLogJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attackerId': serializer.toJson<int>(attackerId),
      'defenderId': serializer.toJson<int>(defenderId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'combatType': serializer.toJson<String>(combatType),
      'result': serializer.toJson<String>(result),
      'attackerLossesJson': serializer.toJson<String>(attackerLossesJson),
      'defenderLossesJson': serializer.toJson<String>(defenderLossesJson),
      'spoilsJson': serializer.toJson<String?>(spoilsJson),
      'battleLogJson': serializer.toJson<String?>(battleLogJson),
    };
  }

  CombatLogTableData copyWith({
    int? id,
    int? attackerId,
    int? defenderId,
    DateTime? timestamp,
    String? combatType,
    String? result,
    String? attackerLossesJson,
    String? defenderLossesJson,
    Value<String?> spoilsJson = const Value.absent(),
    Value<String?> battleLogJson = const Value.absent(),
  }) => CombatLogTableData(
    id: id ?? this.id,
    attackerId: attackerId ?? this.attackerId,
    defenderId: defenderId ?? this.defenderId,
    timestamp: timestamp ?? this.timestamp,
    combatType: combatType ?? this.combatType,
    result: result ?? this.result,
    attackerLossesJson: attackerLossesJson ?? this.attackerLossesJson,
    defenderLossesJson: defenderLossesJson ?? this.defenderLossesJson,
    spoilsJson: spoilsJson.present ? spoilsJson.value : this.spoilsJson,
    battleLogJson: battleLogJson.present
        ? battleLogJson.value
        : this.battleLogJson,
  );
  CombatLogTableData copyWithCompanion(CombatLogTableCompanion data) {
    return CombatLogTableData(
      id: data.id.present ? data.id.value : this.id,
      attackerId: data.attackerId.present
          ? data.attackerId.value
          : this.attackerId,
      defenderId: data.defenderId.present
          ? data.defenderId.value
          : this.defenderId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      combatType: data.combatType.present
          ? data.combatType.value
          : this.combatType,
      result: data.result.present ? data.result.value : this.result,
      attackerLossesJson: data.attackerLossesJson.present
          ? data.attackerLossesJson.value
          : this.attackerLossesJson,
      defenderLossesJson: data.defenderLossesJson.present
          ? data.defenderLossesJson.value
          : this.defenderLossesJson,
      spoilsJson: data.spoilsJson.present
          ? data.spoilsJson.value
          : this.spoilsJson,
      battleLogJson: data.battleLogJson.present
          ? data.battleLogJson.value
          : this.battleLogJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CombatLogTableData(')
          ..write('id: $id, ')
          ..write('attackerId: $attackerId, ')
          ..write('defenderId: $defenderId, ')
          ..write('timestamp: $timestamp, ')
          ..write('combatType: $combatType, ')
          ..write('result: $result, ')
          ..write('attackerLossesJson: $attackerLossesJson, ')
          ..write('defenderLossesJson: $defenderLossesJson, ')
          ..write('spoilsJson: $spoilsJson, ')
          ..write('battleLogJson: $battleLogJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attackerId,
    defenderId,
    timestamp,
    combatType,
    result,
    attackerLossesJson,
    defenderLossesJson,
    spoilsJson,
    battleLogJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CombatLogTableData &&
          other.id == this.id &&
          other.attackerId == this.attackerId &&
          other.defenderId == this.defenderId &&
          other.timestamp == this.timestamp &&
          other.combatType == this.combatType &&
          other.result == this.result &&
          other.attackerLossesJson == this.attackerLossesJson &&
          other.defenderLossesJson == this.defenderLossesJson &&
          other.spoilsJson == this.spoilsJson &&
          other.battleLogJson == this.battleLogJson);
}

class CombatLogTableCompanion extends UpdateCompanion<CombatLogTableData> {
  final Value<int> id;
  final Value<int> attackerId;
  final Value<int> defenderId;
  final Value<DateTime> timestamp;
  final Value<String> combatType;
  final Value<String> result;
  final Value<String> attackerLossesJson;
  final Value<String> defenderLossesJson;
  final Value<String?> spoilsJson;
  final Value<String?> battleLogJson;
  const CombatLogTableCompanion({
    this.id = const Value.absent(),
    this.attackerId = const Value.absent(),
    this.defenderId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.combatType = const Value.absent(),
    this.result = const Value.absent(),
    this.attackerLossesJson = const Value.absent(),
    this.defenderLossesJson = const Value.absent(),
    this.spoilsJson = const Value.absent(),
    this.battleLogJson = const Value.absent(),
  });
  CombatLogTableCompanion.insert({
    this.id = const Value.absent(),
    required int attackerId,
    required int defenderId,
    required DateTime timestamp,
    this.combatType = const Value.absent(),
    required String result,
    required String attackerLossesJson,
    required String defenderLossesJson,
    this.spoilsJson = const Value.absent(),
    this.battleLogJson = const Value.absent(),
  }) : attackerId = Value(attackerId),
       defenderId = Value(defenderId),
       timestamp = Value(timestamp),
       result = Value(result),
       attackerLossesJson = Value(attackerLossesJson),
       defenderLossesJson = Value(defenderLossesJson);
  static Insertable<CombatLogTableData> custom({
    Expression<int>? id,
    Expression<int>? attackerId,
    Expression<int>? defenderId,
    Expression<DateTime>? timestamp,
    Expression<String>? combatType,
    Expression<String>? result,
    Expression<String>? attackerLossesJson,
    Expression<String>? defenderLossesJson,
    Expression<String>? spoilsJson,
    Expression<String>? battleLogJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attackerId != null) 'attacker_id': attackerId,
      if (defenderId != null) 'defender_id': defenderId,
      if (timestamp != null) 'timestamp': timestamp,
      if (combatType != null) 'combat_type': combatType,
      if (result != null) 'result': result,
      if (attackerLossesJson != null)
        'attacker_losses_json': attackerLossesJson,
      if (defenderLossesJson != null)
        'defender_losses_json': defenderLossesJson,
      if (spoilsJson != null) 'spoils_json': spoilsJson,
      if (battleLogJson != null) 'battle_log_json': battleLogJson,
    });
  }

  CombatLogTableCompanion copyWith({
    Value<int>? id,
    Value<int>? attackerId,
    Value<int>? defenderId,
    Value<DateTime>? timestamp,
    Value<String>? combatType,
    Value<String>? result,
    Value<String>? attackerLossesJson,
    Value<String>? defenderLossesJson,
    Value<String?>? spoilsJson,
    Value<String?>? battleLogJson,
  }) {
    return CombatLogTableCompanion(
      id: id ?? this.id,
      attackerId: attackerId ?? this.attackerId,
      defenderId: defenderId ?? this.defenderId,
      timestamp: timestamp ?? this.timestamp,
      combatType: combatType ?? this.combatType,
      result: result ?? this.result,
      attackerLossesJson: attackerLossesJson ?? this.attackerLossesJson,
      defenderLossesJson: defenderLossesJson ?? this.defenderLossesJson,
      spoilsJson: spoilsJson ?? this.spoilsJson,
      battleLogJson: battleLogJson ?? this.battleLogJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attackerId.present) {
      map['attacker_id'] = Variable<int>(attackerId.value);
    }
    if (defenderId.present) {
      map['defender_id'] = Variable<int>(defenderId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (combatType.present) {
      map['combat_type'] = Variable<String>(combatType.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (attackerLossesJson.present) {
      map['attacker_losses_json'] = Variable<String>(attackerLossesJson.value);
    }
    if (defenderLossesJson.present) {
      map['defender_losses_json'] = Variable<String>(defenderLossesJson.value);
    }
    if (spoilsJson.present) {
      map['spoils_json'] = Variable<String>(spoilsJson.value);
    }
    if (battleLogJson.present) {
      map['battle_log_json'] = Variable<String>(battleLogJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CombatLogTableCompanion(')
          ..write('id: $id, ')
          ..write('attackerId: $attackerId, ')
          ..write('defenderId: $defenderId, ')
          ..write('timestamp: $timestamp, ')
          ..write('combatType: $combatType, ')
          ..write('result: $result, ')
          ..write('attackerLossesJson: $attackerLossesJson, ')
          ..write('defenderLossesJson: $defenderLossesJson, ')
          ..write('spoilsJson: $spoilsJson, ')
          ..write('battleLogJson: $battleLogJson')
          ..write(')'))
        .toString();
  }
}

class $MessagesTableTable extends MessagesTable
    with TableInfo<$MessagesTableTable, MessagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fromColonyIdMeta = const VerificationMeta(
    'fromColonyId',
  );
  @override
  late final GeneratedColumn<int> fromColonyId = GeneratedColumn<int>(
    'from_colony_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colonies (id)',
    ),
  );
  static const VerificationMeta _toColonyIdMeta = const VerificationMeta(
    'toColonyId',
  );
  @override
  late final GeneratedColumn<int> toColonyId = GeneratedColumn<int>(
    'to_colony_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colonies (id)',
    ),
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTemplateIdMeta = const VerificationMeta(
    'contentTemplateId',
  );
  @override
  late final GeneratedColumn<String> contentTemplateId =
      GeneratedColumn<String>(
        'content_template_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _variablesJsonMeta = const VerificationMeta(
    'variablesJson',
  );
  @override
  late final GeneratedColumn<String> variablesJson = GeneratedColumn<String>(
    'variables_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _responseTypeMeta = const VerificationMeta(
    'responseType',
  );
  @override
  late final GeneratedColumn<String> responseType = GeneratedColumn<String>(
    'response_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromColonyId,
    toColonyId,
    messageType,
    contentTemplateId,
    variablesJson,
    timestamp,
    isRead,
    responseType,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessagesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('from_colony_id')) {
      context.handle(
        _fromColonyIdMeta,
        fromColonyId.isAcceptableOrUnknown(
          data['from_colony_id']!,
          _fromColonyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromColonyIdMeta);
    }
    if (data.containsKey('to_colony_id')) {
      context.handle(
        _toColonyIdMeta,
        toColonyId.isAcceptableOrUnknown(
          data['to_colony_id']!,
          _toColonyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toColonyIdMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('content_template_id')) {
      context.handle(
        _contentTemplateIdMeta,
        contentTemplateId.isAcceptableOrUnknown(
          data['content_template_id']!,
          _contentTemplateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTemplateIdMeta);
    }
    if (data.containsKey('variables_json')) {
      context.handle(
        _variablesJsonMeta,
        variablesJson.isAcceptableOrUnknown(
          data['variables_json']!,
          _variablesJsonMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('response_type')) {
      context.handle(
        _responseTypeMeta,
        responseType.isAcceptableOrUnknown(
          data['response_type']!,
          _responseTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessagesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessagesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fromColonyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_colony_id'],
      )!,
      toColonyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_colony_id'],
      )!,
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      )!,
      contentTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_template_id'],
      )!,
      variablesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variables_json'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      responseType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_type'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $MessagesTableTable createAlias(String alias) {
    return $MessagesTableTable(attachedDatabase, alias);
  }
}

class MessagesTableData extends DataClass
    implements Insertable<MessagesTableData> {
  final int id;
  final int fromColonyId;
  final int toColonyId;
  final String messageType;
  final String contentTemplateId;
  final String variablesJson;
  final DateTime timestamp;
  final bool isRead;
  final String? responseType;
  final bool isArchived;
  const MessagesTableData({
    required this.id,
    required this.fromColonyId,
    required this.toColonyId,
    required this.messageType,
    required this.contentTemplateId,
    required this.variablesJson,
    required this.timestamp,
    required this.isRead,
    this.responseType,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['from_colony_id'] = Variable<int>(fromColonyId);
    map['to_colony_id'] = Variable<int>(toColonyId);
    map['message_type'] = Variable<String>(messageType);
    map['content_template_id'] = Variable<String>(contentTemplateId);
    map['variables_json'] = Variable<String>(variablesJson);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || responseType != null) {
      map['response_type'] = Variable<String>(responseType);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  MessagesTableCompanion toCompanion(bool nullToAbsent) {
    return MessagesTableCompanion(
      id: Value(id),
      fromColonyId: Value(fromColonyId),
      toColonyId: Value(toColonyId),
      messageType: Value(messageType),
      contentTemplateId: Value(contentTemplateId),
      variablesJson: Value(variablesJson),
      timestamp: Value(timestamp),
      isRead: Value(isRead),
      responseType: responseType == null && nullToAbsent
          ? const Value.absent()
          : Value(responseType),
      isArchived: Value(isArchived),
    );
  }

  factory MessagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessagesTableData(
      id: serializer.fromJson<int>(json['id']),
      fromColonyId: serializer.fromJson<int>(json['fromColonyId']),
      toColonyId: serializer.fromJson<int>(json['toColonyId']),
      messageType: serializer.fromJson<String>(json['messageType']),
      contentTemplateId: serializer.fromJson<String>(json['contentTemplateId']),
      variablesJson: serializer.fromJson<String>(json['variablesJson']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      responseType: serializer.fromJson<String?>(json['responseType']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fromColonyId': serializer.toJson<int>(fromColonyId),
      'toColonyId': serializer.toJson<int>(toColonyId),
      'messageType': serializer.toJson<String>(messageType),
      'contentTemplateId': serializer.toJson<String>(contentTemplateId),
      'variablesJson': serializer.toJson<String>(variablesJson),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isRead': serializer.toJson<bool>(isRead),
      'responseType': serializer.toJson<String?>(responseType),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  MessagesTableData copyWith({
    int? id,
    int? fromColonyId,
    int? toColonyId,
    String? messageType,
    String? contentTemplateId,
    String? variablesJson,
    DateTime? timestamp,
    bool? isRead,
    Value<String?> responseType = const Value.absent(),
    bool? isArchived,
  }) => MessagesTableData(
    id: id ?? this.id,
    fromColonyId: fromColonyId ?? this.fromColonyId,
    toColonyId: toColonyId ?? this.toColonyId,
    messageType: messageType ?? this.messageType,
    contentTemplateId: contentTemplateId ?? this.contentTemplateId,
    variablesJson: variablesJson ?? this.variablesJson,
    timestamp: timestamp ?? this.timestamp,
    isRead: isRead ?? this.isRead,
    responseType: responseType.present ? responseType.value : this.responseType,
    isArchived: isArchived ?? this.isArchived,
  );
  MessagesTableData copyWithCompanion(MessagesTableCompanion data) {
    return MessagesTableData(
      id: data.id.present ? data.id.value : this.id,
      fromColonyId: data.fromColonyId.present
          ? data.fromColonyId.value
          : this.fromColonyId,
      toColonyId: data.toColonyId.present
          ? data.toColonyId.value
          : this.toColonyId,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      contentTemplateId: data.contentTemplateId.present
          ? data.contentTemplateId.value
          : this.contentTemplateId,
      variablesJson: data.variablesJson.present
          ? data.variablesJson.value
          : this.variablesJson,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      responseType: data.responseType.present
          ? data.responseType.value
          : this.responseType,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessagesTableData(')
          ..write('id: $id, ')
          ..write('fromColonyId: $fromColonyId, ')
          ..write('toColonyId: $toColonyId, ')
          ..write('messageType: $messageType, ')
          ..write('contentTemplateId: $contentTemplateId, ')
          ..write('variablesJson: $variablesJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('isRead: $isRead, ')
          ..write('responseType: $responseType, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromColonyId,
    toColonyId,
    messageType,
    contentTemplateId,
    variablesJson,
    timestamp,
    isRead,
    responseType,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessagesTableData &&
          other.id == this.id &&
          other.fromColonyId == this.fromColonyId &&
          other.toColonyId == this.toColonyId &&
          other.messageType == this.messageType &&
          other.contentTemplateId == this.contentTemplateId &&
          other.variablesJson == this.variablesJson &&
          other.timestamp == this.timestamp &&
          other.isRead == this.isRead &&
          other.responseType == this.responseType &&
          other.isArchived == this.isArchived);
}

class MessagesTableCompanion extends UpdateCompanion<MessagesTableData> {
  final Value<int> id;
  final Value<int> fromColonyId;
  final Value<int> toColonyId;
  final Value<String> messageType;
  final Value<String> contentTemplateId;
  final Value<String> variablesJson;
  final Value<DateTime> timestamp;
  final Value<bool> isRead;
  final Value<String?> responseType;
  final Value<bool> isArchived;
  const MessagesTableCompanion({
    this.id = const Value.absent(),
    this.fromColonyId = const Value.absent(),
    this.toColonyId = const Value.absent(),
    this.messageType = const Value.absent(),
    this.contentTemplateId = const Value.absent(),
    this.variablesJson = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isRead = const Value.absent(),
    this.responseType = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  MessagesTableCompanion.insert({
    this.id = const Value.absent(),
    required int fromColonyId,
    required int toColonyId,
    required String messageType,
    required String contentTemplateId,
    this.variablesJson = const Value.absent(),
    required DateTime timestamp,
    this.isRead = const Value.absent(),
    this.responseType = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : fromColonyId = Value(fromColonyId),
       toColonyId = Value(toColonyId),
       messageType = Value(messageType),
       contentTemplateId = Value(contentTemplateId),
       timestamp = Value(timestamp);
  static Insertable<MessagesTableData> custom({
    Expression<int>? id,
    Expression<int>? fromColonyId,
    Expression<int>? toColonyId,
    Expression<String>? messageType,
    Expression<String>? contentTemplateId,
    Expression<String>? variablesJson,
    Expression<DateTime>? timestamp,
    Expression<bool>? isRead,
    Expression<String>? responseType,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromColonyId != null) 'from_colony_id': fromColonyId,
      if (toColonyId != null) 'to_colony_id': toColonyId,
      if (messageType != null) 'message_type': messageType,
      if (contentTemplateId != null) 'content_template_id': contentTemplateId,
      if (variablesJson != null) 'variables_json': variablesJson,
      if (timestamp != null) 'timestamp': timestamp,
      if (isRead != null) 'is_read': isRead,
      if (responseType != null) 'response_type': responseType,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  MessagesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? fromColonyId,
    Value<int>? toColonyId,
    Value<String>? messageType,
    Value<String>? contentTemplateId,
    Value<String>? variablesJson,
    Value<DateTime>? timestamp,
    Value<bool>? isRead,
    Value<String?>? responseType,
    Value<bool>? isArchived,
  }) {
    return MessagesTableCompanion(
      id: id ?? this.id,
      fromColonyId: fromColonyId ?? this.fromColonyId,
      toColonyId: toColonyId ?? this.toColonyId,
      messageType: messageType ?? this.messageType,
      contentTemplateId: contentTemplateId ?? this.contentTemplateId,
      variablesJson: variablesJson ?? this.variablesJson,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      responseType: responseType ?? this.responseType,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fromColonyId.present) {
      map['from_colony_id'] = Variable<int>(fromColonyId.value);
    }
    if (toColonyId.present) {
      map['to_colony_id'] = Variable<int>(toColonyId.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (contentTemplateId.present) {
      map['content_template_id'] = Variable<String>(contentTemplateId.value);
    }
    if (variablesJson.present) {
      map['variables_json'] = Variable<String>(variablesJson.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (responseType.present) {
      map['response_type'] = Variable<String>(responseType.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesTableCompanion(')
          ..write('id: $id, ')
          ..write('fromColonyId: $fromColonyId, ')
          ..write('toColonyId: $toColonyId, ')
          ..write('messageType: $messageType, ')
          ..write('contentTemplateId: $contentTemplateId, ')
          ..write('variablesJson: $variablesJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('isRead: $isRead, ')
          ..write('responseType: $responseType, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $DiplomacyTableTable extends DiplomacyTable
    with TableInfo<$DiplomacyTableTable, DiplomacyTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiplomacyTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _colony1IdMeta = const VerificationMeta(
    'colony1Id',
  );
  @override
  late final GeneratedColumn<int> colony1Id = GeneratedColumn<int>(
    'colony1_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colonies (id)',
    ),
  );
  static const VerificationMeta _colony2IdMeta = const VerificationMeta(
    'colony2Id',
  );
  @override
  late final GeneratedColumn<int> colony2Id = GeneratedColumn<int>(
    'colony2_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colonies (id)',
    ),
  );
  static const VerificationMeta _relationTypeMeta = const VerificationMeta(
    'relationType',
  );
  @override
  late final GeneratedColumn<String> relationType = GeneratedColumn<String>(
    'relation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('neutral'),
  );
  static const VerificationMeta _dispositionMeta = const VerificationMeta(
    'disposition',
  );
  @override
  late final GeneratedColumn<int> disposition = GeneratedColumn<int>(
    'disposition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _trustLevelMeta = const VerificationMeta(
    'trustLevel',
  );
  @override
  late final GeneratedColumn<int> trustLevel = GeneratedColumn<int>(
    'trust_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastInteractionMeta = const VerificationMeta(
    'lastInteraction',
  );
  @override
  late final GeneratedColumn<DateTime> lastInteraction =
      GeneratedColumn<DateTime>(
        'last_interaction',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pactTypeMeta = const VerificationMeta(
    'pactType',
  );
  @override
  late final GeneratedColumn<String> pactType = GeneratedColumn<String>(
    'pact_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pactExpiryTimeMeta = const VerificationMeta(
    'pactExpiryTime',
  );
  @override
  late final GeneratedColumn<DateTime> pactExpiryTime =
      GeneratedColumn<DateTime>(
        'pact_expiry_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _treatyViolatedMeta = const VerificationMeta(
    'treatyViolated',
  );
  @override
  late final GeneratedColumn<bool> treatyViolated = GeneratedColumn<bool>(
    'treaty_violated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("treaty_violated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    colony1Id,
    colony2Id,
    relationType,
    disposition,
    trustLevel,
    lastInteraction,
    pactType,
    pactExpiryTime,
    treatyViolated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diplomacy';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiplomacyTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('colony1_id')) {
      context.handle(
        _colony1IdMeta,
        colony1Id.isAcceptableOrUnknown(data['colony1_id']!, _colony1IdMeta),
      );
    } else if (isInserting) {
      context.missing(_colony1IdMeta);
    }
    if (data.containsKey('colony2_id')) {
      context.handle(
        _colony2IdMeta,
        colony2Id.isAcceptableOrUnknown(data['colony2_id']!, _colony2IdMeta),
      );
    } else if (isInserting) {
      context.missing(_colony2IdMeta);
    }
    if (data.containsKey('relation_type')) {
      context.handle(
        _relationTypeMeta,
        relationType.isAcceptableOrUnknown(
          data['relation_type']!,
          _relationTypeMeta,
        ),
      );
    }
    if (data.containsKey('disposition')) {
      context.handle(
        _dispositionMeta,
        disposition.isAcceptableOrUnknown(
          data['disposition']!,
          _dispositionMeta,
        ),
      );
    }
    if (data.containsKey('trust_level')) {
      context.handle(
        _trustLevelMeta,
        trustLevel.isAcceptableOrUnknown(data['trust_level']!, _trustLevelMeta),
      );
    }
    if (data.containsKey('last_interaction')) {
      context.handle(
        _lastInteractionMeta,
        lastInteraction.isAcceptableOrUnknown(
          data['last_interaction']!,
          _lastInteractionMeta,
        ),
      );
    }
    if (data.containsKey('pact_type')) {
      context.handle(
        _pactTypeMeta,
        pactType.isAcceptableOrUnknown(data['pact_type']!, _pactTypeMeta),
      );
    }
    if (data.containsKey('pact_expiry_time')) {
      context.handle(
        _pactExpiryTimeMeta,
        pactExpiryTime.isAcceptableOrUnknown(
          data['pact_expiry_time']!,
          _pactExpiryTimeMeta,
        ),
      );
    }
    if (data.containsKey('treaty_violated')) {
      context.handle(
        _treatyViolatedMeta,
        treatyViolated.isAcceptableOrUnknown(
          data['treaty_violated']!,
          _treatyViolatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {colony1Id, colony2Id},
  ];
  @override
  DiplomacyTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiplomacyTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      colony1Id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colony1_id'],
      )!,
      colony2Id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colony2_id'],
      )!,
      relationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_type'],
      )!,
      disposition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disposition'],
      )!,
      trustLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trust_level'],
      )!,
      lastInteraction: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_interaction'],
      ),
      pactType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pact_type'],
      ),
      pactExpiryTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pact_expiry_time'],
      ),
      treatyViolated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}treaty_violated'],
      )!,
    );
  }

  @override
  $DiplomacyTableTable createAlias(String alias) {
    return $DiplomacyTableTable(attachedDatabase, alias);
  }
}

class DiplomacyTableData extends DataClass
    implements Insertable<DiplomacyTableData> {
  final int id;
  final int colony1Id;
  final int colony2Id;
  final String relationType;
  final int disposition;
  final int trustLevel;
  final DateTime? lastInteraction;
  final String? pactType;
  final DateTime? pactExpiryTime;
  final bool treatyViolated;
  const DiplomacyTableData({
    required this.id,
    required this.colony1Id,
    required this.colony2Id,
    required this.relationType,
    required this.disposition,
    required this.trustLevel,
    this.lastInteraction,
    this.pactType,
    this.pactExpiryTime,
    required this.treatyViolated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['colony1_id'] = Variable<int>(colony1Id);
    map['colony2_id'] = Variable<int>(colony2Id);
    map['relation_type'] = Variable<String>(relationType);
    map['disposition'] = Variable<int>(disposition);
    map['trust_level'] = Variable<int>(trustLevel);
    if (!nullToAbsent || lastInteraction != null) {
      map['last_interaction'] = Variable<DateTime>(lastInteraction);
    }
    if (!nullToAbsent || pactType != null) {
      map['pact_type'] = Variable<String>(pactType);
    }
    if (!nullToAbsent || pactExpiryTime != null) {
      map['pact_expiry_time'] = Variable<DateTime>(pactExpiryTime);
    }
    map['treaty_violated'] = Variable<bool>(treatyViolated);
    return map;
  }

  DiplomacyTableCompanion toCompanion(bool nullToAbsent) {
    return DiplomacyTableCompanion(
      id: Value(id),
      colony1Id: Value(colony1Id),
      colony2Id: Value(colony2Id),
      relationType: Value(relationType),
      disposition: Value(disposition),
      trustLevel: Value(trustLevel),
      lastInteraction: lastInteraction == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInteraction),
      pactType: pactType == null && nullToAbsent
          ? const Value.absent()
          : Value(pactType),
      pactExpiryTime: pactExpiryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(pactExpiryTime),
      treatyViolated: Value(treatyViolated),
    );
  }

  factory DiplomacyTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiplomacyTableData(
      id: serializer.fromJson<int>(json['id']),
      colony1Id: serializer.fromJson<int>(json['colony1Id']),
      colony2Id: serializer.fromJson<int>(json['colony2Id']),
      relationType: serializer.fromJson<String>(json['relationType']),
      disposition: serializer.fromJson<int>(json['disposition']),
      trustLevel: serializer.fromJson<int>(json['trustLevel']),
      lastInteraction: serializer.fromJson<DateTime?>(json['lastInteraction']),
      pactType: serializer.fromJson<String?>(json['pactType']),
      pactExpiryTime: serializer.fromJson<DateTime?>(json['pactExpiryTime']),
      treatyViolated: serializer.fromJson<bool>(json['treatyViolated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'colony1Id': serializer.toJson<int>(colony1Id),
      'colony2Id': serializer.toJson<int>(colony2Id),
      'relationType': serializer.toJson<String>(relationType),
      'disposition': serializer.toJson<int>(disposition),
      'trustLevel': serializer.toJson<int>(trustLevel),
      'lastInteraction': serializer.toJson<DateTime?>(lastInteraction),
      'pactType': serializer.toJson<String?>(pactType),
      'pactExpiryTime': serializer.toJson<DateTime?>(pactExpiryTime),
      'treatyViolated': serializer.toJson<bool>(treatyViolated),
    };
  }

  DiplomacyTableData copyWith({
    int? id,
    int? colony1Id,
    int? colony2Id,
    String? relationType,
    int? disposition,
    int? trustLevel,
    Value<DateTime?> lastInteraction = const Value.absent(),
    Value<String?> pactType = const Value.absent(),
    Value<DateTime?> pactExpiryTime = const Value.absent(),
    bool? treatyViolated,
  }) => DiplomacyTableData(
    id: id ?? this.id,
    colony1Id: colony1Id ?? this.colony1Id,
    colony2Id: colony2Id ?? this.colony2Id,
    relationType: relationType ?? this.relationType,
    disposition: disposition ?? this.disposition,
    trustLevel: trustLevel ?? this.trustLevel,
    lastInteraction: lastInteraction.present
        ? lastInteraction.value
        : this.lastInteraction,
    pactType: pactType.present ? pactType.value : this.pactType,
    pactExpiryTime: pactExpiryTime.present
        ? pactExpiryTime.value
        : this.pactExpiryTime,
    treatyViolated: treatyViolated ?? this.treatyViolated,
  );
  DiplomacyTableData copyWithCompanion(DiplomacyTableCompanion data) {
    return DiplomacyTableData(
      id: data.id.present ? data.id.value : this.id,
      colony1Id: data.colony1Id.present ? data.colony1Id.value : this.colony1Id,
      colony2Id: data.colony2Id.present ? data.colony2Id.value : this.colony2Id,
      relationType: data.relationType.present
          ? data.relationType.value
          : this.relationType,
      disposition: data.disposition.present
          ? data.disposition.value
          : this.disposition,
      trustLevel: data.trustLevel.present
          ? data.trustLevel.value
          : this.trustLevel,
      lastInteraction: data.lastInteraction.present
          ? data.lastInteraction.value
          : this.lastInteraction,
      pactType: data.pactType.present ? data.pactType.value : this.pactType,
      pactExpiryTime: data.pactExpiryTime.present
          ? data.pactExpiryTime.value
          : this.pactExpiryTime,
      treatyViolated: data.treatyViolated.present
          ? data.treatyViolated.value
          : this.treatyViolated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiplomacyTableData(')
          ..write('id: $id, ')
          ..write('colony1Id: $colony1Id, ')
          ..write('colony2Id: $colony2Id, ')
          ..write('relationType: $relationType, ')
          ..write('disposition: $disposition, ')
          ..write('trustLevel: $trustLevel, ')
          ..write('lastInteraction: $lastInteraction, ')
          ..write('pactType: $pactType, ')
          ..write('pactExpiryTime: $pactExpiryTime, ')
          ..write('treatyViolated: $treatyViolated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    colony1Id,
    colony2Id,
    relationType,
    disposition,
    trustLevel,
    lastInteraction,
    pactType,
    pactExpiryTime,
    treatyViolated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiplomacyTableData &&
          other.id == this.id &&
          other.colony1Id == this.colony1Id &&
          other.colony2Id == this.colony2Id &&
          other.relationType == this.relationType &&
          other.disposition == this.disposition &&
          other.trustLevel == this.trustLevel &&
          other.lastInteraction == this.lastInteraction &&
          other.pactType == this.pactType &&
          other.pactExpiryTime == this.pactExpiryTime &&
          other.treatyViolated == this.treatyViolated);
}

class DiplomacyTableCompanion extends UpdateCompanion<DiplomacyTableData> {
  final Value<int> id;
  final Value<int> colony1Id;
  final Value<int> colony2Id;
  final Value<String> relationType;
  final Value<int> disposition;
  final Value<int> trustLevel;
  final Value<DateTime?> lastInteraction;
  final Value<String?> pactType;
  final Value<DateTime?> pactExpiryTime;
  final Value<bool> treatyViolated;
  const DiplomacyTableCompanion({
    this.id = const Value.absent(),
    this.colony1Id = const Value.absent(),
    this.colony2Id = const Value.absent(),
    this.relationType = const Value.absent(),
    this.disposition = const Value.absent(),
    this.trustLevel = const Value.absent(),
    this.lastInteraction = const Value.absent(),
    this.pactType = const Value.absent(),
    this.pactExpiryTime = const Value.absent(),
    this.treatyViolated = const Value.absent(),
  });
  DiplomacyTableCompanion.insert({
    this.id = const Value.absent(),
    required int colony1Id,
    required int colony2Id,
    this.relationType = const Value.absent(),
    this.disposition = const Value.absent(),
    this.trustLevel = const Value.absent(),
    this.lastInteraction = const Value.absent(),
    this.pactType = const Value.absent(),
    this.pactExpiryTime = const Value.absent(),
    this.treatyViolated = const Value.absent(),
  }) : colony1Id = Value(colony1Id),
       colony2Id = Value(colony2Id);
  static Insertable<DiplomacyTableData> custom({
    Expression<int>? id,
    Expression<int>? colony1Id,
    Expression<int>? colony2Id,
    Expression<String>? relationType,
    Expression<int>? disposition,
    Expression<int>? trustLevel,
    Expression<DateTime>? lastInteraction,
    Expression<String>? pactType,
    Expression<DateTime>? pactExpiryTime,
    Expression<bool>? treatyViolated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (colony1Id != null) 'colony1_id': colony1Id,
      if (colony2Id != null) 'colony2_id': colony2Id,
      if (relationType != null) 'relation_type': relationType,
      if (disposition != null) 'disposition': disposition,
      if (trustLevel != null) 'trust_level': trustLevel,
      if (lastInteraction != null) 'last_interaction': lastInteraction,
      if (pactType != null) 'pact_type': pactType,
      if (pactExpiryTime != null) 'pact_expiry_time': pactExpiryTime,
      if (treatyViolated != null) 'treaty_violated': treatyViolated,
    });
  }

  DiplomacyTableCompanion copyWith({
    Value<int>? id,
    Value<int>? colony1Id,
    Value<int>? colony2Id,
    Value<String>? relationType,
    Value<int>? disposition,
    Value<int>? trustLevel,
    Value<DateTime?>? lastInteraction,
    Value<String?>? pactType,
    Value<DateTime?>? pactExpiryTime,
    Value<bool>? treatyViolated,
  }) {
    return DiplomacyTableCompanion(
      id: id ?? this.id,
      colony1Id: colony1Id ?? this.colony1Id,
      colony2Id: colony2Id ?? this.colony2Id,
      relationType: relationType ?? this.relationType,
      disposition: disposition ?? this.disposition,
      trustLevel: trustLevel ?? this.trustLevel,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      pactType: pactType ?? this.pactType,
      pactExpiryTime: pactExpiryTime ?? this.pactExpiryTime,
      treatyViolated: treatyViolated ?? this.treatyViolated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (colony1Id.present) {
      map['colony1_id'] = Variable<int>(colony1Id.value);
    }
    if (colony2Id.present) {
      map['colony2_id'] = Variable<int>(colony2Id.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(relationType.value);
    }
    if (disposition.present) {
      map['disposition'] = Variable<int>(disposition.value);
    }
    if (trustLevel.present) {
      map['trust_level'] = Variable<int>(trustLevel.value);
    }
    if (lastInteraction.present) {
      map['last_interaction'] = Variable<DateTime>(lastInteraction.value);
    }
    if (pactType.present) {
      map['pact_type'] = Variable<String>(pactType.value);
    }
    if (pactExpiryTime.present) {
      map['pact_expiry_time'] = Variable<DateTime>(pactExpiryTime.value);
    }
    if (treatyViolated.present) {
      map['treaty_violated'] = Variable<bool>(treatyViolated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiplomacyTableCompanion(')
          ..write('id: $id, ')
          ..write('colony1Id: $colony1Id, ')
          ..write('colony2Id: $colony2Id, ')
          ..write('relationType: $relationType, ')
          ..write('disposition: $disposition, ')
          ..write('trustLevel: $trustLevel, ')
          ..write('lastInteraction: $lastInteraction, ')
          ..write('pactType: $pactType, ')
          ..write('pactExpiryTime: $pactExpiryTime, ')
          ..write('treatyViolated: $treatyViolated')
          ..write(')'))
        .toString();
  }
}

class $ResearchTableTable extends ResearchTable
    with TableInfo<$ResearchTableTable, ResearchTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _techIdMeta = const VerificationMeta('techId');
  @override
  late final GeneratedColumn<String> techId = GeneratedColumn<String>(
    'tech_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _techNameMeta = const VerificationMeta(
    'techName',
  );
  @override
  late final GeneratedColumn<String> techName = GeneratedColumn<String>(
    'tech_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _techTierMeta = const VerificationMeta(
    'techTier',
  );
  @override
  late final GeneratedColumn<int> techTier = GeneratedColumn<int>(
    'tech_tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completionPercentageMeta =
      const VerificationMeta('completionPercentage');
  @override
  late final GeneratedColumn<int> completionPercentage = GeneratedColumn<int>(
    'completion_percentage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsRequiredMeta = const VerificationMeta(
    'pointsRequired',
  );
  @override
  late final GeneratedColumn<int> pointsRequired = GeneratedColumn<int>(
    'points_required',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsInvestedMeta = const VerificationMeta(
    'pointsInvested',
  );
  @override
  late final GeneratedColumn<int> pointsInvested = GeneratedColumn<int>(
    'points_invested',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _prerequisitesJsonMeta = const VerificationMeta(
    'prerequisitesJson',
  );
  @override
  late final GeneratedColumn<String> prerequisitesJson =
      GeneratedColumn<String>(
        'prerequisites_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    techId,
    techName,
    techTier,
    isCompleted,
    completionPercentage,
    startTime,
    endTime,
    pointsRequired,
    pointsInvested,
    prerequisitesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResearchTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tech_id')) {
      context.handle(
        _techIdMeta,
        techId.isAcceptableOrUnknown(data['tech_id']!, _techIdMeta),
      );
    } else if (isInserting) {
      context.missing(_techIdMeta);
    }
    if (data.containsKey('tech_name')) {
      context.handle(
        _techNameMeta,
        techName.isAcceptableOrUnknown(data['tech_name']!, _techNameMeta),
      );
    } else if (isInserting) {
      context.missing(_techNameMeta);
    }
    if (data.containsKey('tech_tier')) {
      context.handle(
        _techTierMeta,
        techTier.isAcceptableOrUnknown(data['tech_tier']!, _techTierMeta),
      );
    } else if (isInserting) {
      context.missing(_techTierMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completion_percentage')) {
      context.handle(
        _completionPercentageMeta,
        completionPercentage.isAcceptableOrUnknown(
          data['completion_percentage']!,
          _completionPercentageMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('points_required')) {
      context.handle(
        _pointsRequiredMeta,
        pointsRequired.isAcceptableOrUnknown(
          data['points_required']!,
          _pointsRequiredMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointsRequiredMeta);
    }
    if (data.containsKey('points_invested')) {
      context.handle(
        _pointsInvestedMeta,
        pointsInvested.isAcceptableOrUnknown(
          data['points_invested']!,
          _pointsInvestedMeta,
        ),
      );
    }
    if (data.containsKey('prerequisites_json')) {
      context.handle(
        _prerequisitesJsonMeta,
        prerequisitesJson.isAcceptableOrUnknown(
          data['prerequisites_json']!,
          _prerequisitesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      techId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tech_id'],
      )!,
      techName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tech_name'],
      )!,
      techTier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tech_tier'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completionPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_percentage'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      pointsRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_required'],
      )!,
      pointsInvested: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_invested'],
      )!,
      prerequisitesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prerequisites_json'],
      )!,
    );
  }

  @override
  $ResearchTableTable createAlias(String alias) {
    return $ResearchTableTable(attachedDatabase, alias);
  }
}

class ResearchTableData extends DataClass
    implements Insertable<ResearchTableData> {
  final int id;
  final String techId;
  final String techName;
  final int techTier;
  final bool isCompleted;
  final int completionPercentage;
  final DateTime? startTime;
  final DateTime? endTime;
  final int pointsRequired;
  final int pointsInvested;
  final String prerequisitesJson;
  const ResearchTableData({
    required this.id,
    required this.techId,
    required this.techName,
    required this.techTier,
    required this.isCompleted,
    required this.completionPercentage,
    this.startTime,
    this.endTime,
    required this.pointsRequired,
    required this.pointsInvested,
    required this.prerequisitesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tech_id'] = Variable<String>(techId);
    map['tech_name'] = Variable<String>(techName);
    map['tech_tier'] = Variable<int>(techTier);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['completion_percentage'] = Variable<int>(completionPercentage);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['points_required'] = Variable<int>(pointsRequired);
    map['points_invested'] = Variable<int>(pointsInvested);
    map['prerequisites_json'] = Variable<String>(prerequisitesJson);
    return map;
  }

  ResearchTableCompanion toCompanion(bool nullToAbsent) {
    return ResearchTableCompanion(
      id: Value(id),
      techId: Value(techId),
      techName: Value(techName),
      techTier: Value(techTier),
      isCompleted: Value(isCompleted),
      completionPercentage: Value(completionPercentage),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      pointsRequired: Value(pointsRequired),
      pointsInvested: Value(pointsInvested),
      prerequisitesJson: Value(prerequisitesJson),
    );
  }

  factory ResearchTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchTableData(
      id: serializer.fromJson<int>(json['id']),
      techId: serializer.fromJson<String>(json['techId']),
      techName: serializer.fromJson<String>(json['techName']),
      techTier: serializer.fromJson<int>(json['techTier']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completionPercentage: serializer.fromJson<int>(
        json['completionPercentage'],
      ),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      pointsRequired: serializer.fromJson<int>(json['pointsRequired']),
      pointsInvested: serializer.fromJson<int>(json['pointsInvested']),
      prerequisitesJson: serializer.fromJson<String>(json['prerequisitesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'techId': serializer.toJson<String>(techId),
      'techName': serializer.toJson<String>(techName),
      'techTier': serializer.toJson<int>(techTier),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completionPercentage': serializer.toJson<int>(completionPercentage),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'pointsRequired': serializer.toJson<int>(pointsRequired),
      'pointsInvested': serializer.toJson<int>(pointsInvested),
      'prerequisitesJson': serializer.toJson<String>(prerequisitesJson),
    };
  }

  ResearchTableData copyWith({
    int? id,
    String? techId,
    String? techName,
    int? techTier,
    bool? isCompleted,
    int? completionPercentage,
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
    int? pointsRequired,
    int? pointsInvested,
    String? prerequisitesJson,
  }) => ResearchTableData(
    id: id ?? this.id,
    techId: techId ?? this.techId,
    techName: techName ?? this.techName,
    techTier: techTier ?? this.techTier,
    isCompleted: isCompleted ?? this.isCompleted,
    completionPercentage: completionPercentage ?? this.completionPercentage,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    pointsRequired: pointsRequired ?? this.pointsRequired,
    pointsInvested: pointsInvested ?? this.pointsInvested,
    prerequisitesJson: prerequisitesJson ?? this.prerequisitesJson,
  );
  ResearchTableData copyWithCompanion(ResearchTableCompanion data) {
    return ResearchTableData(
      id: data.id.present ? data.id.value : this.id,
      techId: data.techId.present ? data.techId.value : this.techId,
      techName: data.techName.present ? data.techName.value : this.techName,
      techTier: data.techTier.present ? data.techTier.value : this.techTier,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completionPercentage: data.completionPercentage.present
          ? data.completionPercentage.value
          : this.completionPercentage,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      pointsRequired: data.pointsRequired.present
          ? data.pointsRequired.value
          : this.pointsRequired,
      pointsInvested: data.pointsInvested.present
          ? data.pointsInvested.value
          : this.pointsInvested,
      prerequisitesJson: data.prerequisitesJson.present
          ? data.prerequisitesJson.value
          : this.prerequisitesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchTableData(')
          ..write('id: $id, ')
          ..write('techId: $techId, ')
          ..write('techName: $techName, ')
          ..write('techTier: $techTier, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('pointsRequired: $pointsRequired, ')
          ..write('pointsInvested: $pointsInvested, ')
          ..write('prerequisitesJson: $prerequisitesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    techId,
    techName,
    techTier,
    isCompleted,
    completionPercentage,
    startTime,
    endTime,
    pointsRequired,
    pointsInvested,
    prerequisitesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchTableData &&
          other.id == this.id &&
          other.techId == this.techId &&
          other.techName == this.techName &&
          other.techTier == this.techTier &&
          other.isCompleted == this.isCompleted &&
          other.completionPercentage == this.completionPercentage &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.pointsRequired == this.pointsRequired &&
          other.pointsInvested == this.pointsInvested &&
          other.prerequisitesJson == this.prerequisitesJson);
}

class ResearchTableCompanion extends UpdateCompanion<ResearchTableData> {
  final Value<int> id;
  final Value<String> techId;
  final Value<String> techName;
  final Value<int> techTier;
  final Value<bool> isCompleted;
  final Value<int> completionPercentage;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<int> pointsRequired;
  final Value<int> pointsInvested;
  final Value<String> prerequisitesJson;
  const ResearchTableCompanion({
    this.id = const Value.absent(),
    this.techId = const Value.absent(),
    this.techName = const Value.absent(),
    this.techTier = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completionPercentage = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.pointsRequired = const Value.absent(),
    this.pointsInvested = const Value.absent(),
    this.prerequisitesJson = const Value.absent(),
  });
  ResearchTableCompanion.insert({
    this.id = const Value.absent(),
    required String techId,
    required String techName,
    required int techTier,
    this.isCompleted = const Value.absent(),
    this.completionPercentage = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    required int pointsRequired,
    this.pointsInvested = const Value.absent(),
    this.prerequisitesJson = const Value.absent(),
  }) : techId = Value(techId),
       techName = Value(techName),
       techTier = Value(techTier),
       pointsRequired = Value(pointsRequired);
  static Insertable<ResearchTableData> custom({
    Expression<int>? id,
    Expression<String>? techId,
    Expression<String>? techName,
    Expression<int>? techTier,
    Expression<bool>? isCompleted,
    Expression<int>? completionPercentage,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? pointsRequired,
    Expression<int>? pointsInvested,
    Expression<String>? prerequisitesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (techId != null) 'tech_id': techId,
      if (techName != null) 'tech_name': techName,
      if (techTier != null) 'tech_tier': techTier,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completionPercentage != null)
        'completion_percentage': completionPercentage,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (pointsRequired != null) 'points_required': pointsRequired,
      if (pointsInvested != null) 'points_invested': pointsInvested,
      if (prerequisitesJson != null) 'prerequisites_json': prerequisitesJson,
    });
  }

  ResearchTableCompanion copyWith({
    Value<int>? id,
    Value<String>? techId,
    Value<String>? techName,
    Value<int>? techTier,
    Value<bool>? isCompleted,
    Value<int>? completionPercentage,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? pointsRequired,
    Value<int>? pointsInvested,
    Value<String>? prerequisitesJson,
  }) {
    return ResearchTableCompanion(
      id: id ?? this.id,
      techId: techId ?? this.techId,
      techName: techName ?? this.techName,
      techTier: techTier ?? this.techTier,
      isCompleted: isCompleted ?? this.isCompleted,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      pointsInvested: pointsInvested ?? this.pointsInvested,
      prerequisitesJson: prerequisitesJson ?? this.prerequisitesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (techId.present) {
      map['tech_id'] = Variable<String>(techId.value);
    }
    if (techName.present) {
      map['tech_name'] = Variable<String>(techName.value);
    }
    if (techTier.present) {
      map['tech_tier'] = Variable<int>(techTier.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completionPercentage.present) {
      map['completion_percentage'] = Variable<int>(completionPercentage.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (pointsRequired.present) {
      map['points_required'] = Variable<int>(pointsRequired.value);
    }
    if (pointsInvested.present) {
      map['points_invested'] = Variable<int>(pointsInvested.value);
    }
    if (prerequisitesJson.present) {
      map['prerequisites_json'] = Variable<String>(prerequisitesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchTableCompanion(')
          ..write('id: $id, ')
          ..write('techId: $techId, ')
          ..write('techName: $techName, ')
          ..write('techTier: $techTier, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completionPercentage: $completionPercentage, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('pointsRequired: $pointsRequired, ')
          ..write('pointsInvested: $pointsInvested, ')
          ..write('prerequisitesJson: $prerequisitesJson')
          ..write(')'))
        .toString();
  }
}

class $QuestsTableTable extends QuestsTable
    with TableInfo<$QuestsTableTable, QuestsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questIdMeta = const VerificationMeta(
    'questId',
  );
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
    'quest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _questNameMeta = const VerificationMeta(
    'questName',
  );
  @override
  late final GeneratedColumn<String> questName = GeneratedColumn<String>(
    'quest_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questTypeMeta = const VerificationMeta(
    'questType',
  );
  @override
  late final GeneratedColumn<String> questType = GeneratedColumn<String>(
    'quest_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressJsonMeta = const VerificationMeta(
    'progressJson',
  );
  @override
  late final GeneratedColumn<String> progressJson = GeneratedColumn<String>(
    'progress_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _progressPercentageMeta =
      const VerificationMeta('progressPercentage');
  @override
  late final GeneratedColumn<int> progressPercentage = GeneratedColumn<int>(
    'progress_percentage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewardXpMeta = const VerificationMeta(
    'rewardXp',
  );
  @override
  late final GeneratedColumn<int> rewardXp = GeneratedColumn<int>(
    'reward_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rewardCreditsMeta = const VerificationMeta(
    'rewardCredits',
  );
  @override
  late final GeneratedColumn<int> rewardCredits = GeneratedColumn<int>(
    'reward_credits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questId,
    questName,
    questType,
    description,
    progressJson,
    progressPercentage,
    isCompleted,
    startedAt,
    completedAt,
    rewardXp,
    rewardCredits,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quest_id')) {
      context.handle(
        _questIdMeta,
        questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('quest_name')) {
      context.handle(
        _questNameMeta,
        questName.isAcceptableOrUnknown(data['quest_name']!, _questNameMeta),
      );
    } else if (isInserting) {
      context.missing(_questNameMeta);
    }
    if (data.containsKey('quest_type')) {
      context.handle(
        _questTypeMeta,
        questType.isAcceptableOrUnknown(data['quest_type']!, _questTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_questTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('progress_json')) {
      context.handle(
        _progressJsonMeta,
        progressJson.isAcceptableOrUnknown(
          data['progress_json']!,
          _progressJsonMeta,
        ),
      );
    }
    if (data.containsKey('progress_percentage')) {
      context.handle(
        _progressPercentageMeta,
        progressPercentage.isAcceptableOrUnknown(
          data['progress_percentage']!,
          _progressPercentageMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('reward_xp')) {
      context.handle(
        _rewardXpMeta,
        rewardXp.isAcceptableOrUnknown(data['reward_xp']!, _rewardXpMeta),
      );
    }
    if (data.containsKey('reward_credits')) {
      context.handle(
        _rewardCreditsMeta,
        rewardCredits.isAcceptableOrUnknown(
          data['reward_credits']!,
          _rewardCreditsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_id'],
      )!,
      questName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_name'],
      )!,
      questType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      progressJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}progress_json'],
      )!,
      progressPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_percentage'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      rewardXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_xp'],
      )!,
      rewardCredits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_credits'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $QuestsTableTable createAlias(String alias) {
    return $QuestsTableTable(attachedDatabase, alias);
  }
}

class QuestsTableData extends DataClass implements Insertable<QuestsTableData> {
  final int id;
  final String questId;
  final String questName;
  final String questType;
  final String? description;
  final String progressJson;
  final int progressPercentage;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int rewardXp;
  final int rewardCredits;
  final bool isActive;
  const QuestsTableData({
    required this.id,
    required this.questId,
    required this.questName,
    required this.questType,
    this.description,
    required this.progressJson,
    required this.progressPercentage,
    required this.isCompleted,
    this.startedAt,
    this.completedAt,
    required this.rewardXp,
    required this.rewardCredits,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quest_id'] = Variable<String>(questId);
    map['quest_name'] = Variable<String>(questName);
    map['quest_type'] = Variable<String>(questType);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['progress_json'] = Variable<String>(progressJson);
    map['progress_percentage'] = Variable<int>(progressPercentage);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['reward_xp'] = Variable<int>(rewardXp);
    map['reward_credits'] = Variable<int>(rewardCredits);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  QuestsTableCompanion toCompanion(bool nullToAbsent) {
    return QuestsTableCompanion(
      id: Value(id),
      questId: Value(questId),
      questName: Value(questName),
      questType: Value(questType),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      progressJson: Value(progressJson),
      progressPercentage: Value(progressPercentage),
      isCompleted: Value(isCompleted),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      rewardXp: Value(rewardXp),
      rewardCredits: Value(rewardCredits),
      isActive: Value(isActive),
    );
  }

  factory QuestsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestsTableData(
      id: serializer.fromJson<int>(json['id']),
      questId: serializer.fromJson<String>(json['questId']),
      questName: serializer.fromJson<String>(json['questName']),
      questType: serializer.fromJson<String>(json['questType']),
      description: serializer.fromJson<String?>(json['description']),
      progressJson: serializer.fromJson<String>(json['progressJson']),
      progressPercentage: serializer.fromJson<int>(json['progressPercentage']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      rewardXp: serializer.fromJson<int>(json['rewardXp']),
      rewardCredits: serializer.fromJson<int>(json['rewardCredits']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questId': serializer.toJson<String>(questId),
      'questName': serializer.toJson<String>(questName),
      'questType': serializer.toJson<String>(questType),
      'description': serializer.toJson<String?>(description),
      'progressJson': serializer.toJson<String>(progressJson),
      'progressPercentage': serializer.toJson<int>(progressPercentage),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'rewardXp': serializer.toJson<int>(rewardXp),
      'rewardCredits': serializer.toJson<int>(rewardCredits),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  QuestsTableData copyWith({
    int? id,
    String? questId,
    String? questName,
    String? questType,
    Value<String?> description = const Value.absent(),
    String? progressJson,
    int? progressPercentage,
    bool? isCompleted,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    int? rewardXp,
    int? rewardCredits,
    bool? isActive,
  }) => QuestsTableData(
    id: id ?? this.id,
    questId: questId ?? this.questId,
    questName: questName ?? this.questName,
    questType: questType ?? this.questType,
    description: description.present ? description.value : this.description,
    progressJson: progressJson ?? this.progressJson,
    progressPercentage: progressPercentage ?? this.progressPercentage,
    isCompleted: isCompleted ?? this.isCompleted,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    rewardXp: rewardXp ?? this.rewardXp,
    rewardCredits: rewardCredits ?? this.rewardCredits,
    isActive: isActive ?? this.isActive,
  );
  QuestsTableData copyWithCompanion(QuestsTableCompanion data) {
    return QuestsTableData(
      id: data.id.present ? data.id.value : this.id,
      questId: data.questId.present ? data.questId.value : this.questId,
      questName: data.questName.present ? data.questName.value : this.questName,
      questType: data.questType.present ? data.questType.value : this.questType,
      description: data.description.present
          ? data.description.value
          : this.description,
      progressJson: data.progressJson.present
          ? data.progressJson.value
          : this.progressJson,
      progressPercentage: data.progressPercentage.present
          ? data.progressPercentage.value
          : this.progressPercentage,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      rewardXp: data.rewardXp.present ? data.rewardXp.value : this.rewardXp,
      rewardCredits: data.rewardCredits.present
          ? data.rewardCredits.value
          : this.rewardCredits,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestsTableData(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('questName: $questName, ')
          ..write('questType: $questType, ')
          ..write('description: $description, ')
          ..write('progressJson: $progressJson, ')
          ..write('progressPercentage: $progressPercentage, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('rewardCredits: $rewardCredits, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    questId,
    questName,
    questType,
    description,
    progressJson,
    progressPercentage,
    isCompleted,
    startedAt,
    completedAt,
    rewardXp,
    rewardCredits,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestsTableData &&
          other.id == this.id &&
          other.questId == this.questId &&
          other.questName == this.questName &&
          other.questType == this.questType &&
          other.description == this.description &&
          other.progressJson == this.progressJson &&
          other.progressPercentage == this.progressPercentage &&
          other.isCompleted == this.isCompleted &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.rewardXp == this.rewardXp &&
          other.rewardCredits == this.rewardCredits &&
          other.isActive == this.isActive);
}

class QuestsTableCompanion extends UpdateCompanion<QuestsTableData> {
  final Value<int> id;
  final Value<String> questId;
  final Value<String> questName;
  final Value<String> questType;
  final Value<String?> description;
  final Value<String> progressJson;
  final Value<int> progressPercentage;
  final Value<bool> isCompleted;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rewardXp;
  final Value<int> rewardCredits;
  final Value<bool> isActive;
  const QuestsTableCompanion({
    this.id = const Value.absent(),
    this.questId = const Value.absent(),
    this.questName = const Value.absent(),
    this.questType = const Value.absent(),
    this.description = const Value.absent(),
    this.progressJson = const Value.absent(),
    this.progressPercentage = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.rewardCredits = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  QuestsTableCompanion.insert({
    this.id = const Value.absent(),
    required String questId,
    required String questName,
    required String questType,
    this.description = const Value.absent(),
    this.progressJson = const Value.absent(),
    this.progressPercentage = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.rewardCredits = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : questId = Value(questId),
       questName = Value(questName),
       questType = Value(questType);
  static Insertable<QuestsTableData> custom({
    Expression<int>? id,
    Expression<String>? questId,
    Expression<String>? questName,
    Expression<String>? questType,
    Expression<String>? description,
    Expression<String>? progressJson,
    Expression<int>? progressPercentage,
    Expression<bool>? isCompleted,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rewardXp,
    Expression<int>? rewardCredits,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questId != null) 'quest_id': questId,
      if (questName != null) 'quest_name': questName,
      if (questType != null) 'quest_type': questType,
      if (description != null) 'description': description,
      if (progressJson != null) 'progress_json': progressJson,
      if (progressPercentage != null) 'progress_percentage': progressPercentage,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rewardXp != null) 'reward_xp': rewardXp,
      if (rewardCredits != null) 'reward_credits': rewardCredits,
      if (isActive != null) 'is_active': isActive,
    });
  }

  QuestsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? questId,
    Value<String>? questName,
    Value<String>? questType,
    Value<String?>? description,
    Value<String>? progressJson,
    Value<int>? progressPercentage,
    Value<bool>? isCompleted,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rewardXp,
    Value<int>? rewardCredits,
    Value<bool>? isActive,
  }) {
    return QuestsTableCompanion(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      questName: questName ?? this.questName,
      questType: questType ?? this.questType,
      description: description ?? this.description,
      progressJson: progressJson ?? this.progressJson,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardCredits: rewardCredits ?? this.rewardCredits,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (questName.present) {
      map['quest_name'] = Variable<String>(questName.value);
    }
    if (questType.present) {
      map['quest_type'] = Variable<String>(questType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (progressJson.present) {
      map['progress_json'] = Variable<String>(progressJson.value);
    }
    if (progressPercentage.present) {
      map['progress_percentage'] = Variable<int>(progressPercentage.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rewardXp.present) {
      map['reward_xp'] = Variable<int>(rewardXp.value);
    }
    if (rewardCredits.present) {
      map['reward_credits'] = Variable<int>(rewardCredits.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsTableCompanion(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('questName: $questName, ')
          ..write('questType: $questType, ')
          ..write('description: $description, ')
          ..write('progressJson: $progressJson, ')
          ..write('progressPercentage: $progressPercentage, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('rewardCredits: $rewardCredits, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

abstract class _$GameDatabase extends GeneratedDatabase {
  _$GameDatabase(QueryExecutor e) : super(e);
  $GameDatabaseManager get managers => $GameDatabaseManager(this);
  late final $PlayerTableTable playerTable = $PlayerTableTable(this);
  late final $ColoniesTableTable coloniesTable = $ColoniesTableTable(this);
  late final $BuildingsTableTable buildingsTable = $BuildingsTableTable(this);
  late final $TroopsTableTable troopsTable = $TroopsTableTable(this);
  late final $WorldMapTableTable worldMapTable = $WorldMapTableTable(this);
  late final $CombatLogTableTable combatLogTable = $CombatLogTableTable(this);
  late final $MessagesTableTable messagesTable = $MessagesTableTable(this);
  late final $DiplomacyTableTable diplomacyTable = $DiplomacyTableTable(this);
  late final $ResearchTableTable researchTable = $ResearchTableTable(this);
  late final $QuestsTableTable questsTable = $QuestsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerTable,
    coloniesTable,
    buildingsTable,
    troopsTable,
    worldMapTable,
    combatLogTable,
    messagesTable,
    diplomacyTable,
    researchTable,
    questsTable,
  ];
}

typedef $$PlayerTableTableCreateCompanionBuilder =
    PlayerTableCompanion Function({
      Value<int> id,
      required String username,
      Value<int> level,
      Value<int> experience,
      Value<int> credits,
      Value<int> biomass,
      Value<int> minerals,
      Value<int> energy,
      required DateTime createdAt,
      required DateTime lastPlayedAt,
      Value<double> gameSpeedMultiplier,
      Value<bool> tutorialCompleted,
      Value<String> talentsUnlocked,
      Value<String> playstylePreference,
    });
typedef $$PlayerTableTableUpdateCompanionBuilder =
    PlayerTableCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<int> level,
      Value<int> experience,
      Value<int> credits,
      Value<int> biomass,
      Value<int> minerals,
      Value<int> energy,
      Value<DateTime> createdAt,
      Value<DateTime> lastPlayedAt,
      Value<double> gameSpeedMultiplier,
      Value<bool> tutorialCompleted,
      Value<String> talentsUnlocked,
      Value<String> playstylePreference,
    });

class $$PlayerTableTableFilterComposer
    extends Composer<_$GameDatabase, $PlayerTableTable> {
  $$PlayerTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get biomass => $composableBuilder(
    column: $table.biomass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minerals => $composableBuilder(
    column: $table.minerals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gameSpeedMultiplier => $composableBuilder(
    column: $table.gameSpeedMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tutorialCompleted => $composableBuilder(
    column: $table.tutorialCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get talentsUnlocked => $composableBuilder(
    column: $table.talentsUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playstylePreference => $composableBuilder(
    column: $table.playstylePreference,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerTableTableOrderingComposer
    extends Composer<_$GameDatabase, $PlayerTableTable> {
  $$PlayerTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get biomass => $composableBuilder(
    column: $table.biomass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minerals => $composableBuilder(
    column: $table.minerals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gameSpeedMultiplier => $composableBuilder(
    column: $table.gameSpeedMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tutorialCompleted => $composableBuilder(
    column: $table.tutorialCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get talentsUnlocked => $composableBuilder(
    column: $table.talentsUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playstylePreference => $composableBuilder(
    column: $table.playstylePreference,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $PlayerTableTable> {
  $$PlayerTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => column,
  );

  GeneratedColumn<int> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<int> get biomass =>
      $composableBuilder(column: $table.biomass, builder: (column) => column);

  GeneratedColumn<int> get minerals =>
      $composableBuilder(column: $table.minerals, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gameSpeedMultiplier => $composableBuilder(
    column: $table.gameSpeedMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get tutorialCompleted => $composableBuilder(
    column: $table.tutorialCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get talentsUnlocked => $composableBuilder(
    column: $table.talentsUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playstylePreference => $composableBuilder(
    column: $table.playstylePreference,
    builder: (column) => column,
  );
}

class $$PlayerTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $PlayerTableTable,
          PlayerTableData,
          $$PlayerTableTableFilterComposer,
          $$PlayerTableTableOrderingComposer,
          $$PlayerTableTableAnnotationComposer,
          $$PlayerTableTableCreateCompanionBuilder,
          $$PlayerTableTableUpdateCompanionBuilder,
          (
            PlayerTableData,
            BaseReferences<_$GameDatabase, $PlayerTableTable, PlayerTableData>,
          ),
          PlayerTableData,
          PrefetchHooks Function()
        > {
  $$PlayerTableTableTableManager(_$GameDatabase db, $PlayerTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> experience = const Value.absent(),
                Value<int> credits = const Value.absent(),
                Value<int> biomass = const Value.absent(),
                Value<int> minerals = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastPlayedAt = const Value.absent(),
                Value<double> gameSpeedMultiplier = const Value.absent(),
                Value<bool> tutorialCompleted = const Value.absent(),
                Value<String> talentsUnlocked = const Value.absent(),
                Value<String> playstylePreference = const Value.absent(),
              }) => PlayerTableCompanion(
                id: id,
                username: username,
                level: level,
                experience: experience,
                credits: credits,
                biomass: biomass,
                minerals: minerals,
                energy: energy,
                createdAt: createdAt,
                lastPlayedAt: lastPlayedAt,
                gameSpeedMultiplier: gameSpeedMultiplier,
                tutorialCompleted: tutorialCompleted,
                talentsUnlocked: talentsUnlocked,
                playstylePreference: playstylePreference,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                Value<int> level = const Value.absent(),
                Value<int> experience = const Value.absent(),
                Value<int> credits = const Value.absent(),
                Value<int> biomass = const Value.absent(),
                Value<int> minerals = const Value.absent(),
                Value<int> energy = const Value.absent(),
                required DateTime createdAt,
                required DateTime lastPlayedAt,
                Value<double> gameSpeedMultiplier = const Value.absent(),
                Value<bool> tutorialCompleted = const Value.absent(),
                Value<String> talentsUnlocked = const Value.absent(),
                Value<String> playstylePreference = const Value.absent(),
              }) => PlayerTableCompanion.insert(
                id: id,
                username: username,
                level: level,
                experience: experience,
                credits: credits,
                biomass: biomass,
                minerals: minerals,
                energy: energy,
                createdAt: createdAt,
                lastPlayedAt: lastPlayedAt,
                gameSpeedMultiplier: gameSpeedMultiplier,
                tutorialCompleted: tutorialCompleted,
                talentsUnlocked: talentsUnlocked,
                playstylePreference: playstylePreference,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $PlayerTableTable,
      PlayerTableData,
      $$PlayerTableTableFilterComposer,
      $$PlayerTableTableOrderingComposer,
      $$PlayerTableTableAnnotationComposer,
      $$PlayerTableTableCreateCompanionBuilder,
      $$PlayerTableTableUpdateCompanionBuilder,
      (
        PlayerTableData,
        BaseReferences<_$GameDatabase, $PlayerTableTable, PlayerTableData>,
      ),
      PlayerTableData,
      PrefetchHooks Function()
    >;
typedef $$ColoniesTableTableCreateCompanionBuilder =
    ColoniesTableCompanion Function({
      Value<int> id,
      required String ownerType,
      required String name,
      required String typePersonnalite,
      required int positionX,
      required int positionY,
      Value<String> faction,
      Value<int> population,
      Value<int> niveauDome,
      Value<int> healthDome,
      Value<int> credits,
      Value<int> biomass,
      Value<int> minerals,
      Value<int> energy,
      Value<int> loyalty,
      Value<String> aiPersonalityTraits,
      Value<String?> aiBehaviorState,
      Value<int?> aiThreatLevel,
      Value<bool> discoveredByPlayer,
      required DateTime lastActivityAt,
      required DateTime createdAt,
    });
typedef $$ColoniesTableTableUpdateCompanionBuilder =
    ColoniesTableCompanion Function({
      Value<int> id,
      Value<String> ownerType,
      Value<String> name,
      Value<String> typePersonnalite,
      Value<int> positionX,
      Value<int> positionY,
      Value<String> faction,
      Value<int> population,
      Value<int> niveauDome,
      Value<int> healthDome,
      Value<int> credits,
      Value<int> biomass,
      Value<int> minerals,
      Value<int> energy,
      Value<int> loyalty,
      Value<String> aiPersonalityTraits,
      Value<String?> aiBehaviorState,
      Value<int?> aiThreatLevel,
      Value<bool> discoveredByPlayer,
      Value<DateTime> lastActivityAt,
      Value<DateTime> createdAt,
    });

final class $$ColoniesTableTableReferences
    extends
        BaseReferences<_$GameDatabase, $ColoniesTableTable, ColoniesTableData> {
  $$ColoniesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$BuildingsTableTable, List<BuildingsTableData>>
  _buildingsTableRefsTable(_$GameDatabase db) => MultiTypedResultKey.fromTable(
    db.buildingsTable,
    aliasName: $_aliasNameGenerator(
      db.coloniesTable.id,
      db.buildingsTable.colonyId,
    ),
  );

  $$BuildingsTableTableProcessedTableManager get buildingsTableRefs {
    final manager = $$BuildingsTableTableTableManager(
      $_db,
      $_db.buildingsTable,
    ).filter((f) => f.colonyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_buildingsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TroopsTableTable, List<TroopsTableData>>
  _troopsTableRefsTable(_$GameDatabase db) => MultiTypedResultKey.fromTable(
    db.troopsTable,
    aliasName: $_aliasNameGenerator(
      db.coloniesTable.id,
      db.troopsTable.colonyId,
    ),
  );

  $$TroopsTableTableProcessedTableManager get troopsTableRefs {
    final manager = $$TroopsTableTableTableManager(
      $_db,
      $_db.troopsTable,
    ).filter((f) => f.colonyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_troopsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ColoniesTableTableFilterComposer
    extends Composer<_$GameDatabase, $ColoniesTableTable> {
  $$ColoniesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typePersonnalite => $composableBuilder(
    column: $table.typePersonnalite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faction => $composableBuilder(
    column: $table.faction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get niveauDome => $composableBuilder(
    column: $table.niveauDome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get healthDome => $composableBuilder(
    column: $table.healthDome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get biomass => $composableBuilder(
    column: $table.biomass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minerals => $composableBuilder(
    column: $table.minerals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiPersonalityTraits => $composableBuilder(
    column: $table.aiPersonalityTraits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiBehaviorState => $composableBuilder(
    column: $table.aiBehaviorState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aiThreatLevel => $composableBuilder(
    column: $table.aiThreatLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get discoveredByPlayer => $composableBuilder(
    column: $table.discoveredByPlayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> buildingsTableRefs(
    Expression<bool> Function($$BuildingsTableTableFilterComposer f) f,
  ) {
    final $$BuildingsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buildingsTable,
      getReferencedColumn: (t) => t.colonyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableTableFilterComposer(
            $db: $db,
            $table: $db.buildingsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> troopsTableRefs(
    Expression<bool> Function($$TroopsTableTableFilterComposer f) f,
  ) {
    final $$TroopsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.troopsTable,
      getReferencedColumn: (t) => t.colonyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TroopsTableTableFilterComposer(
            $db: $db,
            $table: $db.troopsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ColoniesTableTableOrderingComposer
    extends Composer<_$GameDatabase, $ColoniesTableTable> {
  $$ColoniesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typePersonnalite => $composableBuilder(
    column: $table.typePersonnalite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faction => $composableBuilder(
    column: $table.faction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get niveauDome => $composableBuilder(
    column: $table.niveauDome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get healthDome => $composableBuilder(
    column: $table.healthDome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get biomass => $composableBuilder(
    column: $table.biomass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minerals => $composableBuilder(
    column: $table.minerals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiPersonalityTraits => $composableBuilder(
    column: $table.aiPersonalityTraits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiBehaviorState => $composableBuilder(
    column: $table.aiBehaviorState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aiThreatLevel => $composableBuilder(
    column: $table.aiThreatLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get discoveredByPlayer => $composableBuilder(
    column: $table.discoveredByPlayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ColoniesTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $ColoniesTableTable> {
  $$ColoniesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get typePersonnalite => $composableBuilder(
    column: $table.typePersonnalite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionX =>
      $composableBuilder(column: $table.positionX, builder: (column) => column);

  GeneratedColumn<int> get positionY =>
      $composableBuilder(column: $table.positionY, builder: (column) => column);

  GeneratedColumn<String> get faction =>
      $composableBuilder(column: $table.faction, builder: (column) => column);

  GeneratedColumn<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => column,
  );

  GeneratedColumn<int> get niveauDome => $composableBuilder(
    column: $table.niveauDome,
    builder: (column) => column,
  );

  GeneratedColumn<int> get healthDome => $composableBuilder(
    column: $table.healthDome,
    builder: (column) => column,
  );

  GeneratedColumn<int> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<int> get biomass =>
      $composableBuilder(column: $table.biomass, builder: (column) => column);

  GeneratedColumn<int> get minerals =>
      $composableBuilder(column: $table.minerals, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get loyalty =>
      $composableBuilder(column: $table.loyalty, builder: (column) => column);

  GeneratedColumn<String> get aiPersonalityTraits => $composableBuilder(
    column: $table.aiPersonalityTraits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiBehaviorState => $composableBuilder(
    column: $table.aiBehaviorState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get aiThreatLevel => $composableBuilder(
    column: $table.aiThreatLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get discoveredByPlayer => $composableBuilder(
    column: $table.discoveredByPlayer,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> buildingsTableRefs<T extends Object>(
    Expression<T> Function($$BuildingsTableTableAnnotationComposer a) f,
  ) {
    final $$BuildingsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buildingsTable,
      getReferencedColumn: (t) => t.colonyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.buildingsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> troopsTableRefs<T extends Object>(
    Expression<T> Function($$TroopsTableTableAnnotationComposer a) f,
  ) {
    final $$TroopsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.troopsTable,
      getReferencedColumn: (t) => t.colonyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TroopsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.troopsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ColoniesTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $ColoniesTableTable,
          ColoniesTableData,
          $$ColoniesTableTableFilterComposer,
          $$ColoniesTableTableOrderingComposer,
          $$ColoniesTableTableAnnotationComposer,
          $$ColoniesTableTableCreateCompanionBuilder,
          $$ColoniesTableTableUpdateCompanionBuilder,
          (ColoniesTableData, $$ColoniesTableTableReferences),
          ColoniesTableData,
          PrefetchHooks Function({
            bool buildingsTableRefs,
            bool troopsTableRefs,
          })
        > {
  $$ColoniesTableTableTableManager(_$GameDatabase db, $ColoniesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColoniesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColoniesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColoniesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ownerType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> typePersonnalite = const Value.absent(),
                Value<int> positionX = const Value.absent(),
                Value<int> positionY = const Value.absent(),
                Value<String> faction = const Value.absent(),
                Value<int> population = const Value.absent(),
                Value<int> niveauDome = const Value.absent(),
                Value<int> healthDome = const Value.absent(),
                Value<int> credits = const Value.absent(),
                Value<int> biomass = const Value.absent(),
                Value<int> minerals = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<int> loyalty = const Value.absent(),
                Value<String> aiPersonalityTraits = const Value.absent(),
                Value<String?> aiBehaviorState = const Value.absent(),
                Value<int?> aiThreatLevel = const Value.absent(),
                Value<bool> discoveredByPlayer = const Value.absent(),
                Value<DateTime> lastActivityAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ColoniesTableCompanion(
                id: id,
                ownerType: ownerType,
                name: name,
                typePersonnalite: typePersonnalite,
                positionX: positionX,
                positionY: positionY,
                faction: faction,
                population: population,
                niveauDome: niveauDome,
                healthDome: healthDome,
                credits: credits,
                biomass: biomass,
                minerals: minerals,
                energy: energy,
                loyalty: loyalty,
                aiPersonalityTraits: aiPersonalityTraits,
                aiBehaviorState: aiBehaviorState,
                aiThreatLevel: aiThreatLevel,
                discoveredByPlayer: discoveredByPlayer,
                lastActivityAt: lastActivityAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ownerType,
                required String name,
                required String typePersonnalite,
                required int positionX,
                required int positionY,
                Value<String> faction = const Value.absent(),
                Value<int> population = const Value.absent(),
                Value<int> niveauDome = const Value.absent(),
                Value<int> healthDome = const Value.absent(),
                Value<int> credits = const Value.absent(),
                Value<int> biomass = const Value.absent(),
                Value<int> minerals = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<int> loyalty = const Value.absent(),
                Value<String> aiPersonalityTraits = const Value.absent(),
                Value<String?> aiBehaviorState = const Value.absent(),
                Value<int?> aiThreatLevel = const Value.absent(),
                Value<bool> discoveredByPlayer = const Value.absent(),
                required DateTime lastActivityAt,
                required DateTime createdAt,
              }) => ColoniesTableCompanion.insert(
                id: id,
                ownerType: ownerType,
                name: name,
                typePersonnalite: typePersonnalite,
                positionX: positionX,
                positionY: positionY,
                faction: faction,
                population: population,
                niveauDome: niveauDome,
                healthDome: healthDome,
                credits: credits,
                biomass: biomass,
                minerals: minerals,
                energy: energy,
                loyalty: loyalty,
                aiPersonalityTraits: aiPersonalityTraits,
                aiBehaviorState: aiBehaviorState,
                aiThreatLevel: aiThreatLevel,
                discoveredByPlayer: discoveredByPlayer,
                lastActivityAt: lastActivityAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ColoniesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({buildingsTableRefs = false, troopsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (buildingsTableRefs) db.buildingsTable,
                    if (troopsTableRefs) db.troopsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (buildingsTableRefs)
                        await $_getPrefetchedData<
                          ColoniesTableData,
                          $ColoniesTableTable,
                          BuildingsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ColoniesTableTableReferences
                              ._buildingsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ColoniesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).buildingsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.colonyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (troopsTableRefs)
                        await $_getPrefetchedData<
                          ColoniesTableData,
                          $ColoniesTableTable,
                          TroopsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ColoniesTableTableReferences
                              ._troopsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ColoniesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).troopsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.colonyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ColoniesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $ColoniesTableTable,
      ColoniesTableData,
      $$ColoniesTableTableFilterComposer,
      $$ColoniesTableTableOrderingComposer,
      $$ColoniesTableTableAnnotationComposer,
      $$ColoniesTableTableCreateCompanionBuilder,
      $$ColoniesTableTableUpdateCompanionBuilder,
      (ColoniesTableData, $$ColoniesTableTableReferences),
      ColoniesTableData,
      PrefetchHooks Function({bool buildingsTableRefs, bool troopsTableRefs})
    >;
typedef $$BuildingsTableTableCreateCompanionBuilder =
    BuildingsTableCompanion Function({
      Value<int> id,
      required int colonyId,
      required String buildingType,
      Value<int> level,
      Value<DateTime?> constructionEndTime,
      Value<int> damageLevel,
      Value<double> productionRate,
      Value<bool> isActive,
      required DateTime builtAt,
    });
typedef $$BuildingsTableTableUpdateCompanionBuilder =
    BuildingsTableCompanion Function({
      Value<int> id,
      Value<int> colonyId,
      Value<String> buildingType,
      Value<int> level,
      Value<DateTime?> constructionEndTime,
      Value<int> damageLevel,
      Value<double> productionRate,
      Value<bool> isActive,
      Value<DateTime> builtAt,
    });

final class $$BuildingsTableTableReferences
    extends
        BaseReferences<
          _$GameDatabase,
          $BuildingsTableTable,
          BuildingsTableData
        > {
  $$BuildingsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ColoniesTableTable _colonyIdTable(_$GameDatabase db) =>
      db.coloniesTable.createAlias(
        $_aliasNameGenerator(db.buildingsTable.colonyId, db.coloniesTable.id),
      );

  $$ColoniesTableTableProcessedTableManager get colonyId {
    final $_column = $_itemColumn<int>('colony_id')!;

    final manager = $$ColoniesTableTableTableManager(
      $_db,
      $_db.coloniesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colonyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BuildingsTableTableFilterComposer
    extends Composer<_$GameDatabase, $BuildingsTableTable> {
  $$BuildingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buildingType => $composableBuilder(
    column: $table.buildingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get constructionEndTime => $composableBuilder(
    column: $table.constructionEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get damageLevel => $composableBuilder(
    column: $table.damageLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get productionRate => $composableBuilder(
    column: $table.productionRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get builtAt => $composableBuilder(
    column: $table.builtAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ColoniesTableTableFilterComposer get colonyId {
    final $$ColoniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableFilterComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BuildingsTableTableOrderingComposer
    extends Composer<_$GameDatabase, $BuildingsTableTable> {
  $$BuildingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buildingType => $composableBuilder(
    column: $table.buildingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get constructionEndTime => $composableBuilder(
    column: $table.constructionEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get damageLevel => $composableBuilder(
    column: $table.damageLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get productionRate => $composableBuilder(
    column: $table.productionRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get builtAt => $composableBuilder(
    column: $table.builtAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ColoniesTableTableOrderingComposer get colonyId {
    final $$ColoniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BuildingsTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $BuildingsTableTable> {
  $$BuildingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get buildingType => $composableBuilder(
    column: $table.buildingType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get constructionEndTime => $composableBuilder(
    column: $table.constructionEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get damageLevel => $composableBuilder(
    column: $table.damageLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get productionRate => $composableBuilder(
    column: $table.productionRate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get builtAt =>
      $composableBuilder(column: $table.builtAt, builder: (column) => column);

  $$ColoniesTableTableAnnotationComposer get colonyId {
    final $$ColoniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BuildingsTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $BuildingsTableTable,
          BuildingsTableData,
          $$BuildingsTableTableFilterComposer,
          $$BuildingsTableTableOrderingComposer,
          $$BuildingsTableTableAnnotationComposer,
          $$BuildingsTableTableCreateCompanionBuilder,
          $$BuildingsTableTableUpdateCompanionBuilder,
          (BuildingsTableData, $$BuildingsTableTableReferences),
          BuildingsTableData,
          PrefetchHooks Function({bool colonyId})
        > {
  $$BuildingsTableTableTableManager(
    _$GameDatabase db,
    $BuildingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuildingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuildingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuildingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> colonyId = const Value.absent(),
                Value<String> buildingType = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<DateTime?> constructionEndTime = const Value.absent(),
                Value<int> damageLevel = const Value.absent(),
                Value<double> productionRate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> builtAt = const Value.absent(),
              }) => BuildingsTableCompanion(
                id: id,
                colonyId: colonyId,
                buildingType: buildingType,
                level: level,
                constructionEndTime: constructionEndTime,
                damageLevel: damageLevel,
                productionRate: productionRate,
                isActive: isActive,
                builtAt: builtAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int colonyId,
                required String buildingType,
                Value<int> level = const Value.absent(),
                Value<DateTime?> constructionEndTime = const Value.absent(),
                Value<int> damageLevel = const Value.absent(),
                Value<double> productionRate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime builtAt,
              }) => BuildingsTableCompanion.insert(
                id: id,
                colonyId: colonyId,
                buildingType: buildingType,
                level: level,
                constructionEndTime: constructionEndTime,
                damageLevel: damageLevel,
                productionRate: productionRate,
                isActive: isActive,
                builtAt: builtAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BuildingsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({colonyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (colonyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.colonyId,
                                referencedTable: $$BuildingsTableTableReferences
                                    ._colonyIdTable(db),
                                referencedColumn:
                                    $$BuildingsTableTableReferences
                                        ._colonyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BuildingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $BuildingsTableTable,
      BuildingsTableData,
      $$BuildingsTableTableFilterComposer,
      $$BuildingsTableTableOrderingComposer,
      $$BuildingsTableTableAnnotationComposer,
      $$BuildingsTableTableCreateCompanionBuilder,
      $$BuildingsTableTableUpdateCompanionBuilder,
      (BuildingsTableData, $$BuildingsTableTableReferences),
      BuildingsTableData,
      PrefetchHooks Function({bool colonyId})
    >;
typedef $$TroopsTableTableCreateCompanionBuilder =
    TroopsTableCompanion Function({
      Value<int> id,
      required int colonyId,
      required String troopType,
      Value<int> count,
      Value<int> healthPerUnit,
      Value<String> status,
      Value<int?> targetX,
      Value<int?> targetY,
      Value<DateTime?> etaArrival,
      Value<int> morale,
      required DateTime trainedAt,
    });
typedef $$TroopsTableTableUpdateCompanionBuilder =
    TroopsTableCompanion Function({
      Value<int> id,
      Value<int> colonyId,
      Value<String> troopType,
      Value<int> count,
      Value<int> healthPerUnit,
      Value<String> status,
      Value<int?> targetX,
      Value<int?> targetY,
      Value<DateTime?> etaArrival,
      Value<int> morale,
      Value<DateTime> trainedAt,
    });

final class $$TroopsTableTableReferences
    extends BaseReferences<_$GameDatabase, $TroopsTableTable, TroopsTableData> {
  $$TroopsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ColoniesTableTable _colonyIdTable(_$GameDatabase db) =>
      db.coloniesTable.createAlias(
        $_aliasNameGenerator(db.troopsTable.colonyId, db.coloniesTable.id),
      );

  $$ColoniesTableTableProcessedTableManager get colonyId {
    final $_column = $_itemColumn<int>('colony_id')!;

    final manager = $$ColoniesTableTableTableManager(
      $_db,
      $_db.coloniesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colonyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TroopsTableTableFilterComposer
    extends Composer<_$GameDatabase, $TroopsTableTable> {
  $$TroopsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get troopType => $composableBuilder(
    column: $table.troopType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get healthPerUnit => $composableBuilder(
    column: $table.healthPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetX => $composableBuilder(
    column: $table.targetX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetY => $composableBuilder(
    column: $table.targetY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get etaArrival => $composableBuilder(
    column: $table.etaArrival,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get morale => $composableBuilder(
    column: $table.morale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get trainedAt => $composableBuilder(
    column: $table.trainedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ColoniesTableTableFilterComposer get colonyId {
    final $$ColoniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableFilterComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TroopsTableTableOrderingComposer
    extends Composer<_$GameDatabase, $TroopsTableTable> {
  $$TroopsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get troopType => $composableBuilder(
    column: $table.troopType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get healthPerUnit => $composableBuilder(
    column: $table.healthPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetX => $composableBuilder(
    column: $table.targetX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetY => $composableBuilder(
    column: $table.targetY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get etaArrival => $composableBuilder(
    column: $table.etaArrival,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get morale => $composableBuilder(
    column: $table.morale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get trainedAt => $composableBuilder(
    column: $table.trainedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ColoniesTableTableOrderingComposer get colonyId {
    final $$ColoniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TroopsTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $TroopsTableTable> {
  $$TroopsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get troopType =>
      $composableBuilder(column: $table.troopType, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get healthPerUnit => $composableBuilder(
    column: $table.healthPerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get targetX =>
      $composableBuilder(column: $table.targetX, builder: (column) => column);

  GeneratedColumn<int> get targetY =>
      $composableBuilder(column: $table.targetY, builder: (column) => column);

  GeneratedColumn<DateTime> get etaArrival => $composableBuilder(
    column: $table.etaArrival,
    builder: (column) => column,
  );

  GeneratedColumn<int> get morale =>
      $composableBuilder(column: $table.morale, builder: (column) => column);

  GeneratedColumn<DateTime> get trainedAt =>
      $composableBuilder(column: $table.trainedAt, builder: (column) => column);

  $$ColoniesTableTableAnnotationComposer get colonyId {
    final $$ColoniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TroopsTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $TroopsTableTable,
          TroopsTableData,
          $$TroopsTableTableFilterComposer,
          $$TroopsTableTableOrderingComposer,
          $$TroopsTableTableAnnotationComposer,
          $$TroopsTableTableCreateCompanionBuilder,
          $$TroopsTableTableUpdateCompanionBuilder,
          (TroopsTableData, $$TroopsTableTableReferences),
          TroopsTableData,
          PrefetchHooks Function({bool colonyId})
        > {
  $$TroopsTableTableTableManager(_$GameDatabase db, $TroopsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TroopsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TroopsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TroopsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> colonyId = const Value.absent(),
                Value<String> troopType = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> healthPerUnit = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> targetX = const Value.absent(),
                Value<int?> targetY = const Value.absent(),
                Value<DateTime?> etaArrival = const Value.absent(),
                Value<int> morale = const Value.absent(),
                Value<DateTime> trainedAt = const Value.absent(),
              }) => TroopsTableCompanion(
                id: id,
                colonyId: colonyId,
                troopType: troopType,
                count: count,
                healthPerUnit: healthPerUnit,
                status: status,
                targetX: targetX,
                targetY: targetY,
                etaArrival: etaArrival,
                morale: morale,
                trainedAt: trainedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int colonyId,
                required String troopType,
                Value<int> count = const Value.absent(),
                Value<int> healthPerUnit = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> targetX = const Value.absent(),
                Value<int?> targetY = const Value.absent(),
                Value<DateTime?> etaArrival = const Value.absent(),
                Value<int> morale = const Value.absent(),
                required DateTime trainedAt,
              }) => TroopsTableCompanion.insert(
                id: id,
                colonyId: colonyId,
                troopType: troopType,
                count: count,
                healthPerUnit: healthPerUnit,
                status: status,
                targetX: targetX,
                targetY: targetY,
                etaArrival: etaArrival,
                morale: morale,
                trainedAt: trainedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TroopsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({colonyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (colonyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.colonyId,
                                referencedTable: $$TroopsTableTableReferences
                                    ._colonyIdTable(db),
                                referencedColumn: $$TroopsTableTableReferences
                                    ._colonyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TroopsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $TroopsTableTable,
      TroopsTableData,
      $$TroopsTableTableFilterComposer,
      $$TroopsTableTableOrderingComposer,
      $$TroopsTableTableAnnotationComposer,
      $$TroopsTableTableCreateCompanionBuilder,
      $$TroopsTableTableUpdateCompanionBuilder,
      (TroopsTableData, $$TroopsTableTableReferences),
      TroopsTableData,
      PrefetchHooks Function({bool colonyId})
    >;
typedef $$WorldMapTableTableCreateCompanionBuilder =
    WorldMapTableCompanion Function({
      Value<int> zoneId,
      required int chunkX,
      required int chunkY,
      Value<String> terrainType,
      required int depthLevel,
      Value<String?> specialResource,
      Value<double> resourceAbundance,
      Value<int> explorationLevel,
      Value<DateTime?> discoveredAt,
    });
typedef $$WorldMapTableTableUpdateCompanionBuilder =
    WorldMapTableCompanion Function({
      Value<int> zoneId,
      Value<int> chunkX,
      Value<int> chunkY,
      Value<String> terrainType,
      Value<int> depthLevel,
      Value<String?> specialResource,
      Value<double> resourceAbundance,
      Value<int> explorationLevel,
      Value<DateTime?> discoveredAt,
    });

class $$WorldMapTableTableFilterComposer
    extends Composer<_$GameDatabase, $WorldMapTableTable> {
  $$WorldMapTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkX => $composableBuilder(
    column: $table.chunkX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkY => $composableBuilder(
    column: $table.chunkY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terrainType => $composableBuilder(
    column: $table.terrainType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depthLevel => $composableBuilder(
    column: $table.depthLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialResource => $composableBuilder(
    column: $table.specialResource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get resourceAbundance => $composableBuilder(
    column: $table.resourceAbundance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get explorationLevel => $composableBuilder(
    column: $table.explorationLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorldMapTableTableOrderingComposer
    extends Composer<_$GameDatabase, $WorldMapTableTable> {
  $$WorldMapTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkX => $composableBuilder(
    column: $table.chunkX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkY => $composableBuilder(
    column: $table.chunkY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terrainType => $composableBuilder(
    column: $table.terrainType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depthLevel => $composableBuilder(
    column: $table.depthLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialResource => $composableBuilder(
    column: $table.specialResource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get resourceAbundance => $composableBuilder(
    column: $table.resourceAbundance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get explorationLevel => $composableBuilder(
    column: $table.explorationLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorldMapTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $WorldMapTableTable> {
  $$WorldMapTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<int> get chunkX =>
      $composableBuilder(column: $table.chunkX, builder: (column) => column);

  GeneratedColumn<int> get chunkY =>
      $composableBuilder(column: $table.chunkY, builder: (column) => column);

  GeneratedColumn<String> get terrainType => $composableBuilder(
    column: $table.terrainType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get depthLevel => $composableBuilder(
    column: $table.depthLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialResource => $composableBuilder(
    column: $table.specialResource,
    builder: (column) => column,
  );

  GeneratedColumn<double> get resourceAbundance => $composableBuilder(
    column: $table.resourceAbundance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get explorationLevel => $composableBuilder(
    column: $table.explorationLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => column,
  );
}

class $$WorldMapTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $WorldMapTableTable,
          WorldMapTableData,
          $$WorldMapTableTableFilterComposer,
          $$WorldMapTableTableOrderingComposer,
          $$WorldMapTableTableAnnotationComposer,
          $$WorldMapTableTableCreateCompanionBuilder,
          $$WorldMapTableTableUpdateCompanionBuilder,
          (
            WorldMapTableData,
            BaseReferences<
              _$GameDatabase,
              $WorldMapTableTable,
              WorldMapTableData
            >,
          ),
          WorldMapTableData,
          PrefetchHooks Function()
        > {
  $$WorldMapTableTableTableManager(_$GameDatabase db, $WorldMapTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorldMapTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorldMapTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorldMapTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> zoneId = const Value.absent(),
                Value<int> chunkX = const Value.absent(),
                Value<int> chunkY = const Value.absent(),
                Value<String> terrainType = const Value.absent(),
                Value<int> depthLevel = const Value.absent(),
                Value<String?> specialResource = const Value.absent(),
                Value<double> resourceAbundance = const Value.absent(),
                Value<int> explorationLevel = const Value.absent(),
                Value<DateTime?> discoveredAt = const Value.absent(),
              }) => WorldMapTableCompanion(
                zoneId: zoneId,
                chunkX: chunkX,
                chunkY: chunkY,
                terrainType: terrainType,
                depthLevel: depthLevel,
                specialResource: specialResource,
                resourceAbundance: resourceAbundance,
                explorationLevel: explorationLevel,
                discoveredAt: discoveredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> zoneId = const Value.absent(),
                required int chunkX,
                required int chunkY,
                Value<String> terrainType = const Value.absent(),
                required int depthLevel,
                Value<String?> specialResource = const Value.absent(),
                Value<double> resourceAbundance = const Value.absent(),
                Value<int> explorationLevel = const Value.absent(),
                Value<DateTime?> discoveredAt = const Value.absent(),
              }) => WorldMapTableCompanion.insert(
                zoneId: zoneId,
                chunkX: chunkX,
                chunkY: chunkY,
                terrainType: terrainType,
                depthLevel: depthLevel,
                specialResource: specialResource,
                resourceAbundance: resourceAbundance,
                explorationLevel: explorationLevel,
                discoveredAt: discoveredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorldMapTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $WorldMapTableTable,
      WorldMapTableData,
      $$WorldMapTableTableFilterComposer,
      $$WorldMapTableTableOrderingComposer,
      $$WorldMapTableTableAnnotationComposer,
      $$WorldMapTableTableCreateCompanionBuilder,
      $$WorldMapTableTableUpdateCompanionBuilder,
      (
        WorldMapTableData,
        BaseReferences<_$GameDatabase, $WorldMapTableTable, WorldMapTableData>,
      ),
      WorldMapTableData,
      PrefetchHooks Function()
    >;
typedef $$CombatLogTableTableCreateCompanionBuilder =
    CombatLogTableCompanion Function({
      Value<int> id,
      required int attackerId,
      required int defenderId,
      required DateTime timestamp,
      Value<String> combatType,
      required String result,
      required String attackerLossesJson,
      required String defenderLossesJson,
      Value<String?> spoilsJson,
      Value<String?> battleLogJson,
    });
typedef $$CombatLogTableTableUpdateCompanionBuilder =
    CombatLogTableCompanion Function({
      Value<int> id,
      Value<int> attackerId,
      Value<int> defenderId,
      Value<DateTime> timestamp,
      Value<String> combatType,
      Value<String> result,
      Value<String> attackerLossesJson,
      Value<String> defenderLossesJson,
      Value<String?> spoilsJson,
      Value<String?> battleLogJson,
    });

final class $$CombatLogTableTableReferences
    extends
        BaseReferences<
          _$GameDatabase,
          $CombatLogTableTable,
          CombatLogTableData
        > {
  $$CombatLogTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ColoniesTableTable _attackerIdTable(_$GameDatabase db) =>
      db.coloniesTable.createAlias(
        $_aliasNameGenerator(db.combatLogTable.attackerId, db.coloniesTable.id),
      );

  $$ColoniesTableTableProcessedTableManager get attackerId {
    final $_column = $_itemColumn<int>('attacker_id')!;

    final manager = $$ColoniesTableTableTableManager(
      $_db,
      $_db.coloniesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attackerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ColoniesTableTable _defenderIdTable(_$GameDatabase db) =>
      db.coloniesTable.createAlias(
        $_aliasNameGenerator(db.combatLogTable.defenderId, db.coloniesTable.id),
      );

  $$ColoniesTableTableProcessedTableManager get defenderId {
    final $_column = $_itemColumn<int>('defender_id')!;

    final manager = $$ColoniesTableTableTableManager(
      $_db,
      $_db.coloniesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defenderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CombatLogTableTableFilterComposer
    extends Composer<_$GameDatabase, $CombatLogTableTable> {
  $$CombatLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get combatType => $composableBuilder(
    column: $table.combatType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attackerLossesJson => $composableBuilder(
    column: $table.attackerLossesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defenderLossesJson => $composableBuilder(
    column: $table.defenderLossesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spoilsJson => $composableBuilder(
    column: $table.spoilsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get battleLogJson => $composableBuilder(
    column: $table.battleLogJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ColoniesTableTableFilterComposer get attackerId {
    final $$ColoniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attackerId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableFilterComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableFilterComposer get defenderId {
    final $$ColoniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defenderId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableFilterComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CombatLogTableTableOrderingComposer
    extends Composer<_$GameDatabase, $CombatLogTableTable> {
  $$CombatLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get combatType => $composableBuilder(
    column: $table.combatType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attackerLossesJson => $composableBuilder(
    column: $table.attackerLossesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defenderLossesJson => $composableBuilder(
    column: $table.defenderLossesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spoilsJson => $composableBuilder(
    column: $table.spoilsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get battleLogJson => $composableBuilder(
    column: $table.battleLogJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ColoniesTableTableOrderingComposer get attackerId {
    final $$ColoniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attackerId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableOrderingComposer get defenderId {
    final $$ColoniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defenderId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CombatLogTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $CombatLogTableTable> {
  $$CombatLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get combatType => $composableBuilder(
    column: $table.combatType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get attackerLossesJson => $composableBuilder(
    column: $table.attackerLossesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defenderLossesJson => $composableBuilder(
    column: $table.defenderLossesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spoilsJson => $composableBuilder(
    column: $table.spoilsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get battleLogJson => $composableBuilder(
    column: $table.battleLogJson,
    builder: (column) => column,
  );

  $$ColoniesTableTableAnnotationComposer get attackerId {
    final $$ColoniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attackerId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableAnnotationComposer get defenderId {
    final $$ColoniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defenderId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CombatLogTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $CombatLogTableTable,
          CombatLogTableData,
          $$CombatLogTableTableFilterComposer,
          $$CombatLogTableTableOrderingComposer,
          $$CombatLogTableTableAnnotationComposer,
          $$CombatLogTableTableCreateCompanionBuilder,
          $$CombatLogTableTableUpdateCompanionBuilder,
          (CombatLogTableData, $$CombatLogTableTableReferences),
          CombatLogTableData,
          PrefetchHooks Function({bool attackerId, bool defenderId})
        > {
  $$CombatLogTableTableTableManager(
    _$GameDatabase db,
    $CombatLogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CombatLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CombatLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CombatLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attackerId = const Value.absent(),
                Value<int> defenderId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> combatType = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String> attackerLossesJson = const Value.absent(),
                Value<String> defenderLossesJson = const Value.absent(),
                Value<String?> spoilsJson = const Value.absent(),
                Value<String?> battleLogJson = const Value.absent(),
              }) => CombatLogTableCompanion(
                id: id,
                attackerId: attackerId,
                defenderId: defenderId,
                timestamp: timestamp,
                combatType: combatType,
                result: result,
                attackerLossesJson: attackerLossesJson,
                defenderLossesJson: defenderLossesJson,
                spoilsJson: spoilsJson,
                battleLogJson: battleLogJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int attackerId,
                required int defenderId,
                required DateTime timestamp,
                Value<String> combatType = const Value.absent(),
                required String result,
                required String attackerLossesJson,
                required String defenderLossesJson,
                Value<String?> spoilsJson = const Value.absent(),
                Value<String?> battleLogJson = const Value.absent(),
              }) => CombatLogTableCompanion.insert(
                id: id,
                attackerId: attackerId,
                defenderId: defenderId,
                timestamp: timestamp,
                combatType: combatType,
                result: result,
                attackerLossesJson: attackerLossesJson,
                defenderLossesJson: defenderLossesJson,
                spoilsJson: spoilsJson,
                battleLogJson: battleLogJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CombatLogTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attackerId = false, defenderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (attackerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attackerId,
                                referencedTable: $$CombatLogTableTableReferences
                                    ._attackerIdTable(db),
                                referencedColumn:
                                    $$CombatLogTableTableReferences
                                        ._attackerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (defenderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.defenderId,
                                referencedTable: $$CombatLogTableTableReferences
                                    ._defenderIdTable(db),
                                referencedColumn:
                                    $$CombatLogTableTableReferences
                                        ._defenderIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CombatLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $CombatLogTableTable,
      CombatLogTableData,
      $$CombatLogTableTableFilterComposer,
      $$CombatLogTableTableOrderingComposer,
      $$CombatLogTableTableAnnotationComposer,
      $$CombatLogTableTableCreateCompanionBuilder,
      $$CombatLogTableTableUpdateCompanionBuilder,
      (CombatLogTableData, $$CombatLogTableTableReferences),
      CombatLogTableData,
      PrefetchHooks Function({bool attackerId, bool defenderId})
    >;
typedef $$MessagesTableTableCreateCompanionBuilder =
    MessagesTableCompanion Function({
      Value<int> id,
      required int fromColonyId,
      required int toColonyId,
      required String messageType,
      required String contentTemplateId,
      Value<String> variablesJson,
      required DateTime timestamp,
      Value<bool> isRead,
      Value<String?> responseType,
      Value<bool> isArchived,
    });
typedef $$MessagesTableTableUpdateCompanionBuilder =
    MessagesTableCompanion Function({
      Value<int> id,
      Value<int> fromColonyId,
      Value<int> toColonyId,
      Value<String> messageType,
      Value<String> contentTemplateId,
      Value<String> variablesJson,
      Value<DateTime> timestamp,
      Value<bool> isRead,
      Value<String?> responseType,
      Value<bool> isArchived,
    });

final class $$MessagesTableTableReferences
    extends
        BaseReferences<_$GameDatabase, $MessagesTableTable, MessagesTableData> {
  $$MessagesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ColoniesTableTable _fromColonyIdTable(_$GameDatabase db) =>
      db.coloniesTable.createAlias(
        $_aliasNameGenerator(
          db.messagesTable.fromColonyId,
          db.coloniesTable.id,
        ),
      );

  $$ColoniesTableTableProcessedTableManager get fromColonyId {
    final $_column = $_itemColumn<int>('from_colony_id')!;

    final manager = $$ColoniesTableTableTableManager(
      $_db,
      $_db.coloniesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromColonyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ColoniesTableTable _toColonyIdTable(_$GameDatabase db) =>
      db.coloniesTable.createAlias(
        $_aliasNameGenerator(db.messagesTable.toColonyId, db.coloniesTable.id),
      );

  $$ColoniesTableTableProcessedTableManager get toColonyId {
    final $_column = $_itemColumn<int>('to_colony_id')!;

    final manager = $$ColoniesTableTableTableManager(
      $_db,
      $_db.coloniesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toColonyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableTableFilterComposer
    extends Composer<_$GameDatabase, $MessagesTableTable> {
  $$MessagesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentTemplateId => $composableBuilder(
    column: $table.contentTemplateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseType => $composableBuilder(
    column: $table.responseType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  $$ColoniesTableTableFilterComposer get fromColonyId {
    final $$ColoniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromColonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableFilterComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableFilterComposer get toColonyId {
    final $$ColoniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toColonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableFilterComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableOrderingComposer
    extends Composer<_$GameDatabase, $MessagesTableTable> {
  $$MessagesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentTemplateId => $composableBuilder(
    column: $table.contentTemplateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseType => $composableBuilder(
    column: $table.responseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  $$ColoniesTableTableOrderingComposer get fromColonyId {
    final $$ColoniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromColonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableOrderingComposer get toColonyId {
    final $$ColoniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toColonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $MessagesTableTable> {
  $$MessagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentTemplateId => $composableBuilder(
    column: $table.contentTemplateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variablesJson => $composableBuilder(
    column: $table.variablesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get responseType => $composableBuilder(
    column: $table.responseType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  $$ColoniesTableTableAnnotationComposer get fromColonyId {
    final $$ColoniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromColonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableAnnotationComposer get toColonyId {
    final $$ColoniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toColonyId,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $MessagesTableTable,
          MessagesTableData,
          $$MessagesTableTableFilterComposer,
          $$MessagesTableTableOrderingComposer,
          $$MessagesTableTableAnnotationComposer,
          $$MessagesTableTableCreateCompanionBuilder,
          $$MessagesTableTableUpdateCompanionBuilder,
          (MessagesTableData, $$MessagesTableTableReferences),
          MessagesTableData,
          PrefetchHooks Function({bool fromColonyId, bool toColonyId})
        > {
  $$MessagesTableTableTableManager(_$GameDatabase db, $MessagesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fromColonyId = const Value.absent(),
                Value<int> toColonyId = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<String> contentTemplateId = const Value.absent(),
                Value<String> variablesJson = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String?> responseType = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => MessagesTableCompanion(
                id: id,
                fromColonyId: fromColonyId,
                toColonyId: toColonyId,
                messageType: messageType,
                contentTemplateId: contentTemplateId,
                variablesJson: variablesJson,
                timestamp: timestamp,
                isRead: isRead,
                responseType: responseType,
                isArchived: isArchived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fromColonyId,
                required int toColonyId,
                required String messageType,
                required String contentTemplateId,
                Value<String> variablesJson = const Value.absent(),
                required DateTime timestamp,
                Value<bool> isRead = const Value.absent(),
                Value<String?> responseType = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => MessagesTableCompanion.insert(
                id: id,
                fromColonyId: fromColonyId,
                toColonyId: toColonyId,
                messageType: messageType,
                contentTemplateId: contentTemplateId,
                variablesJson: variablesJson,
                timestamp: timestamp,
                isRead: isRead,
                responseType: responseType,
                isArchived: isArchived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fromColonyId = false, toColonyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fromColonyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fromColonyId,
                                referencedTable: $$MessagesTableTableReferences
                                    ._fromColonyIdTable(db),
                                referencedColumn: $$MessagesTableTableReferences
                                    ._fromColonyIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (toColonyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.toColonyId,
                                referencedTable: $$MessagesTableTableReferences
                                    ._toColonyIdTable(db),
                                referencedColumn: $$MessagesTableTableReferences
                                    ._toColonyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $MessagesTableTable,
      MessagesTableData,
      $$MessagesTableTableFilterComposer,
      $$MessagesTableTableOrderingComposer,
      $$MessagesTableTableAnnotationComposer,
      $$MessagesTableTableCreateCompanionBuilder,
      $$MessagesTableTableUpdateCompanionBuilder,
      (MessagesTableData, $$MessagesTableTableReferences),
      MessagesTableData,
      PrefetchHooks Function({bool fromColonyId, bool toColonyId})
    >;
typedef $$DiplomacyTableTableCreateCompanionBuilder =
    DiplomacyTableCompanion Function({
      Value<int> id,
      required int colony1Id,
      required int colony2Id,
      Value<String> relationType,
      Value<int> disposition,
      Value<int> trustLevel,
      Value<DateTime?> lastInteraction,
      Value<String?> pactType,
      Value<DateTime?> pactExpiryTime,
      Value<bool> treatyViolated,
    });
typedef $$DiplomacyTableTableUpdateCompanionBuilder =
    DiplomacyTableCompanion Function({
      Value<int> id,
      Value<int> colony1Id,
      Value<int> colony2Id,
      Value<String> relationType,
      Value<int> disposition,
      Value<int> trustLevel,
      Value<DateTime?> lastInteraction,
      Value<String?> pactType,
      Value<DateTime?> pactExpiryTime,
      Value<bool> treatyViolated,
    });

final class $$DiplomacyTableTableReferences
    extends
        BaseReferences<
          _$GameDatabase,
          $DiplomacyTableTable,
          DiplomacyTableData
        > {
  $$DiplomacyTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ColoniesTableTable _colony1IdTable(_$GameDatabase db) =>
      db.coloniesTable.createAlias(
        $_aliasNameGenerator(db.diplomacyTable.colony1Id, db.coloniesTable.id),
      );

  $$ColoniesTableTableProcessedTableManager get colony1Id {
    final $_column = $_itemColumn<int>('colony1_id')!;

    final manager = $$ColoniesTableTableTableManager(
      $_db,
      $_db.coloniesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colony1IdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ColoniesTableTable _colony2IdTable(_$GameDatabase db) =>
      db.coloniesTable.createAlias(
        $_aliasNameGenerator(db.diplomacyTable.colony2Id, db.coloniesTable.id),
      );

  $$ColoniesTableTableProcessedTableManager get colony2Id {
    final $_column = $_itemColumn<int>('colony2_id')!;

    final manager = $$ColoniesTableTableTableManager(
      $_db,
      $_db.coloniesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colony2IdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiplomacyTableTableFilterComposer
    extends Composer<_$GameDatabase, $DiplomacyTableTable> {
  $$DiplomacyTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get disposition => $composableBuilder(
    column: $table.disposition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInteraction => $composableBuilder(
    column: $table.lastInteraction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pactType => $composableBuilder(
    column: $table.pactType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pactExpiryTime => $composableBuilder(
    column: $table.pactExpiryTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get treatyViolated => $composableBuilder(
    column: $table.treatyViolated,
    builder: (column) => ColumnFilters(column),
  );

  $$ColoniesTableTableFilterComposer get colony1Id {
    final $$ColoniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colony1Id,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableFilterComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableFilterComposer get colony2Id {
    final $$ColoniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colony2Id,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableFilterComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiplomacyTableTableOrderingComposer
    extends Composer<_$GameDatabase, $DiplomacyTableTable> {
  $$DiplomacyTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get disposition => $composableBuilder(
    column: $table.disposition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInteraction => $composableBuilder(
    column: $table.lastInteraction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pactType => $composableBuilder(
    column: $table.pactType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pactExpiryTime => $composableBuilder(
    column: $table.pactExpiryTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get treatyViolated => $composableBuilder(
    column: $table.treatyViolated,
    builder: (column) => ColumnOrderings(column),
  );

  $$ColoniesTableTableOrderingComposer get colony1Id {
    final $$ColoniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colony1Id,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableOrderingComposer get colony2Id {
    final $$ColoniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colony2Id,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiplomacyTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $DiplomacyTableTable> {
  $$DiplomacyTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get disposition => $composableBuilder(
    column: $table.disposition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastInteraction => $composableBuilder(
    column: $table.lastInteraction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pactType =>
      $composableBuilder(column: $table.pactType, builder: (column) => column);

  GeneratedColumn<DateTime> get pactExpiryTime => $composableBuilder(
    column: $table.pactExpiryTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get treatyViolated => $composableBuilder(
    column: $table.treatyViolated,
    builder: (column) => column,
  );

  $$ColoniesTableTableAnnotationComposer get colony1Id {
    final $$ColoniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colony1Id,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ColoniesTableTableAnnotationComposer get colony2Id {
    final $$ColoniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colony2Id,
      referencedTable: $db.coloniesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColoniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.coloniesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiplomacyTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $DiplomacyTableTable,
          DiplomacyTableData,
          $$DiplomacyTableTableFilterComposer,
          $$DiplomacyTableTableOrderingComposer,
          $$DiplomacyTableTableAnnotationComposer,
          $$DiplomacyTableTableCreateCompanionBuilder,
          $$DiplomacyTableTableUpdateCompanionBuilder,
          (DiplomacyTableData, $$DiplomacyTableTableReferences),
          DiplomacyTableData,
          PrefetchHooks Function({bool colony1Id, bool colony2Id})
        > {
  $$DiplomacyTableTableTableManager(
    _$GameDatabase db,
    $DiplomacyTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiplomacyTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiplomacyTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiplomacyTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> colony1Id = const Value.absent(),
                Value<int> colony2Id = const Value.absent(),
                Value<String> relationType = const Value.absent(),
                Value<int> disposition = const Value.absent(),
                Value<int> trustLevel = const Value.absent(),
                Value<DateTime?> lastInteraction = const Value.absent(),
                Value<String?> pactType = const Value.absent(),
                Value<DateTime?> pactExpiryTime = const Value.absent(),
                Value<bool> treatyViolated = const Value.absent(),
              }) => DiplomacyTableCompanion(
                id: id,
                colony1Id: colony1Id,
                colony2Id: colony2Id,
                relationType: relationType,
                disposition: disposition,
                trustLevel: trustLevel,
                lastInteraction: lastInteraction,
                pactType: pactType,
                pactExpiryTime: pactExpiryTime,
                treatyViolated: treatyViolated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int colony1Id,
                required int colony2Id,
                Value<String> relationType = const Value.absent(),
                Value<int> disposition = const Value.absent(),
                Value<int> trustLevel = const Value.absent(),
                Value<DateTime?> lastInteraction = const Value.absent(),
                Value<String?> pactType = const Value.absent(),
                Value<DateTime?> pactExpiryTime = const Value.absent(),
                Value<bool> treatyViolated = const Value.absent(),
              }) => DiplomacyTableCompanion.insert(
                id: id,
                colony1Id: colony1Id,
                colony2Id: colony2Id,
                relationType: relationType,
                disposition: disposition,
                trustLevel: trustLevel,
                lastInteraction: lastInteraction,
                pactType: pactType,
                pactExpiryTime: pactExpiryTime,
                treatyViolated: treatyViolated,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DiplomacyTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({colony1Id = false, colony2Id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (colony1Id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.colony1Id,
                                referencedTable: $$DiplomacyTableTableReferences
                                    ._colony1IdTable(db),
                                referencedColumn:
                                    $$DiplomacyTableTableReferences
                                        ._colony1IdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (colony2Id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.colony2Id,
                                referencedTable: $$DiplomacyTableTableReferences
                                    ._colony2IdTable(db),
                                referencedColumn:
                                    $$DiplomacyTableTableReferences
                                        ._colony2IdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DiplomacyTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $DiplomacyTableTable,
      DiplomacyTableData,
      $$DiplomacyTableTableFilterComposer,
      $$DiplomacyTableTableOrderingComposer,
      $$DiplomacyTableTableAnnotationComposer,
      $$DiplomacyTableTableCreateCompanionBuilder,
      $$DiplomacyTableTableUpdateCompanionBuilder,
      (DiplomacyTableData, $$DiplomacyTableTableReferences),
      DiplomacyTableData,
      PrefetchHooks Function({bool colony1Id, bool colony2Id})
    >;
typedef $$ResearchTableTableCreateCompanionBuilder =
    ResearchTableCompanion Function({
      Value<int> id,
      required String techId,
      required String techName,
      required int techTier,
      Value<bool> isCompleted,
      Value<int> completionPercentage,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      required int pointsRequired,
      Value<int> pointsInvested,
      Value<String> prerequisitesJson,
    });
typedef $$ResearchTableTableUpdateCompanionBuilder =
    ResearchTableCompanion Function({
      Value<int> id,
      Value<String> techId,
      Value<String> techName,
      Value<int> techTier,
      Value<bool> isCompleted,
      Value<int> completionPercentage,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<int> pointsRequired,
      Value<int> pointsInvested,
      Value<String> prerequisitesJson,
    });

class $$ResearchTableTableFilterComposer
    extends Composer<_$GameDatabase, $ResearchTableTable> {
  $$ResearchTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techId => $composableBuilder(
    column: $table.techId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techName => $composableBuilder(
    column: $table.techName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get techTier => $composableBuilder(
    column: $table.techTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsRequired => $composableBuilder(
    column: $table.pointsRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsInvested => $composableBuilder(
    column: $table.pointsInvested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prerequisitesJson => $composableBuilder(
    column: $table.prerequisitesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResearchTableTableOrderingComposer
    extends Composer<_$GameDatabase, $ResearchTableTable> {
  $$ResearchTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techId => $composableBuilder(
    column: $table.techId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techName => $composableBuilder(
    column: $table.techName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get techTier => $composableBuilder(
    column: $table.techTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsRequired => $composableBuilder(
    column: $table.pointsRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsInvested => $composableBuilder(
    column: $table.pointsInvested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prerequisitesJson => $composableBuilder(
    column: $table.prerequisitesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResearchTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $ResearchTableTable> {
  $$ResearchTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get techId =>
      $composableBuilder(column: $table.techId, builder: (column) => column);

  GeneratedColumn<String> get techName =>
      $composableBuilder(column: $table.techName, builder: (column) => column);

  GeneratedColumn<int> get techTier =>
      $composableBuilder(column: $table.techTier, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completionPercentage => $composableBuilder(
    column: $table.completionPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get pointsRequired => $composableBuilder(
    column: $table.pointsRequired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointsInvested => $composableBuilder(
    column: $table.pointsInvested,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prerequisitesJson => $composableBuilder(
    column: $table.prerequisitesJson,
    builder: (column) => column,
  );
}

class $$ResearchTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $ResearchTableTable,
          ResearchTableData,
          $$ResearchTableTableFilterComposer,
          $$ResearchTableTableOrderingComposer,
          $$ResearchTableTableAnnotationComposer,
          $$ResearchTableTableCreateCompanionBuilder,
          $$ResearchTableTableUpdateCompanionBuilder,
          (
            ResearchTableData,
            BaseReferences<
              _$GameDatabase,
              $ResearchTableTable,
              ResearchTableData
            >,
          ),
          ResearchTableData,
          PrefetchHooks Function()
        > {
  $$ResearchTableTableTableManager(_$GameDatabase db, $ResearchTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> techId = const Value.absent(),
                Value<String> techName = const Value.absent(),
                Value<int> techTier = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> completionPercentage = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> pointsRequired = const Value.absent(),
                Value<int> pointsInvested = const Value.absent(),
                Value<String> prerequisitesJson = const Value.absent(),
              }) => ResearchTableCompanion(
                id: id,
                techId: techId,
                techName: techName,
                techTier: techTier,
                isCompleted: isCompleted,
                completionPercentage: completionPercentage,
                startTime: startTime,
                endTime: endTime,
                pointsRequired: pointsRequired,
                pointsInvested: pointsInvested,
                prerequisitesJson: prerequisitesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String techId,
                required String techName,
                required int techTier,
                Value<bool> isCompleted = const Value.absent(),
                Value<int> completionPercentage = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                required int pointsRequired,
                Value<int> pointsInvested = const Value.absent(),
                Value<String> prerequisitesJson = const Value.absent(),
              }) => ResearchTableCompanion.insert(
                id: id,
                techId: techId,
                techName: techName,
                techTier: techTier,
                isCompleted: isCompleted,
                completionPercentage: completionPercentage,
                startTime: startTime,
                endTime: endTime,
                pointsRequired: pointsRequired,
                pointsInvested: pointsInvested,
                prerequisitesJson: prerequisitesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $ResearchTableTable,
      ResearchTableData,
      $$ResearchTableTableFilterComposer,
      $$ResearchTableTableOrderingComposer,
      $$ResearchTableTableAnnotationComposer,
      $$ResearchTableTableCreateCompanionBuilder,
      $$ResearchTableTableUpdateCompanionBuilder,
      (
        ResearchTableData,
        BaseReferences<_$GameDatabase, $ResearchTableTable, ResearchTableData>,
      ),
      ResearchTableData,
      PrefetchHooks Function()
    >;
typedef $$QuestsTableTableCreateCompanionBuilder =
    QuestsTableCompanion Function({
      Value<int> id,
      required String questId,
      required String questName,
      required String questType,
      Value<String?> description,
      Value<String> progressJson,
      Value<int> progressPercentage,
      Value<bool> isCompleted,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rewardXp,
      Value<int> rewardCredits,
      Value<bool> isActive,
    });
typedef $$QuestsTableTableUpdateCompanionBuilder =
    QuestsTableCompanion Function({
      Value<int> id,
      Value<String> questId,
      Value<String> questName,
      Value<String> questType,
      Value<String?> description,
      Value<String> progressJson,
      Value<int> progressPercentage,
      Value<bool> isCompleted,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rewardXp,
      Value<int> rewardCredits,
      Value<bool> isActive,
    });

class $$QuestsTableTableFilterComposer
    extends Composer<_$GameDatabase, $QuestsTableTable> {
  $$QuestsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questId => $composableBuilder(
    column: $table.questId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questName => $composableBuilder(
    column: $table.questName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questType => $composableBuilder(
    column: $table.questType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get progressJson => $composableBuilder(
    column: $table.progressJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressPercentage => $composableBuilder(
    column: $table.progressPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardCredits => $composableBuilder(
    column: $table.rewardCredits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestsTableTableOrderingComposer
    extends Composer<_$GameDatabase, $QuestsTableTable> {
  $$QuestsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questId => $composableBuilder(
    column: $table.questId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questName => $composableBuilder(
    column: $table.questName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questType => $composableBuilder(
    column: $table.questType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progressJson => $composableBuilder(
    column: $table.progressJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressPercentage => $composableBuilder(
    column: $table.progressPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardCredits => $composableBuilder(
    column: $table.rewardCredits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestsTableTableAnnotationComposer
    extends Composer<_$GameDatabase, $QuestsTableTable> {
  $$QuestsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => column);

  GeneratedColumn<String> get questName =>
      $composableBuilder(column: $table.questName, builder: (column) => column);

  GeneratedColumn<String> get questType =>
      $composableBuilder(column: $table.questType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get progressJson => $composableBuilder(
    column: $table.progressJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressPercentage => $composableBuilder(
    column: $table.progressPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rewardXp =>
      $composableBuilder(column: $table.rewardXp, builder: (column) => column);

  GeneratedColumn<int> get rewardCredits => $composableBuilder(
    column: $table.rewardCredits,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$QuestsTableTableTableManager
    extends
        RootTableManager<
          _$GameDatabase,
          $QuestsTableTable,
          QuestsTableData,
          $$QuestsTableTableFilterComposer,
          $$QuestsTableTableOrderingComposer,
          $$QuestsTableTableAnnotationComposer,
          $$QuestsTableTableCreateCompanionBuilder,
          $$QuestsTableTableUpdateCompanionBuilder,
          (
            QuestsTableData,
            BaseReferences<_$GameDatabase, $QuestsTableTable, QuestsTableData>,
          ),
          QuestsTableData,
          PrefetchHooks Function()
        > {
  $$QuestsTableTableTableManager(_$GameDatabase db, $QuestsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> questId = const Value.absent(),
                Value<String> questName = const Value.absent(),
                Value<String> questType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> progressJson = const Value.absent(),
                Value<int> progressPercentage = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<int> rewardCredits = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => QuestsTableCompanion(
                id: id,
                questId: questId,
                questName: questName,
                questType: questType,
                description: description,
                progressJson: progressJson,
                progressPercentage: progressPercentage,
                isCompleted: isCompleted,
                startedAt: startedAt,
                completedAt: completedAt,
                rewardXp: rewardXp,
                rewardCredits: rewardCredits,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String questId,
                required String questName,
                required String questType,
                Value<String?> description = const Value.absent(),
                Value<String> progressJson = const Value.absent(),
                Value<int> progressPercentage = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<int> rewardCredits = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => QuestsTableCompanion.insert(
                id: id,
                questId: questId,
                questName: questName,
                questType: questType,
                description: description,
                progressJson: progressJson,
                progressPercentage: progressPercentage,
                isCompleted: isCompleted,
                startedAt: startedAt,
                completedAt: completedAt,
                rewardXp: rewardXp,
                rewardCredits: rewardCredits,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$GameDatabase,
      $QuestsTableTable,
      QuestsTableData,
      $$QuestsTableTableFilterComposer,
      $$QuestsTableTableOrderingComposer,
      $$QuestsTableTableAnnotationComposer,
      $$QuestsTableTableCreateCompanionBuilder,
      $$QuestsTableTableUpdateCompanionBuilder,
      (
        QuestsTableData,
        BaseReferences<_$GameDatabase, $QuestsTableTable, QuestsTableData>,
      ),
      QuestsTableData,
      PrefetchHooks Function()
    >;

class $GameDatabaseManager {
  final _$GameDatabase _db;
  $GameDatabaseManager(this._db);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db, _db.playerTable);
  $$ColoniesTableTableTableManager get coloniesTable =>
      $$ColoniesTableTableTableManager(_db, _db.coloniesTable);
  $$BuildingsTableTableTableManager get buildingsTable =>
      $$BuildingsTableTableTableManager(_db, _db.buildingsTable);
  $$TroopsTableTableTableManager get troopsTable =>
      $$TroopsTableTableTableManager(_db, _db.troopsTable);
  $$WorldMapTableTableTableManager get worldMapTable =>
      $$WorldMapTableTableTableManager(_db, _db.worldMapTable);
  $$CombatLogTableTableTableManager get combatLogTable =>
      $$CombatLogTableTableTableManager(_db, _db.combatLogTable);
  $$MessagesTableTableTableManager get messagesTable =>
      $$MessagesTableTableTableManager(_db, _db.messagesTable);
  $$DiplomacyTableTableTableManager get diplomacyTable =>
      $$DiplomacyTableTableTableManager(_db, _db.diplomacyTable);
  $$ResearchTableTableTableManager get researchTable =>
      $$ResearchTableTableTableManager(_db, _db.researchTable);
  $$QuestsTableTableTableManager get questsTable =>
      $$QuestsTableTableTableManager(_db, _db.questsTable);
}
