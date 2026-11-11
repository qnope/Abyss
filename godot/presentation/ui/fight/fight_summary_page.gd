class_name FightSummaryPage
extends FullPage
## The report of a fight against a lair
## (lib/presentation/screens/game/fight/fight_summary_screen.dart): the result,
## the monsters, what became of the units sent, the enemies killed, the loot of
## a victory and the turns, each a card of `fight/`. It ends with null when
## "back to the map" is pressed.
##
## It is shown right after the fight, from the [FightMonsterResult] the action
## gave, and later by the history from the entry that recorded it
## ([method HistoryReports.fight_summary]).
##
## No static factory of its own: a script that builds itself in a static
## function leaks at exit when another script loads it first.

const GAP := 12

var result: FightMonsterResult
var lair: MonsterLair
var target_x: int
var target_y: int
var map_button := Button.new()


## The report of [param result_] against [param lair_], on the cell
## ([param x], [param y]).
func _init(result_: FightMonsterResult, lair_: MonsterLair, x: int, y: int) -> void:
	result = result_
	lair = lair_
	target_x = x
	target_y = y
	super()
	body.add_theme_constant_override(&"separation", GAP)
	var fight := result.fight
	body.add_child(FightResultBanner.new(result.victory, fight.turn_count))
	body.add_child(MonsterPreview.new(lair))
	body.add_child(FightUnitAccounting.new(result.sent, result.survivors_intact, result.wounded, result.dead))
	body.add_child(FightKillCount.new(fight))
	if result.victory:
		body.add_child(FightLootCard.new(result.loot))
	body.add_child(FightTurnList.new(fight.turn_summaries))
	map_button.pressed.connect(close)
	body.add_child(map_button)
	refresh()


func refresh() -> void:
	set_title(Texts.t(&"fightTitle", {"x": target_x, "y": target_y}))
	map_button.text = Texts.t(&"commonBackToMap")
