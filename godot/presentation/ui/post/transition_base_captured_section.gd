class_name TransitionBaseCapturedSection
extends SheetSection
## The part of the sheet of a Faille or a Cheminée the player holds
## (lib/presentation/widgets/map/transition_base_captured_section.dart): that
## it is captured and what it yields, the units that defend the level below,
## what is lost should it fall ([PostDefencePanel], when the defence is known),
## and the button that sends units down, off with the building it asks for
## named when that one is not raised.

## The player wants to send units down through the post.
signal descend_requested

var base: TransitionBase
var human: Player
var requirement_met: bool
var descend_button: Button
var warning_label: Label
var defence_panel: PostDefencePanel


## The section of [param base_], seen by [param human_]; [param defence] is
## what the player knows of the post's defence, null to hide the block.
func _init(base_: TransitionBase, human_: Player, defence: PostDefence = null) -> void:
	base = base_
	human = human_
	requirement_met = PostRequirement.met_by(human, base)
	super()
	var level := base.target_level()
	column.add_child(label(func() -> String: return Texts.t(&"mapCaptured"), &"LabelLarge", AbyssColors.BIOLUM_CYAN))
	column.add_child(label(func() -> String: return Texts.t(&"mapPearlsPerTurn", {"count": base.pearls_per_turn()}),
		&"", AbyssColors.PEARL_WHITE))
	column.add_child(swap(func() -> Control: return UnitCountPanel.new(
		Texts.t(&"mapDefendersOnLevel", {"level": level}), human.unit_counts_on_level(level),
		Texts.t(&"mapNoDefenders"))))
	if defence != null:
		defence_panel = PostDefencePanel.new(base, defence)
		column.add_child(defence_panel)
	column.add_child(HSeparator.new())
	warning_label = label(func() -> String: return Texts.t(&"mapBuildingRequired",
		{"building": BuildingTexts.display_name(PostRequirement.building_for(base))}),
		&"BodySmall", AbyssColors.ERROR)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.visible = not requirement_met
	column.add_child(warning_label)
	descend_button = button(func() -> String: return Texts.t(&"mapSendUnitsToLevel", {"level": level}))
	descend_button.disabled = not requirement_met
	descend_button.pressed.connect(descend_requested.emit)
	column.add_child(descend_button)
