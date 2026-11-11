class_name TechTestCase
extends UiTestCase
## The base of the tests of the research tree: a new game with its actions,
## and helpers to put the laboratory and the branches in the state a test
## needs.

const Branch := TechBranch.Value

var game: Game
var human: Player
var actions: GameActions


func before_each() -> void:
	game = GameFactory.new_single_player("Nemo", 1)
	human = game.human_player()
	actions = GameActions.new(game)


func set_lab(level: int) -> void:
	human.buildings[BuildingType.Value.LABORATORY].level = level


## Unlocks [param branch] and researches it up to [param level], with the
## [param options] taken at its choice nodes (levels 2 then 4).
func research(branch: TechBranch.Value, level: int, options: Array[int] = []) -> TechBranchState:
	var state := human.tech_branches[branch]
	state.unlocked = true
	state.research_level = level
	state.choices = options
	return state


## Fills every store to the brim.
func fill_stores() -> void:
	for resource: GameResource in human.resources.values():
		resource.amount = resource.max_storage


func view() -> TechView:
	return TechView.of(game)
