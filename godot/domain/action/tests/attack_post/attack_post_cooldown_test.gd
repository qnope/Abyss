extends TestCase
## test/domain/action/attack_post/attack_post_cooldown_test.dart: the rest
## an attacker gives the posts of a player between two attacks.

const FAILLE := TransitionBaseType.Value.FAILLE
const HARPOONIST := UnitType.Value.HARPOONIST
const HORDE := PostWar.HORDE


## A war at turn 40 where `by` last attacked the posts of the owner `ago`
## turns before.
func _war(by: Callable, ago: int, human_holds := false) -> PostWar:
	var war := PostWar.new(FAILLE, 7, human_holds)
	war.game.turn = 40
	var attacker: Player = by.call(war)
	war.arm(attacker)
	attacker.raid_state.post_attack_turns[war.owner().id] = 40 - ago
	return war


func _refusal(war: PostWar, attacker: Player) -> Variant:
	return war.strike(HORDE).validate(war.game, attacker).reason


func _attacker(w: PostWar) -> Player:
	return w.attacker()


func _human(w: PostWar) -> Player:
	return w.human()


func test_a_faction_waits_the_cooldown_before_attacking_the_human_again() -> void:
	var soon := _war(_attacker, 3, true)
	var late := _war(_attacker, 4, true)
	assert_eq(AttackCooldown.TURNS, 4)
	assert_eq(_refusal(soon, soon.attacker()), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_refusal(late, late.attacker()))


func test_a_faction_waits_the_cooldown_before_attacking_a_faction_again() -> void:
	var soon := _war(_attacker, 1)
	var late := _war(_attacker, 4)
	assert_eq(_refusal(soon, soon.attacker()), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_refusal(late, late.attacker()))


func test_the_human_waits_the_cooldown_before_attacking_a_faction_again() -> void:
	var soon := _war(_human, 3)
	var late := _war(_human, 4)
	assert_eq(_refusal(soon, soon.human()), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_refusal(late, late.human()))


func test_another_attacker_may_strike_the_very_next_turn() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	war.game.turn = 40
	war.arm(war.attacker(), {HARPOONIST: 6})
	war.put(war.human(), war.below(), PostWar.WALL)
	ActionExecutor.new().execute(war.strike({HARPOONIST: 6}), war.game, war.attacker())
	var other: Player = war.game.players[war.game.factions()[1].id()]
	other.add_revealed_cell(war.level, war.at)
	war.arm(other)
	war.game.turn = 41
	assert_eq(_refusal(war, war.attacker()), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_refusal(war, other))


func test_an_attack_starts_the_cooldown_whatever_its_outcome() -> void:
	var won := PostWar.new(FAILLE, 7, true)
	won.game.turn = 40
	won.arm(won.attacker())
	var lost := PostWar.new(FAILLE, 7, true)
	lost.game.turn = 40
	lost.arm(lost.attacker(), {HARPOONIST: 6})
	lost.put(lost.human(), lost.below(), PostWar.WALL)
	ActionExecutor.new().execute(won.strike(HORDE), won.game, won.attacker())
	ActionExecutor.new().execute(lost.strike({HARPOONIST: 6}), lost.game, lost.attacker())
	assert_eq(won.post.captured_by, won.attacker().id)
	assert_eq(lost.post.captured_by, lost.human().id)
	assert_eq(won.attacker().raid_state.post_attack_turns, {won.human().id: 40})
	assert_eq(lost.attacker().raid_state.post_attack_turns, {lost.human().id: 40})


func test_the_kernel_cooldown_leaves_the_posts_alone() -> void:
	var war := PostWar.new(FAILLE)
	war.game.turn = 40
	war.arm(war.attacker())
	war.attacker().raid_state.kernel_attack_turns[war.owner().id] = 40
	assert_null(_refusal(war, war.attacker()))
