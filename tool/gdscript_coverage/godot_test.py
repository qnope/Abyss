"""The Godot steps of the coverage stop a hung run and retry a crashed
import, checked with fake engine binaries named by GODOT."""

import os
import shutil
import tempfile
import time
import unittest
from unittest import mock

from gdscript_coverage.godot import CoverageError, import_project, run_tests


class GodotTest(unittest.TestCase):
    def setUp(self):
        self.root = tempfile.mkdtemp()
        self.calls = os.path.join(self.root, "calls")

    def tearDown(self):
        shutil.rmtree(self.root)

    def fake_godot(self, body):
        """A Godot that counts its calls in self.calls, then runs body."""
        path = os.path.join(self.root, "godot")
        with open(path, "w") as file:
            file.write('#!/bin/sh\necho "$@" >> "%s"\ncalls=$(wc -l < "%s")\n%s\n'
                       % (self.calls, self.calls, body))
        os.chmod(path, 0o755)
        return mock.patch.dict(os.environ, {"GODOT": path, "GODOT_TEST_TIMEOUT": "1"})

    def call_lines(self):
        with open(self.calls) as file:
            return file.read().splitlines()

    def test_stops_a_test_run_that_hangs(self):
        with self.fake_godot("exec sleep 30"):
            start = time.monotonic()
            with self.assertRaises(CoverageError) as raised:
                run_tests(self.root, [], os.path.join(self.root, "hits.txt"), self.root)
        self.assertLess(time.monotonic() - start, 10)
        self.assertIn("did not finish within 1 s (GODOT_TEST_TIMEOUT)", str(raised.exception))

    def test_gives_the_runner_the_same_timeout(self):
        with self.fake_godot("exit 3"):
            self.assertEqual(run_tests(self.root, ["app"], "/tmp/hits.txt", self.root), 3)
        self.assertIn("-- --coverage-out=/tmp/hits.txt --timeout=1 app", self.call_lines()[0])

    def test_tells_the_tests_where_the_repository_is(self):
        # The copy lies in a temporary folder: reference/ is not above it.
        seen = os.path.join(self.root, "seen")
        with self.fake_godot('echo "$ABYSS_REPO_ROOT" > "%s"' % seen):
            run_tests(self.root, [], "/tmp/hits.txt", "/work/Abyss")
        with open(seen) as file:
            self.assertEqual(file.read(), "/work/Abyss\n")

    def test_imports_again_after_a_crash(self):
        with self.fake_godot('[ "$calls" -gt 1 ] || kill -ABRT $$'):
            import_project(self.root)
        self.assertEqual(len(self.call_lines()), 2)

    def test_gives_up_after_a_second_failed_import(self):
        with self.fake_godot('echo "import broke"; exit 1'):
            with self.assertRaises(CoverageError) as raised:
                import_project(self.root)
        self.assertEqual(len(self.call_lines()), 2)
        self.assertIn("does not import", str(raised.exception))
        self.assertIn("import broke", str(raised.exception))

    def test_stops_an_import_that_hangs(self):
        with self.fake_godot("exec sleep 30"):
            with self.assertRaises(CoverageError) as raised:
                import_project(self.root)
        self.assertIn("did not finish within 1 s (GODOT_TEST_TIMEOUT)", str(raised.exception))


if __name__ == "__main__":
    unittest.main()
