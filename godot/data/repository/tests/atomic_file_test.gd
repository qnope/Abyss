extends TestCase
## AtomicFile: a file replaced whole, its folder created, and what it does
## when it cannot write.

var temp := TempFolder.new()


func after_each() -> void:
	temp.remove()


func test_writes_a_file_in_a_new_folder_and_reads_it_back() -> void:
	var path := temp.path.path_join("a/b/save.json")
	assert_eq(AtomicFile.write(path, "{\"é\":1}"), OK)
	assert_eq(AtomicFile.read(path), "{\"é\":1}")
	assert_eq(DirAccess.get_files_at(path.get_base_dir()), PackedStringArray(["save.json"]), "no temp file left")


func test_replaces_a_file_whole() -> void:
	var path := temp.path.path_join("save.json")
	AtomicFile.write(path, "a long first text")
	assert_eq(AtomicFile.write(path, "short"), OK)
	assert_eq(AtomicFile.read(path), "short")


func test_a_missing_file_reads_as_null() -> void:
	assert_null(AtomicFile.read(temp.path.path_join("none.json")))


## A crash between the temp file and the rename leaves the old file whole,
## and the next write goes on over the temp file left.
func test_a_temp_file_left_by_a_crash_changes_nothing() -> void:
	var path := temp.path.path_join("save.json")
	AtomicFile.write(path, "saved")
	AtomicFile.write(temp.path.path_join("other"), "")
	DirAccess.rename_absolute(temp.path.path_join("other"), path + AtomicFile.TEMP_SUFFIX)
	assert_eq(AtomicFile.read(path), "saved")
	assert_eq(AtomicFile.write(path, "next"), OK)
	assert_eq(AtomicFile.read(path), "next")


func test_tells_the_error_when_the_folder_or_the_file_cannot_be_made() -> void:
	var blocker := temp.path.path_join("blocker")
	AtomicFile.write(blocker, "a file where a folder should be")
	assert_ne(AtomicFile.write(blocker.path_join("save.json"), "x"), OK)
	expect_error("Could not create directory")
	assert_ne(AtomicFile.write(blocker.path_join("sub/save.json"), "x"), OK)
	DirAccess.make_dir_recursive_absolute(temp.path.path_join("dir.json.tmp"))
	assert_ne(AtomicFile.write(temp.path.path_join("dir.json"), "x"), OK)
	DirAccess.make_dir_recursive_absolute(temp.path.path_join("taken.json"))
	assert_ne(AtomicFile.write(temp.path.path_join("taken.json"), "x"), OK, "a folder in the way of the rename")
