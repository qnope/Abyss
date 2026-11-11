class_name FightResultBanner
extends FightReportCard
## The top of a fight report: victory or defeat, or a custom text such as a
## capture, and how many turns the fight lasted when there was one
## (lib/presentation/widgets/fight/fight_result_banner.dart).

var victory: bool
## The ARB key of a text in place of "victory" and "defeat", or empty.
var label_key: StringName
## How many turns the fight lasted, or -1 to say nothing of it.
var turn_count: int
var title_label := text_label(&"HeadlineMedium")
var turns_label := text_label(&"BodyMedium", AbyssColors.ON_SURFACE_DIM)


func _init(victory_: bool, turn_count_ := -1, label_key_: StringName = &"") -> void:
	victory = victory_
	turn_count = turn_count_
	label_key = label_key_
	super()
	title_label.add_theme_color_override(&"font_color", AbyssColors.BIOLUM_CYAN if victory else AbyssColors.WARNING)
	turns_label.visible = turn_count >= 0
	column.add_child(title_label)
	column.add_child(turns_label)
	refresh()


func refresh() -> void:
	var key := label_key
	if key.is_empty():
		key = &"fightVictory" if victory else &"fightDefeat"
	title_label.text = Texts.t(key)
	turns_label.text = Texts.t(&"fightTurnCount", {"count": maxi(turn_count, 0)})
