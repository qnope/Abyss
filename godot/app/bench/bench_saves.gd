class_name BenchSaves
extends RefCounted
## Where a bench of the game saves it: a folder of its own beside the player's
## saves (`user://bench` beside `user://saves`), never among them, removed
## with what it holds once the bench is over. A bench cut short (the page
## closed) leaves its folder behind: the next one removes it first.

## The folder's name.
const NAME := "bench"

## The saves of the bench.
var repository: GameRepository


## The saves of a bench, beside those [param players] keeps.
func _init(players: GameRepository) -> void:
	repository = GameRepository.new(beside(players.folder))
	remove()


## The bench's folder for the saves folder [param saves].
static func beside(saves: String) -> String:
	return saves.get_base_dir().path_join(NAME)


## Removes the folder and the saves in it.
func remove() -> void:
	var folder := repository.folder
	if not DirAccess.dir_exists_absolute(folder):
		return
	for file: String in DirAccess.get_files_at(folder):
		DirAccess.remove_absolute(folder.path_join(file))
	DirAccess.remove_absolute(folder)
