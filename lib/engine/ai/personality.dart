import 'package:abysses/domain/models/personality.dart';

enum StrategicEventType {
  attackReceived,
  attackLaunched,
  tradeSuccess,
  tradeFailed,
  conquestVictory,
  conquestDefeat,
  allianceFormed,
  betrayed,
  resourceShortage,
  explorationSuccess,
}

class PersonalityEvolution {
  static const double maxChange = 0.05;

  void updateFromEvent(Personality personality, StrategicEventType eventType) {
    switch (eventType) {
      case StrategicEventType.attackReceived:
        personality.aggressivity += 0.03;
        personality.diplomacy -= 0.02;
        break;
      case StrategicEventType.tradeSuccess:
        personality.diplomacy += 0.03;
        personality.aggressivity -= 0.02;
        break;
      case StrategicEventType.conquestVictory:
        personality.aggressivity += 0.04;
        personality.expansion += 0.05;
        break;
      case StrategicEventType.conquestDefeat:
        personality.aggressivity -= 0.03;
        personality.economy += 0.02;
        break;
      case StrategicEventType.betrayed:
        personality.diplomacy -= 0.05;
        personality.aggressivity += 0.05;
        personality.cunning += 0.03;
        break;
      case StrategicEventType.allianceFormed:
        personality.diplomacy += 0.04;
        personality.aggressivity -= 0.02;
        break;
      case StrategicEventType.resourceShortage:
        personality.economy += 0.04;
        personality.expansion -= 0.02;
        break;
      case StrategicEventType.explorationSuccess:
        personality.expansion += 0.03;
        personality.cunning += 0.02;
        break;
      default:
        break;
    }
    personality.clamp();
  }
}
