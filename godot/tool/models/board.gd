extends SceneTree
## Composes the review board of a lot of models: one contact sheet, each
## model in a row (board_row.gd). tool/models/board.sh runs it, after the
## renders and the figures are made:
##   godot --path godot --script res://tool/models/board.gd -- <folder> <out.png> <figures.json>
## The folder holds <name>_<view>.png and <name>.png; the figures file is
## {"models": [{"name": ..., "lines": [...]}, ...]} (board_figures.py).

const Studio := preload("res://tool/models/studio.gd")
const BoardRow := preload("res://tool/models/board_row.gd")
const MARGIN := 24


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 3:
		printerr("usage: board.gd -- <folder> <out.png> <figures.json>")
		quit(2)
		return
	var figures: Variant = JSON.parse_string(FileAccess.get_file_as_string(args[2]))
	var models: Array = []
	if figures is Dictionary:
		var document: Dictionary = figures
		models = document.get("models", [])
	if models.is_empty():
		printerr("cannot read the figures %s" % args[2])
		quit(1)
		return
	_compose(args[0], args[1], models)


func _compose(folder: String, out: String, models: Array) -> void:
	var viewport := SubViewport.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var background := ColorRect.new()
	background.color = Studio.BACKGROUND
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 28)
	for entry: Variant in models:
		var model: Dictionary = entry
		var name_: String = model["name"]
		var lines: PackedStringArray = []
		for line: String in model["lines"]:
			lines.append(line)
		column.add_child(BoardRow.new(folder, name_, lines))
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override(StringName("margin_" + side), MARGIN)
	margin.add_child(column)
	viewport.add_child(background)
	viewport.add_child(margin)
	await process_frame
	await process_frame
	var size := Vector2i(margin.get_combined_minimum_size())
	viewport.size = size
	background.size = Vector2(size)
	margin.size = Vector2(size)
	for i in 3:
		await RenderingServer.frame_post_draw
	var error := viewport.get_texture().get_image().save_png(out)
	if error != OK:
		printerr("cannot write %s: %s" % [out, error_string(error)])
		quit(1)
		return
	print(out)
	quit(0)
