extends TestCase
## test/data/language_settings_test.dart, on a file of a folder of its
## own; its Hive box held open with another type is a file Godot cannot
## read here.

const Choice := LanguageChoice.Value

var temp := TempFolder.new()
var path := temp.path.path_join("settings.json")


func after_each() -> void:
	temp.remove()


## As a new launch would read the file.
func _relaunch() -> LanguageSettings:
	return LanguageSettings.new(path)


func test_follows_the_device_language_until_the_player_picks_one() -> void:
	assert_eq(LanguageSettings.new(path).choice(), Choice.AUTOMATIC)
	assert_eq(LanguageSettings.new().path, "user://settings.json")


func test_keeps_the_chosen_language_across_launches() -> void:
	var settings := LanguageSettings.new(path)
	assert_eq(settings.choose(Choice.SPANISH), OK)
	assert_eq(settings.choice(), Choice.SPANISH)
	assert_eq(_relaunch().choice(), Choice.SPANISH)
	assert_eq(AtomicFile.read(path), "{\"format\":1,\"language\":\"es\"}")


func test_choosing_automatic_again_forgets_the_stored_language() -> void:
	var settings := LanguageSettings.new(path)
	settings.choose(Choice.ENGLISH)
	settings.choose(Choice.AUTOMATIC)
	assert_eq(AtomicFile.read(path), "{\"format\":1}")
	assert_eq(_relaunch().choice(), Choice.AUTOMATIC)


func test_tells_its_listeners_once_per_real_change() -> void:
	var settings := LanguageSettings.new(path)
	var heard: Array[Choice] = []
	settings.changed.connect(func(choice: Choice) -> void: heard.append(choice))
	for choice: Choice in [Choice.FRENCH, Choice.FRENCH, Choice.AUTOMATIC, Choice.AUTOMATIC]:
		settings.choose(choice)
	assert_eq(heard, [Choice.FRENCH, Choice.AUTOMATIC] as Array[Choice])


func test_reads_an_unknown_stored_code_as_automatic() -> void:
	AtomicFile.write(path, "{\"format\":1,\"language\":\"klingon\"}")
	assert_eq(_relaunch().choice(), Choice.AUTOMATIC)


func test_starts_over_on_automatic_when_the_file_cannot_be_read() -> void:
	for text: String in ["{\"format\":1,\"language\":42}", "not json", "[\"fr\"]", "{\"format\":2,\"language\":\"fr\"}"]:
		AtomicFile.write(path, text)
		assert_eq(_relaunch().choice(), Choice.AUTOMATIC, text)
	var settings := _relaunch()
	settings.choose(Choice.FRENCH)
	assert_eq(_relaunch().choice(), Choice.FRENCH)
