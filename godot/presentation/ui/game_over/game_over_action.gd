class_name GameOverAction
extends RefCounted
## A button at the foot of an end-of-game screen
## (lib/presentation/screens/game/game_over_screen.dart: GameOverAction): the
## text it shows by key, the id the screen tells when it is pressed, and
## whether it is the primary one (filled; the others are outlined).

const MENU := &"menu"
const CONTINUE := &"continue"
const EXPORT := &"export"

var id: StringName
var text_key: StringName
var primary: bool


func _init(id_: StringName, text_key_: StringName, primary_ := false) -> void:
	id = id_
	text_key = text_key_
	primary = primary_
