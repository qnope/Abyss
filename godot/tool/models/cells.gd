extends SceneTree
## Renders models of assets/models/ side by side on the cells of a map, from
## the map's own camera (MapCamera, the game's default view) and its floor:
## tool/models/cells.sh runs it,
##   godot --path godot --script res://tool/models/cells.gd -- <out prefix> <name>...
## and writes <out prefix>_near.png (a few cells across, to judge each against
## its neighbours) and <out prefix>_far.png (a phone's width of the map, about
## 15 cells, as the player sees it). A name may end in @rrggbb to tint the
## model's node Tint, and in ! to dim it as an emptied content is.

const CellRow := preload("res://tool/models/cell_row.gd")

## The views: cells per row, and size in pixels (the far one is the phone's
## width at twice its scale, as the previews are).
const NEAR_PER_ROW := 8
const NEAR_SIZE := Vector2i(1600, 760)
const FAR_PER_ROW := 15
const FAR_SIZE := Vector2i(780, 520)


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		printerr("usage: cells.gd -- <out prefix> <model name>...")
		quit(2)
		return
	var names := args.slice(1)
	var near := await _render(names, NEAR_PER_ROW, NEAR_SIZE, args[0] + "_near.png")
	var far := await _render(names, FAR_PER_ROW, FAR_SIZE, args[0] + "_far.png")
	quit(0 if near and far else 1)


func _render(names: PackedStringArray, per_row: int, size: Vector2i, path: String) -> bool:
	var models := CellRow.load_models(names)
	if models.size() != names.size():
		printerr("cannot load every model of %s" % ", ".join(names))
		return false
	var spans: Array[int] = []
	for name in names:
		spans.append(CellRow.span_of(name))
	var row := CellRow.new(models, spans, per_row)
	var viewport := SubViewport.new()
	viewport.size = size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.use_hdr_2d = true
	viewport.positional_shadow_atlas_size = 4096
	root.add_child(viewport)
	# The sea, the light and the camera of the map scene itself.
	for part: Node in [UnderwaterEnvironment.new(), KeyLight.new(), row]:
		viewport.add_child(part)
	var camera := MapCamera.new()
	viewport.add_child(camera)
	row.frame(camera, float(size.x) / size.y)
	for i in 4:
		await RenderingServer.frame_post_draw
	var error := viewport.get_texture().get_image().save_png(path)
	viewport.queue_free()
	if error != OK:
		printerr("cannot write %s: %s" % [path, error_string(error)])
		return false
	print(path)
	return true
