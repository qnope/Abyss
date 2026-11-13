#!/usr/bin/env python3
"""Checks that the Godot simulator prints what the Flutter version printed.

    tool/simulations.py                     # every case, checked
    tool/simulations.py balanced no-game    # some cases only

Plays each case of reference/simulations/cases.txt (`name: options`) with
`tool/godot_simulate.sh <options>` from the repository, and compares what it
prints with <name>.txt, which the last Flutter version wrote. Prints a line
per case and exits with 1 when one differs, fails or has no case
(reference/simulations/README.md).
"""

import argparse
import os
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FOLDER = os.path.join(REPO, "reference", "simulations")
COMMAND = ["tool/godot_simulate.sh"]


class SimulationError(Exception):
    """A simulator that did not finish well."""


def parse_cases(text):
    """{name: [option, ...]} of the lines `name: options`, in their order."""
    cases = {}
    for number, line in enumerate(text.splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        name, colon, options = line.partition(":")
        name = name.strip()
        if not colon or not name or name.startswith("-"):
            raise ValueError("cases.txt, line %d: not `name: options`" % number)
        if name in cases:
            raise ValueError("cases.txt: a case named twice: %s" % name)
        cases[name] = options.split()
    return cases


def play(command, options):
    """What the simulator prints, run from the repository."""
    done = subprocess.run(
        command + options, cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False
    )
    if done.returncode != 0:
        tail = done.stderr.decode("utf-8", "replace").strip().splitlines()[-3:]
        raise SimulationError("exit status %d %s" % (done.returncode, " / ".join(tail)))
    return done.stdout.decode("utf-8")


def _read(path):
    if not os.path.exists(path):
        return None
    with open(path, encoding="utf-8", newline="") as f:
        return f.read()


def _one(name, options, path, engine):
    try:
        printed = engine(options)
    except SimulationError as e:
        return False, "FAILED, %s" % e
    expected = _read(path)
    if expected is None:
        return False, "no output yet"
    return expected == printed, "ok" if expected == printed else "differs"


def run(folder, names, engine):
    """Plays the cases, prints a line each; True when all went well."""
    cases = parse_cases(_read(os.path.join(folder, "cases.txt")) or "")
    unknown = [n for n in names if n not in cases]
    for name in unknown:
        print("%s: no such case in cases.txt" % name)
    if unknown:
        return False
    good = True
    for name, options in cases.items():
        if names and name not in names:
            continue
        ok, verdict = _one(name, options, os.path.join(folder, name + ".txt"), engine)
        good = good and ok
        print("%s: %s" % (name, verdict), flush=True)
    if names:
        return good
    for file in sorted(os.listdir(folder)):
        name, extension = os.path.splitext(file)
        if extension == ".txt" and file != "cases.txt" and name not in cases:
            print("%s: no case in cases.txt" % name)
            good = False
    return good


def main(argv, simulate=play):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("names", nargs="*", help="cases to play, all by default")
    parser.add_argument("--folder", default=FOLDER, help=argparse.SUPPRESS)
    args = parser.parse_args(argv)
    good = run(args.folder, args.names, lambda options: simulate(COMMAND, options))
    return 0 if good else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
