extends TestCase
## test/domain/action/announce_attack/announced_attack_report_test.dart: the
## attacks on the base reported by the end of the turn.

const CULT := FactionPersonality.Value.ANGLER_CULT


static func _end_turn(game: Game) -> TurnResult:
	var result: EndTurnActionResult = EndTurnAction.new(DartRandom.new(1), false).execute(game, game.human_player())
	return result.turn_result


static func _faction_game() -> Game:
	var game := AssaultSamples.announce_game(12, Faction.new(CULT).id())
	game.saved_factions.assign([CULT])
	return game


## The rival of `game` announces its attack on a bare base.
static func _announced(game: Game) -> Game:
	AssaultSamples.station(game.human_player(), {})
	AssaultSamples.announce().execute(game, AssaultSamples.rival_of(game))
	return game


## The single attack the end of the turn reports.
func _single(game: Game) -> FactionAttackReport:
	var attacks := _end_turn(game).attacks
	assert_eq(attacks.size(), 1)
	return attacks[0]


func test_a_turn_without_an_attack_reports_none() -> void:
	assert_true(_end_turn(AssaultSamples.announce_game()).attacks.is_empty())


func test_the_turn_the_faction_attacks_reports_it_with_its_faction() -> void:
	var game := _announced(_faction_game())

	var report := _single(game)

	var rival := AssaultSamples.rival_of(game)
	assert_eq(report.attacker_id, rival.id)
	assert_eq(report.personality, CULT)
	assert_eq(report.attacker_name, rival.name)
	assert_true(report.entry.defending)
	assert_true(report.entry.victory)
	assert_eq(report.outcome(), AttackOutcome.Value.PILLAGED)


func test_a_repelled_attack_reads_as_repelled() -> void:
	var game := _announced(_faction_game())
	AssaultSamples.station(game.human_player(), AssaultSamples.WALL)

	var report := _single(game)

	assert_false(report.entry.victory)
	assert_eq(report.outcome(), AttackOutcome.Value.REPELLED)


func test_a_won_attack_on_empty_stocks_only_damages_the_base() -> void:
	var game := _announced(_faction_game())
	for resource: GameResource in game.human_player().resources.values():
		resource.amount = 0

	assert_eq(_single(game).outcome(), AttackOutcome.Value.DAMAGED)


func test_a_rival_that_is_not_a_faction_has_no_personality() -> void:
	var game := _announced(AssaultSamples.announce_game())

	assert_null(_single(game).personality)
