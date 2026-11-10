class_name MonsterRules
extends RefCounted
## lib/domain/fight/monster_rules.dart: combat rules of the monster families
## (see MonsterFamily).

## Damage multiplier of a hunter against a unit that does not taunt.
const HUNT_MULTIPLIER := 2
## `UnitType.harpoonist.name`, a constant so that a blow reads no enum name;
## its test holds it to the Dart name.
const HARPOONIST_KEY := "harpoonist"

const _HUNTER := MonsterFamily.Value.HUNTER
const _SWARM := MonsterFamily.Value.SWARM
const _KRAKEN := MonsterFamily.Value.KRAKEN


## The family of `c` (a MonsterFamily.Value), null for a unit.
static func family_of(c: Combatant) -> Variant:
	return c.family


## Traque: hunters go for the frailest unit.
static func hunts(attacker: Combatant) -> bool:
	return attacker.family == _HUNTER


## Damage multiplier the family rules give `attacker` against `target`.
static func multiplier(attacker: Combatant, target: Combatant) -> int:
	if attacker.family == _HUNTER and target.role != CombatRole.Value.TAUNT:
		return HUNT_MULTIPLIER
	return 1


## The frailest alive combatant of `pool`, null when none stands: the first
## of those as frail.
static func frailest(pool: Array[Combatant]) -> Combatant:
	var best: Combatant = null
	for c: Combatant in pool:
		if c.current_hp <= 0:
			continue
		if best == null or c.current_hp < best.current_hp:
			best = c
	return best


## Essaim: a Harponneur's hit on a swarm fish also strikes another fish of
## the swarm, picked at random. Null when the hit does not sweep or no
## other fish stands.
static func sweep_target(
	attacker: Combatant, target: Combatant, pool: Array[Combatant], random: DartRandom
) -> Combatant:
	return sweep_target_in(attacker, target, AliveIndex.new(pool), random)


## `sweep_target` through the AliveIndex of the pool.
static func sweep_target_in(
	attacker: Combatant, target: Combatant, pool: AliveIndex, random: DartRandom
) -> Combatant:
	if attacker.type_key != HARPOONIST_KEY or target.family != _SWARM:
		return null
	var others := pool.swarm_except(target)
	if others == 0:
		return null
	return pool.nth_swarm_except(random.next_int(others), target)


## Étreinte: a kraken's tentacles also strike another defender, picked at
## random. Null when `attacker` is no kraken or no one else stands.
static func embrace_target(
	attacker: Combatant, target: Combatant, pool: Array[Combatant], random: DartRandom
) -> Combatant:
	return embrace_target_in(attacker, target, AliveIndex.new(pool), random)


## `embrace_target` through the AliveIndex of the pool.
static func embrace_target_in(
	attacker: Combatant, target: Combatant, pool: AliveIndex, random: DartRandom
) -> Combatant:
	if attacker.family != _KRAKEN:
		return null
	var others := pool.alive_except(target)
	if others == 0:
		return null
	return pool.nth_alive_except(random.next_int(others), target)


## Second combatant `attacker`'s hit on `target` strikes, by the Essaim or
## Étreinte rule, or null.
static func second_target(
	attacker: Combatant, target: Combatant, pool: Array[Combatant], random: DartRandom
) -> Combatant:
	return second_target_in(attacker, target, AliveIndex.new(pool), random)


## `second_target` through the AliveIndex of the pool. A swarm fish is no
## kraken, so at most one of the two rules draws.
static func second_target_in(
	attacker: Combatant, target: Combatant, pool: AliveIndex, random: DartRandom
) -> Combatant:
	if attacker.family != _KRAKEN and attacker.type_key != HARPOONIST_KEY:
		return null  # Neither rule applies: the fight's most common blow, answered at once.
	var swept := sweep_target_in(attacker, target, pool, random)
	if swept != null:
		return swept
	return embrace_target_in(attacker, target, pool, random)
