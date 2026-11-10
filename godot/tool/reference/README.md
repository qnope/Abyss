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
- `VectorInputs` builds what the rules take from what a case writes, as
  `tool/vectors/domain/vector_inputs.dart` does on the Dart side: an enum
  value from its Dart name, the stocks, the buildings, the units and the
  research of a player in the order of their enum; and writes an answer
  keyed by an enum under the Dart names a case holds.
- `FightInputs` reads what a fight case writes: a combatant, the runs of a
  side (and writes a side back as runs), an army as `[type, count]` pairs
  in their order, a boost.
- `EventInputs` reads what an event case writes: an event or none, a set
  of events as the list of their names, the lasting effect of an
  `EventState`.
- `RaidInputs` writes what a case of `raids.json` holds: a wave as
  `[difficulty, family, unitCount, secondFamily, secondCount]`.
- `MapWriter` writes a generated map as a case of `maps.json` does, as
  `tool/vectors/domain/map_writer.dart` on the Dart side: its size, its
  bases and each cell that holds anything, the lair or the post a cell
  keeps under another content included.
- `VectorRegistry` lists every section of every vector file under the test
  that reads it, or under `pending: <module>` while the module of
  `lib/domain` it belongs to is not ported. `vector_registry_test.gd` fails
  on a section that is in neither state or in both, on a test that does not
  read its section, and on a module that does not exist: porting a module
  moves its sections from pending to its test.
- `ReferenceFiles` finds the repository: the folder above `res://`, or the one
  `ABYSS_REPO_ROOT` names. `tool/godot_coverage.py` sets it, as it runs the
  tests on a copy of the project in a temporary folder.

In a test, never write `-0.0`: GDScript keeps one constant for `0.0` and
`-0.0` in a function, the first it meets. Take it from its bits,
`VectorValues.float_of("8000000000000000")`.
