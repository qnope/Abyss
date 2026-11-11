class_name TransitionBaseSheet
extends MapSheet
## What a touch on a Faille or a Cheminée nobody else holds opens
## (lib/presentation/widgets/map/transition_base_sheet.dart): its picture lit
## by its holder (the guardians' until the player takes it), its name and its
## kind, then [TransitionBaseUncapturedSection] to assault it or
## [TransitionBaseCapturedSection] to send units down.
##
## The sheet only tells what the player wants: both signals come after it
## closed, for its owner to open the army to assault with or the descent.

## The player wants to assault the post.
signal assault_requested
## The player wants to send units down through the post.
signal descend_requested

var base: TransitionBase
var kind_label: Label
var section: SheetSection


## The sheet of [param base_] for the human of [param game]; [param plan] is
## the plan of an assault on it (`../assault/`), shown above the assault button.
func _init(game: Game, base_: TransitionBase, plan: Control = null) -> void:
	base = base_
	var human := game.human_player()
	super(PostPicture.of(base.type, PostHolder.of(base, human.id)),
		func() -> String: return TransitionBaseNameTexts.label(base_.name))
	kind_label = label(func() -> String: return TransitionBaseTexts.display_name(base_.type), &"BodySmall")
	kind_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	column.add_child(kind_label)
	if base.is_captured():
		var captured := TransitionBaseCapturedSection.new(base, human, PostDefence.of(game, human, base))
		captured.descend_requested.connect(_then.bind(descend_requested))
		section = captured
	else:
		var guarded := TransitionBaseUncapturedSection.new(base, plan)
		guarded.assault_requested.connect(_then.bind(assault_requested))
		section = guarded
	column.add_child(section)


## Closes the sheet, then tells [param asked].
func _then(asked: Signal) -> void:
	close()
	asked.emit()
