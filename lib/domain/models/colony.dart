import 'personality.dart';
import 'resource.dart';

enum OwnerType { player, ai }

class Colony {
  final int id;
  final OwnerType ownerType;
  final String name;
  final String personalityType;
  final double positionX;
  final double positionY;
  final String faction;
  final int population;
  final int domeLevel;
  final int healthDome;
  final Resources resources;
  final double loyalty;
  final Personality? aiPersonalityTraits;
  final String? aiBehaviorState;
  final double aiThreatLevel;
  final bool discoveredByPlayer;
  final DateTime lastActivityAt;
  final DateTime createdAt;

  const Colony({
    required this.id,
    required this.ownerType,
    required this.name,
    required this.personalityType,
    required this.positionX,
    required this.positionY,
    required this.faction,
    this.population = 100,
    this.domeLevel = 1,
    this.healthDome = 100,
    this.resources = const Resources(),
    this.loyalty = 1.0,
    this.aiPersonalityTraits,
    this.aiBehaviorState,
    this.aiThreatLevel = 0.0,
    this.discoveredByPlayer = false,
    required this.lastActivityAt,
    required this.createdAt,
  });

  Colony copyWith({
    int? id,
    OwnerType? ownerType,
    String? name,
    String? personalityType,
    double? positionX,
    double? positionY,
    String? faction,
    int? population,
    int? domeLevel,
    int? healthDome,
    Resources? resources,
    double? loyalty,
    Personality? aiPersonalityTraits,
    String? aiBehaviorState,
    double? aiThreatLevel,
    bool? discoveredByPlayer,
    DateTime? lastActivityAt,
    DateTime? createdAt,
  }) =>
      Colony(
        id: id ?? this.id,
        ownerType: ownerType ?? this.ownerType,
        name: name ?? this.name,
        personalityType: personalityType ?? this.personalityType,
        positionX: positionX ?? this.positionX,
        positionY: positionY ?? this.positionY,
        faction: faction ?? this.faction,
        population: population ?? this.population,
        domeLevel: domeLevel ?? this.domeLevel,
        healthDome: healthDome ?? this.healthDome,
        resources: resources ?? this.resources,
        loyalty: loyalty ?? this.loyalty,
        aiPersonalityTraits: aiPersonalityTraits ?? this.aiPersonalityTraits,
        aiBehaviorState: aiBehaviorState ?? this.aiBehaviorState,
        aiThreatLevel: aiThreatLevel ?? this.aiThreatLevel,
        discoveredByPlayer: discoveredByPlayer ?? this.discoveredByPlayer,
        lastActivityAt: lastActivityAt ?? this.lastActivityAt,
        createdAt: createdAt ?? this.createdAt,
      );
}
