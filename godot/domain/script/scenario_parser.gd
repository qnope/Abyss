class_name ScenarioParser
extends RefCounted
## lib/domain/script/scenario_parser.dart: reads a JSON scenario into a
## TimelineScript:
##
##     {
##       "name": "rush-caserne",
##       "otherwise": "economy",
##       "turns": {
##         "1": [{"do": "upgrade", "building": "headquarters"}],
##         "3": [{"do": "recruit", "unit": "harpoonist", "count": 4}]
##       }
##     }
##
## `otherwise` names a built-in strategy that plays the turns left out.
##
## A replay exported from the game (see ReplayExport) adds `player`,
## `mapSeed`, `lastTurn` and `endTurnSeeds`, which replay that very game;
## `factions` lists the personalities it was played against, whose moves
## are in the turns and never asked from a brain.
##
## Where Dart throws a FormatException, logs an error and gives null.


static func parse(source: String) -> TimelineScript:
	var parsed: Variant = ReplayJournal.whole_numbers(JSON.parse_string(source))
	if parsed is not Dictionary:
		return _refuse("Un scénario est un objet JSON")
	var json: Dictionary = parsed
	if json.get("turns", {}) is not Dictionary:
		return _refuse("\"turns\" doit être un objet")
	var turns: Dictionary[int, Array] = {}
	var actors: Dictionary[int, Array] = {}
	var entries: Dictionary = json.get("turns", {})
	for key: String in entries:
		if _turn_of(key) < 1:
			return _refuse("Numéro de tour invalide : %s" % key)
		if entries[key] is not Array:
			return _refuse("Chaque tour est une liste d'actions")
		turns[_turn_of(key)] = []
		actors[_turn_of(key)] = []
		for move: Dictionary in entries[key]:
			var spec := ActionCodec.decode(move)
			if not spec.is_valid():
				return null
			turns[_turn_of(key)].append(spec)
			actors[_turn_of(key)].append(move.get("player"))
	var otherwise: GameScript = null
	if json.get("otherwise") is String:
		var strategy: String = json["otherwise"]
		otherwise = ScriptLibrary.by_name(strategy)
		if otherwise == null:
			return null
	var difficulty: Variant = null
	if json.get("difficulty") != null:
		difficulty = DartEnum.by_name(Difficulty.Value, str(json["difficulty"]))
		if difficulty == null:
			return _refuse("Difficulté inconnue : %s" % json["difficulty"])
	if json.get("factions", []) is not Array:
		return _refuse("\"factions\" doit être une liste")
	var factions: Array[FactionPersonality.Value] = []
	for name: Variant in json.get("factions", []):
		var personality: Variant = DartEnum.by_name(FactionPersonality.Value, str(name))
		if personality == null:
			return _refuse("Faction inconnue : %s" % name)
		factions.append(personality)
	if json.get("endTurnSeeds", {}) is not Dictionary:
		return _refuse("\"endTurnSeeds\" doit être un objet")
	var seeds: Dictionary[int, int] = {}
	var recorded: Dictionary = json.get("endTurnSeeds", {})
	for key: String in recorded:
		if _turn_of(key) < 1:
			return _refuse("Numéro de tour invalide : %s" % key)
		seeds[_turn_of(key)] = recorded[key]
	var name_: String = json.get("name", "scenario")
	return TimelineScript.new(
		name_, turns, otherwise, json.get("player"), json.get("mapSeed"),
		difficulty, json.get("lastTurn"), factions, seeds, actors,
	)


## The turn a key names, or 0 when it names none.
static func _turn_of(key: String) -> int:
	return key.to_int() if key.is_valid_int() else 0


static func _refuse(message: String) -> TimelineScript:
	push_error(message)
	return null
