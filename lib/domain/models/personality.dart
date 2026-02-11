enum Archetype {
  warrior,
  diplomat,
  economist,
  explorer,
  manipulator,
  balanced,
  conqueror,
  defender,
}

class Personality {
  double aggressivity;
  double diplomacy;
  double expansion;
  double economy;
  double cunning;

  Personality({
    required this.aggressivity,
    required this.diplomacy,
    required this.expansion,
    required this.economy,
    required this.cunning,
  });

  Personality copyWith({
    double? aggressivity,
    double? diplomacy,
    double? expansion,
    double? economy,
    double? cunning,
  }) =>
      Personality(
        aggressivity: aggressivity ?? this.aggressivity,
        diplomacy: diplomacy ?? this.diplomacy,
        expansion: expansion ?? this.expansion,
        economy: economy ?? this.economy,
        cunning: cunning ?? this.cunning,
      );

  void clamp() {
    aggressivity = aggressivity.clamp(0.0, 1.0);
    diplomacy = diplomacy.clamp(0.0, 1.0);
    expansion = expansion.clamp(0.0, 1.0);
    economy = economy.clamp(0.0, 1.0);
    cunning = cunning.clamp(0.0, 1.0);
  }
}
