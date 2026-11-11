extends TestCase
## The files and colours of the research (tech_node_extensions_test.dart,
## tech_branch_extensions_test.dart).

const Branch := TechBranch.Value


func test_every_node_of_every_branch_has_its_icon() -> void:
	var missing: Array[String] = []
	for branch: TechBranch.Value in Branch.values():
		for node in TechNodeTexts.NODES:
			var option: Variant = null
			if node.length() == 2:
				option = TechOption.Value.A if node.ends_with("a") else TechOption.Value.B
			var path := TechIcons.node_path(branch, int(node), option)
			if not ResourceLoader.exists(path):
				missing.append(path)
	assert_eq(missing, [] as Array[String])


func test_a_node_is_named_after_its_branch_level_and_option() -> void:
	assert_eq(TechIcons.node_key(Branch.MILITARY, 1), "military_1")
	assert_eq(TechIcons.node_key(Branch.EXPLORER, 4, TechOption.Value.B), "explorer_4b")
	assert_eq(TechIcons.node_path(Branch.RESOURCES, 2, TechOption.Value.A),
		"res://assets/icons/tech/resources_2a.svg")


func test_each_branch_has_an_emblem_that_exists() -> void:
	for branch: TechBranch.Value in Branch.values():
		var icon := TechIcons.branch_icon(branch, 32.0, Color.RED)
		add_cleanup(icon.free)
		assert_not_null(icon.texture)
		assert_eq(icon.custom_minimum_size, Vector2(32, 32))


func test_the_glyphs_take_the_colour_and_the_algae_keep_theirs() -> void:
	var shield := TechIcons.branch_icon(Branch.MILITARY, 32.0, Color.RED)
	var algae := TechIcons.branch_icon(Branch.RESOURCES, 32.0, Color.RED)
	var compass := TechIcons.branch_icon(Branch.EXPLORER, 32.0, Color.RED)
	for icon: UiIcon in [shield, algae, compass]:
		add_cleanup(icon.free)
	assert_eq(shield.icon_path, UiIcon.glyph_path(&"shield"))
	assert_eq(shield.self_modulate, Color.RED)
	assert_eq(algae.icon_path, ResourceIcon.path_for(ResourceType.Value.ALGAE))
	assert_eq(algae.self_modulate, Color.WHITE)
	assert_eq(compass.icon_path, UiIcon.glyph_path(&"explore"))


func test_the_branches_wear_the_colours_of_the_flutter_version() -> void:
	assert_eq(TechColors.of(Branch.MILITARY), AbyssColors.BIOLUM_PINK)
	assert_eq(TechColors.of(Branch.RESOURCES), AbyssColors.ALGAE_GREEN)
	assert_eq(TechColors.of(Branch.EXPLORER), AbyssColors.BIOLUM_CYAN)
