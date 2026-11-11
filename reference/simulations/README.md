# Simulations

What `dart run bin/simulate.dart` prints for a few sets of options, which
the Godot simulator (`tool/godot_simulate.sh`, `godot/tool/simulate/`) must
print the same, to the byte: the text summary, `--verbose` with the action
log, `--json`, the difficulties, the human plans and their variants, a
scenario, an exact replay and an empty batch.

`cases.txt` gives one case per line, `name: options`, and `<name>.txt` what
Dart printed. Never edit a `.txt` by hand:

```sh
python3 tool/simulations.py --update          # Dart's outputs, written again
python3 tool/simulations.py                   # Dart's outputs, checked
python3 tool/simulations.py --engine godot    # Godot's outputs, checked
python3 tool/simulations.py balanced no-game  # some cases only
```

Each case is played from the repository, so its files are named from
there. The check prints a line per case and exits with 1 when one differs,
fails, has no output yet, or when a `.txt` has no case (`--update` removes
it). After a change of rules in `lib/domain`, update the outputs with the
games and vectors (`reference/README.md`). CI checks Dart's in the
`Reference` job and Godot's in `Godot Reference`; the unit tests play two
cases in process (`godot/tool/simulate/tests/simulation_test.gd`).
