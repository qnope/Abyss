"""What the monsters are made of: turns and loops of actions, lofted bodies,
curves, and the monsters' atlas."""

import math
import unittest

import bpy  # noqa: F401, loads mathutils
from mathutils import Euler, Matrix, Vector

from catalog.parts import creature, motion
from catalog.parts.motion import X, Y, Z
from catalog.textures import monster
from workshop.rig import Rig


class MotionTest(unittest.TestCase):
    def test_a_turn_about_a_cardinal_axis_is_that_euler_angle(self):
        self.assertEqual(motion.turn(X, 30), (30.0, 0.0, 0.0))
        self.assertEqual(motion.turn(Z, -45), (0.0, 0.0, -45.0))

    def test_a_turn_about_any_axis_is_the_same_rotation_as_blenders(self):
        axis = (1.0, 2.0, 0.5)
        expected = Matrix.Rotation(math.radians(40), 3, Vector(axis))
        found = Euler([math.radians(a) for a in motion.turn(axis, 40)]).to_matrix()
        for row in range(3):
            for column in range(3):
                self.assertAlmostEqual(found[row][column], expected[row][column], places=4)

    def test_turns_made_at_once_are_one_turn_about_the_summed_axis(self):
        self.assertEqual(motion.rotvec((X, 10), (X, 5)), motion.turn(X, 15))
        self.assertEqual(motion.rotvec((Y, 0)), (0.0, 0.0, 0.0))

    def test_a_cycle_closes_on_itself(self):
        keys = motion.sway(48, 10, Z, 0.3)
        self.assertEqual(keys[0].frame, 0)
        self.assertEqual(keys[-1].frame, 48)
        self.assertEqual(keys[0].rotation, keys[-1].rotation)
        self.assertEqual(motion.bob(24, 0.1)[0].location, motion.bob(24, 0.1)[-1].location)

    def test_a_wave_turns_each_bone_further_and_later(self):
        tracks = motion.wave(["A", "B"], 24, 10, 0.25)
        self.assertEqual(set(tracks), {"A", "B"})
        peak = lambda keys: max(abs(k.rotation[2]) for k in keys)  # noqa: E731
        self.assertLess(peak(tracks["A"]), peak(tracks["B"]))

    def test_a_pose_to_pose_action_rests_where_a_bone_is_not_posed(self):
        tracks = motion.pose([(0, {}), (5, {"A": motion.turn(X, 20)}), (10, {})])
        self.assertEqual([k.frame for k in tracks["A"]], [0, 5, 10])
        self.assertEqual(tracks["A"][1].rotation, (20.0, 0.0, 0.0))
        self.assertEqual(tracks["A"][0].rotation, (0, 0, 0))

    def test_declares_the_four_actions_with_their_loops(self):
        rig = Rig()
        rig.bone("A", None, (0, 0, 0), (0, 1, 0))
        quiet = (10, {"A": motion.sway(10, 1, Z, steps=2)})
        motion.declare(rig, quiet, quiet, (10, {}), (10, {}))
        self.assertEqual([(a.name, a.loop) for a in rig.actions],
                         [("idle", True), ("swim", True), ("attack", False), ("hit", False)])


class CreatureTest(unittest.TestCase):
    def test_a_loft_has_a_ring_of_sides_at_each_point_and_a_face_between(self):
        body = creature.loft([(0, y, 0) for y in (0, 1, 2)], [1, 1, 1], [1, 1, 1], sides=8,
                             caps=(False, False))
        self.assertEqual(len(body.verts), 24)
        self.assertEqual(len(body.faces), 16)

    def test_a_loft_closes_its_ends_with_a_point_when_asked(self):
        body = creature.loft([(0, y, 0) for y in (0, 1)], [1, 1], [1, 1], sides=6)
        self.assertEqual(len(body.verts), 14)
        self.assertEqual(len(body.faces), 6 + 12)

    def test_a_loft_is_as_wide_and_high_as_asked_and_can_be_raised(self):
        body = creature.loft([(0, y, 0) for y in (0, 1, 2)], [2, 2, 2], [0.5, 0.5, 0.5], sides=8,
                             caps=(False, False), lift=[1, 1, 1])
        low, high = body.bounds()
        self.assertAlmostEqual(high.z - low.z, 1.0, places=3)
        self.assertAlmostEqual(low.z, 0.5, places=3)
        self.assertAlmostEqual(high.x - low.x, 4.0, places=3)

    def test_a_curve_passes_through_its_points_and_samples_between(self):
        points = [(0, 0, 0), (1, 2, 0), (3, 2, 1)]
        found = creature.curve(points, 9)
        self.assertEqual(len(found), 9)
        self.assertEqual(tuple(round(c, 6) for c in found[0]), (0, 0, 0))
        self.assertEqual(tuple(round(c, 6) for c in found[4]), (1, 2, 0))
        self.assertEqual(tuple(round(c, 6) for c in found[-1]), (3, 2, 1))
        self.assertEqual([round(v, 6) for v in creature.curve([1.0, 3.0], 3)], [1.0, 2.0, 3.0])

    def test_spikes_make_one_cone_each(self):
        cones = creature.spikes([(0, 0, 0), (1, 0, 0)], [(0, 0, 1), (1, 0, 1)], 0.1, 4)
        self.assertEqual(cones.triangles, 2 * (8 + 4))

    def test_a_membrane_is_one_polygon_and_dots_are_beads(self):
        self.assertEqual(len(creature.membrane([(0, 0, 0), (0, 1, 0), (0, 1, 1)]).faces), 1)
        self.assertEqual(creature.dots([(0, 0, 0), (1, 1, 1)], 0.1).triangles, 16)

    def test_a_fin_is_a_slab_in_the_plane_along_and_up(self):
        low, high = creature.fin([(0, 0), (1, 0), (0.5, 1)], 0.1).bounds()
        self.assertAlmostEqual(high.y - low.y, 1.0, places=4)
        self.assertAlmostEqual(high.z - low.z, 1.0, places=4)
        self.assertAlmostEqual(high.x - low.x, 0.1, places=4)


class AtlasTest(unittest.TestCase):
    def test_every_light_has_a_plain_tile_and_an_eye(self):
        atlas = monster.atlas(1)
        for name in monster.LIGHTS:
            self.assertIn(name, atlas.tiles)
            self.assertIn("eye_" + name, atlas.tiles)
        for skin in ("plain", "skin", "scales", "plates", "hide"):
            self.assertIn(skin, atlas.tiles)

    def test_the_atlas_is_a_512_px_image_the_same_for_the_same_seed(self):
        first, second = monster.atlas(3).pixels(), monster.atlas(3).pixels()
        self.assertEqual(first.shape, (512, 512, 3))
        self.assertTrue((first == second).all())
        self.assertFalse((first == monster.atlas(4).pixels()).all())


if __name__ == "__main__":
    unittest.main()
