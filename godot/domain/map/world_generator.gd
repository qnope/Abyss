class_name WorldGenerator
extends RefCounted
## lib/domain/map/world_generator.dart: generates every level of a map at
## once.

const LEVELS: Array[int] = [1, 2, 3]


## The levels, each one holding the transition bases of the one above as
## passages, as the descent generates them one by one. Level 1 is what
## `MapGenerator.generate` gives for the seed (an int, or null to draw one);
## the others get a seed drawn from it, `Random(seed + level)`. A number of
## players Dart throws for gives a world without any level.
static func generate(
	seed_: Variant = null, player_count := 1
) -> Dictionary[int, MapGenerationResult]:
	var actual_seed: int = (
		seed_ if seed_ != null else DartRandom.unseeded().next_int(0x7FFFFFFF)
	)
	var world: Dictionary[int, MapGenerationResult] = {}
	for level: int in LEVELS:
		var level_seed := actual_seed
		var reserved_passages: Dictionary[Vector2i, String] = {}
		if level != 1:
			level_seed = DartRandom.new(actual_seed + level).next_int(0x7FFFFFFF)
			reserved_passages = PassageExtractor.from(world[level - 1].map)
		var result := MapGenerator.generate(level_seed, level, reserved_passages, player_count)
		if result == null:
			return world
		world[level] = result
	return world
