class RelationshipScore {
  double diplomacyLevel; // -1.0 (enemy) to +1.0 (ally)
  double trustLevel; // -1.0 (traitor) to +1.0 (reliable)
  int tradeCompletions;
  int attacksExchanged;
  DateTime? lastInteraction;

  RelationshipScore({
    this.diplomacyLevel = 0.0,
    this.trustLevel = 0.0,
    this.tradeCompletions = 0,
    this.attacksExchanged = 0,
    this.lastInteraction,
  });

  bool get isDeadlyEnemy => diplomacyLevel < -0.7;
  bool get isAlly => diplomacyLevel > 0.6;
  bool get isTrusted => trustLevel > 0.5;

  int successfulTradesWith() => tradeCompletions;
}

class StrategicEvent {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  StrategicEvent({
    required this.type,
    required this.timestamp,
    this.details = const {},
  });
}

class ColonyDisposition {
  final int colonyId;
  double estimatedResources;
  double estimatedMilitary;
  int positionX;
  int positionY;
  DateTime lastSeen;

  ColonyDisposition({
    required this.colonyId,
    this.estimatedResources = 0,
    this.estimatedMilitary = 0,
    this.positionX = 0,
    this.positionY = 0,
    required this.lastSeen,
  });
}

class AIMemory {
  static const int maxRecentEvents = 50;

  final Map<int, ColonyDisposition> knownColonies = {};
  final List<StrategicEvent> recentEvents = [];
  String? currentObjective; // 'EXPAND', 'DEFEND', 'ECONOMIZE', 'CONQUEST'
  double objectiveProgress = 0.0;
  final Map<int, RelationshipScore> relationships = {};
  final Map<String, DateTime> actionCooldowns = {};

  void recordEvent(StrategicEvent event) {
    recentEvents.add(event);
    if (recentEvents.length > maxRecentEvents) {
      recentEvents.removeAt(0);
    }
  }

  void updateRelationship(int colonyId,
      {double? diplomacyDelta, double? trustDelta}) {
    final rel =
        relationships.putIfAbsent(colonyId, () => RelationshipScore());
    if (diplomacyDelta != null) {
      rel.diplomacyLevel =
          (rel.diplomacyLevel + diplomacyDelta).clamp(-1.0, 1.0);
    }
    if (trustDelta != null) {
      rel.trustLevel = (rel.trustLevel + trustDelta).clamp(-1.0, 1.0);
    }
    rel.lastInteraction = DateTime.now();
  }

  bool isOnCooldown(String actionKey) {
    final cooldownEnd = actionCooldowns[actionKey];
    if (cooldownEnd == null) return false;
    return DateTime.now().isBefore(cooldownEnd);
  }

  void setCooldown(String actionKey, Duration duration) {
    actionCooldowns[actionKey] = DateTime.now().add(duration);
  }

  bool isDeadlyEnemy(int colonyId) {
    return relationships[colonyId]?.isDeadlyEnemy ?? false;
  }

  int successfulTradesWith(int colonyId) {
    return relationships[colonyId]?.tradeCompletions ?? 0;
  }
}
