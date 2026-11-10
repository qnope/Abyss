extends TestCase
## test/domain/action/fight_monster_action_military_bonus_test.dart: the
## military research boosts the units that attack a lair.

const HARPOONIST := UnitType.Value.HARPOONIST


func _first(game: Game) -> Combatant:
	var action := FightMonsterAction.new(1, 1, 1, {HARPOONIST: 1}, DartRandom.new(0))
	var result: FightMonsterResult = action.execute(game, game.human_player())
	return result.fight.initial_player_combatants[0]


func _base() -> UnitStats:
	return UnitStats.for_type(HARPOONIST)


func test_fight_monster_action_military_bonus_combatant_atk_reflects_player_military_level() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 1}, 3)
	# 2 tiers (+40%) + Lames de corail (+35%, option A by default).
	assert_eq(_first(game).atk, roundi(_base().atk * 1.75))


func test_fight_monster_action_military_bonus_carapace_de_nacre_and_assaut_boost_hp_and_attacking_atk() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 1}, 4)
	game.human_player().tech_branches[TechBranch.Value.MILITARY].choices = [TechOption.Value.B as int, TechOption.Value.B as int]
	var unit := _first(game)
	assert_eq(unit.atk, roundi(_base().atk * 1.75)) # 40% tiers + 35% Assaut
	assert_eq(unit.max_hp, roundi(_base().hp * 1.35))
	assert_eq(unit.def, roundi(_base().def * 1.4))


func test_fight_monster_action_military_bonus_level_0_leaves_atk_unchanged() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 1}, 0)
	assert_eq(_first(game).atk, _base().atk)


func test_fight_monster_action_military_bonus_unlocked_false_yields_no_bonus() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 1})
	var military: TechBranchState = game.human_player().tech_branches[TechBranch.Value.MILITARY]
	military.unlocked = false
	military.research_level = 5
	assert_eq(_first(game).atk, _base().atk)


func test_fight_monster_action_military_bonus_monster_combatants_are_unaffected() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, {HARPOONIST: 1}, 3)
	_first(game)
	var monsters := CombatantBuilder.monster_combatants_from(game.levels[1].cell_at(1, 1).lair)
	assert_false(monsters.is_empty())
	for c: Combatant in monsters:
		assert_eq(c.atk, MonsterUnitStats.for_level(1).atk)
