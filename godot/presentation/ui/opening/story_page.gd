class_name StoryPage
extends RefCounted
## One card of a story told card after card
## (lib/presentation/widgets/opening/story_page.dart): its picture, its title
## and the few lines telling it.

## Builds the picture, drawn in a wide frame above the title (a Portrait, an
## icon); called each time the card is shown, so that a card holds no node
## until then.
var make_picture: Callable
var title: String
var lines: PackedStringArray


func _init(make_picture_: Callable, title_: String, lines_: PackedStringArray) -> void:
	make_picture = make_picture_
	title = title_
	lines = lines_
