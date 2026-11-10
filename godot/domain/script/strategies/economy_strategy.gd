class_name EconomyStrategy
extends GameScript
## lib/domain/script/strategies/economy_strategy.dart: "Tout éco", grows
## production as fast as it can and never trains a single defender. Raids
## should end it.

const BUILD_ORDER: Array[BuildingType.Value] = [
	BuildingType.Value.SOLAR_PANEL,
	BuildingType.Value.ALGAE_FARM,
	BuildingType.Value.CORAL_MINE,
	BuildingType.Value.ORE_EXTRACTOR,
	BuildingType.Value.HEADQUARTERS,
]


func name() -> String:
	return "economy"


func play_turn(turn: ScriptTurn) -> void:
	ScriptTurnMoves.upgrade_in_order(turn, BUILD_ORDER)
