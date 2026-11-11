class_name PostCaptureGame
extends RefCounted
## The game the post capture plays (post_capture.gd): the map capture's game
## (MapCaptureGame) with the Faille of the surface and the Volcanic Kernel in
## sight, an army able to take them on the surface and on the volcano, a few
## units already down on level 2, a Descent Module and a Noyau of level 3.

const VOLCANO := KernelGarrison.VOLCANO_LEVEL


static func of_posts() -> Game:
	var game := MapCaptureGame.of_three_levels()
	var human := game.human_player()
	var faille := find(game, 1, CellContentType.Value.TRANSITION_BASE)
	var kernel := find(game, VOLCANO, CellContentType.Value.VOLCANIC_KERNEL)
	human.add_revealed_cell(1, GridPosition.new(faille.x, faille.y))
	human.add_revealed_cell(VOLCANO, GridPosition.new(kernel.x, kernel.y))
	var army: Dictionary[UnitType.Value, int] = {UnitType.Value.ABYSS_ADMIRAL: 1, UnitType.Value.HARPOONIST: 150, UnitType.Value.GUARDIAN: 100}
	human.units_per_level[1] = DomainSamples.units(army)
	human.units_per_level[2] = DomainSamples.units({UnitType.Value.HARPOONIST: 12, UnitType.Value.GUARDIAN: 3})
	human.units_per_level[VOLCANO] = DomainSamples.units(army)
	human.buildings[BuildingType.Value.DESCENT_MODULE] = Building.new(BuildingType.Value.DESCENT_MODULE, 1)
	human.buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(BuildingType.Value.VOLCANIC_KERNEL, 3)
	return game


## The first cell of [param level] that holds [param content].
static func find(game: Game, level: int, content: CellContentType.Value) -> Vector2i:
	var map: GameMap = game.levels[level]
	for y in map.height:
		for x in map.width:
			if map.cell_at(x, y).content == content:
				return Vector2i(x, y)
	return Vector2i.ZERO
