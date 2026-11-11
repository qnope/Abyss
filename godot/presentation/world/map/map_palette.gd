class_name MapPalette
extends RefCounted
## The colours of the map's stand-ins, told apart at a glance on a small
## screen: a floor per terrain, the dark of the fog, and one colour per kind of
## content. A post and its passage take the colour of who holds them, the
## volcano's seal that of its owner (given by `app/`, which knows the
## factions). Like [WorldPalette] this layer never reads the interface's.

## The floor of each terrain; the sea floor has one kind, the plain.
const TERRAINS: Dictionary[TerrainType.Value, Color] = {
	TerrainType.Value.PLAIN: Color("3f6377"),
}
## The floor of a cell not seen yet, dark under the water.
const FOG := Color("0a111d")
## How much lighter every other tile is, so that the grid reads.
const CHECKER := 0.06

const TREASURE := Color("ffd740")
const RUINS := Color("d7ccc8")
const WRECK := Color("ff8a65")
## The lairs: the deeper the redder.
const LAIRS: Dictionary[MonsterDifficulty.Value, Color] = {
	MonsterDifficulty.Value.EASY: Color("ff8a80"),
	MonsterDifficulty.Value.MEDIUM: Color("ff5252"),
	MonsterDifficulty.Value.HARD: Color("b71c1c"),
}
const KERNEL := Color("ff6d00")
## The player's own base, in the cyan of its posts.
const HOME := Color("00e5ff")
## A faction's base with no colour given.
const FACTION := Color("ff80ab")
## A post, and the passage under it: its guardians' grey, the player's green,
## a faction's pink.
const HOLDERS: Dictionary[PostHolder.Value, Color] = {
	PostHolder.Value.GUARDIANS: Color("90a4ae"),
	PostHolder.Value.HUMAN: Color("69f0ae"),
	PostHolder.Value.FACTION: Color("ff80ab"),
}
