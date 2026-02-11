import 'dart:math';

import 'package:abysses/domain/models/personality.dart';

enum StrategicAction {
  attack,
  defend,
  buildResource,
  buildMilitary,
  trade,
  explore,
  spy,
  diplomacy,
  research,
  retreat,
}

class UtilityScoringEngine {
  final Random _random = Random();

  static const Map<StrategicAction, double> _baseScores = {
    StrategicAction.attack: 0.6,
    StrategicAction.defend: 0.75,
    StrategicAction.buildResource: 0.7,
    StrategicAction.buildMilitary: 0.65,
    StrategicAction.trade: 0.5,
    StrategicAction.explore: 0.4,
    StrategicAction.spy: 0.45,
    StrategicAction.diplomacy: 0.55,
    StrategicAction.research: 0.6,
    StrategicAction.retreat: 0.3,
  };

  double calculateUtility({
    required StrategicAction action,
    required Personality personality,
    Map<String, dynamic> context = const {},
  }) {
    final baseScore = _baseScores[action] ?? 0.5;
    final contextMultiplier = _calculateContextMultiplier(action, context);
    final personalityMultiplier =
        _calculatePersonalityFilter(action, personality);
    final randomVariation = 1.0 + (_random.nextDouble() - 0.5) * 0.2;

    return (baseScore *
            contextMultiplier *
            personalityMultiplier *
            randomVariation)
        .clamp(0.0, 1.0);
  }

  StrategicAction? selectBestAction({
    required Personality personality,
    Map<String, dynamic> context = const {},
    double threshold = 0.5,
  }) {
    double bestScore = 0.0;
    StrategicAction? bestAction;

    for (final action in StrategicAction.values) {
      final score = calculateUtility(
          action: action, personality: personality, context: context);
      if (score > bestScore && score > threshold) {
        bestScore = score;
        bestAction = action;
      }
    }

    return bestAction;
  }

  double _calculateContextMultiplier(
      StrategicAction action, Map<String, dynamic> context) {
    double multiplier = 1.0;
    // Context multipliers will be filled in as game state matures.
    // For now, check for basic context flags.
    switch (action) {
      case StrategicAction.attack:
        final powerRatio = context['powerRatio'] as double? ?? 1.0;
        if (powerRatio > 1.8) {
          multiplier *= 1.8;
        } else if (powerRatio < 1.1) {
          multiplier *= 0.3;
        }
        break;
      case StrategicAction.defend:
        if (context['threatDetected'] == true) multiplier *= 2.0;
        break;
      case StrategicAction.buildResource:
        if (context['lowFood'] == true) multiplier *= 1.6;
        break;
      case StrategicAction.trade:
        final tradeHistory = context['tradeHistory'] as int? ?? 0;
        multiplier *= 1.0 + (tradeHistory * 0.15).clamp(0.0, 0.6);
        break;
      case StrategicAction.diplomacy:
        if (context['isDeadlyEnemy'] == true) multiplier *= 0.1;
        if (context['weakMilitary'] == true) multiplier *= 1.4;
        break;
      default:
        break;
    }
    return multiplier;
  }

  double _calculatePersonalityFilter(
      StrategicAction action, Personality personality) {
    double multiplier = 1.0;
    switch (action) {
      case StrategicAction.attack:
        multiplier *= (0.5 + personality.aggressivity);
        multiplier *= (1.5 - personality.diplomacy * 0.5);
        break;
      case StrategicAction.buildResource:
        multiplier *= (0.5 + personality.economy);
        break;
      case StrategicAction.buildMilitary:
        multiplier *=
            (0.5 + personality.aggressivity * 0.6 + personality.expansion * 0.4);
        break;
      case StrategicAction.explore:
        multiplier *= (0.5 + personality.cunning);
        multiplier *= (0.5 + personality.expansion * 0.5);
        break;
      case StrategicAction.spy:
        multiplier *= (0.5 + personality.cunning * 1.2);
        break;
      case StrategicAction.trade:
        multiplier *= (0.5 + personality.diplomacy * 0.8);
        break;
      case StrategicAction.diplomacy:
        multiplier *= (0.5 + personality.diplomacy);
        break;
      case StrategicAction.research:
        multiplier *= (0.5 + personality.economy * 0.7);
        break;
      default:
        break;
    }
    return multiplier;
  }
}
