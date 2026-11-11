class_name GameSnapshotDigests
extends RefCounted
## The digests of the snapshot of a whole game that the digest test of the
## whole games (turn_digest_test.gd) compares with what a scratch Dart
## script printed through GameSnapshot (SnapshotHistories): as turns 1 to 4
## and every fifth turn start (`T<turn>`), and when the game stops
## (`F<turn>`), the first 16 hex digits of the SHA-256 of every section, in
## the order of SnapshotSections.names().

## The journal records no action until `ReplayJournal.record` is ported:
## its section is compared at the start of the game only.
const JOURNAL := "journal"

var rows := PackedStringArray()


## TurnDigests.play's `on_state`.
func collect(game: Game, final: bool) -> void:
	if final or game.turn <= 4 or game.turn % 5 == 1:
		rows.append(row(("F%d" if final else "T%d") % game.turn, game))


static func row(tag: String, game: Game) -> String:
	var digests := PackedStringArray([tag])
	for digest: String in GameSnapshot.digests(game, Sha256Hex.of):
		digests.append(digest.left(16))
	return " ".join(digests)


## `line` with the digest of the journal written `-` unless it is the
## first turn's.
static func comparable(line: String) -> String:
	if line.begins_with("T1 "):
		return line
	var digests := line.split(" ")
	digests[SnapshotSections.names().find(JOURNAL) + 1] = "-"
	return " ".join(digests)
