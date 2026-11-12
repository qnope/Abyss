#!/usr/bin/env python3
"""Says which models' portraits to render, for portraits.sh.

    tool/models/portraits.py [name ...]

Prints the names to render, one a line: the given ones, or every model that
declares PORTRAIT = True. A name that does not declare one, or has no glb
built yet, fails the command. Needs Python 3.13 with bpy, as build.py does,
for the catalog."""

import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
MODELS_FOLDER = os.path.join(ROOT, "godot", "assets", "models")
FOLDER = os.path.join(ROOT, "godot", "assets", "portraits")
# The side of a portrait in pixels, held equal to godot/tool/models/portrait.gd by a test.
SIDE = 256

try:
    from catalog import MODELS
except ImportError:
    sys.exit("portraits.py needs Blender's Python module: pip install bpy==5.2.3 (Python 3.13)")


def declared():
    """The names of the models that have a portrait, in the catalog's order."""
    return [name for name, script in MODELS.items() if getattr(script, "PORTRAIT", False)]


def path(name):
    """Where the portrait of the model [name] is committed."""
    return os.path.join(FOLDER, f"{name}.png")


def select(names):
    """The models to render among [names] (all the declared ones when empty);
    a ValueError says what cannot be."""
    names = names or declared()
    for name in names:
        if name not in declared():
            raise ValueError(f"{name} declares no PORTRAIT; the models that do: "
                             f"{', '.join(declared())}")
        if not os.path.exists(os.path.join(MODELS_FOLDER, f"{name}.glb")):
            raise ValueError(f"no godot/assets/models/{name}.glb: tool/models/build.py {name}")
    return names


if __name__ == "__main__":
    try:
        print("\n".join(select(sys.argv[1:])))
    except ValueError as error:
        sys.exit(str(error))
