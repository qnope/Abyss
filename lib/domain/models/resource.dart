enum ResourceType { credits, biomass, minerals, energy }

class Resources {
  final int credits;
  final int biomass;
  final int minerals;
  final int energy;

  const Resources({
    this.credits = 0,
    this.biomass = 0,
    this.minerals = 0,
    this.energy = 0,
  });

  Resources operator +(Resources other) => Resources(
        credits: credits + other.credits,
        biomass: biomass + other.biomass,
        minerals: minerals + other.minerals,
        energy: energy + other.energy,
      );

  Resources operator -(Resources other) => Resources(
        credits: credits - other.credits,
        biomass: biomass - other.biomass,
        minerals: minerals - other.minerals,
        energy: energy - other.energy,
      );

  Resources operator *(double factor) => Resources(
        credits: (credits * factor).round(),
        biomass: (biomass * factor).round(),
        minerals: (minerals * factor).round(),
        energy: (energy * factor).round(),
      );

  int get total => credits + biomass + minerals + energy;

  int byType(ResourceType type) {
    switch (type) {
      case ResourceType.credits:
        return credits;
      case ResourceType.biomass:
        return biomass;
      case ResourceType.minerals:
        return minerals;
      case ResourceType.energy:
        return energy;
    }
  }

  Resources copyWith({
    int? credits,
    int? biomass,
    int? minerals,
    int? energy,
  }) =>
      Resources(
        credits: credits ?? this.credits,
        biomass: biomass ?? this.biomass,
        minerals: minerals ?? this.minerals,
        energy: energy ?? this.energy,
      );
}
