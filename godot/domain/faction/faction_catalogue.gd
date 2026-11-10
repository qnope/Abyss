class_name FactionCatalogue
extends RefCounted
## lib/domain/faction/faction_catalogue.dart: draws the factions of a game
## from the ten personalities.

const MIN_COUNT := 1
const MAX_COUNT := 10


## `count` different personalities, in the order they are given the free
## bases; the same seed always draws the same ones. A count out of 1 to 10,
## where Dart throws, logs an error and draws nothing.
static func draw(count: int, seed_: int) -> Array[FactionPersonality.Value]:
	var deck: Array[FactionPersonality.Value] = []
	if count < MIN_COUNT or count > MAX_COUNT:
		push_error("FactionCatalogue.draw: the count %d must be 1 to %d" % [count, MAX_COUNT])
		return deck
	deck.assign(FactionPersonality.Value.values())
	DartRandom.shuffle(deck, DartRandom.new(seed_ ^ 0x5FAC7))
	deck.resize(count)
	return deck
