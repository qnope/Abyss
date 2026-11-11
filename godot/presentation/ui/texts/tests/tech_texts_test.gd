extends TextsTestCase
## test/presentation/extensions/tech_branch_extensions_test.dart and
## tech_node_extensions_test.dart, for the texts.

const Branch := TechBranch.Value
const Option := TechOption.Value


func test_names_a_branch() -> void:
	assert_eq(TechBranchTexts.display_name(Branch.EXPLORER), "Explorateur")
	assert_eq(TechBranchTexts.description(Branch.MILITARY), "Améliore l'attaque et la défense de toutes les unités.")


func test_every_branch_has_a_name_and_a_description_in_every_language() -> void:
	for suffix: String in ["Name", "Description"]:
		assert_every_value_translated(Branch, func(branch: int) -> String:
			return TextKeys.of("techBranch", Branch, branch, suffix))


func test_names_a_node_and_tells_its_effect() -> void:
	assert_eq(TechNodeTexts.node_name(Branch.MILITARY, 2, Option.A), "Lames de corail")
	assert_eq(TechNodeTexts.node_effect(Branch.MILITARY, 2, Option.A), "+35 % ATK")
	assert_eq(TechNodeTexts.node_name(Branch.EXPLORER, 3), "Cartographie des courants")
	TranslationServer.set_locale("en")
	assert_eq(TechNodeTexts.node_name(Branch.EXPLORER, 1), "Bioluminescent Lantern")


func test_a_plain_level_has_the_effect_of_its_branch() -> void:
	assert_eq(TechNodeTexts.node_effect(Branch.MILITARY, 1), "+20 % ATK et DEF")
	assert_eq(TechNodeTexts.node_effect(Branch.MILITARY, 5), "+20 % ATK et DEF")
	assert_eq(TechNodeTexts.node_effect(Branch.RESOURCES, 3), "+20 % de production")


func test_the_explorer_s_plain_levels_tell_the_size_of_the_area() -> void:
	assert_eq(TechNodeTexts.node_effect(Branch.EXPLORER, 1), "Zone explorée 5×5")
	assert_eq(TechNodeTexts.node_effect(Branch.EXPLORER, 3), "Zone explorée 7×7")
	assert_eq(TechNodeTexts.node_effect(Branch.EXPLORER, 5), "Zone explorée 9×9")


func test_a_node_the_reef_lacks_has_no_text() -> void:
	assert_eq(TechNodeTexts.node_name(Branch.MILITARY, 2), "")
	assert_eq(TechNodeTexts.node_effect(Branch.MILITARY, 2), "")
	assert_eq(TechNodeTexts.node_name(Branch.MILITARY, 1, Option.A), "")
	assert_eq(TechNodeTexts.node_effect(Branch.RESOURCES, 6), "")


func test_every_node_of_every_branch_has_a_name_and_an_effect_in_every_language() -> void:
	for branch: int in Branch.values():
		for node in TechNodeTexts.NODES:
			var plain := node.length() == 1
			assert_translated(TextKeys.of("tech", Branch, branch, node + "Name"))
			if not plain:
				assert_translated(TextKeys.of("tech", Branch, branch, node + "Effect"))
	for key: StringName in [&"techTierEffect", &"techProductionEffect", &"techExploredAreaEffect"]:
		assert_translated(key)


func test_every_node_reads_in_every_language() -> void:
	for locale in LANGUAGES:
		TranslationServer.set_locale(locale)
		for branch: int in Branch.values():
			for level in range(1, 6):
				var options: Array = [null] if level % 2 == 1 else [Option.A, Option.B]
				for option: Variant in options:
					assert_false(TechNodeTexts.node_name(branch as Branch, level, option).is_empty(), locale)
					assert_false(TechNodeTexts.node_effect(branch as Branch, level, option).is_empty(), locale)
