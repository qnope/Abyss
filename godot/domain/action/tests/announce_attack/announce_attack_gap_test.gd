extends TestCase
## test/domain/action/announce_attack/announce_attack_gap_test.dart: the
## turns between two attacks on the human base, by the difficulty.

const HARPOONIST := UnitType.Value.HARPOONIST


func _reason(game: Game) -> Variant:
	return AssaultSamples.announce().validate(game, AssaultSamples.rival_of(game)).reason


func test_the_harder_the_game_the_closer_the_attacks_can_come() -> void:
	assert_true(Difficulty.attack_gap(Difficulty.Value.EASY) > Difficulty.attack_gap(Difficulty.Value.NORMAL))
	assert_true(Difficulty.attack_gap(Difficulty.Value.NORMAL) > Difficulty.attack_gap(Difficulty.Value.HARD))


func test_a_second_faction_waits_while_an_attack_is_pending() -> void:
	var game := AssaultSamples.announce_game()
	AssaultSamples.announce({HARPOONIST: 10}).execute(game, AssaultSamples.rival_of(game))
	var other := AssaultSamples.announce_game(13, "rival-2")
	other.human_player().raid_state.attacks.append_array(game.human_player().raid_state.attacks)
	assert_eq(_reason(other), ActionFailure.Value.ATTACK_TOO_SOON)


func test_the_gap_runs_from_the_last_attack_fought_on_the_base() -> void:
	var gap := Difficulty.attack_gap(Difficulty.Value.NORMAL)
	var early := AssaultSamples.announce_game(14 + gap - 1)
	early.human_player().add_history_entry(HistorySamples.base_assault_entry(true, true))
	var late := AssaultSamples.announce_game(14 + gap)
	late.human_player().add_history_entry(HistorySamples.base_assault_entry(true, true))
	assert_eq(_reason(early), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_reason(late))


func test_an_attack_of_the_human_on_another_player_does_not_count() -> void:
	var game := AssaultSamples.announce_game(15)
	game.human_player().add_history_entry(HistorySamples.base_assault_entry(true, false))
	assert_null(_reason(game))


func test_an_attack_on_a_post_of_the_human_does_not_count_either() -> void:
	var game := AssaultSamples.announce_game(15)
	var entry := HistorySamples.base_assault_entry(true, true)
	entry.post_name = "Faille Beta"
	game.human_player().add_history_entry(entry)
	assert_null(_reason(game))


## Not in the Dart file: the latest of the attacks pending or fought sets
## the gap, whatever their order, and other entries do not count.
func test_the_latest_attack_sets_the_gap() -> void:
	var gap := Difficulty.attack_gap(Difficulty.Value.NORMAL)
	var game := AssaultSamples.announce_game(14 + gap)
	var human := game.human_player()
	human.raid_state.attacks.append(AnnouncedAttack.new("rival-2", {HARPOONIST: 1}, 13, 1))
	human.add_history_entry(HistorySamples.raid_entry(true))
	human.add_history_entry(HistorySamples.base_assault_entry(true, true))
	var older := HistorySamples.base_assault_entry(true, true)
	older.turn = 2
	human.add_history_entry(older)
	assert_null(_reason(game))
	human.raid_state.attacks.append(AnnouncedAttack.new("rival-3", {HARPOONIST: 1}, 15, 1))
	human.raid_state.attacks.append(AnnouncedAttack.new("rival-4", {HARPOONIST: 1}, 11, 1))
	assert_eq(_reason(game), ActionFailure.Value.ATTACK_TOO_SOON)
