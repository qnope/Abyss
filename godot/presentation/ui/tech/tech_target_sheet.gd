class_name TechTargetSheet
extends BottomSheet
## The bottom sheet a touch on a branch or a node of the tree opens: its
## [TechTargetPanel] and, under it, why the last attempt was refused
## (lib/presentation/widgets/tech/tech_tree_view.dart: _openPopup, and
## game_screen_tech_actions.dart: unlockBranch, researchTech).
##
## Unlocking and researching go through the [GameActions]: a success closes the
## sheet with the [ActionResult] (the owner saves and redraws on [signal
## GameActions.acted]); a refusal, which Flutter ignores, is told in the sheet,
## which is read again from the game. The sheet is built again by [method
## refresh], on a change and on the language. What it replaces is hidden and
## kept until the next refresh or the end of the sheet, not freed at once: the
## button that was pressed is in the panel being replaced.

const PAD := 16
const BOTTOM_PAD := 24
const GAP := 8

var actions: GameActions
var target: TechTarget
var panel: TechTargetPanel
## The last attempt's refusal, null if it was not refused.
var refusal: ActionResult
## Why the last attempt was refused, in the language on; "" if it was not.
var failure := ""
var column := VBoxContainer.new()
var _retired := Control.new()


func _init(actions_: GameActions, target_: TechTarget) -> void:
	super()
	actions = actions_
	target = target_
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
	panel = TechTargetPanel.new(TechView.of(actions.game), target)
	panel.act_pressed.connect(_act)
	column.add_child(panel)
	failure = ActionFailureTexts.failure_message(refusal) if refusal != null else ""
	if not failure.is_empty():
		column.add_child(NoticeBanner.new(UiIcon.glyph_path(&"warning"), AbyssColors.ERROR, failure))


## Runs the action: unlocking the branch, or researching the node taking
## [param option].
func _act(option: TechOption.Value) -> void:
	var action: Action = UnlockBranchAction.new(target.branch) if target.is_branch() \
		else ResearchTechAction.new(target.branch, option)
	var result := actions.execute(action)
	if result.is_success:
		close(result)
		return
	refusal = result
	refresh()
