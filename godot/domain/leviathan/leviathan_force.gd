class_name LeviathanForce
extends RefCounted
## lib/domain/leviathan/leviathan_force.dart: the guardians that come back to
## the human's first Faille: a Léviathan and SENTINELS Sentinelles, those of
## a Faille (GuardianFactory), scaled like the other monsters of the game.
## They attack, so they fight on the player's side of the engine, the
## defenders on the other.

## Sentinelles at the Léviathan's side, one less than on a Faille.
const SENTINELS := 4

## Type keys of the force, as the fight and the reports name them.
const LEVIATHAN_KEY := "leviathan"
const SENTINEL_KEY := "sentinelle"

## Name of the attacker in the history and the end-of-turn reports.
const ATTACKER_NAME := LEVIATHAN_KEY

## How many of each kind come.
const COUNTS: Dictionary[String, int] = {
	LEVIATHAN_KEY: 1,
	SENTINEL_KEY: SENTINELS,
}


## The share of their strength the monsters keep against the human in
## `game`, in percent (see Difficulty.monster_percent_for).
static func percent_of(game: Game) -> int:
	return Difficulty.monster_percent_for(game.difficulty(), false, game.factions().size())


## The force that strikes in `game`.
static func of(game: Game) -> Array[Combatant]:
	return combatants(percent_of(game))


## The force, its health and attack scaled by `monster_percent`.
static func combatants(monster_percent := 100) -> Array[Combatant]:
	var faille := GuardianFactory.for_faille()
	var leviathan: Combatant = faille.filter(func(c: Combatant) -> bool: return c.is_boss)[0]
	var sentinel: Combatant = faille.filter(func(c: Combatant) -> bool: return not c.is_boss)[0]
	var force: Array[Combatant] = [_scaled(leviathan, monster_percent)]
	for _i: int in SENTINELS:
		force.append(_scaled(sentinel, monster_percent))
	return force


static func _scaled(c: Combatant, percent: int) -> Combatant:
	return Combatant.new(
		CombatSide.Value.PLAYER, c.type_key, DartMath.trunc_div(c.max_hp * percent, 100),
		DartMath.trunc_div(c.atk * percent, 100), c.def, null, c.is_boss,
	)
