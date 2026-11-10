extends TestCase
## test/domain/action/attack_post/attack_post_validate_test.dart: whether a
## player may attack a post another player holds.

const FAILLE := TransitionBaseType.Value.FAILLE
const HARPOONIST := UnitType.Value.HARPOONIST
const HORDE := PostWar.HORDE


func _ready_war(kind := FAILLE) -> PostWar:
	var war := PostWar.new(kind)
	war.arm(war.attacker())
	return war


func _reason(war: PostWar, player: Player, army: Dictionary[UnitType.Value, int] = HORDE) -> Variant:
	return war.strike(army).validate(war.game, player).reason


func test_a_post_held_by_a_rival_can_be_attacked() -> void:
	for kind: TransitionBaseType.Value in TransitionBaseType.Value.values():
		var war := _ready_war(kind)
		assert_true(war.strike(HORDE).validate(war.game, war.attacker()).is_success, str(kind))


func test_the_army_comes_from_the_units_of_the_level_of_the_post() -> void:
	var war := PostWar.new(TransitionBaseType.Value.CHEMINEE)
	war.put(war.attacker(), 1, HORDE)
	assert_eq(_reason(war, war.attacker()), ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_an_army_must_have_at_least_one_unit() -> void:
	var war := _ready_war()
	assert_eq(_reason(war, war.attacker(), {HARPOONIST: 0}), ActionFailure.Value.NO_UNIT_SELECTED)


func test_a_free_post_is_not_attacked_it_is_captured() -> void:
	var war := _ready_war()
	war.post.captured_by = null
	assert_eq(_reason(war, war.attacker()), ActionFailure.Value.BASE_NOT_CAPTURED)


func test_a_player_cannot_attack_its_own_post() -> void:
	var war := _ready_war()
	war.post.captured_by = war.attacker().id
	assert_eq(_reason(war, war.attacker()), ActionFailure.Value.CANNOT_ATTACK_SELF)


func test_a_cell_that_is_not_a_post_is_refused() -> void:
	var war := _ready_war()
	var blank := AttackPostAction.new(war.at.x, war.at.y, 3, HORDE)
	assert_eq(blank.validate(war.game, war.attacker()).reason, ActionFailure.Value.NO_TRANSITION_BASE_HERE)


func test_a_post_of_an_owner_who_fell_is_refused() -> void:
	var war := _ready_war()
	war.owner().saved_fallen = true
	assert_eq(_reason(war, war.attacker()), ActionFailure.Value.PLAYER_FALLEN)


func test_nobody_attacks_a_post_before_the_first_raid_turn() -> void:
	var war := _ready_war()
	war.game.turn = 5
	assert_eq(_reason(war, war.attacker()), ActionFailure.Value.ATTACK_TOO_EARLY)


func test_the_human_must_have_seen_the_post_a_faction_need_not() -> void:
	var war := PostWar.new(FAILLE)
	war.owner().revealed_cells_per_level[1] = [] as Array[GridPosition]
	war.human().revealed_cells_per_level[1] = [] as Array[GridPosition]
	war.arm(war.human())
	war.arm(war.attacker())
	assert_eq(_reason(war, war.human()), ActionFailure.Value.BASE_NOT_REVEALED)
	assert_true(war.strike(HORDE).validate(war.game, war.attacker()).is_success)


func test_it_is_the_attack_post_action() -> void:
	var war := _ready_war()
	assert_eq(war.strike(HORDE).type(), ActionType.Value.ATTACK_POST)
	assert_true(war.strike(HORDE).description().begins_with("Attaque poste ("))


## Not in the Dart file: the refusals the Dart tests leave unchecked, and
## the description in full.
func test_the_refusals_no_dart_test_reaches() -> void:
	var war := _ready_war()
	var nowhere := AttackPostAction.new(war.at.x, war.at.y, 9, HORDE)
	assert_eq(nowhere.validate(war.game, war.attacker()).reason, ActionFailure.Value.MAP_NOT_GENERATED)
	assert_eq(nowhere.description(), "Attaque poste (%d, %d)" % [war.at.x, war.at.y])
	var map: GameMap = war.game.levels[war.level]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"transition_base": null}))
	assert_eq(_reason(war, war.attacker()), ActionFailure.Value.BASE_NOT_FOUND)
	var ghost := _ready_war()
	ghost.post.captured_by = "nobody"
	assert_eq(_reason(ghost, ghost.attacker()), ActionFailure.Value.NO_SUCH_PLAYER)


## Not in the Dart file: a tutorial under way protects the owner, as it
## protects the attacker.
func test_a_human_owner_still_in_the_tutorial_is_protected() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	war.arm(war.attacker())
	assert_null(_reason(war, war.attacker()))
	ObjectiveMigration.state_of(war.game, war.human()).tutorial_enabled = true
	assert_eq(_reason(war, war.attacker()), ActionFailure.Value.ATTACK_TOO_EARLY)


## Not in the Dart file: a player struck once this turn, wherever, is not
## struck again.
func test_a_player_already_hit_this_turn_is_refused() -> void:
	var war := _ready_war()
	var entry := HistorySamples.base_assault_entry(true, false)
	entry.turn = 12
	entry.opponent_name = war.owner().name
	war.attacker().add_history_entry(entry)
	assert_eq(_reason(war, war.attacker()), ActionFailure.Value.ALREADY_ATTACKED_THIS_TURN)
