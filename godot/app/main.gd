extends Control
## The startup screen: the abyss background and the game's title.

## AbyssColors.abyssBlack, the background of every Flutter screen.
const BACKGROUND := Color("0a0e1a")
## AbyssColors.biolumCyan, the colour of the title.
const TITLE_COLOR := Color("00e5ff")

@onready var _background: ColorRect = $Background
@onready var _title: Label = $Title


func _ready() -> void:
	_background.color = BACKGROUND
	_title.add_theme_color_override("font_color", TITLE_COLOR)
