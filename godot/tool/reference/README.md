# tool/reference

What the Godot tests read from `reference/`, at the root of the repository:
test infrastructure, not game code, left out of exports.

`reference/vectors/*.json` hold inputs and what the Dart rules answer to them
(`reference/vectors/README.md`); a module ported to `godot/domain` must give
the same answers, to the last bit. Its test extends `VectorTestCase`:

    extends VectorTestCase

    func test_boosts_a_stat_as_dart_does() -> void:
        for case: Dictionary in VectorFile.new("units").cases("boost"):
            var percent: int = case["percent"]
            assert_same(UnitBoost.new(percent).atk(5), case["out"], str(case))

- `VectorFile` reads a file and gives the cases of a section. A file or a
  section that is missing or empty logs an error, which fails the test: a
  vector is never skipped.
- `VectorValues` decodes the values: a JSON number is an `int` (Godot's `JSON`
  reads it as a float), `"d:3ff8000000000000"` the `float` with those IEEE-754
  bits, `"i:9223372036854775807"` an `int` no float holds. `encode()` writes
  the floats back as `d:` texts, and `assert_same` compares those: a NaN equals
  a NaN, 0.0 is not -0.0, 1 is not 1.0.
- `ReferenceFiles` finds the repository: the folder above `res://`, or the one
  `ABYSS_REPO_ROOT` names. `tool/godot_coverage.py` sets it, as it runs the
  tests on a copy of the project in a temporary folder.

In a test, never write `-0.0`: GDScript keeps one constant for `0.0` and
`-0.0` in a function, the first it meets. Take it from its bits,
`VectorValues.float_of("8000000000000000")`.
