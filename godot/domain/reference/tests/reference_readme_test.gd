extends TestCase
## test/domain/reference/reference_readme_test.dart, its tests of the
## keys, of the fields left out and of the sections. The port leaves out
## other fields than Dart (no `title`, `subtitle`, `createdAt`, but the
## derived `role` and `family` of a Combatant): each is named in a
## paragraph of the README that names its class. The list of the games
## waits for the reader of a reference file (`committed_games.dart`).

var readme := FileAccess.get_file_as_string(ReferenceFiles.repo_root().path_join("reference/README.md"))


func test_lists_the_keys_of_every_class_as_the_snapshots_write_them() -> void:
	var listed := readme.split("<!-- keys:start -->")[1].split("<!-- keys:end -->")[0].strip_edges()
	var expected := PackedStringArray()
	for s: ClassSnapshot in SnapshotCatalog.all():
		var keys: Array[String] = []
		for field: String in s.field_names():
			keys.append(s.key_of(field))
		CanonicalKeys.sort(keys)
		var quoted := PackedStringArray()
		for key: String in keys:
			quoted.append("`%s`" % key)
		expected.append("- `%s`: %s" % [s.dart_class, ", ".join(quoted)])
	assert_eq(listed.split("\n"), expected)


func test_names_every_field_left_out() -> void:
	var paragraphs := readme.split("\n\n")
	for s: ClassSnapshot in SnapshotCatalog.all():
		for field: String in s.omitted:
			var named := false
			for paragraph: String in paragraphs:
				var text := paragraph.replace("\n", " ")
				named = named or text.contains("`%s.%s`" % [s.dart_class, field]) \
					or (text.contains("`%s`" % field) and text.contains("`%s`" % s.dart_class))
			assert_true(named, "%s.%s" % [s.dart_class, field])


func test_names_every_section() -> void:
	for name: String in SnapshotSections.names():
		assert_true(readme.contains("`%s`" % name), name)
