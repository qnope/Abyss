class_name GameUpgradeReadiness
extends RefCounted
## lib/domain/game/game_upgrade_readiness.dart: which buildings a player can
## raise right now in this game: the bases and the volcanic core they
## captured, their research's discount. An extension of Game in Dart: each
## function takes the game first.


## The readiness of the building of `type` of `player`.
static func upgrade_readiness_of(game: Game, player: Player, type: BuildingType.Value) -> UpgradeReadiness:
	var only: Array[BuildingType.Value] = [type]
	return upgrade_readinesses_of(game, player, only)[type]


## The readiness of every building of `player`, or of the `only` ones (an
## `Array[BuildingType.Value]`, null for all), in that order.
static func upgrade_readinesses_of(
	game: Game, player: Player, only: Variant = null
) -> Dictionary[BuildingType.Value, UpgradeReadiness]:
	var captured := game.captured_base_types_of(player.id)
	var kernel := game.is_volcanic_kernel_captured_by(player.id)
	var discount := TechEffects.of(player).upgrade_discount_percent()
	var types: Array[BuildingType.Value] = player.buildings.keys() if only == null else only
	var readiness: Dictionary[BuildingType.Value, UpgradeReadiness] = {}
	for type: BuildingType.Value in types:
		readiness[type] = UpgradeReadiness.of(
			type, player.buildings, player.resources, player.worksite, captured, kernel, discount
		)
	return readiness
