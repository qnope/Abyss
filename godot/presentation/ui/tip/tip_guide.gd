class_name TipGuide
extends AbyssDialog
## The Guide (lib/.../tip_guide.dart): every tip, section by section, those
## seen by their title to open their card again, the others greyed as « ??? ».
## It reads the state of the player when it opens and again when the language
## changes.

var state: ObjectiveState
## The rows, section after section.
var rows: Array[TipGuideRow] = []


func _init(state_: ObjectiveState) -> void:
	state = state_
	super()
	add_action("", null)
	refresh()


func refresh() -> void:
	# Called once by the base class, before there is an action to write.
	if actions().is_empty():
		return
	set_title(Texts.t(&"tipGuideTitle"))
	actions()[0].text = Texts.t(&"commonClose")
	for old in body.get_children():
		body.remove_child(old)
		old.free()
	rows.clear()
	for category: TipCategory.Value in TipCategory.Value.values():
		var header := Label.new()
		header.text = TipTexts.category_label(category)
		header.theme_type_variation = &"LabelLarge"
		header.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
		body.add_child(header)
		for tip in TipCatalog.all():
			if tip.category == category:
				_add_row(tip)


func _add_row(tip: Tip) -> void:
	var row := TipGuideRow.new(tip, state.has_seen(tip.id))
	row.pressed.connect(_open.bind(tip))
	rows.append(row)
	body.add_child(row)


func _open(tip: Tip) -> void:
	var layer := ModalLayer.enclosing(self)
	if layer != null:
		layer.open(TipCard.new(tip))
