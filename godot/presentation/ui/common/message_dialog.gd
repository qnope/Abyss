class_name MessageDialog
extends AbyssDialog
## A dialog that tells something and asks for nothing: a line of text and an
## OK. Flutter tells such news in a snack bar (a descent done, the garrison's
## size, an action refused); here it is a dialog, which the player closes.
## The text is written by a function, so that it follows the language.

var message_label := Label.new()
var ok_button: Button
var _message: Callable


## A dialog titled [param title_text] (none when empty) that says what
## [param message] returns (a function with no argument returning a String).
func _init(title_text: String, message: Callable) -> void:
	_message = message
	super(title_text)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(message_label)
	ok_button = add_action("", null, &"")
	refresh()


func refresh() -> void:
	# Called once by the base class, before the label is built.
	if ok_button == null:
		return
	message_label.text = str(_message.call())
	ok_button.text = Texts.t(&"commonOk")
