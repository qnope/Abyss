extends TestCase
## test/domain/faction/post_defence_test.dart: what the human knows of the
## defence of a post it holds, the groups "PostDefence threat" and
## "PostDefence losses".

const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE
const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN

var _war: PostWar
var _first: Player
var _second: Player


func before_each() -> void:
	super()
	_war = PostWar.new(FAILLE, 7, true)
	_first = _war.game.players[_war.game.factions()[0].id()]
	_second = _war.game.players[_war.game.factions()[1].id()]


static func _report(turn: int, army: Dictionary[UnitType.Value, int]) -> BaseIntel:
	return BaseIntel.new(turn, 3, 0, army, {})


static func _order(to_level: int, units: Dictionary[UnitType.Value, int]) -> ReinforcementOrder:
	return ReinforcementOrder.new(to_level - 1, to_level, units, 11, GridPosition.new(0, 0))


static func _of(war: PostWar) -> PostDefence:
	return PostDefence.of(war.game, war.human(), war.post)


func test_threat_is_unknown_without_any_scouting_report() -> void:
	assert_null(_of(_war).threat)


func test_threat_is_the_faction_whose_reported_army_is_the_largest() -> void:
	_war.human().intel()[_first.id] = _report(9, {HARPOONIST: 12})
	_war.human().intel()[_second.id] = _report(10, {HARPOONIST: 20, GUARDIAN: 15})

	var threat := _of(_war).threat

	assert_eq(threat.faction.id(), _second.id)
	assert_eq(threat.faction.name(), _war.game.factions()[1].name())
	assert_eq(threat.units, 35)
	assert_eq(threat.report_turn, 10)
	assert_eq(threat.turns_ago, 2)


func test_threat_keeps_a_stale_report_telling_how_old_it_is() -> void:
	_war.human().intel()[_first.id] = _report(1, {HARPOONIST: 4})

	var threat := _of(_war).threat

	assert_eq(threat.report_turn, 1)
	assert_eq(threat.turns_ago, 11)


func test_threat_ignores_a_faction_that_has_fallen() -> void:
	_war.human().intel()[_first.id] = _report(9, {HARPOONIST: 4})
	_war.human().intel()[_second.id] = _report(9, {HARPOONIST: 40})
	_second.saved_fallen = true

	assert_eq(_of(_war).threat.faction.id(), _first.id)


func test_threat_ignores_a_report_of_an_empty_base() -> void:
	_war.human().intel()[_first.id] = _report(9, {HARPOONIST: 0})

	assert_null(_of(_war).threat)


func test_threat_is_unknown_on_a_cheminee_the_reports_being_of_level_1() -> void:
	var cheminee := PostWar.new(CHEMINEE, 7, true)
	cheminee.human().intel()[cheminee.game.factions()[0].id()] = _report(9, {HARPOONIST: 30})

	assert_null(_of(cheminee).threat)


## Not in the Dart file: a smaller army reported later does not replace
## the largest, and a faction whose player is gone is left out.
func test_threat_keeps_the_largest_whatever_the_order() -> void:
	_war.human().intel()[_first.id] = _report(9, {HARPOONIST: 40})
	_war.human().intel()[_second.id] = _report(10, {HARPOONIST: 40})
	assert_eq(_of(_war).threat.faction.id(), _first.id)
	_war.game.players.erase(_first.id)
	assert_eq(_of(_war).threat.faction.id(), _second.id)


func test_losses_name_the_passage_building_of_a_faille() -> void:
	assert_eq(_of(_war).passage, BuildingType.Value.DESCENT_MODULE)


func test_losses_name_the_passage_building_of_a_cheminee() -> void:
	var war := PostWar.new(CHEMINEE, 7, true)

	assert_eq(_of(war).passage, BuildingType.Value.PRESSURE_CAPSULE)


func test_losses_name_no_passage_building_while_it_is_at_level_0() -> void:
	_war.human().buildings[BuildingType.Value.DESCENT_MODULE].level = 0

	assert_null(_of(_war).passage)


func test_losses_count_the_units_on_the_level_below() -> void:
	_war.put(_war.human(), 2, {HARPOONIST: 7, GUARDIAN: 5})
	_war.put(_war.human(), 1, {HARPOONIST: 30})

	assert_eq(_of(_war).units_below, 12)


func test_losses_are_zero_units_below_when_nobody_stands_there() -> void:
	var war := PostWar.new(CHEMINEE, 7, true)

	assert_eq(_of(war).units_below, 0)
	assert_eq(_of(war).reinforcements, 0)


func test_losses_count_the_reinforcements_heading_to_the_level_below() -> void:
	_war.human().pending_reinforcements.append(_order(2, {HARPOONIST: 2}))
	_war.human().pending_reinforcements.append(_order(2, {GUARDIAN: 1}))
	_war.human().pending_reinforcements.append(_order(3, {HARPOONIST: 9}))

	assert_eq(_of(_war).reinforcements, 3)
