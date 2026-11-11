class_name BaseReadiness
extends RefCounted
## Which buildings of the human player's base can rise right now and which
## plots a missing prerequisite holds back, read from the rules: what the
## base's signs show (lib/presentation/screens/game/game_screen_tabs.dart:
## upgradable and locked of the BaseView).


## The buildings that can go up a level now, as a set.
static func upgradable(game: Game) -> Dictionary[BuildingType.Value, bool]:
	var ready: Dictionary[BuildingType.Value, bool] = {}
	var readiness := GameUpgradeReadiness.upgrade_readinesses_of(game, game.human_player())
	for type: BuildingType.Value in readiness:
		if readiness[type].is_ready():
			ready[type] = true
	return ready


## The buildings a prerequisite holds back, as a set.
static func locked(game: Game) -> Dictionary[BuildingType.Value, bool]:
	var held: Dictionary[BuildingType.Value, bool] = {}
	var readiness := GameUpgradeReadiness.upgrade_readinesses_of(game, game.human_player())
	for type: BuildingType.Value in readiness:
		if readiness[type].is_locked():
			held[type] = true
	return held
