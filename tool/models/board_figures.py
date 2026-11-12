#!/usr/bin/env python3
"""The figures written under each model of a review board (board.sh).

    tool/models/board_figures.py <out.json> <name> [name ...]

Reads each model's committed glb in godot/assets/models/ and writes, for the
board, {"models": [{"name": ..., "lines": [...]}]}: its family, its budget
figures (triangles, materials, texture, and for a creature its bones and
keyframes, against the model's BUDGET), its draw calls and its animations, and
whether it stays within its family's caps. A building with tiers (the nodes
Tier1..Tier3 that add up) tells what it costs shown up to each, and the
document gives their number as "tiers" for the board's rows, a creature (a model
with animations) "poses": true, for the strips of its actions, and the "extras"
of a floor (the nodes Lit1...): its tiles on a grid of cells, with and without
fog, as board.sh renders them. Needs Python 3.13 with bpy, as
build.py does, for the catalog."""

import json
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
GRID_VIEWS = ("grid", "gridfog", "far")
MODELS_FOLDER = os.path.normpath(os.path.join(HERE, "..", "..", "godot", "assets", "models"))

try:
    from catalog import MODELS
    from catalog.families import FAMILIES
except ImportError:
    sys.exit("board_figures.py needs Blender's Python module: pip install bpy==5.2.3 (Python 3.13)")

from workshop import tiers  # noqa: E402
from workshop.glb import read_glb  # noqa: E402


def figures(name, folder=MODELS_FOLDER):
    """The lines under the model [name] on the board."""
    script = MODELS[name]
    report = read_glb(os.path.join(folder, f"{name}.glb"))
    caps = FAMILIES[script.FAMILY]
    lines = [f"{script.FAMILY}: {script.BUDGET.describe(report)}, {report.draw_calls} draw calls"]
    if report.animations:
        lines.append("animations: " + ", ".join(sorted(report.animations)))
    if tiers.count(report):
        names = ("tier 1", "tiers 1+2", "tiers 1+2+3")
        lines.append("; ".join(f"{label}: {drawn} triangles, {calls} draw calls" for label, (drawn, calls)
                               in zip(names, tiers.shown(report))))
    problems = script.BUDGET.overruns(report) + script.BUDGET.within(caps)
    lines.append("within its budget and its family's caps" if not problems
                 else "OVER: " + "; ".join(problems))
    return lines


def has_poses(name, folder=MODELS_FOLDER):
    """Whether the glb of the model [name] has animations to show as poses."""
    return bool(read_glb(os.path.join(folder, f"{name}.glb")).animations)


def tier_count(name, folder=MODELS_FOLDER):
    """How many tiers the glb of the model [name] has: 0 for none."""
    return tiers.count(read_glb(os.path.join(folder, f"{name}.glb")))


def extras(name, folder=MODELS_FOLDER):
    """The extra views of the model [name] on the board: the grid views of a
    level's floor, none otherwise."""
    report = read_glb(os.path.join(folder, f"{name}.glb"))
    if "Lit1" in report.paths:
        return list(GRID_VIEWS)
    return []


def main(argv):
    if len(argv) < 2:
        sys.exit("usage: board_figures.py <out.json> <name> [name ...]")
    unknown = [name for name in argv[1:] if name not in MODELS]
    if unknown:
        sys.exit(f"no model {', '.join(unknown)}; the models: {', '.join(MODELS)}")
    for name in argv[1:]:
        if not os.path.exists(os.path.join(MODELS_FOLDER, f"{name}.glb")):
            sys.exit(f"no godot/assets/models/{name}.glb: tool/models/build.py {name}")
    document = {"models": [{"name": name, "lines": figures(name), "tiers": tier_count(name),
                            "poses": has_poses(name), "extras": extras(name)}
                           for name in argv[1:]]}
    with open(argv[0], "w", encoding="utf-8") as file:
        json.dump(document, file, indent=1)


if __name__ == "__main__":
    main(sys.argv[1:])
