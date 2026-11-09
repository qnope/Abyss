"""The instrumented copy of the Godot project."""

import os
import shutil
from dataclasses import dataclass

from gdscript_coverage.instrumenter import instrument
from gdscript_coverage.probe_script import probe_script

# Inside tool/, which is never instrumented.
PROBE_PATH = "tool/coverage_probe.gd"


@dataclass
class Script:
    path: str  # relative to the project, with /
    index: int  # the file number its probes pass
    lines: list  # the executable lines
    line_count: int
    text: str  # instrumented


def game_scripts(project):
    """Every .gd file but the tests, tool/ and hidden folders such as .godot/."""
    found = []
    for folder, folders, files in os.walk(project):
        relative = os.path.relpath(folder, project).replace(os.sep, "/")
        if relative == ".":
            folders[:] = [f for f in folders if f != "tool"]
        folders[:] = [f for f in folders if not f.startswith(".")]
        for name in files:
            if name.endswith(".gd") and not name.endswith("_test.gd"):
                found.append(name if relative == "." else relative + "/" + name)
    return sorted(found)


def instrument_copy(project, copy):
    """Copies the project but its .godot/ cache, instruments its game
    scripts and adds the CoverageProbe class; returns the scripts."""
    shutil.copytree(project, copy, ignore=shutil.ignore_patterns(".godot"))
    scripts = []
    for index, path in enumerate(game_scripts(project)):
        with open(os.path.join(project, path), encoding="utf-8", newline="") as file:
            result = instrument(file.read(), index)
        with open(os.path.join(copy, path), "w", encoding="utf-8", newline="") as file:
            file.write(result.text)
        scripts.append(Script(path, index, result.lines, result.line_count, result.text))
    with open(os.path.join(copy, PROBE_PATH), "w", encoding="utf-8") as file:
        file.write(probe_script([script.line_count for script in scripts]))
    return scripts
