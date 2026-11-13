# Simulations

> **Frozen.** The Flutter version that wrote these files, and the Dart tools
> this document mentions (`bin/`, `lib/domain`, `tool/vectors/`), were removed
> when the game switched to Godot; they are in the git history, in the
> parent of the commit that removed them. What is here is what they computed
> and is no longer written again: the Godot port is checked against it
> (`tool/godot_reference.sh`, `tool/simulations.py`, the tests of
> `godot/tool/reference/`). Only change a file by hand with a rule change
> that is meant, and say why in the commit.

What the Flutter version's simulator (`bin/simulate.dart`, gone with it) printed for a few sets of options, which
the Godot simulator (`tool/godot_simulate.sh`, `godot/tool/simulate/`) must
print the same, to the byte: the text summary, `--verbose` with the action
log, `--json`, the difficulties, the human plans and their variants, a
scenario, an exact replay and an empty batch.

`cases.txt` gives one case per line, `name: options`, and `<name>.txt` what
the Flutter version printed. They are frozen, and the check is:

```sh
python3 tool/simulations.py                   # Godot's outputs, checked
python3 tool/simulations.py balanced no-game  # some cases only
```

Each case is played from the repository, so its files are named from
there. The check prints a line per case and exits with 1 when one differs,
fails, has no output yet, or when a `.txt` has no case. CI checks them in
`Godot Reference`; the unit tests play two cases in process (`godot/tool/simulate/tests/simulation_test.gd`).
