extends VBoxContainer
## One model's row of the review board: its game view, its four sides, its
## close view and its portrait side by side, each with its caption, and under
## them its name and its budget figures. Built from the renders that
## preview.sh and portrait.gd wrote as <folder>/<name>_<view>.png and
## <folder>/<name>.png. A building with tiers has two lines of pictures: its
## game views and its close views at tier 1, tiers 1 and 2, then all tiers
## (board.sh renders the lower ones with TIER=n, as <name>_t<n>_<view>.png).

const VIEWS: Array[String] = ["game", "front", "right", "back", "left", "close"]
const TIERED_GAME: Array[String] = ["t1_game", "t2_game", "game", "front", "right"]
const TIERED_CLOSE: Array[String] = ["t1_close", "t2_close", "close", "back", "left"]
## The height of every picture of the row, in pixels.
const TILE := 320
const TEXT := Color("e8f1ff")
const DIM := Color("8fa8c8")
const SIZE := 18


## The lines of views of a model with [param tiers] tiers (0 for none): the
## portrait follows the first line.
static func views(tiers: int) -> Array[Array]:
	if tiers < 2:
		return [VIEWS]
	return [TIERED_GAME, TIERED_CLOSE]


func _init(folder: String, name_: String, lines: PackedStringArray, tiers := 0) -> void:
	add_theme_constant_override(&"separation", 6)
	var first := true
	for line: Array in views(tiers):
		var pictures := HBoxContainer.new()
		pictures.add_theme_constant_override(&"separation", 10)
		for view: String in line:
			pictures.add_child(_cell("%s/%s_%s.png" % [folder, name_, view], _caption(view)))
		if first:
			pictures.add_child(_cell("%s/%s.png" % [folder, name_], "portrait"))
			first = false
		add_child(pictures)
	add_child(_label(name_, TEXT, SIZE + 6))
	for line in lines:
		add_child(_label(line, DIM, SIZE))


## "t2_game" reads "game, tiers 1+2" and "game" alone is the whole model.
static func _caption(view: String) -> String:
	if not view.begins_with("t"):
		return view
	var parts := view.split("_")
	return "%s, tiers 1-%s" % [parts[1], parts[0].substr(1)] if parts[0] != "t1" else "%s, tier 1" % parts[1]


func _cell(path: String, caption: String) -> VBoxContainer:
	var cell := VBoxContainer.new()
	var rect := TextureRect.new()
	rect.texture = _texture(path)
	rect.custom_minimum_size = Vector2(rect.texture.get_size()) if rect.texture != null else Vector2(TILE, TILE)
	cell.add_child(rect)
	cell.add_child(_label(caption if rect.texture != null else caption + " (missing)", DIM, SIZE - 4))
	return cell


## The picture at [param path] scaled to [constant TILE] high, or null.
func _texture(path: String) -> ImageTexture:
	var image := Image.load_from_file(path)
	if image == null:
		return null
	var scale := float(TILE) / image.get_height()
	image.resize(roundi(image.get_width() * scale), TILE, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)


func _label(text: String, color: Color, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_font_size_override(&"font_size", size)
	return label
