extends TestCase
## Not in the Dart files: held_post_report_test.dart and
## held_kernel_report_test.dart read the attacks on what the human holds
## through the end of a turn (`turn`); these call HeldAttackReports, which
## the end of the turn reads them from, on the turn of the attack.

const HARPOONIST := UnitType.Value.HARPOONIST


## A post of `kind` the human holds, with `below` on the level it opens
## onto, struck by the first faction's `army`.
func _struck(
	kind: TransitionBaseType.Value, below: Dictionary[UnitType.Value, int] = {HARPOONIST: 5},
	army: Dictionary[UnitType.Value, int] = PostWar.HORDE,
) -> PostWar:
	var war := PostWar.new(kind, 7, true)
	war.arm(war.attacker(), army)
	war.put(war.human(), war.below(), below)
	ActionExecutor.new().execute(war.strike(army), war.game, war.attacker())
	return war


func test_a_faille_taken_from_the_human_is_reported_with_its_losses() -> void:
	var war := _struck(TransitionBaseType.Value.FAILLE)
	var reports := HeldAttackReports.of(war.game)
	assert_eq(reports.size(), 1)
	var report := reports[0]
	assert_eq([report.target(), report.outcome()], [AttackTarget.Value.POST, AttackOutcome.Value.POST_TAKEN])
	assert_eq([report.attacker_id, report.attacker_name], [war.attacker().id, war.attacker().name])
	assert_eq(report.personality, war.game.factions()[0].personality)
	assert_eq(report.post().code(), war.post.name)
	assert_eq(report.passage_lost(), BuildingType.Value.DESCENT_MODULE)
	assert_eq([report.units_lost(), report.level_below()], [5, 2])


func test_a_cheminee_held_is_a_repelled_attack() -> void:
	var war := _struck(TransitionBaseType.Value.CHEMINEE, PostWar.WALL, {HARPOONIST: 4})
	var report := HeldAttackReports.of(war.game)[0]
	assert_eq([report.target(), report.outcome(), report.units_lost()], [AttackTarget.Value.POST, AttackOutcome.Value.REPELLED, 0])


func test_is_reported_on_the_turn_of_the_attack_only() -> void:
	var war := _struck(TransitionBaseType.Value.FAILLE)
	war.game.turn += 1
	assert_eq(HeldAttackReports.of(war.game), [])


func test_a_post_the_human_takes_an_attack_on_the_base_and_a_wave_are_not_reported() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.post.captured_by = war.attacker().id
	war.arm(war.human())
	ActionExecutor.new().execute(war.strike(PostWar.HORDE), war.game, war.human())
	var entry := HistorySamples.base_assault_entry(true, true)
	entry.turn = war.game.turn
	war.human().add_history_entry(entry)
	var volcano := HistorySamples.volcano_entry(false)
	volcano.turn = war.game.turn
	war.human().add_history_entry(volcano)
	assert_eq(HeldAttackReports.of(war.game), [])


func test_an_attacker_no_longer_in_the_game_is_reported_by_its_name() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	war.game.turn = 14
	war.human().add_history_entry(HistorySamples.base_assault_entry(true, true, war.post.name))
	var report := HeldAttackReports.of(war.game)[0]
	assert_eq([report.attacker_id, report.attacker_name, report.personality], ["Nacre", "Nacre", null])


func test_a_kernel_struck_is_reported_with_its_faction() -> void:
	var war := KernelWar.new(3, 7, true)
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	ActionExecutor.new().execute(war.strike(KernelWar.HORDE), war.game, war.attacker())
	var report := HeldAttackReports.of(war.game)[0]
	assert_eq([report.target(), report.outcome()], [AttackTarget.Value.KERNEL, AttackOutcome.Value.KERNEL_DAMAGED])
	assert_eq([report.attacker_id, report.personality], [war.attacker().id, war.game.factions()[0].personality])
	assert_eq([report.entry.rampart_before, report.entry.rampart_after], [3, 2])


## Not in the Dart files: the human is never the attacker it reports, even
## named as the entry's opponent.
func test_the_human_is_never_the_attacker() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	var entry := HistorySamples.base_assault_entry(true, true, war.post.name)
	entry.turn = war.game.turn
	entry.opponent_name = war.human().name
	war.human().add_history_entry(entry)
	var report := HeldAttackReports.of(war.game)[0]
	assert_eq([report.attacker_id, report.attacker_name], [war.human().name, war.human().name])
