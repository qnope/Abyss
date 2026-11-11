class_name FightKillCount
extends FightReportCard
## How many of the enemies of a fight were killed, counted as guardians for an
## assault on a guarded place (lib/presentation/widgets/fight/
## fight_kill_count.dart).

var fight: FightResult
var guardians: bool
var label := text_label()


func _init(fight_: FightResult, guardians_ := false) -> void:
	fight = fight_
	guardians = guardians_
	super()
	column.add_child(label)
	refresh()


func refresh() -> void:
	var total := fight.initial_monster_count
	label.text = Texts.t(&"fightGuardiansKilled" if guardians else &"fightEnemiesKilled", {
		"killed": total - fight.final_monster_count,
		"total": total,
	})
