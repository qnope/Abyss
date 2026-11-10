extends TestCase
## test/domain/action/held_attack_report/faction_attack_report_test.dart:
## what the report of an attack on the human reads from the entry it holds.

const GUARDIAN := UnitType.Value.GUARDIAN
const SCOUT := UnitType.Value.SCOUT


func _report(entry: BaseAssaultEntry) -> FactionAttackReport:
	return FactionAttackReport.new("nacre", "Nacre", null, entry)


func test_a_base_attack_has_no_post_passage_nor_losses_below() -> void:
	var report := _report(HistorySamples.base_assault_entry(true, true))
	assert_eq(report.target(), AttackTarget.Value.BASE)
	assert_null(report.post())
	assert_null(report.passage_lost())
	assert_null(report.level_below())
	assert_eq(report.units_lost(), 0)


func test_a_post_of_an_unknown_name_has_no_passage_nor_level() -> void:
	var entry := HistorySamples.base_assault_entry(true, true, "Atlantide")
	var report := _report(entry)
	assert_eq(report.target(), AttackTarget.Value.POST)
	assert_eq(report.outcome(), AttackOutcome.Value.POST_TAKEN)
	assert_null(report.post())
	assert_null(report.passage_lost())
	assert_null(report.level_below())


func test_a_kernel_report_reads_its_target_from_the_entry() -> void:
	var report := _report(HistorySamples.base_assault_entry(true, true, "volcanicKernel", Vector2i(1, 0)))
	assert_eq(report.target(), AttackTarget.Value.KERNEL)
	assert_eq(report.outcome(), AttackOutcome.Value.KERNEL_TAKEN)
	assert_null(report.post())


## Not in the Dart file: the names and the order of the two enums.
func test_the_enums_have_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(AttackTarget.Value), PackedStringArray(["base", "post", "kernel"]))
	assert_eq(DartEnum.names(AttackOutcome.Value), PackedStringArray([
		"repelled", "damaged", "pillaged", "postTaken", "kernelDamaged", "kernelTaken",
	]))


## Not in the Dart file (the tests of the end of a turn read it): `of` names
## the attacker and its personality, null for a player who is no faction.
func test_of_reads_the_attacker_and_its_personality() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	var entry := HistorySamples.base_assault_entry(true, true)
	var report := FactionAttackReport.of(war.game, war.attacker(), entry)
	assert_eq([report.attacker_id, report.attacker_name], [war.attacker().id, war.attacker().name])
	assert_eq(report.personality, war.game.factions()[0].personality)
	assert_true(report.entry == entry)
	var human := FactionAttackReport.of(war.game, war.human(), entry)
	assert_eq([human.attacker_id, human.personality], [war.human().id, null])


## Not in the Dart file: a base held, razed, or razed and pillaged.
func test_the_outcomes_of_a_base_attack() -> void:
	assert_eq(_report(HistorySamples.base_assault_entry(false, true)).outcome(), AttackOutcome.Value.REPELLED)
	var razed := HistorySamples.base_assault_entry(true, true)
	razed.pillaged = {ResourceType.Value.ALGAE: 0}
	assert_eq(_report(razed).outcome(), AttackOutcome.Value.DAMAGED)
	razed.pillaged = {ResourceType.Value.ALGAE: 0, ResourceType.Value.CORAL: 4}
	assert_eq(_report(razed).outcome(), AttackOutcome.Value.PILLAGED)
	assert_eq(_report(razed).units_lost(), 0)


## Not in the Dart file: a Faille taken costs its module, the level below
## and the units dead or lost with it; held, it costs nothing.
func test_a_post_taken_and_a_post_held() -> void:
	var dead: Dictionary[UnitType.Value, int] = {GUARDIAN: 2, SCOUT: 1}
	var lost: Dictionary[UnitType.Value, int] = {SCOUT: 4}
	var taken := _report(HistorySamples.base_assault_entry(true, true, "faille:1", null, lost, dead))
	assert_true(taken.post().equals(TransitionBaseName.new(TransitionBaseType.Value.FAILLE, 1)))
	assert_eq(taken.passage_lost(), BuildingType.Value.DESCENT_MODULE)
	assert_eq(taken.level_below(), 2)
	assert_eq(taken.units_lost(), 7)
	var bare := _report(HistorySamples.base_assault_entry(true, true, "cheminee:0", null, lost, dead, false))
	assert_null(bare.passage_lost())
	assert_eq(bare.level_below(), 3)
	var held := _report(HistorySamples.base_assault_entry(false, true, "cheminee:0", null, lost, dead))
	assert_eq(held.outcome(), AttackOutcome.Value.REPELLED)
	assert_null(held.passage_lost())
	assert_eq(held.units_lost(), 0)


## Not in the Dart file: a kernel down one level costs its dead only; taken,
## its garrison too.
func test_a_kernel_damaged_and_a_kernel_taken() -> void:
	var dead: Dictionary[UnitType.Value, int] = {GUARDIAN: 3}
	var lost: Dictionary[UnitType.Value, int] = {SCOUT: 5}
	var damaged := _report(HistorySamples.base_assault_entry(true, true, "volcanicKernel", Vector2i(3, 2), lost, dead))
	assert_eq(damaged.outcome(), AttackOutcome.Value.KERNEL_DAMAGED)
	assert_eq(damaged.units_lost(), 3)
	assert_null(damaged.level_below())
	var last_level := _report(HistorySamples.base_assault_entry(true, true, "volcanicKernel", Vector2i(2, 1)))
	assert_eq(last_level.outcome(), AttackOutcome.Value.KERNEL_DAMAGED)
	var taken := _report(HistorySamples.base_assault_entry(true, true, "volcanicKernel", Vector2i(1, 0), lost, dead))
	assert_eq(taken.units_lost(), 8)
