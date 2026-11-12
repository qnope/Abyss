"""The map's fog, backdrops and living creatures: what each is made of and
what the game relies on in them."""

import math
import unittest

from catalog import MODELS
from catalog.backdrop import rim
from catalog.families import FAMILIES
from model_builds import built

CREATURES = {"map_turtle": (8, 0.9), "map_jelly": (16, 0.5), "map_ray": (10, 0.9)}
BACKDROPS = ("map_backdrop_1", "map_backdrop_2", "map_backdrop_3")


def _span(report):
    low, high = report.bounds
    return max(high[0] - low[0], high[2] - low[2])


class MapFogTest(unittest.TestCase):
    def test_the_fog_is_blended_with_clouds_and_wisps_and_no_texture(self):
        report = built("map_fog")[1]
        self.assertEqual([m.get("alphaMode") for m in report.document["materials"]], ["BLEND"])
        self.assertEqual(report.images, [])
        for node in ("Cloud1", "Cloud2", "Cloud3", "Wisp1", "Wisp2", "Wisp3"):
            self.assertGreater(report.triangles_under(node), 30, node)

    def test_a_cloud_overspills_its_cell_and_stays_low(self):
        report = built("map_fog")[1]
        for k in (1, 2, 3):
            (x0, y0, z0), (x1, y1, z1) = report.bounds_of(f"Cloud{k}")
            self.assertGreater(x1 - x0, 1.4)  # neighbours merge into a blanket
            self.assertLess(y1, 0.3)
            self.assertGreater(y0, -0.1)


class MapBackdropTest(unittest.TestCase):
    def test_every_backdrop_has_its_rim_pieces_and_far_silhouettes(self):
        for name in BACKDROPS:
            script, report = MODELS[name], built(name)[1]
            with self.subTest(name):
                self.assertEqual(script.FAMILY, "decor")
                for node in ("Edge1", "Edge2", "Corner"):
                    self.assertIn(node, report.paths)
                self.assertGreaterEqual(len(script.NODES), 5)

    def test_a_straight_piece_is_two_long_and_falls_away_outward(self):
        for name in BACKDROPS:
            report = built(name)[1]
            for node in ("Edge1", "Edge2"):
                with self.subTest(f"{name}/{node}"):
                    (x0, y0, z0), (x1, y1, z1) = report.bounds_of(node)
                    self.assertLess(x0, -0.99)
                    self.assertGreater(x1, 0.99)
                    self.assertLess(x1 - x0, 2.5)  # what grows on it hardly overhangs
                    self.assertLess(y0, -5.0)  # the abyss below
                    self.assertGreater(z1, 4.0)  # out to the front

    def test_the_pieces_meet_on_the_bare_section(self):
        ends = []
        for seed in (41, 42, 43, 50):
            columns = rim.edge(seed).verts
            rows = len(rim.SECTION)
            first, last = columns[:rows], columns[-rows:]
            ends.append([(round(v.y, 4), round(v.z, 4)) for v in first])
            self.assertEqual([(round(v.y, 4), round(v.z, 4)) for v in first],
                             [(round(v.y, 4), round(v.z, 4)) for v in last])
        self.assertEqual(ends[0], ends[1])
        self.assertEqual(ends[0], ends[3])
        self.assertEqual(ends[0], [(round(-out, 4), round(z, 4)) for out, z in rim.SECTION])

    def test_a_corner_turns_the_same_section_a_quarter(self):
        verts = rim.corner(5).verts
        rows = len(rim.SECTION)
        south, east = verts[:rows], verts[-rows:]
        for k, (out, z) in enumerate(rim.SECTION):
            self.assertAlmostEqual(south[k].y, -out, places=4)
            self.assertAlmostEqual(east[k].x, out, places=4)
            self.assertAlmostEqual(south[k].z, z, places=4)
            self.assertAlmostEqual(east[k].z, z, places=4)
            self.assertAlmostEqual(math.hypot(east[k].x, east[k].y), abs(out), places=4)

    def test_the_three_backdrops_differ(self):
        hashes = {built(name)[1].geometry_hash for name in BACKDROPS}
        self.assertEqual(len(hashes), 3)
        self.assertEqual(len({MODELS[name].SEED for name in BACKDROPS}), 3)


class MapCreaturesTest(unittest.TestCase):
    def test_every_creature_has_its_two_loops_and_its_bones(self):
        for name, (bones, _) in CREATURES.items():
            report = built(name)[1]
            with self.subTest(name):
                self.assertEqual(sorted(report.animations), ["idle_loop", "swim_loop"])
                self.assertEqual(report.bones, bones)
                self.assertGreater(report.keyframes, bones * 10)

    def test_every_creature_is_small_harmless_and_within_the_monster_caps(self):
        for name, (_, span) in CREATURES.items():
            script, report = MODELS[name], built(name)[1]
            with self.subTest(name):
                self.assertEqual(script.FAMILY, "monster")
                self.assertEqual(script.BUDGET.within(FAMILIES["monster"]), [])
                self.assertLess(_span(report), span)  # a part of a cell
                self.assertLessEqual(report.triangles, 1_500)

    def test_the_creatures_swim_in_their_levels_palette(self):
        self.assertIn("coral", built("map_turtle")[1].materials)
        self.assertEqual(sorted(built("map_jelly")[1].materials), ["glow_pink", "jelly"])
        self.assertEqual(sorted(built("map_ray")[1].materials), ["coral", "glow"])
        jelly = built("map_jelly")[1].document["materials"]
        self.assertEqual({m["name"]: m.get("alphaMode") for m in jelly}["jelly"], "BLEND")


if __name__ == "__main__":
    unittest.main()
