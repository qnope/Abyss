class_name FightTurnList
extends VBoxContainer
## The turns of a fight, one [FightTurnTile] each, as tall as they are
## (lib/presentation/widgets/fight/fight_turn_list.dart).

const GAP := 8

var tiles: Array[FightTurnTile] = []


func _init(summaries: Array[FightTurnSummary]) -> void:
	add_theme_constant_override(&"separation", GAP)
	for summary in summaries:
		var tile := FightTurnTile.new(summary)
		tiles.append(tile)
		add_child(tile)
