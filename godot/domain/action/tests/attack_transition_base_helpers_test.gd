extends TestCase
## Not in the Dart files: lib/domain/action/attack_transition_base_helpers
## .dart and attack_transition_base_result.dart, which the Dart tests read
## through AttackTransitionBaseAction (waiting for the leviathan module):
## the army sent out of the stock, the admiral among the survivors, the
## result of a won assault.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const HARPOONIST := UnitType.Value.HARPOONIST


func test_sends_the_army_out_of_the_stock_and_skips_empty_entries() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 2, HARPOONIST: 10})
	var player := game.human_player()
	AttackTransitionBaseHelpers.remove_units_from_stock(player, 1, {ADMIRAL: 1, HARPOONIST: 0, UnitType.Value.SCOUT: -1})
	assert_eq(player.unit_counts_on_level(1), {ADMIRAL: 1, HARPOONIST: 10})


func test_tells_whether_an_admiral_still_stands() -> void:
	var army := CombatantBuilder.player_combatants_from({HARPOONIST: 1, ADMIRAL: 1})
	assert_true(AttackTransitionBaseHelpers.is_admiral_alive(army))
	for c: Combatant in army:
		if c.type_key == "abyssAdmiral":
			c.current_hp = 0
	assert_false(AttackTransitionBaseHelpers.is_admiral_alive(army))
	assert_false(AttackTransitionBaseHelpers.is_admiral_alive([]))


func test_brings_back_the_survivors_and_the_wounded() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1, HARPOONIST: 30})
	var player := game.human_player()
	var units: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, HARPOONIST: 30}
	var army := CombatantBuilder.player_combatants_from(units)
	AttackTransitionBaseHelpers.remove_units_from_stock(player, 1, units)
	var fight := FightEngine.new(DartRandom.new(3)).resolve(army, GuardianFactory.for_faille())
	var breakdown := AttackTransitionBaseHelpers.resolve_casualties(player, 1, fight, DartRandom.new(4))
	var back := 0
	for count: int in breakdown.survivors_intact.values() + breakdown.wounded.values():
		back += count
	var lost := 0
	for count: int in breakdown.dead.values():
		lost += count
	assert_eq(back + lost, 31)
	var standing := 0
	for count: int in player.unit_counts_on_level(1).values():
		standing += count
	assert_eq(standing, back)
	var won := AttackTransitionBaseResult.success(true, true, fight, units, breakdown.survivors_intact)
	assert_eq([won.is_success, won.victory, won.captured, won.sent], [true, true, true, units])
	assert_true(won.fight == fight)
