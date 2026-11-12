extends TestCase
## Attackers besieging a place.

var _made: Array[Node] = []


func after_each() -> void:
	for node in _made:
		node.free()


func _figure(siege: MapSiege) -> Node3D:
	var figure: Node3D = siege.attacker.call()
	_made.append(figure)
	return figure


func test_a_wave_of_monsters_is_made_of_their_figures() -> void:
	var lair := StrikeSamples.lair(MonsterFamily.Value.HUNTER)
	var fight := StrikeSamples.fight([7, 4], [2, 0])
	var siege := MapSiege.by_wave(Vector2i(3, 3), lair, fight, true)
	assert_true(_figure(siege) is MonsterFigure)
	assert_eq(siege.rounds, [Vector2i(2, 7), Vector2i(0, 4)] as Array[Vector2i], "from the defenders' side")
	assert_true(siege.victory)
	assert_eq(siege.span, 1)
	assert_eq(siege.ring, MapPalette.DAMAGE)


func test_an_army_is_made_of_the_figures_of_its_lead_in_its_colour() -> void:
	var fight := StrikeSamples.fight([7], [2])
	var siege := MapSiege.by_army(Vector2i(1, 2), UnitType.Value.HARPOONIST, Color.GREEN, fight, false, 2)
	var figure := _figure(siege)
	assert_false(figure is MonsterFigure)
	assert_not_null(WorldModels.animator(figure))
	assert_eq(siege.ring, Color.GREEN)
	assert_false(siege.victory)
	assert_eq(siege.span, 2)
