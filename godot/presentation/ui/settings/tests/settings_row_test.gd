extends UiTestCase
## A row of a settings list that opens something: its title and a chevron.


func test_shows_its_title_and_a_chevron() -> void:
	var row := mount(SettingsRow.new("L'histoire du jeu")) as SettingsRow
	assert_eq(row.title_label.text, "L'histoire du jeu")
	assert_eq(row.accessibility_name, "L'histoire du jeu")
	assert_eq(row.chevron.icon_path, UiIcon.glyph_path(&"chevron_right"))


func test_the_whole_row_is_the_touch_area() -> void:
	var row := mount(SettingsRow.new("Revoir")) as SettingsRow
	var touched := [0]
	row.pressed.connect(func() -> void: touched[0] += 1)
	press("Revoir")
	assert_eq(touched[0], 1)
	assert_true(row.custom_minimum_size.y >= AbyssHudTheme.TOUCH_SIZE)


func test_rewrites_its_title() -> void:
	var row := mount(SettingsRow.new("Revoir")) as SettingsRow
	row.set_title("Review")
	assert_eq(row.title_label.text, "Review")
	assert_eq(row.accessibility_name, "Review")
