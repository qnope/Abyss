extends ThreatWarningsCase
## The warnings about the kernel and the Faille
## (widgets/volcano/volcano_due_warning_test.dart,
## widgets/leviathan/leviathan_due_warning_test.dart).


func test_warns_of_a_wave_on_an_unguarded_kernel() -> void:
	var wave := VolcanoWaveFactory.from_kernel_level(1)
	_human.volcano_state.announce(wave, 12)
	assert_eq(texts(_volcano()), PackedStringArray([
		"Vague sur le Noyau ce tour : %s, et aucune garnison. Le Noyau perdra probablement un niveau." % MonsterLairTexts.wave_label(wave)]))
	assert_no_raw_keys()


func test_no_wave_warning_with_a_guard_in_the_kernel_or_a_wave_still_far() -> void:
	_human.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 13)
	assert_null(_volcano())
	_human.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 12)
	KernelGarrison.stock_of(_human)[UnitType.Value.GUARDIAN].count = 1
	assert_null(_volcano())
	_human.volcano_state.clear_incoming()
	assert_null(_volcano())


func test_warns_when_level_2_is_empty_or_too_weak_for_the_guardians() -> void:
	var war := _strike()
	assert_eq(texts(_guardians(war)), PackedStringArray([
		"Le Léviathan frappe ta Faille à la fin du tour, et aucun défenseur ne l'attend au niveau 2."]))
	war.put(war.human(), 2, {UnitType.Value.HARPOONIST: 1})
	assert_eq(texts(_guardians(war)), PackedStringArray([
		"Le Léviathan frappe ta Faille à la fin du tour, et seulement 1 défenseur l'attend au niveau 2."]))


func test_no_guardian_warning_before_the_strike_or_once_level_2_should_hold() -> void:
	assert_null(_guardians(_strike(true)))
	var war := _strike()
	var needed: int = LeviathanDefenceAdvisor.units_for(war.game, war.human(), 2)
	war.put(war.human(), 2, {UnitType.Value.HARPOONIST: needed})
	assert_null(_guardians(war))
