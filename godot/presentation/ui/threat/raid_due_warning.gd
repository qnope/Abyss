class_name RaidDueWarning
extends DueWarning
## The warning when a raid hits at the end of this turn, or a school of
## predators fought like one: the wave against the defenders standing on the
## base level, and a reminder when losing it ends the game
## (lib/presentation/widgets/raid/raid_due_warning.dart).

var wave: MonsterLair
var defender_count: int
## Whether a school of predators strikes, fought like a raid.
var predators: bool
## Whether losing this raid ends the game.
var last_chance: bool
## The reminder that the game is at stake, hidden unless [member last_chance].
var last_chance_label := Label.new()


func _init(wave_: MonsterLair, defender_count_: int, predators_ := false, last_chance_ := false) -> void:
	wave = wave_
	defender_count = defender_count_
	predators = predators_
	last_chance = last_chance_
	super(&"warning", func() -> String:
		return Texts.t(&"raidDueThisTurn", {
			"attacker": Texts.t(&"randomEventPredatorsLabel" if predators_ else &"raidName"),
			"wave": MonsterLairTexts.wave_label(wave_),
			"defenders": Texts.t(&"raidDefenders", {"count": defender_count_}),
		}))
	last_chance_label.theme_type_variation = &"TitleSmall"
	last_chance_label.add_theme_color_override(&"font_color", AbyssColors.ERROR)
	last_chance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	last_chance_label.visible = last_chance
	column.add_child(last_chance_label)
	refresh()


func refresh() -> void:
	last_chance_label.text = Texts.t(&"raidLastChance")
