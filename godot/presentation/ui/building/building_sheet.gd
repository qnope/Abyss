class_name BuildingSheet
extends BottomSheet
## What a touch on a building of the base opens: its picture, name and level
## (or that it is still to build), what it does, why it is degraded if it is,
## what it asks and costs to raise, and the button that does it
## (lib/presentation/widgets/building/building_detail_sheet.dart and
## showBuildingDetailAction). The Coral Citadel adds the rampart it raises, the
## headquarters the worksites and the rampart of the base.
##
## The upgrade goes through the [GameActions]: a success closes the sheet with
## the [ActionResult] (the owner saves and redraws on [signal GameActions.acted]);
## a refusal is told in the sheet, which is read again from the game. The
## sheet is built again by [method refresh], on a change and on the language:
## its sections depend on the state. What it replaces is hidden and kept until
## the next refresh or the end of the sheet, not freed at once: the button
## that was pressed may be the one being replaced.

const PAD := 24
const BOTTOM_PAD := 32
const GAP := 8

var actions: GameActions
var type: BuildingType.Value
var view: BuildingView
## Why the last upgrade was refused, "" if none was.
var failure := ""
var column := VBoxContainer.new()
var _retired := Control.new()


func _init(actions_: GameActions, type_: BuildingType.Value) -> void:
	super()
	actions = actions_
	type = type_
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
	view = BuildingView.of(actions.game, type)
	column.add_child(BuildingHeader.new(view.building))
	var notice := DegradedNotice.of(type, view.buildings)
	if notice != null:
		column.add_child(notice)
	var description := Label.new()
	description.text = BuildingTexts.description(type)
	description.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(description)
	_add_specifics()
	column.add_child(HSeparator.new())
	if not failure.is_empty():
		column.add_child(NoticeBanner.new(UiIcon.glyph_path(&"warning"), AbyssColors.ERROR, failure))
	var upgrade := UpgradeSection.new(view)
	upgrade.upgrade_pressed.connect(_upgrade)
	column.add_child(upgrade)


## The citadel's rampart; the headquarters' rampart and worksites.
func _add_specifics() -> void:
	if type == BuildingType.Value.CORAL_CITADEL:
		column.add_child(CitadelSection.new(view.building))
	if type == BuildingType.Value.HEADQUARTERS:
		var human := actions.game.human_player()
		var shield := ShieldBadge.new(human.buildings)
		var worksite := WorksiteBadge.new(human.worksite, human.buildings, true)
		for badge: Control in [shield, worksite]:
			badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			column.add_child(badge)


func _upgrade() -> void:
	var result := actions.execute(UpgradeBuildingAction.new(type))
	if result.is_success:
		close(result)
		return
	failure = ActionFailureTexts.failure_message(result)
	refresh()
