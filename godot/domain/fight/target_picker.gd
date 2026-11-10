class_name TargetPicker
extends RefCounted
## lib/domain/fight/target_picker.dart: who an attacker strikes.


static func pick_random(pool: Array[Combatant], random: DartRandom) -> Combatant:
	return pick_random_from(AliveIndex.new(pool), random)


## A random alive combatant of `index`, null when none stands.
static func pick_random_from(index: AliveIndex, random: DartRandom) -> Combatant:
	var alive := index.alive()
	if alive == 0:
		return null
	return index.nth_alive(random.next_int(alive))


## Picks a random alive target, restricted to taunting combatants when at
## least one of them still stands. A hunting `attacker` goes for the
## frailest target instead of a random one.
static func pick(pool: Array[Combatant], random: DartRandom, attacker: Combatant = null) -> Combatant:
	return pick_from(AliveIndex.new(pool), random, attacker)


## `pick` through an AliveIndex the caller keeps up to date.
static func pick_from(index: AliveIndex, random: DartRandom, attacker: Combatant = null) -> Combatant:
	var taunting := index.taunting()
	if taunting > 0:
		return index.nth_taunting(random.next_int(taunting))
	if attacker != null and MonsterRules.hunts(attacker):
		return MonsterRules.frailest(index.pool)
	return pick_random_from(index, random)
