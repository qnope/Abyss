extends TestCase
## test/domain/action/held_attack_report/held_kernel_report_test.dart: the
## attacks on the kernel the human holds, reported by the end of the turn.


## The kernel the human holds at `level` with `garrison`, struck by the
## first faction's `army`.
static func _struck(
	level := 3,
	garrison: Dictionary[UnitType.Value, int] = KernelWar.SMALL_GARRISON,
	army: Dictionary[UnitType.Value, int] = KernelWar.HORDE,
) -> KernelWar:
	var war := KernelWar.new(level, 7, true)
	war.arm(army)
	war.garrison(garrison)
	ActionExecutor.new().execute(war.strike(army), war.game, war.attacker())
	return war


func _report_of(war: KernelWar) -> FactionAttackReport:
	var result: EndTurnActionResult = EndTurnAction.new(DartRandom.new(1), false).execute(war.game, war.human())
	var attacks := result.turn_result.attacks
	assert_eq(attacks.size(), 1)
	return attacks[0]


func test_a_won_attack_that_leaves_the_kernel_costs_it_a_level() -> void:
	var war := _struck()

	var report := _report_of(war)

	assert_eq(report.target(), AttackTarget.Value.KERNEL)
	assert_eq(report.outcome(), AttackOutcome.Value.KERNEL_DAMAGED)
	assert_eq(report.attacker_id, war.attacker().id)
	assert_eq(report.personality, war.game.factions()[0].personality)
	assert_eq(report.entry.rampart_before, 3)
	assert_eq(report.entry.rampart_after, 2)
	var dead := 0
	for type: UnitType.Value in report.entry.dead:
		dead += report.entry.dead[type]
	assert_true(dead > 0)
	assert_eq(report.units_lost(), dead)


func test_a_kernel_brought_to_level_0_is_taken_with_its_garrison() -> void:
	var war := _struck(1)

	var report := _report_of(war)

	assert_eq(report.outcome(), AttackOutcome.Value.KERNEL_TAKEN)
	assert_eq(report.units_lost(), KernelWar.SMALL_GARRISON[UnitType.Value.HARPOONIST])
	assert_null(report.level_below())
	assert_null(report.passage_lost())


func test_a_garrison_that_holds_repels_the_attack() -> void:
	var war := _struck(3, KernelWar.FORTRESS, {UnitType.Value.HARPOONIST: 4})

	var report := _report_of(war)

	assert_eq(report.target(), AttackTarget.Value.KERNEL)
	assert_eq(report.outcome(), AttackOutcome.Value.REPELLED)
	assert_eq(report.units_lost(), 0)
