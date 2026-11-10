extends TestCase
## A vector file of reference/vectors read from the tests, its values
## decoded; a file or a section that is not there fails the test.

const FIXTURES := "res://tool/reference/fixtures"
const LANGUAGE_FILES: Array[String] = ["dart_random", "dart_shuffle", "dart_sort", "dart_math"]


func test_the_repository_is_above_the_project() -> void:
	var given := OS.get_environment(ReferenceFiles.ROOT_VARIABLE)
	OS.unset_environment(ReferenceFiles.ROOT_VARIABLE)
	var root := ReferenceFiles.repo_root()
	if not given.is_empty():
		OS.set_environment(ReferenceFiles.ROOT_VARIABLE, given)
	assert_eq(root.path_join("godot"), ProjectSettings.globalize_path("res://").trim_suffix("/"))


func test_the_repository_can_be_named_for_a_copy_of_the_project() -> void:
	var given := OS.get_environment(ReferenceFiles.ROOT_VARIABLE)
	OS.set_environment(ReferenceFiles.ROOT_VARIABLE, "/somewhere/Abyss")
	var root := ReferenceFiles.repo_root()
	var path := ReferenceFiles.vector_path("units")
	if given.is_empty():
		OS.unset_environment(ReferenceFiles.ROOT_VARIABLE)
	else:
		OS.set_environment(ReferenceFiles.ROOT_VARIABLE, given)
	assert_eq(root, "/somewhere/Abyss")
	assert_eq(path, "/somewhere/Abyss/reference/vectors/units.json")


func test_the_committed_vectors_are_found() -> void:
	for file_name: String in LANGUAGE_FILES:
		assert_true(FileAccess.file_exists(ReferenceFiles.vector_path(file_name)), file_name)
		var file := VectorFile.new(file_name)
		assert_eq(file.name, file_name)
		assert_false(file.section_names().is_empty(), file_name)


func test_reads_the_cases_of_a_section_decoded() -> void:
	var file := VectorFile.new("sample", FIXTURES)
	assert_eq(file.name, "sample")
	assert_eq(file.section_names(), PackedStringArray(["empty", "halves"]))
	assert_eq(file.api("halves"), "x / 2")
	var cases := file.cases("halves")
	assert_eq(cases.size(), 2)
	assert_eq(cases[0], {"x": 3, "out": 1.5})
	assert_eq(cases[1]["x"], 9223372036854775807)
	assert_eq(cases[1]["out"], 4611686018427387904)
	assert_eq(cases[1]["army"], [["scout", 2], ["harpoonist", 1]])


func test_a_missing_file_fails_the_test() -> void:
	expect_error("No vector file")
	var file := VectorFile.new("missing", FIXTURES)
	assert_eq(file.name, "missing")
	assert_eq(file.section_names(), PackedStringArray())
	expect_error('No section "halves" in the vector file "missing"')
	assert_true(file.cases("halves").is_empty())


func test_a_file_that_is_not_json_fails_the_test() -> void:
	expect_error("broken.json is not a vector file")
	assert_eq(VectorFile.new("broken", FIXTURES).section_names(), PackedStringArray())


func test_a_missing_section_fails_the_test() -> void:
	var file := VectorFile.new("sample", FIXTURES)
	expect_error('No section "thirds" in the vector file "sample"')
	assert_true(file.cases("thirds").is_empty())
	expect_error('No section "thirds" in the vector file "sample"')
	assert_eq(file.api("thirds"), "")


func test_an_empty_section_fails_the_test() -> void:
	var file := VectorFile.new("sample", FIXTURES)
	expect_error('The section "empty" of the vector file "sample" has no case')
	assert_true(file.cases("empty").is_empty())
