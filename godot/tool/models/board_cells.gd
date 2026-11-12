extends VBoxContainer
## The head of a board that shows what stands on the cells: the renders of
## tool/models/cells.sh (<folder>/cells_near.png, a few cells across, and
## cells_far.png, a phone's width of the map) one over the other, scaled down
## to [constant WIDTH] wide at most, each with its caption. Empty when there
## are none.

const WIDTH := 1500
const TEXT := Color(0.86, 0.92, 0.96)
const VIEWS := {"cells_near": "on the cells, near", "cells_far": "on the cells, a phone's width of the map"}


func _init(folder: String) -> void:
	add_theme_constant_override(&"separation", 6)
	for view: String in VIEWS:
		var path := "%s/%s.png" % [folder, view]
		var image := Image.load_from_file(path) if FileAccess.file_exists(path) else null
		if image == null:
			continue
		if image.get_width() > WIDTH:
			image.resize(WIDTH, roundi(image.get_height() * float(WIDTH) / image.get_width()), Image.INTERPOLATE_LANCZOS)
		var rect := TextureRect.new()
		rect.texture = ImageTexture.create_from_image(image)
		rect.custom_minimum_size = Vector2(rect.texture.get_size())
		var label := Label.new()
		label.text = VIEWS[view]
		label.add_theme_color_override(&"font_color", TEXT)
		add_child(label)
		add_child(rect)
