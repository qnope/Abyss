class_name ScriptRunReport
extends RefCounted
## lib/domain/script/script_run_report.dart: how one scripted game ended.
## Its `seed` is `run_seed`, `seed` being a function of Godot.

var script_name: String
var run_seed: int
var status: GameStatus.Value
var statistics: GameStatistics
## Turns ended before the game stopped; a won game counts the turn the
## victory came on.
var turns_played: int
## Noise made over the whole game; it drives the raid strength.
var total_noise: int
var buildings: Dictionary[BuildingType.Value, int]
var base_units: Dictionary[UnitType.Value, int]
var resources: Dictionary[ResourceType.Value, int]
var log: Array[ScriptLogEntry]
var milestones: ScriptMilestones
## Whether a faction tamed the volcano first.
var faction_won: bool


func _init(
	script_name_: String, run_seed_: int, status_: GameStatus.Value, statistics_: GameStatistics,
	turns_played_: int, total_noise_: int, buildings_: Dictionary[BuildingType.Value, int],
	base_units_: Dictionary[UnitType.Value, int], resources_: Dictionary[ResourceType.Value, int],
	log_: Array[ScriptLogEntry], milestones_: ScriptMilestones, faction_won_ := false,
) -> void:
	script_name = script_name_
	run_seed = run_seed_
	status = status_
	statistics = statistics_
	turns_played = turns_played_
	total_noise = total_noise_
	buildings = buildings_
	base_units = base_units_
	resources = resources_
	log = log_
	milestones = milestones_
	faction_won = faction_won_


## `ScriptRunReport.of`: the report of `game` for `player_id` (a String;
## the human when null or unknown).
static func of(
	game: Game, script_name_: String, seed_: int, log_: Array[ScriptLogEntry],
	milestones_: ScriptMilestones = null, player_id: Variant = null,
) -> ScriptRunReport:
	var player := game.human_player()
	if player_id != null and game.players.has(player_id):
		player = game.players[player_id]
	var levels: Dictionary[BuildingType.Value, int] = {}
	for type: BuildingType.Value in player.buildings:
		levels[type] = player.buildings[type].level
	var units: Dictionary[UnitType.Value, int] = {}
	var on_base := player.units_on_level(1)
	for type: UnitType.Value in on_base:
		units[type] = on_base[type].count
	var amounts: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in player.resources:
		amounts[type] = player.resources[type].amount
	var winner := VictoryChecker.winner_of(game)
	return ScriptRunReport.new(
		script_name_, seed_, game.status, GameStatisticsCalculator.new().compute(game, player),
		game.turn if game.status == GameStatus.Value.VICTORY else game.turn - 1,
		player.raid_state.total_noise, levels, units, amounts, log_.duplicate(),
		milestones_ if milestones_ != null else ScriptMilestones.new(),
		winner != null and winner.id != game.human_player_id,
	)


func is_defeat() -> bool:
	return status == GameStatus.Value.DEFEAT


func is_victory() -> bool:
	return status == GameStatus.Value.VICTORY


func raids_repelled() -> int:
	return statistics.raids_repelled


func raids_lost() -> int:
	return statistics.raids_lost


func failed_actions() -> int:
	return log.filter(func(e: ScriptLogEntry) -> bool: return not e.success).size()


func to_json() -> Dictionary:
	var json := {"script": script_name, "seed": run_seed, "status": DartEnum.name_of(GameStatus.Value, status)}
	if faction_won:
		json["factionWon"] = true
	json.merge({
		"turnsPlayed": turns_played,
		"raidsRepelled": raids_repelled(),
		"raidsLost": raids_lost(),
		"monstersDefeated": statistics.monsters_defeated,
		"totalNoise": total_noise,
		"failedActions": failed_actions(),
		"buildings": _by_name(BuildingType.Value, buildings),
		"baseUnits": _by_name(UnitType.Value, base_units),
		"resources": _by_name(ResourceType.Value, resources),
	})
	json.merge(milestones.to_json())
	return json


static func _by_name(type: Dictionary, values: Dictionary) -> Dictionary:
	var named := {}
	for key: int in values:
		named[DartEnum.name_of(type, key)] = values[key]
	return named
