class_name DefeatCauseCard
extends RefreshingPanel
## "What happened": the raids that made the base fall, each against its
## defenders, and one piece of advice for the next game
## (lib/presentation/widgets/game_over/defeat_cause_card.dart).

const GAP := 8

var analysis: DefeatAnalysis
var title_label := Label.new()
var raid_labels: Array[Label] = []
var advice_label := Label.new()


func _init(analysis_: DefeatAnalysis) -> void:
	analysis = analysis_
	super()
	var card := PanelContainer.new()
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	title_label.theme_type_variation = &"TitleMedium"
	title_label.add_theme_color_override(&"font_color", AbyssColors.BIOLUM_CYAN)
	column.add_child(title_label)
	for _raid in analysis.raids:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		raid_labels.append(label)
		column.add_child(label)
	advice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	advice_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	column.add_child(advice_label)
	card.add_child(column)
	add_child(card)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"defeatCauseTitle")
	for i in raid_labels.size():
		var raid := analysis.raids[i]
		raid_labels[i].text = Texts.t(&"defeatCauseRaid", {
			"turn": raid.turn, "wave": MonsterLairTexts.wave_label(raid.wave), "defenders": raid.defenders})
	advice_label.text = advice()


## The advice of the analysis, worded for the last raid lost.
func advice() -> String:
	var last: LostRaid = analysis.raids.back()
	var needed: Variant = analysis.harpoonists_needed
	match analysis.advice:
		DefeatAdvice.Value.RAISE_AN_ARMY:
			return Texts.t(&"defeatAdviceRaiseAnArmy")
		DefeatAdvice.Value.MORE_DEFENDERS:
			if needed == null:
				return Texts.t(&"defeatAdviceTooStrong", {"max": RaidDefenceAdvisor.MAX_ADDED})
			return Texts.t(&"defeatAdviceMoreDefenders", {"needed": needed, "defenders": last.defenders})
	var weakness: Variant = MonsterLairTexts.weakness_label(last.wave)
	return Texts.t(&"defeatAdviceWrongUnits") if weakness == null else "%s %s" % [Texts.t(&"defeatAdviceWrongUnits"), weakness]
