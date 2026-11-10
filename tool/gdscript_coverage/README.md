# tool/gdscript_coverage

Line coverage for the Godot tests. Godot 4 has no coverage tool of its own,
so this one instruments a copy of the project.

    tool/godot_coverage.py [test file or folder ...]
    COVERAGE_MIN=97 tool/godot_coverage.py

Paths are as for `tool/godot_test.sh` (`godot/domain`, `domain`, `res://domain`);
without any, every test runs. It writes `coverage/godot/lcov.info` (`SF:godot/...`
paths from the repo root; a script no test loads has all its lines at 0) and
`coverage/godot/summary.md` through `.github/scripts/coverage_summary.sh`, which
also fails below `COVERAGE_MIN`. Nothing else in the repo is written. It exits
with 1 when a test fails, when the minimum is not reached, or when a step fails.
`GODOT` names the engine binary, `godot` by default. Each Godot step that
outlasts `GODOT_TEST_TIMEOUT` seconds (600 by default) is killed and fails the
tool; the test run also passes it to the runner as `--timeout`.

## How

1. Copies `godot/` (but `.godot/`) to a temporary folder.
2. Instruments each game script: every `.gd` but `*_test.gd`, `tool/` and hidden
   folders. Each executable line gets a probe before its statement, on the same
   line, so every line keeps its number: `\tCoverageProbe.hit(3, 17); var x := f()`.
3. Adds `res://tool/coverage_probe.gd`, the `CoverageProbe` class that counts the
   hits, and imports the copy, as a step of its own; a failed import is tried
   once more, as Godot once crashed importing a font there.
4. Parses each instrumented script with `godot --check-only`, and stops at the
   first that breaks, naming its file, line and the instrumented text.
5. Runs the tests with `--coverage-out=<file>`: the runner then calls
   `CoverageProbe.dump()`, a class it looks up by name, since only the copy has it.
   `ABYSS_REPO_ROOT` names the repo to the tests, which read `reference/` from
   it: the copy has no repo above it (`godot/tool/reference/reference_files.gd`).
6. Writes the lcov file and its summary.

## What counts as an executable line

A line where a statement starts inside a function body: a `func`, a lambda (whose
body sits on its own lines, even inside brackets), a property's `set` or `get`.
That includes `pass`, local `var` and `const`, a block header such as `if`, `for`,
`while` or `match`, and a whole one-line `if x: return`.

Not counted: blank lines, comments, class-level declarations (`extends`,
`class_name`, `signal`, `enum`, `const`, `var`, annotations, `func` and `class`
lines), annotation-only lines in a body, and the lines that go on with a
statement: inside open brackets, after a trailing backslash, inside a
multi-line string. `elif`, `else` and match patterns cannot have a probe before
them, so the first statement of their body counts instead; when that body is on
the same line (`else: return 0`, `1: return "one"`), the probe goes after the
colon, as for a one-line `func f() -> int: return 1` or `get: return hp`.

## Limits

- A one-line lambda (`a.map(func(x): return x * 2)`) counts with the line of
  the statement around it, not on its own.
- The hits of a child Godot process that a test starts are not counted.
- The tokenizer follows GDScript as of Godot 4.7; a new syntax may need a test
  here. A wrong probe cannot go unnoticed: step 4 fails on it.

## Tests

    python3 -m unittest discover -s tool -p '*_test.py'

`end_to_end_test.py` runs the tool with Godot on `fixtures/calc.gd` and checks
each line's hits; it is skipped when Godot is missing.
