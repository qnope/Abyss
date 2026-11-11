class_name BatchSummary
extends RefCounted
## lib/domain/script/batch_summary.dart: the summary of a batch the
## simulator prints, line by line: survival, raids, the steps of the road
## to the volcano, the guardians' strike back at the first Faille and the
## kraken waves on the kernel.


static func lines_of(name: String, report: BatchReport) -> Array[String]:
	var waves: Array[ScriptRaid] = []
	for r: ScriptRunReport in report.runs:
		waves.append_array(r.milestones.waves)
	var earliest: Variant = report.earliest_defeat()
	var lines: Array[String] = [
		"Stratégie : %s, %d parties" % [name, report.games()],
		"Survie : %s (%d défaites, %d victoires)" % [_pct(report.survival_rate()), report.defeats(), report.victories()],
		"Tours joués en moyenne : %s" % _avg(report.average_turns()),
		"Raids repoussés / perdus en moyenne : %s / %s" % [
			_avg(report.average_raids_repelled()), _avg(report.average_raids_lost()),
		],
		"Bruit total moyen : %s" % _avg(report.average_noise()),
		"Première défaite : tour %s" % (str(earliest) if earliest != null else "-"),
	]
	lines.append_array(_milestone(report, "Faille prise", func(r: ScriptRunReport) -> Variant:
		return r.milestones.faille_captured))
	lines.append_array(_milestone(report, "Cheminée prise", func(r: ScriptRunReport) -> Variant:
		return r.milestones.cheminee_captured))
	lines.append_array(_milestone(report, "Noyau pris", func(r: ScriptRunReport) -> Variant:
		return r.milestones.kernel_captured))
	lines.append_array(_milestone(report, "Victoire", func(r: ScriptRunReport) -> Variant:
		return r.turns_played if r.is_victory() else null))
	lines.append_array(_milestone(report, "Léviathan", func(r: ScriptRunReport) -> Variant:
		return r.milestones.leviathan_struck))
	lines.append_array(_milestone(report, "Module perdu au Léviathan", func(r: ScriptRunReport) -> Variant:
		return r.milestones.leviathan_struck if r.milestones.leviathan_held == false else null))
	if not waves.is_empty():
		var lost := waves.filter(func(w: ScriptRaid) -> bool: return not w.victory).size()
		lines.append("Vagues du Noyau : %d combattues, %d perdues" % [waves.size(), lost])
	return lines


## The line of a milestone, none when no game reached it.
static func _milestone(report: BatchReport, label: String, turn_of: Callable) -> Array[String]:
	var m := report.milestone(turn_of)
	if m.games == 0:
		return []
	var average: float = m.average_turn
	return ["%s : %d/%d parties, tour %s en moyenne" % [
		label, m.games, report.games(), DartDouble.text_as_fixed(average, 1),
	]]


static func _pct(v: float) -> String:
	return DartDouble.text_as_fixed(v * 100, 0) + " %"


static func _avg(v: float) -> String:
	return DartDouble.text_as_fixed(v, 1)
