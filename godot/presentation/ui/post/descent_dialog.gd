class_name DescentDialog
extends UnitTransferDialog
## Picks the units that go down for good through a captured post
## (lib/presentation/screens/game/descent_dialog.dart): the level they go to in
## the title, the post under it with its picture, and the warning that the
## descent is final. Confirming tells [signal UnitTransferDialog.confirmed]
## with the picks; the descent itself is its owner's.

const WARNING_COLOR := AbyssColors.WARNING
const PICTURE_SIZE := 48.0


## The dialog for the units [param available], going to [param target_level]
## through the post [param base]: its name, and its picture lit by the player.
func _init(available_: Dictionary[UnitType.Value, Unit], target_level: int, base: TransitionBase) -> void:
	var notice := NoticeBanner.new(UiIcon.glyph_path(&"warning"), WARNING_COLOR, Texts.t(&"screenDescentWarning"))
	super(Texts.t(&"screenDescentTitle", {"level": target_level}), available_,
		func(total: int) -> String: return Texts.t(&"screenDescentConfirm", {"count": total}),
		TransitionBaseNameTexts.label(base.name), PostPicture.of(base.type, PostHolder.Value.HUMAN, PICTURE_SIZE),
		notice)
