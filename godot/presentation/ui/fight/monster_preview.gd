class_name MonsterPreview
extends FightReportCard
## A group of monsters before the fight, or in its report: its family and
## difficulty, its level and count, the stats of one monster and the family's
## rule (lib/presentation/widgets/fight/monster_preview.dart). The picture is
## a [Portrait] until step 7 renders the models.

const PORTRAIT_SIZE := 40.0
const GAP := 12
const CHIP_RADIUS := 8
const CHIP_PADDING := Vector2i(10, 6)

var lair: MonsterLair
var stats: MonsterUnitStats
var title_label := text_label(&"TitleLarge", AbyssColors.BIOLUM_CYAN)
var level_label := text_label(&"BodyMedium", AbyssColors.ON_SURFACE_DIM)
var count_label := text_label(&"BodyMedium", AbyssColors.ON_SURFACE_DIM)
## The chips of the stats: hit points, attack, defence.
var chips: Array[Label] = []
var traits: MonsterFamilyTraits
var portrait: Portrait


func _init(lair_: MonsterLair) -> void:
	lair = lair_
	stats = MonsterUnitStats.of(lair.family, lair.level())
	portrait = Portrait.new("", PORTRAIT_SIZE, AbyssColors.CORAL_PINK, PortraitFiles.monster(lair.family))
	super()
	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", GAP)
	head.add_child(portrait)
	head.add_child(title_label)
	var counts := HBoxContainer.new()
	counts.add_theme_constant_override(&"separation", GAP)
	counts.add_child(level_label)
	counts.add_child(count_label)
	var stat_row := HBoxContainer.new()
	stat_row.add_theme_constant_override(&"separation", GAP)
	for _chip in 3:
		var label := text_label(&"LabelLarge")
		label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		var box := AbyssBox.flat(AbyssColors.SURFACE_DIM, CHIP_RADIUS, CHIP_PADDING)
		var chip := PanelContainer.new()
		chip.add_theme_stylebox_override(&"panel", AbyssBox.rimmed(box, Color(AbyssColors.BIOLUM_CYAN, 0.2)))
		chip.add_child(label)
		chips.append(label)
		stat_row.add_child(chip)
	traits = MonsterFamilyTraits.new(lair.family)
	for part: Control in [head, counts, stat_row, traits]:
		column.add_child(part)
	column.add_theme_constant_override(&"separation", GAP)
	refresh()


func refresh() -> void:
	portrait.initials_label.text = Portrait.initials(MonsterFamilyTexts.label(lair.family))
	title_label.text = "%s · %s" % [MonsterFamilyTexts.label(lair.family), MonsterDifficultyTexts.label(lair.difficulty)]
	level_label.text = Texts.t(&"fightLevel", {"level": lair.level()})
	count_label.text = MonsterFamilyTexts.monsters(lair.family, lair.unit_count)
	var names: Array[StringName] = [&"statHp", &"statAttack", &"statDefense"]
	var values: Array[int] = [stats.hp, stats.atk, stats.def]
	for i in chips.size():
		chips[i].text = "%s: %d" % [Texts.t(names[i]), values[i]]
