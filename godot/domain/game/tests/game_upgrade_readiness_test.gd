extends TestCase
## test/domain/game/game_upgrade_readiness_test.dart: which buildings a
## player can raise right now in this game.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM

var _player: Player
var _game: Game


func before_each() -> void:
	_player = Player.new("Nemo", "nemo")
	_player.buildings[HQ].level = 2
	_player.buildings[FARM].level = 1
	_game = GameSamples.game([_player])


func test_reads_the_readiness_of_every_building_of_the_player() -> void:
	var readiness := GameUpgradeReadiness.upgrade_readinesses_of(_game, _player)
	assert_eq(readiness.keys(), BuildingType.Value.values())
	assert_true(readiness[FARM].is_ready())
	assert_true(readiness[BuildingType.Value.DESCENT_MODULE].is_locked())


func test_a_worksite_already_used_this_turn_leaves_nothing_ready() -> void:
	_player.worksite.upgrades = 1
	var readiness := GameUpgradeReadiness.upgrade_readinesses_of(_game, _player)
	assert_false(readiness.values().any(func(r: UpgradeReadiness) -> bool: return r.is_ready()))


func test_one_building_reads_the_same_as_the_whole_base() -> void:
	assert_true(GameUpgradeReadiness.upgrade_readiness_of(_game, _player, FARM).is_ready())


## Not in the Dart file: the kernel the player holds and the discount of
## its research reach the readiness; `only` keeps its order.
func test_reads_the_kernel_and_the_discount_of_the_game() -> void:
	var kernel := BuildingType.Value.VOLCANIC_KERNEL
	var only: Array[BuildingType.Value] = [kernel, FARM]
	var before := GameUpgradeReadiness.upgrade_readinesses_of(_game, _player, only)
	assert_eq(before.keys(), only)
	assert_true(before[kernel].check.missing_captured_kernel)
	var cells: Array[MapCell] = [
		MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.VOLCANIC_KERNEL, null, "nemo"),
	]
	_game.levels = {3: GameMap.new(1, 1, cells, 0)}
	assert_false(GameUpgradeReadiness.upgrade_readiness_of(_game, _player, kernel).check.missing_captured_kernel)
	for resource: GameResource in _player.resources.values():
		resource.amount = 0
	var full := GameUpgradeReadiness.upgrade_readiness_of(_game, _player, FARM).check.missing_resources
	_player.tech_branches[TechBranch.Value.RESOURCES] = TechHelpers.researched_branch(
		TechBranch.Value.RESOURCES, 4, [TechOption.Value.A, TechOption.Value.B]
	)
	var thrifty := GameUpgradeReadiness.upgrade_readiness_of(_game, _player, FARM).check.missing_resources
	assert_true(TechEffects.of(_player).upgrade_discount_percent() > 0)
	assert_true(thrifty[ResourceType.Value.CORAL] < full[ResourceType.Value.CORAL])
