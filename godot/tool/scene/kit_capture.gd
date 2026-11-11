extends SceneTree
## Renders the UI kit for review, as a phone held upright shows it, from the
## views of KitGallery. tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/kit_capture.gd -- <out dir>
## writes <out dir>/kit_a.png and kit_b.png (the small components), kit_b_en.png
## (the second page again after the language changed to English, with no
## rebuild), then kit_dialog.png, kit_sheet.png and kit_page.png (a modal over
## the first page).

const SETTLE := 20

var _gallery := KitGallery.new()
var _out := ""


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: kit_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	root.add_child(_gallery)
	_capture()


func _capture() -> void:
	TranslationServer.set_locale("fr")
	_gallery.show_page(KitGallery.PAGE_B)
	await _shot("kit_b")
	TranslationServer.set_locale("en")
	await _shot("kit_b_en")
	TranslationServer.set_locale("fr")
	_gallery.show_page(KitGallery.PAGE_A)
	await _shot("kit_a")
	for kind: String in ["dialog", "sheet", "page"]:
		_gallery.open_modal(kind)
		await _shot("kit_" + kind)
		_gallery.modals.close_top()
	quit(0)


func _shot(shot_name: String) -> void:
	for i in SETTLE:
		await process_frame
	var path := _out.path_join("%s.png" % shot_name)
	root.get_texture().get_image().save_png(path)
	print(path)
	print("  draw calls %d, primitives %d, objects %d" % [
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
	])
