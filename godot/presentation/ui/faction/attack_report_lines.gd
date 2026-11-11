class_name AttackReportLines
extends VBoxContainer
## The lines of one attack on the human in the end-of-turn summary
## (lib/presentation/widgets/turn/attack_report_lines.dart): what it hit (the
## base, a post or the kernel) and how it ended, then what the human lost with
## it: the passage building destroyed and the units lost.

const LOSS_INDENT := 28

var report: FactionAttackReport
var headline: SummaryLine
## The losses, one line each, under the headline.
var losses: Array[SummaryLine] = []


func _init(report_: FactionAttackReport) -> void:
	report = report_
	var outcome := report.outcome()
	headline = SummaryLine.new(glyph_of(outcome), color_of(outcome), _headline)
	add_child(headline)
	for loss in _loss_sources():
		var line := SummaryLine.new(&"remove", AbyssColors.ERROR, loss)
		var indent := MarginContainer.new()
		indent.add_theme_constant_override(&"margin_left", LOSS_INDENT)
		indent.add_child(line)
		add_child(indent)
		losses.append(line)


## The glyph that tells how an attack ended.
static func glyph_of(outcome: AttackOutcome.Value) -> StringName:
	match outcome:
		AttackOutcome.Value.REPELLED:
			return &"shield"
		AttackOutcome.Value.DAMAGED, AttackOutcome.Value.KERNEL_DAMAGED:
			return &"warning"
		AttackOutcome.Value.POST_TAKEN:
			return &"flag"
	return &"dangerous"


## The colour that tells how an attack ended.
static func color_of(outcome: AttackOutcome.Value) -> Color:
	match outcome:
		AttackOutcome.Value.REPELLED:
			return AbyssColors.SUCCESS
		AttackOutcome.Value.DAMAGED, AttackOutcome.Value.KERNEL_DAMAGED:
			return AbyssColors.WARNING
	return AbyssColors.ERROR


func _headline() -> String:
	var args := {"faction": AttackerNameTexts.label(report.attacker_name)}
	if report.target() == AttackTarget.Value.POST:
		args["post"] = TransitionBaseNameTexts.label(str(report.entry.post_name))
	return Texts.t(_key(), args)


## The key of the headline: what an attack on the base, a post or the kernel
## says of each way it ended.
func _key() -> StringName:
	var target := report.target()
	match report.outcome():
		AttackOutcome.Value.REPELLED:
			if target == AttackTarget.Value.POST:
				return &"factionPostRepelled"
			return &"factionKernelRepelled" if target == AttackTarget.Value.KERNEL else &"factionAttackRepelled"
		AttackOutcome.Value.DAMAGED:
			return &"factionAttackDamaged"
		AttackOutcome.Value.PILLAGED:
			return &"factionAttackPillaged"
		AttackOutcome.Value.POST_TAKEN:
			return &"factionPostTaken"
		AttackOutcome.Value.KERNEL_DAMAGED:
			return &"factionKernelDamaged"
	return &"factionKernelTaken"


## The texts of the losses: the passage destroyed and the units lost.
func _loss_sources() -> Array[Callable]:
	var sources: Array[Callable] = []
	var passage: Variant = report.passage_lost()
	if passage != null:
		sources.append(Texts.t.bind(&"factionPostDescentModuleLost" if passage == BuildingType.Value.DESCENT_MODULE
			else &"factionPostPressureCapsuleLost"))
	var units := report.units_lost()
	var level: Variant = report.level_below()
	if units > 0 and level != null:
		sources.append(Texts.t.bind(&"factionPostUnitsLost", {"count": units, "level": level}))
	if units > 0 and report.target() == AttackTarget.Value.KERNEL:
		sources.append(Texts.t.bind(&"factionKernelGarrisonLost", {"count": units}))
	return sources
