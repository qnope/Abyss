extends TestCase
## test/domain/volcano/kernel_defence_advisor_test.dart: the garrison a
## kernel needs against an announced kraken wave.

var _wave := VolcanoWaveFactory.from_kernel_level(1)


func _human() -> Player:
	return RaidSamples.kernel_garrison_game(true, 0).human_player()


func test_an_empty_garrison_needs_units_against_a_wave() -> void:
	var player := _human()
	var needed: Variant = KernelDefenceAdvisor.units_for(player, _wave)
	assert_not_null(needed)
	var count: int = needed if needed != null else 0
	assert_true(count > 0)
	assert_eq(KernelDefenceAdvisor.units_for(player, _wave), needed)


func test_counts_the_garrison_already_inside() -> void:
	var player := RaidSamples.kernel_garrison_game(true, 0, 2).human_player()
	var needed: int = KernelDefenceAdvisor.units_for(player, _wave)
	assert_true(needed >= 2)


func test_a_garrison_that_holds_needs_no_more() -> void:
	var player := _human()
	RaidSamples.set_units(player, UnitType.Value.DOME_BREAKER, 40, KernelGarrison.STOCK_KEY)
	assert_eq(KernelDefenceAdvisor.units_for(player, _wave), 40)


func test_the_magma_rampart_of_a_higher_kernel_helps() -> void:
	var player := _human()
	var low: int = KernelDefenceAdvisor.units_for(player, _wave)
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 9
	var high: int = KernelDefenceAdvisor.units_for(player, _wave)
	assert_true(high <= low)


func test_no_number_of_units_holds_a_flood() -> void:
	var flood := MonsterLair.new(MonsterDifficulty.Value.HARD, 2000, MonsterFamily.Value.KRAKEN)
	assert_null(KernelDefenceAdvisor.units_for(_human(), flood))


## Not in the Dart file: the answers of the Dart rules, read by a scratch
## script run with `dart run` on lib/domain, for volcanoPlayer kernels.
func test_advises_as_dart_does() -> void:
	var got := []
	for level: int in [1, 4, 9]:
		var player := RaidSamples.volcano_player(level)
		got.append(KernelDefenceAdvisor.units_for(player, VolcanoWaveFactory.from_kernel_level(level)))
	var guarded := RaidSamples.volcano_player(
		5, {UnitType.Value.GUARDIAN: 10, UnitType.Value.DOME_BREAKER: 4}
	)
	got.append(KernelDefenceAdvisor.units_for(guarded, VolcanoWaveFactory.from_kernel_level(5, 102)))
	assert_eq(got, [24, 54, 109, 51])


## Not in the Dart file: the remembered answers are forgotten between test
## files.
func test_forgets_its_answers_on_a_reset() -> void:
	var player := _human()
	var needed: Variant = KernelDefenceAdvisor.units_for(player, _wave)
	KernelDefenceAdvisor.debug_reset()
	assert_eq(KernelDefenceAdvisor.units_for(player, _wave), needed)


## Not in the Dart file: a kernel at level 0 fights with no magma rampart;
## the Dart rules answer 26 (`volcanoPlayer(kernelLevel: 0)`).
func test_a_kernel_at_level_0_fights_without_a_rampart() -> void:
	var player := RaidSamples.volcano_player(0)
	assert_eq(KernelDefenceAdvisor.units_for(player, VolcanoWaveFactory.from_kernel_level(1)), 26)
