class_name SaveCheckRecorder
extends ReferenceRecorder
## A ReferenceRecorder that also saves the game as each chosen turn starts
## and loads it back (SaveCodec): the loaded game must have the digests the
## game has, and saving it again must give the same text. It keeps the save
## of the turns to resume (SaveRoundTrip plays on from them).

## A turn is checked when its number is a multiple of `every` (0 checks
## none), or when it is one of `resumed`.
var every: int
var resumed: Array[int]
## What went wrong, one line each.
var problems := PackedStringArray()
## The number of turns saved and loaded.
var checked := 0
## The text of the save of each turn of `resumed`, by turn.
var saves: Dictionary[int, String] = {}


func _init(every_ := 1, resumed_: Array[int] = []) -> void:
	super(Sha256Hex.of)
	every = every_
	resumed = resumed_


func on_start(game_: Game) -> void:
	super.on_start(game_)
	_check(game_)


func execute(action: Action, game_: Game, player: Player) -> ActionResult:
	var result := super.execute(action, game_, player)
	if result.is_success and action is EndTurnAction:
		_check(game_)
	return result


func _check(game_: Game) -> void:
	var turn := game_.turn
	var wanted := resumed.has(turn) or (every > 0 and turn % every == 0)
	if not wanted:
		return
	checked += 1
	var text := SaveCodec.to_text(game_)
	var loaded := SaveCodec.from_text(text)
	if not loaded.is_read():
		problems.append("turn %d: the save is refused: %s" % [turn, loaded.problem])
		return
	var started: ReplayComparison.Turn = turns.back()
	var sections := ReplayComparison.differing(started.digests, GameSnapshot.digests(loaded.game, digest))
	if not sections.is_empty():
		problems.append("turn %d: the loaded game differs in: %s" % [turn, ", ".join(sections)])
	if SaveCodec.to_text(loaded.game) != text:
		problems.append("turn %d: the loaded game saves another text" % turn)
	if loaded.game.created_at != game_.created_at or loaded.game.saved_last_played_at != game_.saved_last_played_at:
		problems.append("turn %d: the loaded game has other dates" % turn)
	if resumed.has(turn):
		saves[turn] = text
