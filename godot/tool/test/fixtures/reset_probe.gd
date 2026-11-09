extends RefCounted
## Static state with a reset, as a game class with a static cache has: the
## tests hand its debug_reset() to the suite, as ProcessResets lists it.

static var count: int = 0


static func debug_reset() -> void:
	count = 0
