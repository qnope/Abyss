extends AttackTurnCase
## attack_turn_section_test.dart: the button that reads the report of an attack.


func test_the_button_opens_the_report_of_the_fight_over_the_summary() -> void:
	var summary := _show(_fought())
	press("Voir le rapport")
	var report := current_modal() as BaseAssaultSummaryPage
	assert_not_null(report)
	assert_eq(modals().depth(), 2, "over the summary")
	assert_not_null(find_text("%s vous a attaqué" % report.entry.opponent_name, report))
	report.close()
	assert_eq(current_modal(), summary, "back to the summary")
	assert_eq(_answers, [], "the summary is still waiting")


func test_each_attack_has_its_own_button() -> void:
	var first := _attack(true)
	var second := _attack(false, KERNEL, Vector2i(2, 2))
	var result := _reported(first)
	result.attacks.append(FactionAttackReport.new("other", "Corail", null, second))
	var section := _section(result)
	assert_eq(section.lines.size(), 2)
	press(section.report_buttons[1])
	assert_eq((current_modal() as BaseAssaultSummaryPage).entry, second)


func test_a_section_outside_any_dialog_opens_nothing() -> void:
	var section := mount(AttackTurnSection.new(_reported(_attack(true)).attacks)) as AttackTurnSection
	press(section.report_buttons[0])
	assert_null(current_modal())
