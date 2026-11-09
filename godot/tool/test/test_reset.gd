class_name TestReset
extends RefCounted
## Puts the process back as at startup before each test file, as
## resetProcessState() does for the Flutter tests: it runs each reset that
## ProcessResets lists.


## Runs the given resets, by default every one ProcessResets lists.
static func reset_all(resets: Array[Callable] = ProcessResets.all()) -> void:
	for reset: Callable in resets:
		reset.call()
