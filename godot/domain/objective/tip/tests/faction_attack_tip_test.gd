extends TestCase
## test/domain/objective/tip/faction_attack_tip_test.dart: the tip of the
## first attack of a faction on the human base.

const Id := TipId.Value

var game: Game


func before_each() -> void:
	game = AssaultSamples.announce_game()
	AssaultSamples.station(game.human_player(), {})
	var state := ObjectiveMigration.state_of(game, game.human_player())
	state.tips_enabled = true
	# The other tips of a base at level 5 are out of the way.
	for id: Id in Id.values():
		if id != Id.FACTION_ATTACK:
			state.mark_seen(id)


func _next() -> Variant:
	var tip := TipCatalog.next_for(game, game.human_player())
	return null if tip == null else tip.id


func _attacked(post: Variant = null) -> void:
	var entry := HistorySamples.base_assault_entry(true, true)
	entry.post_name = post
	game.human_player().add_history_entry(entry)


func test_is_filed_with_the_threats() -> void:
	assert_eq(TipCatalog.by_id(Id.FACTION_ATTACK).category, TipCategory.Value.THREATS)


func test_none_while_no_faction_has_attacked_the_base() -> void:
	assert_null(_next())


func test_none_for_an_attack_of_the_human_on_another_base() -> void:
	game.human_player().add_history_entry(HistorySamples.base_assault_entry(true, false))
	assert_null(_next())


func test_none_for_an_attack_on_a_post() -> void:
	_attacked("Faille Beta")
	assert_null(_next())


func test_opens_after_the_first_attack_on_the_base() -> void:
	_attacked()
	assert_eq(_next(), Id.FACTION_ATTACK)


func test_opens_once_seen_it_never_comes_back() -> void:
	_attacked()
	ObjectiveMigration.state_of(game, game.human_player()).mark_seen(Id.FACTION_ATTACK)
	assert_null(_next())


func test_stays_shut_while_the_tips_are_off() -> void:
	_attacked()
	ObjectiveMigration.state_of(game, game.human_player()).tips_enabled = false
	assert_null(_next())
