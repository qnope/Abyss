extends TestCase
## test/domain/building/building_degradation_solo_test.dart.


func test_no_building_is_ever_degraded_in_a_balanced_game() -> void:
	var watching := Watching.new(BalancedStrategy.new())
	ScriptRunner.new(60).run(watching, 3)
	assert_eq(watching.degraded, [] as Array[String])


func test_no_building_is_ever_degraded_in_a_conquest_game() -> void:
	var watching := Watching.new(ConquestStrategy.new())
	ScriptRunner.new(60).run(watching, 3)
	assert_eq(watching.degraded, [] as Array[String])


## `_Watching`: plays `inner` and checks, after each of its turns, that no
## building of any player is degraded: nothing lowers the headquarters yet.
class Watching extends GameScript:
	var inner: GameScript
	var degraded: Array[String] = []

	func _init(inner_: GameScript) -> void:
		inner = inner_

	func name() -> String:
		return inner.name()

	func factions() -> Array[FactionPersonality.Value]:
		return inner.factions()

	func play_turn(turn: ScriptTurn) -> void:
		inner.play_turn(turn)
		var game := turn.game
		for player: Player in game.players.values():
			for type: BuildingType.Value in BuildingType.Value.values():
				if player.is_degraded(type):
					degraded.append("%s %s turn %d" % [
						player.name, DartEnum.name_of(BuildingType.Value, type), game.turn,
					])
