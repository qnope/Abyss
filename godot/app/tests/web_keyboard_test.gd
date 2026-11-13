extends TestCase
## The Web export brings up a phone's keyboard: without its hidden text input
## (html/experimental_virtual_keyboard), a field of the page never opens the
## keyboard on Safari iOS.


func test_the_web_preset_creates_the_text_input_that_opens_the_keyboard() -> void:
	var presets := ConfigFile.new()
	assert_eq(presets.load("res://export_presets.cfg"), OK)
	var web := ""
	for section: String in presets.get_sections():
		if presets.has_section_key(section, "platform") \
				and presets.get_value(section, "platform") == "Web":
			web = section
	assert_ne(web, "")
	var enabled: bool = presets.get_value(web + ".options", "html/experimental_virtual_keyboard", false)
	assert_true(enabled)
