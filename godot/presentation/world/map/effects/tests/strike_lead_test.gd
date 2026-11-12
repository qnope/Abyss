extends TestCase
## test/presentation/widgets/map/effects/strike/strike_lead_test.dart, and the
## figures that stand for an army on the map.

const Unit := UnitType.Value


func _sent(counts: Dictionary) -> Dictionary[UnitType.Value, int]:
	var sent: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in counts:
		sent[type] = counts[type]
	return sent


func test_the_lead_is_the_unit_type_sent_in_the_largest_number() -> void:
	assert_eq(StrikeLead.of(_sent({Unit.SCOUT: 5, Unit.SABOTEUR: 1})), Unit.SCOUT)


func test_between_types_sent_as_many_the_stronger_attacker_leads() -> void:
	assert_eq(StrikeLead.of(_sent({Unit.SCOUT: 3, Unit.HARPOONIST: 3})), Unit.HARPOONIST)
	assert_eq(StrikeLead.of(_sent({Unit.SABOTEUR: 2, Unit.DOME_BREAKER: 2})), Unit.SABOTEUR)


func test_between_types_as_many_and_as_strong_the_first_type_leads() -> void:
	assert_eq(StrikeLead.of(_sent({Unit.GUARDIAN: 2, Unit.SCOUT: 2})), Unit.SCOUT)
	assert_eq(StrikeLead.of(_sent({Unit.SCOUT: 2, Unit.GUARDIAN: 2})), Unit.SCOUT)


func test_a_type_sent_in_no_number_is_ignored_and_an_empty_army_has_no_lead() -> void:
	assert_eq(StrikeLead.of(_sent({Unit.SABOTEUR: 0, Unit.SCOUT: 1})), Unit.SCOUT)
	assert_null(StrikeLead.of({}))


func test_the_figures_are_as_many_as_the_squad_would_show_up_to_three() -> void:
	assert_eq(StrikeLead.figures(_sent({Unit.SCOUT: 1})), [Unit.SCOUT] as Array[UnitType.Value])
	assert_eq(StrikeLead.figures(_sent({Unit.SCOUT: 4})).size(), 2)
	assert_eq(StrikeLead.figures(_sent({Unit.SCOUT: 12})).size(), 3)
	assert_eq(StrikeLead.figures(_sent({Unit.SCOUT: 400})).size(), StrikeLead.MAX_FIGURES)
	assert_eq(StrikeLead.figures({}), [] as Array[UnitType.Value])


func test_the_figures_are_told_by_the_types_sent_the_lead_first() -> void:
	var sent := _sent({Unit.SCOUT: 4, Unit.SABOTEUR: 2, Unit.HARPOONIST: 8})
	assert_eq(StrikeLead.figures(sent),
		[Unit.HARPOONIST, Unit.SCOUT, Unit.SABOTEUR] as Array[UnitType.Value])
	assert_eq(StrikeLead.figures(_sent({Unit.SCOUT: 20, Unit.SABOTEUR: 1})),
		[Unit.SCOUT, Unit.SABOTEUR, Unit.SCOUT] as Array[UnitType.Value], "round again for a larger army")
