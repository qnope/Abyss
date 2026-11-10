extends TestCase
## test/domain/fight/fight_engine_summary_test.dart: the summaries of the
## turns of one fight, against the fighters it leaves.

var _players: Array[Combatant]
var _monsters: Array[Combatant]
var _initial_player_hp: int
var _initial_monster_hp: int
var _result: FightResult


func before_each() -> void:
	_players = _side(CombatSide.Value.PLAYER, 6, 40, 9, 3)
	_players[2].current_hp = 10
	_monsters = _side(CombatSide.Value.MONSTER, 7, 35, 8, 2)
	_initial_player_hp = _hp_of(_players)
	_initial_monster_hp = _hp_of(_monsters)
	_result = FightEngine.new(DartRandom.new(2024)).resolve(_players, _monsters)


func _side(side: CombatSide.Value, count: int, hp: int, atk: int, def: int) -> Array[Combatant]:
	var name := DartEnum.name_of(CombatSide.Value, side)
	var fighters: Array[Combatant] = []
	for i: int in count:
		fighters.append(Combatant.new(side, "%s%d" % [name, i], hp, atk, def))
	return fighters


func _alive_of(side: Array[Combatant]) -> int:
	return side.filter(func(c: Combatant) -> bool: return c.is_alive()).size()


func _hp_of(side: Array[Combatant]) -> int:
	var hp := 0
	for c: Combatant in side:
		hp += c.current_hp
	return hp


func test_the_fight_lasts_several_turns() -> void:
	assert_true(_result.turn_count > 3)
	assert_eq(_result.turn_summaries.size(), _result.turn_count)


func test_the_last_turn_counters_match_the_final_combatants() -> void:
	var last: FightTurnSummary = _result.turn_summaries.back()

	assert_eq(last.player_alive_at_end, _alive_of(_players))
	assert_eq(last.monster_alive_at_end, _alive_of(_monsters))
	assert_eq(last.player_hp_at_end, _hp_of(_players))
	assert_eq(last.monster_hp_at_end, _hp_of(_monsters))
	assert_eq(_result.final_monster_count, _alive_of(_monsters))


func test_each_turn_removes_exactly_the_damage_dealt_by_the_other_side() -> void:
	var player_hp := _initial_player_hp
	var monster_hp := _initial_monster_hp
	for s: FightTurnSummary in _result.turn_summaries:
		player_hp -= s.damage_dealt_by_monster
		monster_hp -= s.damage_dealt_by_player
		assert_eq(s.player_hp_at_end, player_hp, "turn %d" % s.turn_number)
		assert_eq(s.monster_hp_at_end, monster_hp, "turn %d" % s.turn_number)


func test_alive_counts_and_hp_totals_never_increase() -> void:
	var before := _result.turn_summaries[0]
	assert_true(before.player_alive_at_end <= _players.size())
	assert_true(before.monster_alive_at_end <= _monsters.size())
	for s: FightTurnSummary in _result.turn_summaries.slice(1):
		assert_true(s.player_alive_at_end <= before.player_alive_at_end)
		assert_true(s.monster_alive_at_end <= before.monster_alive_at_end)
		assert_true(s.player_hp_at_end <= before.player_hp_at_end)
		assert_true(s.monster_hp_at_end <= before.monster_hp_at_end)
		before = s
