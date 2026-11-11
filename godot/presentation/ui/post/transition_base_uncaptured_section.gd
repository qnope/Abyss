class_name TransitionBaseUncapturedSection
extends SheetSection
## The part of the sheet of a Faille or a Cheminée still guarded
## (lib/presentation/widgets/map/transition_base_uncaptured_section.dart): its
## difficulty, its income once taken, that its guardians are neutral, the
## plan of the assault when one is given ([param plan], made by `../assault/AssaultPlans`) and the
## button that prepares the assault.

## The player wants to assault the post.
signal assault_requested

var base: TransitionBase
var assault_button: Button


func _init(base_: TransitionBase, plan: Control = null) -> void:
	base = base_
	super()
	column.add_child(SheetInfoRow.new(func() -> String: return Texts.t(&"mapDifficulty"),
		func() -> String: return "%d/5" % base.difficulty()))
	column.add_child(SheetInfoRow.new(func() -> String: return Texts.t(&"mapIncomeOnceCaptured"),
		func() -> String: return Texts.t(&"mapPearlsPerTurn", {"count": base.pearls_per_turn()})))
	column.add_child(label(func() -> String: return Texts.t(&"mapGuardedNeutral"), &"LabelLarge", AbyssColors.ERROR))
	column.add_child(HSeparator.new())
	if plan != null:
		column.add_child(plan)
	assault_button = button(func() -> String: return Texts.t(&"mapAssault"))
	assault_button.pressed.connect(assault_requested.emit)
	column.add_child(assault_button)
