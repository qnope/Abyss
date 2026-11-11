extends TestCase
## test/domain/faction/faction_post_war_cooldown_test.dart: a faction spares
## the posts of a player it attacked a few turns before.


## The human holds the Faille, the faction stands ready; it last attacked
## the human's posts `ago` turns before (never when null).
static func _scene(ago: Variant = null) -> PostWar:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	war.game.turn = 40
	war.arm(war.attacker())
	if ago != null:
		var turns_ago: int = ago
		war.attacker().raid_state.post_attack_turns[war.human().id] = 40 - turns_ago
	return war


static func _play(war: PostWar) -> bool:
	return FactionPostWar.play(
		FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false)),
		ArmyPlanner.new(),
	)


## Another Faille of level 1, given to the second faction and shown to the
## attacker.
static func _second_post(war: PostWar) -> TransitionBase:
	var map: GameMap = war.game.levels[war.level]
	var rival: Player = war.game.players[war.game.factions()[1].id()]
	for y: int in map.height:
		for x: int in map.width:
			var base := map.cell_at(x, y).transition_base
			if base == null or base == war.post or base.type != TransitionBaseType.Value.FAILLE:
				continue
			base.captured_by = rival.id
			rival.buildings[war.passage()] = war.human().buildings[war.passage()]
			war.attacker().add_revealed_cell(war.level, GridPosition.new(x, y))
			return base
	return null


func test_it_leaves_alone_a_post_of_the_human_on_cooldown() -> void:
	var war := _scene(3)

	assert_false(_play(war))
	assert_eq(war.post.captured_by, war.human().id)
	assert_eq(War.assaults(war.attacker()).size(), 0)


func test_it_turns_to_another_target_instead_of_wasting_the_turn() -> void:
	var war := _scene(1)
	var other := _second_post(war)

	assert_true(_play(war))
	assert_eq(war.post.captured_by, war.human().id)
	assert_eq(other.captured_by, war.attacker().id)


func test_it_takes_the_post_of_the_human_again_once_the_cooldown_is_over() -> void:
	var war := _scene(4)

	assert_true(_play(war))
	assert_eq(war.post.captured_by, war.attacker().id)
	assert_eq(war.attacker().raid_state.post_attack_turns, {war.human().id: 40})
