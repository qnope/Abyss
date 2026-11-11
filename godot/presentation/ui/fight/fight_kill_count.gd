class_name FightKillCount
extends FightReportCard
## How many of the enemies of a fight were killed, counted as guardians for an
## assault on a guarded place (lib/presentation/widgets/fight/
## fight_kill_count.dart).

var fight: FightResult
var guardians: bool
## The ARB key of the text, which takes the figures "killed" and "total".
var key: StringName
var label := text_label()


## The count of [param fight_]; [param key_] says it in other words (the
## defenders of a base put out of action) than the enemies' or the guardians'.
func _init(fight_: FightResult, guardians_ := false, key_: StringName = &"") -> void:
	fight = fight_
	guardians = guardians_
	key = key_
	if key.is_empty():
		key = &"fightGuardiansKilled" if guardians else &"fightEnemiesKilled"
	super()
	column.add_child(label)
	refresh()


func refresh() -> void:
	var total := fight.initial_monster_count
	label.text = Texts.t(key, {
		"killed": total - fight.final_monster_count,
		"total": total,
	})
