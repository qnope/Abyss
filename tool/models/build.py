#!/usr/bin/env python3
"""Regenerates the models' glb from their scripts.

    tool/models/build.py [name ...] [--out folder]

Without a name, every model of the catalog. Writes <folder>/<name>.glb, in
godot/assets/models/ by default. Needs Python 3.13 with Blender's module
(pip install bpy==5.2.3). A model over its budget or missing one of its nodes
fails the command, and its glb is not written. See README.md."""

import argparse
import os
import shutil
import sys
import tempfile

sys.dont_write_bytecode = True  # writes nothing in the repo but the glb
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ASSETS = os.path.normpath(os.path.join(HERE, "..", "..", "godot", "assets", "models"))

try:
    import bpy  # noqa: F401
except ImportError:
    sys.exit("build.py needs Blender's Python module: pip install bpy==5.2.3 (Python 3.13)")

from catalog import MODELS  # noqa: E402
from workshop.export import export_glb  # noqa: E402
from workshop.glb import read_glb  # noqa: E402
from workshop.model import Model  # noqa: E402
from workshop.scene import fresh_scene  # noqa: E402


class BuildError(Exception):
    """A model that cannot be written: over its budget, or missing a node."""


def build_model(name, folder=ASSETS):
    """Builds the model [name] into [folder]; gives its path and its report."""
    script = MODELS[name]
    fresh_scene()
    model = Model(name, script.SEED, script.MATERIALS, script.OCCLUSION)
    script.build(model)
    model.emit()
    with tempfile.TemporaryDirectory() as scratch:
        path = os.path.join(scratch, f"{name}.glb")
        export_glb(path)
        report = read_glb(path)
        problems = script.BUDGET.overruns(report) + [
            f"no node {node}" for node in script.NODES if node not in report.paths]
        if problems:
            raise BuildError(f"{name}: " + "; ".join(problems))
        os.makedirs(folder, exist_ok=True)
        target = os.path.join(folder, f"{name}.glb")
        shutil.move(path, target)
    return target, report


def main(argv=None):
    parser = argparse.ArgumentParser(description="Regenerates the models' glb.")
    parser.add_argument("names", nargs="*", help="models to build (all by default)")
    parser.add_argument("--out", default=ASSETS, help="folder of the glb files")
    args = parser.parse_args(argv)
    unknown = [name for name in args.names if name not in MODELS]
    if unknown:
        parser.error(f"no model {', '.join(unknown)}; the models: {', '.join(MODELS)}")
    status = 0
    for name in args.names or MODELS:
        try:
            path, report = build_model(name, args.out)
        except BuildError as error:
            print(error, file=sys.stderr)
            status = 1
            continue
        print(f"{os.path.relpath(path)}: {MODELS[name].BUDGET.describe(report)}, "
              f"{report.draw_calls} draw calls")
    return status


if __name__ == "__main__":
    sys.exit(main())
