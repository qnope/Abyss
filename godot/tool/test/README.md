# tool/test

The Godot tests' runner: test infrastructure, not game code.

    tool/godot_test.sh [paths...]
    godot --headless --path godot --script res://tool/test/run_tests.gd -- [paths...]

Paths are test files or folders, `res://` or relative to `godot/` (the shell
script also takes them relative to the repo root). Without any, every
`*_test.gd` of the project runs, skipping hidden folders and `fixtures/`, the
runner's own sample files. The command prints a line per failed test, then
`N tests, F failed, in T ms`, and exits with 1 when a test failed.

## Writing a test

A test file `extends TestCase`; each `test_*` method is a test, run on a fresh
instance between the optional `before_each()` and `after_each()`. A failed
assertion is recorded and the test goes on. Test files share one process, so a
class with static state exposes `static func debug_reset() -> void` and gets
listed in `process_resets.gd`, whose resets the runner calls before each file,
as `test/helpers/fresh_process.dart` does for Flutter.

## Script errors

GDScript has no exceptions. A function that hits a script error returns at
once with a default value and its caller goes on, so a test never hangs or
stops the run on one: `TestErrorLog`, an engine `Logger`, records the errors
logged while a test runs and fails the test with them. The engine still prints
them. What it cannot catch: an endless loop hangs the run, and a crash of the
engine itself ends it.
