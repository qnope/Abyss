# tool/test

The Godot tests' runner: test infrastructure, not game code.

    tool/godot_test.sh [paths...]
    godot --headless --path godot --script res://tool/test/run_tests.gd -- [paths...]

Paths are test files or folders, `res://` or relative to `godot/` (the shell
script also takes them relative to the repo root). Without any, every
`*_test.gd` of the project runs, skipping hidden folders and `fixtures/`, the
runner's own sample files. The command prints a line per failed test, then
`N tests, F failed, in T ms`, and exits with 1 when a test failed or the run
timed out (see Timeouts).

`--coverage-out=<file>` is for `tool/godot_coverage.py`, which runs the tests on
an instrumented copy of the project (see `tool/gdscript_coverage/README.md`):
the runner then calls the copy's `CoverageProbe.dump()`, and exits with 1 when
it cannot, as on the project itself, which has no such class.

## Writing a test

A test file `extends TestCase`; each `test_*` method is a test, run on a fresh
instance between the optional `before_each()` and `after_each()`. A failed
assertion is recorded and the test goes on. Test files share one process, so a
class with static state exposes `static func debug_reset() -> void` and gets
listed in `process_resets.gd`, whose resets the runner calls before each file,
as `test/helpers/fresh_process.dart` does for Flutter.

## Testing the UI

A test of a UI component `extends UiTestCase` (`ui_test_case.gd`, itself a
`TestCase`). It mounts the component in a window of its own that wears
`AbyssTheme`, finds nodes, presses buttons and reads the modal and the texts:

| Call | Does |
| --- | --- |
| `mount(component)` | adds it to the window (a `Control` of 390 x 844 under the scene tree's root, without automatic translation) and returns it; the window is freed after the test |
| `modals()`, `current_modal()` | the `ModalLayer` mounted over the window the first time (animations reduced), and the modal on top or null |
| `find_text(text, root)`, `texts(root)` | the first visible label, button, rich text or field showing `text`, and every visible text, in tree order |
| `find_type("Button", root)`, `find_named("Name", root)` | nodes by class name and by node name |
| `press(button or text)` | the button, or the text of a button or of a label drawn over one; a toggle changes state as a touch does (the lit button of a `ButtonGroup` stays lit) and `pressed` fires; a button that is disabled, hidden or absent fails the test, as a player could not press it |
| `text(key, args)` | what `Texts` writes in the language on |
| `use_language("en")` | switches the `TranslationServer`, which tells every mounted node (`NOTIFICATION_TRANSLATION_CHANGED`); French is back after the test |
| `assert_no_raw_keys(root)` | fails for a shown text that is an ARB key as it is: a component forgot `Texts` |

Tests run in one frame: no container has laid its children out and no tween
has moved, so read what a component sets (texts, states, signals), not where it
ends up, and emit a signal rather than waiting for one.

The harness cleans up through `add_cleanup(callable)`, which `TestCase`
offers every test: the callables run after `after_each()`, last registered
first, whether or not the test defines hooks, so a test that defines its own
`after_each` never has to call `super`.

## Script errors

GDScript has no exceptions. A function that hits a script error returns at
once with a default value and its caller goes on, so a test never hangs or
stops the run on one: `TestErrorLog`, an engine `Logger`, records the errors
logged while a test runs and fails the test with them. The engine still prints
them. What it cannot catch: an endless loop hangs the run, and a crash of the
engine itself ends it.

A test of code that must log an error (a rule refusing an argument with
`push_error`) says so first with `expect_error("part of the message")`: each
call lets one error holding that text pass, and fails the test if none came.

`Texts.t` logs an error for a key with no translation or a missing argument
(`presentation/ui/l10n/README.md`), so a test that renders a component asking
for a text that does not exist fails with `Texts: no translation for "key"`;
`fixtures/texts_error_test.gd` and `ui_test_case_test.gd` hold that down.

## Timeouts

A script error in the runner's own code would stop it before its `quit()`
and leave the process idling. `TestWatchdog` quits with 1 once the run has
gone on for `--timeout=<seconds>` (600 by default) without finishing. An
endless loop never gives it the hand, so `tool/godot_test.sh` and
`tool/godot_coverage.py` also kill a run after `GODOT_TEST_TIMEOUT` seconds
(600 by default), which they pass to the runner as its `--timeout`.
