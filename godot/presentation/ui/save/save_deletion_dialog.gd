class_name SaveDeletionDialog
extends AbyssDialog
## Asks whether the game of a player is to be deleted for good
## (lib/presentation/widgets/save/confirm_save_deletion.dart). It ends with
## true only when the player confirms; a dismissal ends it with null.

var cancel_button: Button
var delete_button: Button
var message_label := Label.new()
var _player_name: String


func _init(player_name: String) -> void:
	super()
	_player_name = player_name
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(message_label)
	cancel_button = add_action("", false)
	delete_button = add_action("", true)
	delete_button.add_theme_color_override(&"font_color", AbyssColors.ERROR)
	refresh()


func refresh() -> void:
	set_title(Texts.t(&"saveDeleteTitle"))
	message_label.text = Texts.t(&"saveDeleteMessage", {"name": _player_name})
	for button in actions():
		button.text = Texts.t(&"commonCancel" if button == actions()[0] else &"saveDelete")

