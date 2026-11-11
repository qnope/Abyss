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
## capture, and may change the cards between the banner and the turns by
## overriding [method _lead] (a line after the banner), [method _kill_count]
## (the figures of the enemies down) and [method _details] (the cards after
## them): the rival bases do ([BaseAssaultSummaryPage]).

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
	var lead := _lead()
	if lead != null:
		body.add_child(lead)
	body.add_child(FightUnitAccounting.new(sent, intact, wounded, dead))
	if fight != null:
		body.add_child(_kill_count())
		for card in _details():
			body.add_child(card)
		body.add_child(FightTurnList.new(fight.turn_summaries))
	map_button.pressed.connect(close)
	body.add_child(map_button)
	refresh()


func refresh() -> void:
	set_title(str(_title.call()))
	map_button.text = Texts.t(&"commonBackToMap")


## A card between the banner and the units sent, null for none.
func _lead() -> Control:
	return null


## The card of the enemies put down, the guardians of the place by default.
func _kill_count() -> Control:
	return FightKillCount.new(fight, true)


## The cards after the enemies put down, none by default.
func _details() -> Array[Control]:
	return []
