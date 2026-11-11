class_name LoadGameScreen
extends ScreenPage
## The saved games, over the dimmed deep sea, ready to be resumed or deleted
## (lib/presentation/screens/menu/load_game_screen.dart). It shows what it is
## given and tells what the player does: [signal game_chosen] to resume a
## game, [signal delete_confirmed] once the player confirmed a deletion in the
## dialog it opens, [signal new_game_requested] from the empty state. `app/`
## reads the saves again and shows the screen anew.

## The player touched [param game]: resume it.
signal game_chosen(game: Game)
## The player confirmed that [param game] is to be deleted.
signal delete_confirmed(game: Game)
## The player wants a new game, there being none to load.
signal new_game_requested

var list: SaveList
var empty: EmptySaves
var _modals: ModalLayer


## The saves in [param sections], dated against [param now] (milliseconds
## since 1970 UTC); the deletion is confirmed on [param modals].
func _init(sections: SaveSections, modals: ModalLayer, now := Game.now()) -> void:
	super(&"saveLoadTitle")
	_modals = modals
	if sections.is_empty():
		empty = EmptySaves.new()
		empty.new_game_requested.connect(new_game_requested.emit)
		body.add_child(empty)
		return
	list = SaveList.new(sections, now)
	list.game_opened.connect(game_chosen.emit)
	list.delete_requested.connect(_confirm_deletion)
	body.add_child(list)


func _confirm_deletion(game: Game) -> void:
	var dialog := SaveDeletionDialog.new(game.human_player().name)
	dialog.closed.connect(func(confirmed: Variant) -> void:
		if confirmed == true:
			delete_confirmed.emit(game))
	_modals.open(dialog)
