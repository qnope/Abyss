extends TestCase
## The deck of the parade ground and the crest in its middle.

var _ground: ParadeGround


func before_each() -> void:
	_ground = ParadeGround.new()


func after_each() -> void:
	_ground.free()


func test_the_deck_covers_the_island_and_ends_at_the_surface() -> void:
	var box := (_ground.deck.mesh as BoxMesh).size
	assert_almost_eq(box.x, ParadeLayout.ISLAND * ParadeLayout.CELL + 2.0 * ParadeLayout.RIM, 1e-4)
	assert_almost_eq(box.z, box.x, 1e-4)
	assert_almost_eq(_ground.deck.position.y + box.y / 2.0, 0.0, 1e-4)


func test_the_crest_lies_in_the_middle_of_the_deck() -> void:
	assert_eq(_ground.crest.position.x, 0.0)
	assert_eq(_ground.crest.position.z, 0.0)
	assert_true(_ground.crest.position.y > 0.0)
	var light := _ground.crest.material_override as StandardMaterial3D
	assert_eq(light.albedo_color, WorldPalette.CREST)
	assert_true(light.emission_enabled)
