class_name War
extends RefCounted
## The GDScript twin of `War` and `warGame` of
## test/helpers/faction_war_helper.dart: a game against two factions whose
## first one (`attacker()`) stands on its war slot with the horde of
## AssaultSamples and two scouts; nobody else has a unit, the tutorial of
## the human is over.

var game: Game


## `warGame(from:)`: the first turn from `from` where the slot comes.
func _init(from := 12) -> void:
	game = GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 2)
	game.turn = from
	while not FactionWar.is_due(game.turn, game.factions()[0].personality):
		game.turn += 1
	ObjectiveMigration.state_of(game, human()).tutorial_enabled = false
	var army: Dictionary[UnitType.Value, int] = {}
	army.merge(AssaultSamples.HORDE)
	army[UnitType.Value.SCOUT] = 2
	AssaultSamples.station(attacker(), army)
	AssaultSamples.station(human(), {})
	AssaultSamples.station(rival(), {})


func attacker() -> Player:
	return game.players[game.factions()[0].id()]


func rival() -> Player:
	return game.players[game.factions()[1].id()]


func human() -> Player:
	return game.human_player()


func personality() -> FactionPersonality.Value:
	return game.factions()[0].personality


## The faction plays its war, its dice `Random(2)`.
func play() -> void:
	FactionWar.play(turn(), personality())


## `FactionTurn(game, attacker, ActionExecutor(), Random(2))`.
func turn() -> FactionTurn:
	return FactionTurn.new(game, attacker(), ActionExecutor.new(), DartRandom.new(2, false))


func see(base: Player) -> void:
	attacker().add_revealed_cell(1, GridPosition.new(base.base_x, base.base_y))


## `isDue(war)` of faction_spy_test.dart.
func is_due() -> bool:
	return FactionWar.is_due(game.turn, personality())


## The assault entries of `player`'s history.
static func assaults(player: Player) -> Array[BaseAssaultEntry]:
	var found: Array[BaseAssaultEntry] = []
	for e: HistoryEntry in player.history_entries:
		if e is BaseAssaultEntry:
			found.append(e as BaseAssaultEntry)
	return found
