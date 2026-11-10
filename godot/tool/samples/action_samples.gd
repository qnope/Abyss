class_name ActionSamples
extends RefCounted
## Sample players and games for the tests of the actions: what the Dart
## tests of test/domain/action/ write inline (`Player(id: 'test', name:
## 'Test', resources: {...}, buildings: {...})`) and what their helpers
## build (`*_helper.dart`).

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


## The player "test" named "Test", holding the stocks and the buildings
## given (each stock under the default storage), and nothing else.
static func stocked(
	amounts: Dictionary[ResourceType.Value, int],
	levels: Dictionary[BuildingType.Value, int],
	recruited: Array[UnitType.Value] = [],
) -> Player:
	return Player.new(
		"Test", "test", 0, 0, DomainSamples.resources(amounts), DomainSamples.buildings(levels),
		null, null, recruited,
	)


## Stocks of the five resources, in the order of ResourceType.
static func amounts(algae: int, coral: int, ore: int, energy: int, pearl: int) -> Dictionary[ResourceType.Value, int]:
	return {ALGAE: algae, CORAL: coral, ORE: ore, ENERGY: energy, PEARL: pearl}


## The game of `player` alone at `turn`.
static func game_of(player: Player, turn := 1) -> Game:
	return Game.new(player.id, {player.id: player}, turn)

