import 'package:abysses/domain/models/personality.dart';

/// Static definition of an AI personality archetype.
class ArchetypeDefinition {
  final Archetype archetype;
  final String name;
  final String displayName;
  final Personality basePersonality;
  final String description;

  const ArchetypeDefinition({
    required this.archetype,
    required this.name,
    required this.displayName,
    required this.basePersonality,
    required this.description,
  });
}

/// The 8 AI personality archetypes from the GDD.
class PersonalityArchetypes {
  PersonalityArchetypes._();

  static final Map<Archetype, ArchetypeDefinition> archetypes = {
    Archetype.warrior: ArchetypeDefinition(
      archetype: Archetype.warrior,
      name: 'Kraken',
      displayName: 'Guerrier',
      basePersonality: Personality(
        aggressivity: 0.95,
        diplomacy: 0.1,
        expansion: 0.8,
        economy: 0.2,
        cunning: 0.3,
      ),
      description: 'Attaque précoce, raids constants',
    ),
    Archetype.diplomat: ArchetypeDefinition(
      archetype: Archetype.diplomat,
      name: 'Medusa',
      displayName: 'Diplomate',
      basePersonality: Personality(
        aggressivity: 0.2,
        diplomacy: 0.95,
        expansion: 0.5,
        economy: 0.7,
        cunning: 0.4,
      ),
      description: 'Réseau d\'alliances, commerce actif',
    ),
    Archetype.economist: ArchetypeDefinition(
      archetype: Archetype.economist,
      name: 'Leviathan',
      displayName: 'Économe',
      basePersonality: Personality(
        aggressivity: 0.3,
        diplomacy: 0.6,
        expansion: 0.2,
        economy: 0.95,
        cunning: 0.3,
      ),
      description: 'Fermes massives, dominance tardive',
    ),
    Archetype.explorer: ArchetypeDefinition(
      archetype: Archetype.explorer,
      name: 'Nautilus',
      displayName: 'Explorateur',
      basePersonality: Personality(
        aggressivity: 0.4,
        diplomacy: 0.5,
        expansion: 0.9,
        economy: 0.4,
        cunning: 0.8,
      ),
      description: 'Déploiement rapide, opportunisme',
    ),
    Archetype.manipulator: ArchetypeDefinition(
      archetype: Archetype.manipulator,
      name: 'Sirène',
      displayName: 'Manipulateur',
      basePersonality: Personality(
        aggressivity: 0.5,
        diplomacy: 0.4,
        expansion: 0.6,
        economy: 0.5,
        cunning: 0.95,
      ),
      description: 'Espionnage, fausses alliances',
    ),
    Archetype.balanced: ArchetypeDefinition(
      archetype: Archetype.balanced,
      name: 'Triton',
      displayName: 'Équilibré',
      basePersonality: Personality(
        aggressivity: 0.5,
        diplomacy: 0.5,
        expansion: 0.5,
        economy: 0.5,
        cunning: 0.5,
      ),
      description: 'Adaptatif, pas de spécialité',
    ),
    Archetype.conqueror: ArchetypeDefinition(
      archetype: Archetype.conqueror,
      name: 'Titan',
      displayName: 'Conquérant',
      basePersonality: Personality(
        aggressivity: 0.75,
        diplomacy: 0.25,
        expansion: 0.95,
        economy: 0.3,
        cunning: 0.4,
      ),
      description: 'Expansion massive et rapide',
    ),
    Archetype.defender: ArchetypeDefinition(
      archetype: Archetype.defender,
      name: 'Golem',
      displayName: 'Défenseur',
      basePersonality: Personality(
        aggressivity: 0.1,
        diplomacy: 0.4,
        expansion: 0.1,
        economy: 0.8,
        cunning: 0.3,
      ),
      description: 'Fortifications massives, stable',
    ),
  };
}
