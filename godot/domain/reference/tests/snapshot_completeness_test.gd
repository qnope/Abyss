extends TestCase
## test/domain/reference/snapshot_completeness_test.dart. The model is not
## read from `@HiveField`s, which GDScript has not, but from the classes a
## Game reaches through its typed fields (ClassFields): the group of the
## source reader tests that reader instead.

var persisted := ClassFields.persisted()


class Sample:
	extends RefCounted
	const NOT_A_FIELD := 1
	var lost_in_a_row: int
	var fight_seed: int
	var saved_y: Variant

	func is_one() -> bool:
		return lost_in_a_row == 1


func _snapshots() -> Dictionary[String, ClassSnapshot]:
	var found: Dictionary[String, ClassSnapshot] = {}
	for s: ClassSnapshot in SnapshotCatalog.all():
		found[s.dart_class] = s
	return found


func _sorted(names: Array) -> Array[String]:
	var sorted: Array[String] = []
	sorted.assign(names)
	CanonicalKeys.sort(sorted)
	return sorted


func test_reads_the_fields_of_a_class_in_dart_names() -> void:
	assert_eq(ClassFields.of(Sample), ["lostInARow", "fightSeed", "savedY"] as Array[String])
	assert_eq(ClassFields.of(Sample, "AnnouncedAttack"), ["lostInARow", "seed", "savedY"] as Array[String])
	assert_eq(ClassFields.dart_name("map_seed", "GameMap"), "seed")
	assert_eq(ClassFields.dart_name("map_seed", "ReplayJournal"), "mapSeed")
	assert_eq(ClassFields.dart_name("def"), "def")


func test_finds_the_model() -> void:
	for name: String in ["Game", "Player", "MapCell", "Unit", "Resource", "BaseAssaultEntry", "TurnResourceChange"]:
		assert_true(persisted.has(name), name)
	assert_false(persisted.has("HistoryEntry"), "written as its subclasses")
	assert_eq(persisted["Building"], ["type", "level"])
	assert_eq(_sorted(persisted["ExploreEntry"]), ["category", "targetX", "targetY", "turn"] as Array[String])
	assert_null(ClassFields.script_of("NoSuchClass"))


func test_every_persisted_class_has_a_snapshot_and_no_snapshot_is_stale() -> void:
	var snapshots := _snapshots()
	assert_eq(_sorted(snapshots.keys()), _sorted(persisted.keys()))
	assert_eq(snapshots.size(), SnapshotCatalog.all().size(), "twice")


func test_a_snapshot_writes_or_omits_with_a_reason_every_field_of_its_class() -> void:
	var snapshots := _snapshots()
	for name: String in persisted:
		var snapshot: ClassSnapshot = snapshots.get(name)
		if snapshot == null:
			continue
		var written := snapshot.field_names()
		var both: Array[String] = written.duplicate()
		for field: String in snapshot.omitted:
			assert_false(written.has(field), "%s.%s written and omitted" % [name, field])
			both.append(field)
		assert_eq(_sorted(both), _sorted(persisted[name]), "%s: the fields of the snapshot against the class" % name)
		for reason: String in snapshot.omitted.values():
			assert_true(reason.length() > 20, name)
		for field: String in snapshot.renamed:
			assert_true(written.has(field), "%s.%s renamed" % [name, field])


func test_no_two_fields_of_a_class_are_written_under_the_same_key() -> void:
	for s: ClassSnapshot in SnapshotCatalog.all():
		var keys := {}
		for field: String in s.field_names():
			keys[s.key_of(field)] = true
		assert_eq(keys.size(), s.fields.size(), s.dart_class)


func test_the_sections_share_out_every_written_field_of_game_but_the_maps() -> void:
	_assert_shared(SnapshotSections.OF_GAME, GameSnapshots.game())


func test_the_sections_share_out_every_written_field_of_player() -> void:
	_assert_shared(SnapshotSections.OF_PLAYERS, PlayerSnapshots.player())


func test_the_sections_are_listed_by_name_each_once() -> void:
	var names := SnapshotSections.names()
	assert_eq(names, _sorted(names))
	var unique := {}
	for name: String in names:
		unique[name] = true
	assert_eq(unique.size(), names.size())
	assert_eq(names.size(), 20)
	for name: String in ["map1", "map2", "map3", "game", "fog"]:
		assert_true(names.has(name), name)


func _assert_shared(sections: Dictionary[String, Dictionary], snapshot: ClassSnapshot) -> void:
	var fields: Array[String] = []
	for names: Dictionary in sections.values():
		fields.append_array(names.keys())
	var unique := {}
	for field: String in fields:
		unique[field] = true
	assert_eq(unique.size(), fields.size(), "in two sections")
	assert_eq(_sorted(fields), _sorted(snapshot.field_names()))
