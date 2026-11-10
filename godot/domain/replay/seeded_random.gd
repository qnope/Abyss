class_name SeededRandom
extends RefCounted
## lib/domain/replay/seeded_random.dart: a generator that remembers the seed
## it was built from, so the journal can write it down and a replay can roll
## exactly the same dice.
##
## DartRandom remembers its seed already: `SeededRandom(seed)` is
## `DartRandom.new(seed)` and `.seed` its `initial_seed`
## (domain/dart/README.md). Only the factory is left here.


## `SeededRandom.fresh()`: a generator with a seed drawn at random, for an
## action the player performs in the game screen.
static func fresh() -> DartRandom:
	return DartRandom.new(DartRandom.unseeded().next_int(0x7FFFFFFF))
