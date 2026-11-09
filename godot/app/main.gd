extends Control
## The startup screen: the game's title on the abyss background. Every
## screen shows under it, so it gives its window the game's theme.

@onready var _background: ColorRect = $Background


func _enter_tree() -> void:
	get_window().theme = AbyssTheme.build()


func _ready() -> void:
	_background.color = AbyssColors.ABYSS_BLACK
