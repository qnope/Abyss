extends TechTestCase
## What a refused unlock or research tells (the failures the actions give):
## each is told in the sheet, which is read again from the game and stays open.
## A refusal needs a game that changed since the sheet was built, which a
## player cannot press through: the tests spoil the game after opening it.

const Failure := ActionFailure.Value

var _acted := 0


func after_each() -> void:
	if actions.acted.is_connected(_count):
		actions.acted.disconnect(_count)
	_acted = 0


func _count(_result: Variant) -> void:
	_acted += 1


## Opens the sheet of [param target], lets [param spoil] change the game,
## presses [param button] and checks that [param expected] is told.
func _refused(target: TechTarget, spoil: Callable, button: String, expected: ActionFailure.Value) -> TechTargetSheet:
	actions.acted.connect(_count)
	var sheet := TechTargetSheet.new(actions, target)
	modals().open(sheet)
	spoil.call()
	press(button)
	assert_eq(sheet.failure, ActionFailureTexts.message(expected))
	assert_not_null(find_text(sheet.failure, sheet), "told in the sheet")
	assert_false(sheet.is_closed())
	assert_eq(_acted, 0, "nothing changed, nothing to save")
	return sheet


func _ready_to_unlock() -> void:
	set_lab(1)
	fill_stores()


func _ready_to_research(level: int, lab: int) -> void:
	set_lab(lab)
	fill_stores()
	research(Branch.MILITARY, level - 1)


func test_the_stock_ran_short() -> void:
	_ready_to_unlock()
	var sheet := _refused(TechTarget.new(Branch.MILITARY), func() -> void:
		human.resources[ResourceType.Value.ORE].amount = 0, "Débloquer", Failure.NOT_ENOUGH_RESOURCES)
	assert_eq(sheet.panel.cost_row.amounts[ResourceType.Value.ORE].get_theme_color(&"font_color"),
		AbyssColors.ERROR, "the panel is read again")
	assert_false(human.tech_branches[Branch.MILITARY].unlocked)


func test_the_laboratory_was_lost() -> void:
	_ready_to_unlock()
	_refused(TechTarget.new(Branch.MILITARY), func() -> void: set_lab(0), "Débloquer", Failure.LABORATORY_REQUIRED)


func test_the_laboratory_is_too_low_for_the_level() -> void:
	_ready_to_research(1, 1)
	_refused(TechTarget.new(Branch.MILITARY, 1), func() -> void: set_lab(0), "Rechercher",
		Failure.LABORATORY_LEVEL_TOO_LOW)


func test_the_branch_was_unlocked_meanwhile() -> void:
	_ready_to_unlock()
	var sheet := _refused(TechTarget.new(Branch.MILITARY), func() -> void:
		human.tech_branches[Branch.MILITARY].unlocked = true, "Débloquer", Failure.BRANCH_ALREADY_UNLOCKED)
	assert_not_null(find_text("Acquis ✓", sheet), "the panel is read again")


func test_the_branch_was_locked_meanwhile() -> void:
	_ready_to_research(1, 1)
	_refused(TechTarget.new(Branch.MILITARY, 1), func() -> void:
		human.tech_branches[Branch.MILITARY].unlocked = false, "Rechercher", Failure.BRANCH_LOCKED)


func test_the_branch_is_not_in_the_game() -> void:
	_ready_to_unlock()
	_refused(TechTarget.new(Branch.MILITARY), func() -> void:
		human.tech_branches.erase(Branch.MILITARY), "Débloquer", Failure.BRANCH_NOT_FOUND)


func test_the_research_of_the_turn_was_spent() -> void:
	_ready_to_research(1, 1)
	var sheet := _refused(TechTarget.new(Branch.MILITARY, 1), func() -> void: human.worksite.research = 1,
		"Rechercher", Failure.RESEARCH_ALREADY_STARTED)
	assert_not_null(find_text("Une recherche par tour : attends le prochain tour", sheet))


func test_the_last_level_was_reached_meanwhile() -> void:
	_ready_to_research(5, 5)
	_refused(TechTarget.new(Branch.MILITARY, 5), func() -> void:
		human.tech_branches[Branch.MILITARY].research_level = 5, "Rechercher", Failure.MAX_LEVEL_REACHED)


func test_a_refusal_is_told_in_the_language_on() -> void:
	_ready_to_unlock()
	var sheet := _refused(TechTarget.new(Branch.MILITARY), func() -> void: set_lab(0), "Débloquer",
		Failure.LABORATORY_REQUIRED)
	use_language("en")
	assert_eq(sheet.failure, ActionFailureTexts.message(Failure.LABORATORY_REQUIRED))
	assert_not_null(find_text("Laboratory required", sheet))
	use_language("es")
	assert_no_raw_keys(sheet)


func test_a_refusal_goes_once_the_sheet_is_pressed_again_with_success() -> void:
	_ready_to_unlock()
	var sheet := _refused(TechTarget.new(Branch.MILITARY), func() -> void: set_lab(0), "Débloquer",
		Failure.LABORATORY_REQUIRED)
	set_lab(1)
	sheet.refresh()
	press("Débloquer")
	assert_true(human.tech_branches[Branch.MILITARY].unlocked)
	assert_true(sheet.is_closed())
