class_name MapContent
extends RefCounted
## What stands on a cell of the map until its model exists: a kind of
## content, its [StandInShape] (a solid told from the others by its kind and
## its proportions, in metres on a cell 1 wide) and its colour
## ([MapPalette]). [WorldModels.map_content] is the one place that turns a kind
## into something to look at; step 7 adds models there.
##
## The contents the domain has: a treasure, ruins and a wreck, a lair of each
## difficulty, a Faille and a Cheminée (posts), the passage that arrives under
## a post, the volcanic kernel, and the bases: the player's own and a rival's.

const Solid := StandInShape.Kind

enum Kind {
	TREASURE, RUINS, WRECK, LAIR_EASY, LAIR_MEDIUM, LAIR_HARD,
	FAILLE, CHEMINEE, PASSAGE, KERNEL, HOME, FACTION_BASE,
}


## The solid of [param kind].
static func shape_of(kind: Kind) -> StandInShape:
	match kind:
		Kind.TREASURE:
			return StandInShape.new(Solid.BOX, Vector3(0.5, 0.34, 0.38))
		Kind.RUINS:
			return StandInShape.new(Solid.CYLINDER, Vector3(0.42, 0.75, 0.42), 0.6)
		Kind.WRECK:
			return StandInShape.new(Solid.PRISM, Vector3(0.85, 0.4, 0.5))
		Kind.LAIR_EASY:
			return StandInShape.new(Solid.PRISM, Vector3(0.5, 0.6, 0.5))
		Kind.LAIR_MEDIUM:
			return StandInShape.new(Solid.PRISM, Vector3(0.6, 0.95, 0.6))
		Kind.LAIR_HARD:
			return StandInShape.new(Solid.PRISM, Vector3(0.7, 1.3, 0.7))
		Kind.FAILLE:
			return StandInShape.new(Solid.TORUS, Vector3(0.85, 0.2, 0.85))
		Kind.CHEMINEE:
			return StandInShape.new(Solid.CYLINDER, Vector3(0.6, 1.0, 0.6), 0.45)
		Kind.PASSAGE:
			return StandInShape.new(Solid.CYLINDER, Vector3(0.7, 0.1, 0.7))
		Kind.KERNEL:
			return StandInShape.new(Solid.SPHERE, Vector3(1.7, 1.7, 1.7))
		Kind.HOME:
			return StandInShape.new(Solid.CYLINDER, Vector3(0.8, 1.1, 0.8), 0.75)
	return StandInShape.new(Solid.CAPSULE, Vector3(0.6, 1.0, 0.6))


## The colour of [param kind] when nobody tints it.
static func colour_of(kind: Kind) -> Color:
	match kind:
		Kind.TREASURE:
			return MapPalette.TREASURE
		Kind.RUINS:
			return MapPalette.RUINS
		Kind.WRECK:
			return MapPalette.WRECK
		Kind.LAIR_EASY:
			return MapPalette.LAIRS[MonsterDifficulty.Value.EASY]
		Kind.LAIR_MEDIUM:
			return MapPalette.LAIRS[MonsterDifficulty.Value.MEDIUM]
		Kind.LAIR_HARD:
			return MapPalette.LAIRS[MonsterDifficulty.Value.HARD]
		Kind.FAILLE, Kind.CHEMINEE, Kind.PASSAGE:
			return MapPalette.HOLDERS[PostHolder.Value.GUARDIANS]
		Kind.KERNEL:
			return MapPalette.KERNEL
		Kind.HOME:
			return MapPalette.HOME
	return MapPalette.FACTION


## The kind of a lair of [param difficulty].
static func lair_of(difficulty: MonsterDifficulty.Value) -> Kind:
	match difficulty:
		MonsterDifficulty.Value.EASY:
			return Kind.LAIR_EASY
		MonsterDifficulty.Value.MEDIUM:
			return Kind.LAIR_MEDIUM
	return Kind.LAIR_HARD
