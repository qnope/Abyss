"""tool/godot_coverage.py: line coverage of the Godot tests.

Instruments a temporary copy of the project, runs the tests on it, and
writes the lcov file, then its Markdown summary beside it through
.github/scripts/coverage_summary.sh, which fails below COVERAGE_MIN.
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile

from gdscript_coverage.godot import CoverageError, check_scripts, import_project, run_tests
from gdscript_coverage.lcov import FileCoverage, lcov
from gdscript_coverage.probe_script import read_hits
from gdscript_coverage.project import instrument_copy

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SUMMARY = os.path.join(REPO, ".github", "scripts", "coverage_summary.sh")


def main(argv=None):
    """Runs the coverage; the exit code, 1 when a test or a step failed."""
    args = _parser().parse_args(argv)
    project = os.path.abspath(args.project)
    prefix = os.path.basename(project)
    temp = tempfile.mkdtemp(prefix="godot_coverage_")
    try:
        copy = os.path.join(temp, prefix)
        scripts = instrument_copy(project, copy)
        import_project(copy)
        check_scripts(copy, scripts, prefix)
        dump = os.path.join(temp, "hits.txt")
        code = run_tests(copy, [_in_project(path, prefix) for path in args.paths], dump)
        if not os.path.exists(dump):
            raise CoverageError("The test run ended before writing its hits.")
        with open(dump) as file:
            hits = read_hits(file.read(), [script.line_count for script in scripts])
    except CoverageError as error:
        print(error, file=sys.stderr)
        return 1
    finally:
        shutil.rmtree(temp)
    files = [FileCoverage(prefix + "/" + s.path, s.lines, h) for s, h in zip(scripts, hits)]
    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    with open(args.out, "w") as file:
        file.write(lcov(files))
    return max(code, _summarize(args.out))


def _summarize(out):
    """Writes summary.md beside the lcov file and prints its headline."""
    path = os.path.join(os.path.dirname(os.path.abspath(out)), "summary.md")
    with open(path, "w") as summary:
        code = subprocess.run(["bash", SUMMARY, out], stdout=summary).returncode
    with open(path) as summary:
        shown = os.path.relpath(path)
        shown = path if shown.startswith("..") else shown
        print("%s (%s)" % (summary.readline().strip("# \n"), shown))
    return code


def _in_project(path, prefix):
    """A path relative to the repo (godot/app) made relative to the project."""
    return path[len(prefix) + 1:] if path.startswith(prefix + "/") else path


def _parser():
    parser = argparse.ArgumentParser(
        prog="tool/godot_coverage.py", description=__doc__.split("\n\n")[1])
    parser.add_argument("paths", nargs="*", help="test files or folders, as tool/godot_test.sh")
    parser.add_argument("--project", default=os.path.join(REPO, "godot"), help="the Godot project")
    parser.add_argument("--out", default=os.path.join(REPO, "coverage", "godot", "lcov.info"),
                        help="the lcov file to write")
    return parser
