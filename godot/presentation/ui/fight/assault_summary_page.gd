class_name AssaultSummaryPage
extends FullPage
## The report of an assault on a place the guardians hold, whatever it is: a
## Faille, a Cheminée or the volcano (lib/presentation/screens/game/fight/
## transition_fight_summary_screen.dart and kernel_fight_summary_screen.dart).
## It is [FightSummaryPage] with the cards that apply: the result (a capture
## in its own words), what became of the units sent, the guardians killed and
## the turns, and no monsters nor loot. Without a fight (an assault refused
## before it) only the result and the units show. It ends with null when
## "back to the map" is pressed.
##
## A page per place derives from it with its title and its words for a
## capture; the rival bases of lot 13 may do the same.

const GAP := 12

var victory: bool
var captured: bool
var fight: FightResult
var map_button := Button.new()
var _title: Callable


## The report of the assault of [param fight_], titled by [param title_] (a
## function returning a String). A capture reads [param captured_key].
func _init(
	title_: Callable, captured_key: StringName, victory_: bool, captured_: bool, fight_: FightResult,
	sent: Dictionary[UnitType.Value, int], intact: Dictionary[UnitType.Value, int],
	wounded: Dictionary[UnitType.Value, int], dead: Dictionary[UnitType.Value, int],
) -> void:
	_title = title_
	victory = victory_
	captured = captured_
	fight = fight_
	super()
	body.add_theme_constant_override(&"separation", GAP)
	body.add_child(FightResultBanner.new(victory, fight.turn_count if fight != null else -1,
		captured_key if captured else &""))
	body.add_child(FightUnitAccounting.new(sent, intact, wounded, dead))
	if fight != null:
		body.add_child(FightKillCount.new(fight, true))
		body.add_child(FightTurnList.new(fight.turn_summaries))
	map_button.pressed.connect(close)
	body.add_child(map_button)
	refresh()


func refresh() -> void:
	set_title(str(_title.call()))
	map_button.text = Texts.t(&"commonBackToMap")
