extends TextsTestCase
## test/presentation/extensions/resource_type_extensions_test.dart, for the texts.

const Type := ResourceType.Value


func test_names_a_resource_and_tells_its_flavour() -> void:
	assert_eq(ResourceTexts.display_name(Type.PEARL), "Perles")
	assert_eq(ResourceTexts.flavor_text(Type.CORAL), "Matériau de construction récolté sur les récifs pour bâtir votre base.")
	TranslationServer.set_locale("en")
	assert_eq(ResourceTexts.display_name(Type.ALGAE), "Algae")


func test_the_gains_read_in_the_order_of_the_map_without_what_was_not_gained() -> void:
	var gains: Dictionary[ResourceType.Value, int] = {Type.CORAL: 30, Type.ALGAE: 0, Type.ORE: 20}
	assert_eq(ResourceTexts.gain_label(gains), "+30 corail, +20 minerai")
	assert_eq(ResourceTexts.gain_label({} as Dictionary[ResourceType.Value, int]), "")
	TranslationServer.set_locale("en")
	assert_eq(ResourceTexts.gain_label(gains), "+30 coral, +20 ore")


func test_every_resource_has_a_name_and_a_flavour_in_every_language() -> void:
	for suffix: String in ["Name", "Flavor"]:
		assert_every_value_translated(Type, func(type: int) -> String:
			return TextKeys.of("resource", Type, type, suffix))
