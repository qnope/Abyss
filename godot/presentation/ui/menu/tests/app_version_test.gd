extends TestCase
## test/presentation/app_version_test.dart: the version shown to players is the
## one the exports carry.


func test_is_the_version_of_the_android_and_ios_exports() -> void:
	var presets := ConfigFile.new()
	assert_eq(presets.load("res://export_presets.cfg"), OK)
	var versions := []
	for section in presets.get_sections():
		for key: String in ["version/name", "application/short_version"]:
			if presets.has_section_key(section, key):
				versions.append(presets.get_value(section, key))
	assert_eq(versions.size(), 2)
	for version: Variant in versions:
		assert_eq(version, AppVersion.current())


func test_looks_like_a_version() -> void:
	var parts := AppVersion.current().split(".")
	assert_eq(parts.size(), 3)
	for part in parts:
		assert_true(part.is_valid_int(), part)
