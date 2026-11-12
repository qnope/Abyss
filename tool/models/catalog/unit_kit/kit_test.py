"""The units' shared kit: the skeleton's joints, the poses and actions."""

import math
import unittest

from catalog.unit_kit import actions, body
from workshop.rig import Rig


class BodyTest(unittest.TestCase):
    def setUp(self):
        self.build = body.Build()

    def test_the_arms_hang_from_the_shoulders_and_reach_forward_and_down(self):
        for side in (-1, 1):
            shoulder, elbow, wrist = (self.build.shoulder_joint(side), self.build.elbow(side),
                                      self.build.wrist(side))
            self.assertLess(elbow[2], shoulder[2])
            self.assertLess(wrist[2], elbow[2])
            self.assertGreater(wrist[1], shoulder[1])  # the forearm comes forward
            self.assertAlmostEqual(math.dist(shoulder, elbow), self.build.upper)

    def test_a_figure_is_mirrored_left_and_right(self):
        for joint in ("hip_joint", "knee", "ankle", "shoulder_joint", "elbow", "wrist"):
            left, right = getattr(self.build, joint)(-1), getattr(self.build, joint)(1)
            self.assertAlmostEqual(left[0], -right[0])
            self.assertEqual(left[1:], right[1:])

    def test_the_head_sits_on_the_neck_and_a_stoop_carries_it_forward(self):
        self.assertGreater(self.build.head_centre()[2], self.build.neck)
        self.assertEqual(body.Build(stoop=0.05).head_centre()[1], 0.05)

    def test_the_skeleton_has_fourteen_bones_each_after_its_parent(self):
        rig = Rig()
        body.humanoid(rig, self.build)
        self.assertEqual(len(rig.bones), 14)
        self.assertEqual({bone.name for bone in rig.bones if bone.parent is None}, {"Hips"})
        for name in ("Pack", "HeldL", "HeldR", "ShinL", "ForearmR"):
            self.assertIn(name, rig.names)


class ActionsTest(unittest.TestCase):
    def test_poses_laid_over_each_other_add_up(self):
        total = actions.merged({"A": (1, 2, 3)}, {"A": ((1, 0, 0), (0, 0, 0.5)), "B": (4, 0, 0)})
        self.assertEqual(total["A"], ((2, 2, 3), (0, 0, 0.5)))
        self.assertEqual(total["B"], ((4, 0, 0), (0, 0, 0)))

    def test_a_pose_scaled_goes_that_much_further_from_rest(self):
        half = actions.scaled({"A": ((10, 0, 0), (0, 0.2, 0))}, 0.5)
        self.assertEqual(half["A"], ((5, 0, 0), (0, 0.1, 0)))

    def test_a_tool_is_aimed_by_the_turn_left_to_its_own_bone(self):
        self.assertEqual(actions.held(-90, 50, 20), -160)

    def test_an_action_keys_every_bone_a_step_poses_at_every_step(self):
        rig = Rig()
        body.humanoid(rig, body.Build())
        actions.declare(rig, "attack", 10, [(0, {}), (5, {"Chest": (10, 0, 0)}), (10, {})])
        track = rig.actions[0].tracks
        self.assertEqual(list(track), ["Chest"])
        self.assertEqual([key.frame for key in track["Chest"]], [0, 5, 10])
        self.assertEqual(track["Chest"][1].rotation, (10, 0, 0))

    def test_the_shared_loops_close_on_themselves_and_the_hit_gives_less_to_a_heavy_unit(self):
        rig = Rig()
        body.humanoid(rig, body.Build())
        actions.breathe(rig)
        actions.swim(rig)
        actions.hit(rig, heft=0.5)
        light = Rig()
        body.humanoid(light, body.Build())
        actions.hit(light, heft=1.5)
        self.assertEqual([a.name for a in rig.actions], ["idle", "swim", "hit"])
        self.assertTrue(rig.actions[0].loop and rig.actions[1].loop and not rig.actions[2].loop)
        reach = lambda r: abs(r.actions[-1].tracks["Hips"][1].location[1])  # noqa: E731
        self.assertLess(reach(rig), reach(light))

    def test_the_swim_leans_the_body_forward_and_lifts_it_off_the_floor(self):
        rig = Rig()
        body.humanoid(rig, body.Build())
        actions.swim(rig, lean=30)
        hips = rig.actions[0].tracks["Hips"][0]
        self.assertEqual(hips.rotation[0], -30)  # a negative turn about X leans forward
        self.assertGreater(hips.location[2], 0.1)


if __name__ == "__main__":
    unittest.main()
