"""Runs Godot on the instrumented copy: import, parse check, tests."""

import os
import re
import subprocess
from concurrent.futures import ThreadPoolExecutor

RUNNER = "res://tool/test/run_tests.gd"
TIMEOUT = "GODOT_TEST_TIMEOUT"
SCRIPT_ERROR = re.compile(r"SCRIPT ERROR: (.+)\n\s+at: .*\(res://(.+?):(\d+)\)")


class CoverageError(Exception):
    """Stops the coverage rather than let it report a wrong number."""


def godot(*arguments):
    return [os.environ.get("GODOT", "godot"), "--headless", *arguments]


def timeout():
    """The seconds a Godot step may take, GODOT_TEST_TIMEOUT or 600."""
    return int(os.environ.get(TIMEOUT) or 600)


def import_project(copy):
    """Imports the copy, which writes the class cache that finds CoverageProbe.
    A failed import is tried once more: Godot once crashed while importing a
    font ("caller thread can't call propagate_notification() on /root")."""
    for _ in range(2):
        result = _run(godot("--path", copy, "--import"), "The import", capture_output=True, text=True)
        if result.returncode == 0:
            return
    raise CoverageError("The instrumented copy does not import:\n" + result.stdout + result.stderr)


def check_scripts(copy, scripts, prefix):
    """Parses each instrumented script; raises at the first that breaks."""
    with ThreadPoolExecutor(os.cpu_count() or 1) as pool:
        outputs = list(pool.map(lambda script: _check(copy, script.path), scripts))
    for script, output in zip(scripts, outputs):
        if output is not None:
            raise CoverageError(_describe(copy, script.path, output, prefix))


def run_tests(copy, paths, dump):
    """Runs the tests on the copy, which dumps its hits; the exit code."""
    command = godot("--path", copy, "--script", RUNNER, "--",
                    "--coverage-out=" + dump, "--timeout=%d" % timeout(), *paths)
    return _run(command, "The test run").returncode


def _run(command, step, **options):
    """Runs a Godot step; raises when it outlasts timeout(), killing it."""
    try:
        return subprocess.run(command, timeout=timeout(), **options)
    except subprocess.TimeoutExpired:
        raise CoverageError("%s did not finish within %d s (%s)." % (step, timeout(), TIMEOUT))


def _check(copy, path):
    result = _run(godot("--path", copy, "--check-only", "--script", "res://" + path),
                  "The parse check of " + path, stdout=subprocess.PIPE,
                  stderr=subprocess.STDOUT, text=True)
    return None if result.returncode == 0 else result.stdout


def _describe(copy, path, output, prefix):
    error = SCRIPT_ERROR.search(output)
    if error is None:
        return "%s/%s: the instrumented script does not parse:\n%s" % (prefix, path, output)
    message, path, line = error.group(1), error.group(2), int(error.group(3))
    with open(os.path.join(copy, path), encoding="utf-8") as file:
        rows = file.read().split("\n")
    text = rows[line - 1] if 0 < line <= len(rows) else ""
    return "%s/%s:%d: the instrumented script does not parse: %s\n%d | %s" % (
        prefix, path, line, message, line, text)
