import '../../../domain/map/monster_difficulty.dart';
import '../../../domain/map/monster_family.dart';
import '../../extensions/monster_family_extensions.dart';

/// Lairs dangerous enough for their monsters to come alive on the map.
const livingDifficulties = {MonsterDifficulty.hard};

/// Sprites of the map that undulate as living creatures instead of only
/// bobbing: the kraken and the lairs of [livingDifficulties], of every
/// family and of the generic monsters.
final Set<String> livingCreatureSprites = {
  for (final family in <MonsterFamily?>[null, ...MonsterFamily.values])
    for (final difficulty in livingDifficulties) family.svgPathAt(difficulty),
};

/// Whether the content drawn with [sprite] is a living creature.
bool isLivingCreature(String? sprite) =>
    sprite != null && livingCreatureSprites.contains(sprite);
