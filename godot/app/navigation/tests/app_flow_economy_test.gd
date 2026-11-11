extends AppFlowCase
## Ten turns of the first playable loop, through the real screens: an economy
## script builds and raises the base, then ends the turn, each turn asked,
## made and told, and the stock follows what the domain makes of it.

const Type := BuildingType.Value
const Res := ResourceType.Value

## What the script raises, turn by turn: the order of a first economy.
const SCRIPT: Array[BuildingType.Value] = [
	Type.HEADQUARTERS, Type.ALGAE_FARM, Type.SOLAR_PANEL, Type.CORAL_MINE, Type.ALGAE_FARM,
	Type.SOLAR_PANEL, Type.HEADQUARTERS, Type.CORAL_MINE, Type.ORE_EXTRACTOR, Type.ALGAE_FARM,
]


func _stock(game: Game) -> Dictionary[ResourceType.Value, int]:
	var stock: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in game.human_player().resources:
		stock[type] = game.human_player().resources[type].amount
	return stock


func test_ten_turns_of_an_economy_grow_the_stock_as_the_domain_says() -> void:
	var game := _save("Alice")
	_flow.play(game)
	var hud := _flow.current as GameHud
	var raised := 0
	for turn in range(1, 11):
		if hud.actions.execute(UpgradeBuildingAction.new(SCRIPT[turn - 1])).is_success:
			raised += 1
		var before := _stock(game)
		var forecast := TurnForecast.of(game)
		press("Tour suivant")
		press("Confirmer")
		var summary := current_modal() as TurnSummary
		assert_eq(summary.title(), "Tour %d → Tour %d" % [turn, turn + 1])
		for change in summary.result.changes:
			var cap := game.human_player().resources[change.type].max_storage
			assert_eq(change.before_amount, before[change.type], "the turn starts from the stock")
			assert_eq(change.produced, forecast.production.get(change.type, 0), "what was announced")
			assert_eq(change.after_amount, mini(before[change.type] + change.produced - change.consumed, cap),
				"the stock is what it made, less what it spent, up to the storage")
		press("OK")
		assert_eq(game.turn, turn + 1)
		assert_eq(_saved_turn(), turn + 1, "saved at each turn")
		assert_eq(hud.turn_bar.turn_label.text, "Tour %d" % (turn + 1))
	assert_true(raised > 0, "the script built something")
	assert_eq(game.status, GameStatus.Value.PLAYING)
	assert_true(_stock(game)[Res.ALGAE] > 0)
	assert_true(game.human_player().resources[Res.CORAL].amount > 0)
	var ends := game.human_player().history_entries.filter(func(e: HistoryEntry) -> bool: return e is TurnEndEntry)
	assert_eq(ends.size(), 10, "a line of history per turn")


func test_the_stock_stops_at_the_storage() -> void:
	var game := _save("Alice")
	game.human_player().buildings[Type.ALGAE_FARM].level = 3
	var algae := game.human_player().resources[Res.ALGAE]
	algae.amount = algae.max_storage - 1
	_flow.play(game)
	press("Tour suivant")
	press("Confirmer")
	assert_eq(algae.amount, algae.max_storage)
	var summary := current_modal() as TurnSummary
	var capped := summary.result.changes.filter(func(c: TurnResourceChange) -> bool: return c.type == Res.ALGAE)
	var change: TurnResourceChange = capped[0]
	assert_true(change.was_capped)
	assert_not_null(find_text("(max atteint)", summary))


func _saved_turn() -> int:
	return _repository.load_all().games[0].turn
