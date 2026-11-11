class_name UnitSheet
extends BottomSheet
## What a touch on a squad of the parade ground opens: the unit's picture, its
## name in its colour, its role and what it does, then either the barracks
## level it waits for, or its health, attack and defence, how many serve where
## the player looks and the recruiting (lib/presentation/widgets/unit/
## unit_detail_sheet.dart and showUnitDetailAction).
##
## Recruiting goes through the [GameActions]: a success closes the sheet with
## the [ActionResult] (the owner saves and redraws on [signal GameActions.acted]);
## a refusal is told in the sheet, which is read again from the game. The sheet
## is built again by [method refresh], on a change and on the language, what it
## replaces hidden and kept until the next refresh or the end of the sheet: the
## button that was pressed may be the one being replaced.

const PAD := 24
const BOTTOM_PAD := 32
const GAP := 8

var actions: GameActions
var type: UnitType.Value
## The units of the type serving where the player looks.
var count: int
var view: UnitView
## Why the last recruiting was refused, "" if none was.
var failure := ""
var column := VBoxContainer.new()
var _retired := Control.new()


func _init(actions_: GameActions, type_: UnitType.Value, count_: int) -> void:
	super()
	actions = actions_
	type = type_
	count = count_
	column.add_theme_constant_override(&"separation", GAP)
	var padding := MarginContainer.new()
	for side: String in ["left", "right"]:
		padding.add_theme_constant_override("margin_" + side, PAD)
	padding.add_theme_constant_override(&"margin_bottom", BOTTOM_PAD)
	padding.add_child(column)
	_retired.visible = false
	body.add_child(padding)
	body.add_child(_retired)
	refresh()


func refresh() -> void:
	# Called once by the base class, before the sheet is built.
	if actions == null:
		return
	for old in _retired.get_children():
		old.free()
	for child in column.get_children():
		column.remove_child(child)
		_retired.add_child(child)
	view = UnitView.of(actions.game, type, count)
	column.add_child(UnitPortrait.of(type, 64.0, not view.is_unlocked()))
	column.add_child(_text(UnitTexts.display_name(type), &"HeadlineSmall", UnitColors.of(type)))
	column.add_child(_text(UnitTexts.role(type), &"BodySmall"))
	column.add_child(_text(UnitTexts.role_effect(type), &"BodySmall", AbyssColors.ON_SURFACE_DIM))
	if view.is_unlocked():
		_add_unlocked()
	else:
		column.add_child(_text(Texts.t(&"unitBarracksRequired", {"level": view.unlock_level()}),
			&"BodyMedium", AbyssColors.DISABLED))
	if not failure.is_empty():
		column.add_child(NoticeBanner.new(UiIcon.glyph_path(&"warning"), AbyssColors.ERROR, failure))


func _add_unlocked() -> void:
	var stats := UnitStats.for_type(type)
	var chips := HBoxContainer.new()
	chips.alignment = BoxContainer.ALIGNMENT_CENTER
	chips.add_theme_constant_override(&"separation", GAP)
	chips.add_child(_chip(&"statHp", stats.hp))
	chips.add_child(_chip(&"statAttack", stats.atk))
	chips.add_child(_chip(&"statDefense", stats.def))
	column.add_child(chips)
	column.add_child(_text(Texts.t(&"unitInService", {"count": count}), &"BodyMedium", AbyssColors.ON_SURFACE_DIM))
	column.add_child(HSeparator.new())
	var section := RecruitmentSection.new(view)
	section.recruit_pressed.connect(_recruit)
	column.add_child(section)


func _recruit(quantity: int) -> void:
	var result := actions.execute(RecruitUnitAction.new(type, quantity))
	if result.is_success:
		close(result)
		return
	failure = ActionFailureTexts.failure_message(result)
	refresh()


## A stat of the unit: "PV: 10".
func _chip(key: StringName, value: int) -> StatusPill:
	return StatusPill.new("%s: %d" % [Texts.t(key), value], AbyssColors.ON_SURFACE_DIM)


## A centred line of text in a role, in [param color] when it has one.
func _text(text: String, role: StringName, color := Color.TRANSPARENT) -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = role
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if color.a > 0.0:
		label.add_theme_color_override(&"font_color", color)
	return label
