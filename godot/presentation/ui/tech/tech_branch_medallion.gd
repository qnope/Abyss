class_name TechBranchMedallion
extends PanelContainer
## The round emblem of a branch, glowing in its colour once unlocked, grey with
## a padlock otherwise, its name and research level under it
## (lib/presentation/widgets/tech/tech_branch_medallion.dart). A touch tells
## [signal tapped]: it opens the branch's panel.

## The player touched the medallion.
signal tapped

const EMBLEM := 52.0
const ICON_SHARE := 0.6
const LOCK_SIZE := 16.0
const GAP := 4

var branch: TechBranch.Value
var unlocked: bool
var icon: UiIcon
## The padlock of a locked branch, null once it is unlocked.
var lock_icon: UiIcon
var name_label := Label.new()
## "Niv. 3" on an unlocked branch; empty, but as tall, on a locked one, so
## that the columns stay level.
var level_label := Label.new()
var tap_button := Button.new()


func _init(branch_: TechBranch.Value, is_unlocked: bool, research_level: int) -> void:
	branch = branch_
	unlocked = is_unlocked
	theme_type_variation = AbyssSurfaceTheme.BARE
	var color := TechColors.of(branch)
	var ring := color if unlocked else AbyssColors.DISABLED
	var disc := PanelContainer.new()
	disc.custom_minimum_size = Vector2(EMBLEM, EMBLEM)
	var box := AbyssBox.rimmed(AbyssBox.flat(AbyssColors.SURFACE_LIGHT, roundi(EMBLEM / 2.0)), ring, 3)
	disc.add_theme_stylebox_override(&"panel", AbyssBox.glowing(box, Color(color, 0.55), 16) if unlocked else box)
	icon = TechIcons.branch_icon(branch, EMBLEM * ICON_SHARE, color if unlocked else AbyssColors.DISABLED)
	Greyscale.apply(icon, not unlocked)
	disc.add_child(icon)
	var emblem := Control.new()
	emblem.custom_minimum_size = Vector2(EMBLEM, EMBLEM)
	emblem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	emblem.add_child(disc)
	if not unlocked:
		lock_icon = UiIcon.glyph(&"lock", LOCK_SIZE, AbyssColors.WARNING)
		emblem.add_child(lock_icon)
		lock_icon.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		lock_icon.offset_left = -LOCK_SIZE
		lock_icon.offset_top = -LOCK_SIZE
	name_label.text = TechBranchTexts.display_name(branch)
	name_label.theme_type_variation = &"LabelLarge"
	name_label.add_theme_color_override(&"font_color", color if unlocked else AbyssColors.ON_SURFACE_DIM)
	level_label.text = Texts.t(&"techScreenMedallionLevel", {"level": research_level}) if unlocked else ""
	level_label.theme_type_variation = &"BodySmall"
	level_label.add_theme_color_override(&"font_color", color)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	column.add_child(emblem)
	for each: Label in [name_label, level_label]:
		each.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		each.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(each)
	add_child(column)
	tap_button.theme_type_variation = AbyssSurfaceTheme.TAP
	tap_button.accessibility_name = name_label.text
	tap_button.pressed.connect(tapped.emit)
	add_child(tap_button)
