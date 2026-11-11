extends UiTestCase
## test/presentation/widgets/turn/objective_turn_section_test.dart and
## exploration_summary_section_test.dart: the objectives completed and ended,
## and the exploring of the scouts, in the summary of a turn.

const Res := ResourceType.Value
const Outcome := TemporaryObjectiveOutcome.Value
const WRECK := TemporaryObjectiveKind.Value.WRECK
const PREDATORS := TemporaryObjectiveKind.Value.PREDATORS


func _result(objectives: Array[ObjectiveCompletion] = [], ended: Array[TemporaryObjectiveEnd] = [],
		explored: Array[ExplorationResult] = []) -> TurnResult:
	var none: Array[BuildingType.Value] = []
	var turn := TurnResult.new([], 3, 4, false, none, {}, explored)
	turn.objectives = objectives
	turn.temporary_objectives = ended
	return turn


func _completion(id: ObjectiveId.Value, credited: Dictionary[Res, int]) -> ObjectiveCompletion:
	return ObjectiveCompletion.new(ObjectiveCatalog.by_id(id), credited)


func _ended(kind: TemporaryObjectiveKind.Value, outcome: Outcome) -> TemporaryObjectiveEnd:
	return TemporaryObjectiveEnd.new(TemporaryObjective.new(kind, 17), outcome)


func _show(lines: Array[Control]) -> VBoxContainer:
	var column := VBoxContainer.new()
	for line in lines:
		column.add_child(line)
	mount(column)
	return column


func _explored(x: int, y: int, cells: int, notable: Array[CellContentType.Value] = []) -> ExplorationResult:
	return ExplorationResult.new(GridPosition.new(x, y), cells, notable)


func test_has_content_only_with_objectives_completed_or_ended() -> void:
	assert_false(ObjectiveTurnSection.has_content(_result()))
	assert_eq(ObjectiveTurnSection.of(_result()), [])
	assert_true(ObjectiveTurnSection.has_content(_result([_completion(ObjectiveId.Value.HQ_LEVEL_1, {})])))
	assert_true(ObjectiveTurnSection.has_content(_result([], [_ended(WRECK, Outcome.DONE)])))


func test_a_completed_objective_shows_its_credited_reward() -> void:
	_show(ObjectiveTurnSection.of(_result([_completion(ObjectiveId.Value.HQ_LEVEL_1, {Res.CORAL: 30, Res.ORE: 12})])))
	assert_not_null(find_text("Objectif accompli : Monte le QG au niveau 1 (+30 corail, +12 minerai)"))


func test_a_completion_crediting_nothing_has_no_reward() -> void:
	_show(ObjectiveTurnSection.of(_result([_completion(ObjectiveId.Value.KERNEL_LEVEL_10, {})])))
	assert_not_null(find_text("Objectif accompli : Monte le Noyau au niveau 10"))


func test_a_temporary_objective_done_is_accomplished() -> void:
	_show(ObjectiveTurnSection.of(_result([], [_ended(WRECK, Outcome.DONE)])))
	assert_not_null(find_text("Objectif accompli : Fouille l'épave d'ici la fin du tour 17"))


func test_a_temporary_objective_missed_is_struck_through() -> void:
	for outcome: Outcome in [Outcome.EXPIRED, Outcome.FAILED]:
		var lines := ObjectiveTurnSection.of(_result([], [_ended(WRECK, outcome)]))
		var line := lines[1] as MissedObjectiveLine
		assert_true(line.label.text.begins_with("[s]"))
		assert_eq(line.label.get_parsed_text(), "Fouille l'épave d'ici la fin du tour 17 (raté)")
		_show(lines)


func test_the_section_starts_with_a_divider() -> void:
	var lines := ObjectiveTurnSection.of(_result([_completion(ObjectiveId.Value.HQ_LEVEL_1, {})]))
	assert_true(lines[0] is HSeparator)
	_show(lines)


func test_speaks_english_and_spanish() -> void:
	var lines := _show(ObjectiveTurnSection.of(_result([_completion(ObjectiveId.Value.KERNEL_LEVEL_10, {})],
			[_ended(PREDATORS, Outcome.FAILED)])))
	var missed := lines.get_child(2) as MissedObjectiveLine
	use_language("en")
	assert_not_null(find_text("Objective complete: Raise the Core to level 10"))
	assert_eq(missed.label.get_parsed_text(), "Repel the predator shoal (missed)")
	use_language("es")
	assert_not_null(find_text("Objetivo cumplido: Sube el Núcleo al nivel 10"))
	assert_eq(missed.label.get_parsed_text(), "Repele el banco de depredadores (fallido)")
	assert_no_raw_keys(lines)


func test_the_exploration_sums_the_new_cells_of_every_exploration() -> void:
	_show(ExplorationTurnSection.of(_result([], [], [_explored(1, 2, 4), _explored(7, 3, 5)])))
	assert_not_null(find_text("Exploration : 9 nouvelles cellules"))
	assert_not_null(find_text("(1, 2) → 4 cellules"))
	assert_not_null(find_text("(7, 3) → 5 cellules"))


func test_the_exploration_lists_the_notable_content_found() -> void:
	var found: Array[CellContentType.Value] = [CellContentType.Value.RUINS, CellContentType.Value.MONSTER_LAIR]
	_show(ExplorationTurnSection.of(_result([], [], [_explored(0, 6, 9, found)])))
	assert_not_null(find_text("(0, 6) → 9 cellules (Ruines, Repaire)"))


func test_no_exploration_no_section_and_a_single_cell_is_singular() -> void:
	assert_eq(ExplorationTurnSection.of(_result()), [])
	_show(ExplorationTurnSection.of(_result([], [], [_explored(0, 0, 1)])))
	assert_not_null(find_text("Exploration : 1 nouvelle cellule"))


func test_the_exploration_speaks_english_and_spanish() -> void:
	var lines := _show(ExplorationTurnSection.of(_result([], [], [_explored(1, 2, 4)])))
	use_language("en")
	assert_not_null(find_text("Exploration: 4 new cells"))
	assert_no_raw_keys(lines)
	use_language("es")
	assert_no_raw_keys(lines)


func test_the_summary_puts_the_exploration_first_and_the_objectives_last() -> void:
	var turn := _result([_completion(ObjectiveId.Value.HQ_LEVEL_1, {})], [], [_explored(1, 2, 4)])
	turn.had_recruited_units = true
	var shown := texts(_show(SummarySections.of(turn)))
	var explored := shown.find("Exploration : 4 nouvelles cellules")
	var completed := shown.find("Objectif accompli : Monte le QG au niveau 1")
	assert_true(explored >= 0 and completed > explored)
	assert_true(completed < shown.size() - 1, "the recruitment comes after")
