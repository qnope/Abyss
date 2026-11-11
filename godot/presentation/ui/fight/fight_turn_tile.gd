class_name FightTurnTile
extends FightReportCard
## One turn of a fight: the allies' figures on the left, the enemies' on the
## right, and the critical hits when there were some (the tile of
## lib/presentation/widgets/fight/fight_turn_list.dart).

const GAP := 8
const CRIT_RADIUS := 8
const CRIT_PADDING := Vector2i(10, 4)

var summary: FightTurnSummary
var title_label := text_label(&"TitleLarge", AbyssColors.BIOLUM_CYAN)
## The three lines of the allies, then the three of the enemies.
var stat_labels: Array[Label] = []
## The badge of the critical hits, null when there were none.
var crit_label: Label


func _init(summary_: FightTurnSummary) -> void:
	summary = summary_
	super()
	column.add_child(title_label)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override(&"separation", GAP)
	for _side in 2:
		var lines := VBoxContainer.new()
		lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for _line in 3:
			var label := text_label()
			stat_labels.append(label)
			lines.add_child(label)
		columns.add_child(lines)
	column.add_child(columns)
	if summary.crit_count > 0:
		crit_label = text_label(&"LabelMedium", AbyssColors.WARNING)
		crit_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		var badge := PanelContainer.new()
		var box := AbyssBox.flat(AbyssColors.SURFACE_DIM, CRIT_RADIUS, CRIT_PADDING)
		badge.add_theme_stylebox_override(&"panel", AbyssBox.rimmed(box, Color(AbyssColors.WARNING, 0.4)))
		badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		badge.add_child(crit_label)
		column.add_child(badge)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"commonTurn", {"turn": summary.turn_number})
	var keys: Array[StringName] = [
		&"fightAlliesAlive", &"fightAlliesHp", &"fightDamageDealt",
		&"fightEnemiesAlive", &"fightEnemiesHp", &"fightDamageTaken",
	]
	var args: Array[Dictionary] = [
		{"count": summary.player_alive_at_end}, {"hp": summary.player_hp_at_end},
		{"damage": summary.damage_dealt_by_player}, {"count": summary.monster_alive_at_end},
		{"hp": summary.monster_hp_at_end}, {"damage": summary.damage_dealt_by_monster},
	]
	for i in stat_labels.size():
		stat_labels[i].text = Texts.t(keys[i], args[i])
	if crit_label != null:
		crit_label.text = Texts.t(&"fightCriticalHits", {"count": summary.crit_count})
