class_name FightEngine
extends RefCounted
## lib/domain/fight/fight_engine.dart: turn-by-turn fight resolver.
##
## Given two camps of Combatants, loops turn by turn until one camp has no
## alive combatant left, then returns a FightResult. The turn order, the
## targets and the second blows draw from one die, the crits from the die
## of the CritRoller, which is the same one when the engine is given a die.

const _PLAYER := CombatSide.Value.PLAYER

var _random: DartRandom
var _crit_roller: CritRoller


## Without `random_`, the engine rolls a die of its own and its crits
## another, as `FightEngine()` does in Dart.
func _init(random_: DartRandom = null, crit_chance := 0.05) -> void:
	_random = random_ if random_ != null else DartRandom.unseeded()
	_crit_roller = CritRoller.new(crit_chance, random_)


func resolve(player_side: Array[Combatant], monster_side: Array[Combatant]) -> FightResult:
	var initial_player_combatants: Array[Combatant] = []
	for c: Combatant in player_side:
		initial_player_combatants.append(
			Combatant.new(c.side, c.type_key, c.max_hp, c.atk, c.def, c.max_hp, c.is_boss)
		)
	var initial_monster_count := monster_side.size()
	var players := AliveIndex.new(player_side)
	var monsters := AliveIndex.new(monster_side)
	# Running HP totals: every point of damage goes through _hit, whose
	# applied amount is what the turn stats accumulate for the other side.
	var player_hp := _sum_hp(player_side)
	var monster_hp := _sum_hp(monster_side)

	var summaries: Array[FightTurnSummary] = []
	var turn_number := 0
	while players.alive() > 0 and monsters.alive() > 0:
		turn_number += 1
		var stats := _run_turn(players, monsters)
		player_hp -= stats.dmg_monster
		monster_hp -= stats.dmg_player
		summaries.append(FightTurnSummary.new(
			turn_number, stats.attacks, stats.crits, stats.dmg_player, stats.dmg_monster,
			players.alive(), monsters.alive(), player_hp, monster_hp,
		))

	return FightResult.new(
		_PLAYER if players.alive() > 0 else CombatSide.Value.MONSTER,
		turn_number,
		summaries,
		initial_player_combatants,
		player_side,
		initial_monster_count,
		monsters.alive(),
	)


func _run_turn(players: AliveIndex, monsters: AliveIndex) -> FightTurnStats:
	var stats := FightTurnStats.new()
	var order := TurnOrder.shuffle(players.pool, monsters.pool, _random)
	for attacker: Combatant in order:
		if attacker.current_hp <= 0:
			continue
		var pool := monsters if attacker.side == _PLAYER else players
		var target := TargetPicker.pick_from(pool, _random, attacker)
		if target == null:
			break
		var crit := _crit_roller.roll()
		if crit:
			stats.crits += 1
		var applied := _hit(target, AttackDamage.compute(attacker, target, crit), pool)
		var swept := MonsterRules.second_target_in(attacker, target, pool, _random)
		if swept != null:
			applied += _hit(swept, AttackDamage.compute(attacker, swept), pool)
		stats.attacks += 1
		if attacker.side == _PLAYER:
			stats.dmg_player += applied
		else:
			stats.dmg_monster += applied
	return stats


## Deals `damage` to `target` and buries it in `pool` if it falls.
static func _hit(target: Combatant, damage: int, pool: AliveIndex) -> int:
	var applied := target.apply_damage(damage)
	if target.current_hp <= 0:
		pool.bury(target)
	return applied


static func _sum_hp(side: Array[Combatant]) -> int:
	var hp := 0
	for c: Combatant in side:
		hp += c.current_hp
	return hp
