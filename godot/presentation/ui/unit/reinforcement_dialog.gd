class_name ReinforcementDialog
extends UnitTransferDialog
## Picks the units sent down as reinforcements, arriving next turn
## (lib/presentation/screens/game/reinforcement_dialog.dart): the level they go
## to in the title, the post they go through under it, and the notice that they
## arrive at the next turn. The kind of post, drawn beside the title, is
## [param illustration].

const NOTICE_COLOR := AbyssColors.BIOLUM_BLUE


## The dialog for the units [param available], going to the level
## [param target_level] through the post [param base_name].
func _init(
	available_: Dictionary[UnitType.Value, Unit], target_level: int, base_name: String,
	illustration: Control = null,
) -> void:
	var notice := NoticeBanner.new(UiIcon.glyph_path(&"info"), NOTICE_COLOR, Texts.t(&"screenReinforcementInfo"))
	super(Texts.t(&"screenReinforcementTitle", {"level": target_level}), available_,
		func(total: int) -> String: return Texts.t(&"screenReinforcementConfirm", {"count": total}),
		base_name, illustration, notice)
