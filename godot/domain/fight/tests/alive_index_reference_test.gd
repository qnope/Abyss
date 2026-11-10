extends TestCase
## test/domain/fight/alive_index_reference_test.dart: the picks through an
## AliveIndex draw what the list-based picks drew, die for die. The 200 tests
## Dart generates by seed are one test that loops.

const UNIT_KEYS: Array[String] = ["guardian", "harpoonist", "scout"]
const MONSTER_KEYS: Array[String] = ["swarmL1", "hunterL1", "armouredL2"]

var _hunter := _of(CombatSide.Value.MONSTER, "hunterL1")
var _harpoonist := _of(CombatSide.Value.PLAYER, "harpoonist")
var _kraken := _of(CombatSide.Value.MONSTER, "krakenL1")


func _of(side: CombatSide.Value, key: String, hp := 10) -> Combatant:
	return Combatant.new(side, key, hp, 3, 0)


## A pool of 1 to 40 combatants of one side, a third of them dead.
func _random_pool(gen: DartRandom) -> Array[Combatant]:
	var side := CombatSide.Value.PLAYER if gen.next_bool() else CombatSide.Value.MONSTER
	var keys := UNIT_KEYS if side == CombatSide.Value.PLAYER else MONSTER_KEYS
	var pool: Array[Combatant] = []
	for _i: int in 1 + gen.next_int(40):
		var key := keys[gen.next_int(3)]
		var c := _of(side, key, 1 + gen.next_int(20))
		if gen.next_int(3) == 0:
			c.apply_damage(999)
		pool.append(c)
	return pool


## The list-based pick, kept as the reference the index must match.
func _reference_pick(pool: Array[Combatant], random: DartRandom, by: Combatant) -> Combatant:
	var taunting := pool.filter(
		func(c: Combatant) -> bool: return c.is_alive() and c.role == CombatRole.Value.TAUNT
	)
	if not taunting.is_empty():
		return taunting[random.next_int(taunting.size())]
	if by != null and by.family == MonsterFamily.Value.HUNTER:
		return MonsterRules.frailest(pool)
	var alive := pool.filter(func(c: Combatant) -> bool: return c.is_alive())
	if alive.is_empty():
		return null
	return alive[random.next_int(alive.size())]


## The list-based second target: another alive combatant that `keeps`.
func _reference_other(
	pool: Array[Combatant], target: Combatant, random: DartRandom, keeps: Callable
) -> Combatant:
	var others := pool.filter(
		func(c: Combatant) -> bool: return c.is_alive() and c != target and keeps.call(c)
	)
	if others.is_empty():
		return null
	return others[random.next_int(others.size())]


## The list-based Essaim rule for a Harponneur's hit on `target`.
func _reference_sweep(pool: Array[Combatant], target: Combatant, random: DartRandom) -> Combatant:
	if target.family != MonsterFamily.Value.SWARM:
		return null
	return _reference_other(pool, target, random, _swarms)


func _swarms(c: Combatant) -> bool:
	return c.family == MonsterFamily.Value.SWARM


func _anyone(_c: Combatant) -> bool:
	return true


## Wounds `target` as the engine would, burying it in `index` if it falls.
func _wound(target: Combatant, index: AliveIndex, gen: DartRandom) -> void:
	target.apply_damage(999 if gen.next_bool() else 1)
	if not target.is_alive():
		index.bury(target)


func test_alive_index_draws_match_the_list_based_references() -> void:
	for seed_: int in range(1, 201):
		var gen := DartRandom.new(seed_)
		var pool := _random_pool(gen)
		var index := AliveIndex.new(pool)
		var actual := DartRandom.new(seed_ * 31)
		var expected := DartRandom.new(seed_ * 31)
		for _round: int in 12:
			var by: Combatant = _hunter if gen.next_bool() else null
			var target := TargetPicker.pick_from(index, actual, by)
			assert_eq(target, _reference_pick(pool, expected, by), "seed %d" % seed_)
			if target == null:
				break
			_wound(target, index, gen)
			var swept := MonsterRules.sweep_target_in(_harpoonist, target, index, actual)
			assert_eq(swept, _reference_sweep(pool, target, expected), "seed %d" % seed_)
			var embraced := MonsterRules.embrace_target_in(_kraken, target, index, actual)
			var other := _reference_other(pool, target, expected, _anyone)
			assert_eq(embraced, other, "seed %d" % seed_)
			if embraced != null:
				_wound(embraced, index, gen)
		assert_eq(actual.next_int(1 << 20), expected.next_int(1 << 20), "seed %d" % seed_)


func test_pick_random_from_matches_pick_random_draw_for_draw() -> void:
	var pool := _random_pool(DartRandom.new(5))
	var index := AliveIndex.new(pool)
	var actual := DartRandom.new(9)
	var expected := DartRandom.new(9)
	for _i: int in 50:
		var picked := TargetPicker.pick_random_from(index, actual)
		assert_eq(picked, TargetPicker.pick_random(pool, expected))
