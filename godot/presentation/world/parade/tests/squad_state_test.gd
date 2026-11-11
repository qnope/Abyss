extends TestCase
## What the parade shows of a squad (army_roster_test.dart: figuresOf).

const Type := UnitType.Value


func test_a_squad_shows_as_many_figures_as_its_size_tier() -> void:
	var tiers: Dictionary[int, int] = {0: 0, 1: 1, 2: 2, 5: 2, 6: 3, 16: 4, 31: 5, 61: 6, 500: 6}
	for count: int in tiers:
		assert_eq(SquadState.new(Type.SCOUT, count).figures(), tiers[count], "%d units" % count)


func test_a_locked_unit_shows_one_ghost_whatever_its_count() -> void:
	assert_eq(SquadState.new(Type.GUARDIAN, 40, true).figures(), 1)


func test_two_states_of_the_same_squad_have_the_same_signature() -> void:
	var one := SquadState.new(Type.SCOUT, 3, false, true, "Éclaireurs")
	var same := SquadState.new(Type.SCOUT, 3, false, true, "Éclaireurs")
	assert_eq(one.signature(), same.signature())


func test_the_signature_tells_everything_the_squad_shows() -> void:
	var base := SquadState.new(Type.SCOUT, 3, false, false, "Éclaireurs")
	var others: Array[SquadState] = [
		SquadState.new(Type.HARPOONIST, 3, false, false, "Éclaireurs"),
		SquadState.new(Type.SCOUT, 4, false, false, "Éclaireurs"),
		SquadState.new(Type.SCOUT, 3, true, false, "Éclaireurs"),
		SquadState.new(Type.SCOUT, 3, false, true, "Éclaireurs"),
		SquadState.new(Type.SCOUT, 3, false, false, "Scouts"),
	]
	for other in others:
		assert_ne(other.signature(), base.signature())


func test_the_signature_of_a_row_follows_the_order_of_its_squads() -> void:
	var scout := SquadState.new(Type.SCOUT, 1)
	var guardian := SquadState.new(Type.GUARDIAN, 2)
	assert_ne(SquadState.signature_of([scout, guardian]), SquadState.signature_of([guardian, scout]))
