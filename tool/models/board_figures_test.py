"""The figures under each model of the review board."""

import json
import os
import tempfile
import unittest
from unittest import mock

import board_figures


class BoardFiguresTest(unittest.TestCase):
    def test_a_building_tells_its_family_budget_and_draw_calls(self):
        lines = board_figures.figures("solar_panel")
        self.assertTrue(lines[0].startswith("building: "))
        self.assertIn("/ 12000 triangles", lines[0])
        self.assertIn("draw calls", lines[0])
        self.assertEqual(lines[-1], "within its budget and its family's caps")
        self.assertEqual(len(lines), 2)

    def test_a_creature_tells_its_bones_keyframes_and_animations(self):
        lines = board_figures.figures("probe_fish")
        self.assertIn("/ 4 bones", lines[0])
        self.assertIn("keyframes", lines[0])
        self.assertEqual(lines[1], "animations: attack, hit, idle_loop, swim_loop")

    def test_says_when_a_model_is_over_its_caps(self):
        script = board_figures.MODELS["solar_panel"]
        small = script.BUDGET.__class__(triangles=10, materials=5, texture_px=1024)
        with mock.patch.object(script, "BUDGET", small):
            self.assertTrue(board_figures.figures("solar_panel")[-1].startswith("OVER: "))

    def test_writes_the_document_the_board_reads(self):
        with tempfile.TemporaryDirectory() as folder:
            out = os.path.join(folder, "figures.json")
            board_figures.main([out, "headquarters", "probe_fish"])
            with open(out, encoding="utf-8") as file:
                document = json.load(file)
        self.assertEqual([m["name"] for m in document["models"]], ["headquarters", "probe_fish"])
        self.assertTrue(all(m["lines"] for m in document["models"]))

    def test_refuses_an_unknown_model_or_none(self):
        with self.assertRaises(SystemExit):
            board_figures.main(["out.json", "no_such_model"])
        with self.assertRaises(SystemExit):
            board_figures.main(["out.json"])


if __name__ == "__main__":
    unittest.main()
