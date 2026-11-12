"""The figures under each model of the review board."""

import json
import os
import tempfile
import unittest
from unittest import mock

import board_figures


class BoardFiguresTest(unittest.TestCase):
    def test_a_building_tells_its_family_budget_and_draw_calls(self):
        lines = board_figures.figures("headquarters")
        self.assertTrue(lines[0].startswith("building: "))
        self.assertIn("/ 20000 triangles", lines[0])
        self.assertIn("draw calls", lines[0])
        self.assertEqual(lines[-1], "within its budget and its family's caps")
        self.assertEqual(len(lines), 3)

    def test_a_building_with_tiers_tells_what_each_costs(self):
        lines = board_figures.figures("algae_farm")
        self.assertEqual(len(lines), 3)
        self.assertTrue(lines[1].startswith("tier 1: "))
        self.assertIn("; tiers 1+2: ", lines[1])
        self.assertIn("; tiers 1+2+3: ", lines[1])
        self.assertEqual(board_figures.tier_count("algae_farm"), 3)
        self.assertEqual(board_figures.tier_count("material_swatches"), 0)

    def test_a_creature_tells_its_bones_keyframes_and_animations(self):
        lines = board_figures.figures("probe_fish")
        self.assertIn("/ 4 bones", lines[0])
        self.assertIn("keyframes", lines[0])
        self.assertEqual(lines[1], "animations: attack, hit, idle_loop, swim_loop")

    def test_a_floor_asks_for_extra_views(self):
        self.assertEqual(board_figures.extras("map_terrain_2"), ["grid", "gridfog", "far"])
        self.assertEqual(board_figures.extras("map_ray"), [])
        self.assertEqual(board_figures.extras("headquarters"), [])
        self.assertEqual(board_figures.extras("map_fog"), [])

    def test_says_when_a_model_is_over_its_caps(self):
        script = board_figures.MODELS["headquarters"]
        small = script.BUDGET.__class__(triangles=10, materials=5, texture_px=1024)
        with mock.patch.object(script, "BUDGET", small):
            self.assertTrue(board_figures.figures("headquarters")[-1].startswith("OVER: "))

    def test_writes_the_document_the_board_reads(self):
        with tempfile.TemporaryDirectory() as folder:
            out = os.path.join(folder, "figures.json")
            board_figures.main([out, "headquarters", "probe_fish"])
            with open(out, encoding="utf-8") as file:
                document = json.load(file)
        self.assertEqual([m["name"] for m in document["models"]], ["headquarters", "probe_fish"])
        self.assertTrue(all(m["lines"] for m in document["models"]))
        self.assertEqual([m["tiers"] for m in document["models"]], [3, 0])
        self.assertEqual([m["poses"] for m in document["models"]], [False, True])
        self.assertEqual([m["extras"] for m in document["models"]], [[], []])

    def test_refuses_an_unknown_model_or_none(self):
        with self.assertRaises(SystemExit):
            board_figures.main(["out.json", "no_such_model"])
        with self.assertRaises(SystemExit):
            board_figures.main(["out.json"])


if __name__ == "__main__":
    unittest.main()
