class_name ConquestMoves
extends RefCounted
## lib/domain/script/strategies/conquest_moves.dart: the road to the volcano,
## a Faille on the base level, a Cheminée on level 2, then the volcanic
## kernel at the centre of level 3. The Dart extension on ScriptTurn.
##
## Only its constants so far, which the scouts read: `advanceConquest` waits
## for `ExpeditionMoves.assault` and for `SiegeMoves` (domain/README.md,
## "Left for a later lot").

## Units of an assault force: Gardiens to hold, hitters to break (mixes of
## RecruitMoves).
const ASSAULT_MIXES: Array[Dictionary] = [
	{UnitType.Value.GUARDIAN: 1, UnitType.Value.DOME_BREAKER: 1},
	{UnitType.Value.GUARDIAN: 1, UnitType.Value.HARPOONIST: 1},
	{UnitType.Value.HARPOONIST: 1},
]

## Scouts an expedition takes down to explore the level below.
const EXPEDITION_SCOUTS := 4
