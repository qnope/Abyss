extends GameHudCase
## The buildings seen from the game screen: the banners over the base and the
## sheet that opens on a building (game_screen_actions.dart).

const Type := BuildingType.Value


func test_the_banners_tell_the_worksites_over_the_base() -> void:
	var hud := _show(_game_with({Type.HEADQUARTERS: 2}))
	assert_not_null(find_text("Chantiers libres ce tour : 1/1", hud.banners))
	assert_true(hud.content.is_ancestor_of(hud.banners))
	assert_eq(hud.banners.mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_the_banners_follow_the_game_after_a_change() -> void:
	var hud := _show(_game_with({Type.HEADQUARTERS: 2}))
	_game.human_player().worksite.upgrades = 1
	assert_null(find_text("Chantiers libres ce tour : 0/1", hud.banners))
	hud.refresh()
	assert_not_null(find_text("Chantiers libres ce tour : 0/1", hud.banners))


func test_opens_the_sheet_of_a_building_on_the_modals() -> void:
	var hud := _show(_game_with({Type.HEADQUARTERS: 2}))
	hud.open_building(Type.HEADQUARTERS)
	var sheet := current_modal() as BuildingSheet
	assert_not_null(sheet)
	assert_eq(sheet.type, Type.HEADQUARTERS)
	assert_not_null(find_text("Quartier Général", sheet))


func test_raising_a_building_from_its_sheet_tells_the_actions() -> void:
	var hud := _show(_game_with({Type.HEADQUARTERS: 1}))
	for resource: GameResource in _game.human_player().resources.values():
		resource.amount = resource.max_storage
	var acted := []
	_actions.acted.connect(acted.append)
	hud.open_building(Type.HEADQUARTERS)
	press("Améliorer")
	assert_eq(acted.size(), 1)
	assert_null(current_modal())
