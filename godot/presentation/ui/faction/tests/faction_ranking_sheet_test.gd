extends UiTestCase
## test/presentation/widgets/faction/faction_ranking_sheet_test.dart (and
## faction_standing_tile_test.dart): the ranking of the human and the factions.


func _game(factions: int) -> Game:
	return GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, factions)


func _sheet(game: Game) -> FactionRankingSheet:
	var sheet := FactionRankingSheet.new(FactionStanding.ranking(game))
	modals().open(sheet)
	return sheet


func test_lists_the_human_and_every_faction() -> void:
	var game := _game(3)
	var sheet := _sheet(game)
	assert_eq(sheet.title_label.text, "Classement des factions")
	assert_eq(sheet.tiles.size(), 4)
	assert_not_null(find_text("Nemo (Vous)", sheet))
	for faction in game.factions():
		assert_not_null(find_text(faction.name(), sheet))
	for tile in sheet.tiles:
		assert_true(tile.depth_label.text.contains("Profondeur : niveau 1"))
		assert_null(tile.fallen_pill)
	assert_no_raw_keys(sheet)


func test_the_human_has_no_emblem_and_a_faction_has_its_own() -> void:
	var game := _game(1)
	var sheet := _sheet(game)
	assert_true(sheet.tiles[0].leading is UiIcon and not sheet.tiles[0].leading is FactionEmblem)
	var emblem := sheet.tiles[1].leading as FactionEmblem
	assert_eq(emblem.personality, game.factions()[0].personality)
	assert_eq(sheet.tiles[1].name_label.text, game.factions()[0].name())


func test_a_fallen_faction_is_marked() -> void:
	var game := _game(2)
	game.players[game.factions()[0].id()].saved_fallen = true
	var tile := FactionStandingTile.new(FactionStanding.of(game, game.players[game.factions()[0].id()]))
	mount(tile)
	assert_eq(tile.fallen_pill.label.text, "TOMBÉE")
	assert_eq(tile.name_label.get_theme_color(&"font_color"), AbyssColors.DISABLED)
	var sheet := _sheet(game)
	assert_eq(sheet.tiles.back().fallen_pill.label.text, "TOMBÉE", "the fallen come last")


func test_tells_the_origin_of_a_discovered_faction_only() -> void:
	var game := _game(2)
	var seen: Faction = game.factions()[0]
	var hidden: Faction = game.factions()[1]
	var base: Player = game.players[seen.id()]
	game.human_player().add_revealed_cell(1, GridPosition.new(base.base_x, base.base_y))
	var sheet := _sheet(game)
	assert_not_null(find_text(FactionPersonalityTexts.origin(seen.personality), sheet))
	assert_null(find_text(FactionPersonalityTexts.origin(hidden.personality), sheet))
	assert_eq(find_type("LoreText", sheet).size(), 1)


func test_the_holder_of_the_kernel_says_so() -> void:
	var standing := FactionStanding.new("Nacre", FactionPersonality.Value.PEARL_ORDER, 4, 3, true, false, false)
	var tile := mount(FactionStandingTile.new(standing)) as FactionStandingTile
	assert_eq(tile.depth_label.text, "QG niveau 4 - Tient le Noyau du Volcan")


func test_follows_the_language() -> void:
	var game := _game(1)
	game.players[game.factions()[0].id()].saved_fallen = true
	var sheet := _sheet(game)
	use_language("en")
	assert_eq(sheet.title_label.text, "Faction ranking")
	assert_eq(sheet.tiles[0].name_label.text, "Nemo (You)")
	assert_eq(sheet.tiles[1].fallen_pill.label.text, "FALLEN")
	use_language("es")
	assert_no_raw_keys(sheet)
