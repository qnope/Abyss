extends TestCase
## TestDiscovery finds the test files to run.


func test_finds_every_test_file_of_the_project_by_default() -> void:
	var files := TestDiscovery.find(PackedStringArray())
	assert_has(files, "res://app/tests/app_test.gd")
	assert_has(files, "res://tool/test/test_discovery_test.gd")


func test_skips_the_fixtures_and_hidden_folders_by_default() -> void:
	for file: String in TestDiscovery.find(PackedStringArray()):
		assert_false(file.begins_with("res://tool/test/fixtures/"), file)
		assert_false(file.begins_with("res://."), file)


func test_finds_only_files_named_like_tests() -> void:
	for file: String in TestDiscovery.find(PackedStringArray(["res://tool/test"])):
		assert_true(file.ends_with("_test.gd"), file)


func test_finds_the_fixtures_when_asked_for_their_folder() -> void:
	var files := TestDiscovery.find(PackedStringArray(["tool/test/fixtures"]))
	assert_eq(files.size(), 7)
	assert_has(files, "res://tool/test/fixtures/passing_test.gd")


func test_keeps_a_file_given_by_path() -> void:
	assert_eq(
		TestDiscovery.find(PackedStringArray(["app/tests/app_test.gd", "res://x_test.gd"])),
		PackedStringArray(["res://app/tests/app_test.gd", "res://x_test.gd"])
	)


func test_resolves_paths_relative_to_the_project() -> void:
	assert_eq(TestDiscovery.resolve("app"), "res://app")
	assert_eq(TestDiscovery.resolve("./app/"), "res://app")
	assert_eq(TestDiscovery.resolve("res://app/"), "res://app")
	assert_eq(TestDiscovery.resolve("res://"), "res://")
