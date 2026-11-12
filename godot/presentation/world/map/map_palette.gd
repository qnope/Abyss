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

## The effects: the white flash of a blow, the damage floating up (the interface's
## error red, which a test in app/ holds together with this one), the cyan of a
## place taken and of the shield that holds a siege back, the red of its alert
## and of the attackers breaking in, the pearl of the army's count.
const FLASH := Color("ffffff")
const DAMAGE := Color("ff5252")
const CAPTURE := Color("00e5ff")
const SHIELD := Color("00e5ff")
const ALERT := Color("ff5252")
const COUNT := Color("e0f7fa")
const COUNT_OUTLINE := WorldPalette.LEVEL_OUTLINE
