class_name MonsterLairSheet
extends MapSheet
## What a touch on a lair not beaten opens: the monsters, their difficulty,
## level, number and stats, the rule of their family and the unit that answers
## it, and the button that prepares the fight (lib/presentation/widgets/map/
## monster_lair_sheet.dart). The picture is a [Portrait] until step 7.
##
## The sheet only tells what the player wants: [signal prepare_requested]
## comes after it closed, for its owner to open the choice of the army.

## The player wants to choose the army to send.
signal prepare_requested

const PICTURE_SIZE := 64.0
const BUTTON_GAP := 12

var lair: MonsterLair
var stats: MonsterUnitStats
var traits: MonsterFamilyTraits
var cancel_button: Button
var prepare_button: Button


## The sheet of [param lair_], on the cell ([param x], [param y]).
func _init(lair_: MonsterLair, x: int, y: int) -> void:
	lair = lair_
	stats = MonsterUnitStats.of(lair.family, lair.level())
	super(Portrait.new(MonsterFamilyTexts.label(lair.family), PICTURE_SIZE, AbyssColors.CORAL_PINK,
		PortraitFiles.monster(lair.family)),
		func() -> String: return "%s (%d, %d)" % [MonsterFamilyTexts.label(lair_.family), x, y])
	column.add_child(_row(&"mapDifficulty", func() -> String: return MonsterDifficultyTexts.label(lair_.difficulty)))
	column.add_child(_row(&"mapLevel", func() -> String: return str(lair_.level())))
	column.add_child(_row(&"mapUnits", func() -> String: return MonsterFamilyTexts.monsters(lair_.family, lair_.unit_count)))
	column.add_child(SheetInfoRow.new(_stats_label, func() -> String: return "%d / %d / %d" % [stats.hp, stats.atk, stats.def]))
	traits = MonsterFamilyTraits.new(lair.family)
	column.add_child(traits)
	column.add_child(HSeparator.new())
	cancel_button = button(func() -> String: return Texts.t(&"commonCancel"))
	cancel_button.theme_type_variation = &"TextButton"
	cancel_button.pressed.connect(close)
	prepare_button = button(func() -> String: return Texts.t(&"fightPrepare"))
	prepare_button.pressed.connect(_prepare)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override(&"separation", BUTTON_GAP)
	buttons.add_child(cancel_button)
	buttons.add_child(prepare_button)
	column.add_child(buttons)


## "HP / ATK / DEF", the label of the row of the stats.
func _stats_label() -> String:
	return "%s / %s / %s" % [Texts.t(&"statHp"), Texts.t(&"statAttack"), Texts.t(&"statDefense")]


## A row labelled by the text [param key] and valued by [param value].
func _row(key: StringName, value: Callable) -> SheetInfoRow:
	return SheetInfoRow.new(func() -> String: return Texts.t(key), value)


func _prepare() -> void:
	close()
	prepare_requested.emit()
