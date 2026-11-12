"""Tests of the declared skeleton and its actions."""

import unittest

from workshop.rig import Key, Rig


def _rig():
    rig = Rig()
    rig.bone("Root", None, (0, 0, 0), (1, 0, 0))
    return rig


class RigTest(unittest.TestCase):
    def test_bones_come_after_their_parent(self):
        rig = _rig()
        rig.bone("Head", "Root", (1, 0, 0), (2, 0, 0))
        self.assertEqual(rig.names, ["Root", "Head"])
        with self.assertRaises(ValueError):
            rig.bone("Tail", "Missing", (0, 0, 0), (1, 0, 0))
        with self.assertRaises(ValueError):
            rig.bone("Root", None, (0, 0, 0), (1, 0, 0))

    def test_a_chain_is_bones_from_point_to_point_each_under_the_last(self):
        rig = _rig()
        names = rig.chain("Tail", "Root", [(0, 0, 0), (-1, 0, 0), (-2, 0, 0), (-3, 0, 0)])
        self.assertEqual(names, ["Tail1", "Tail2", "Tail3"])
        self.assertEqual([b.parent for b in rig.bones[1:]], ["Root", "Tail1", "Tail2"])
        self.assertEqual(rig.centres(names)[1], (-1.5, 0.0, 0.0))

    def test_an_action_counts_its_keyframes(self):
        rig = _rig()
        rig.action("hit", 6, {"Root": [Key(0), Key(3, (0, 0, 20)), Key(6)]})
        self.assertEqual(rig.keyframes, 3)
        self.assertFalse(rig.actions[0].loop)

    def test_refuses_an_action_over_an_unknown_bone_or_with_keys_out_of_order(self):
        rig = _rig()
        with self.assertRaises(ValueError):
            rig.action("a", 6, {"Nope": [Key(0)]})
        with self.assertRaises(ValueError):
            rig.action("a", 6, {"Root": [Key(3), Key(1)]})
        with self.assertRaises(ValueError):
            rig.action("a", 6, {"Root": [Key(0), Key(7)]})

    def test_a_loop_must_end_where_it_starts_and_a_name_is_taken_once(self):
        rig = _rig()
        with self.assertRaises(ValueError):
            rig.action("idle", 6, {"Root": [Key(0), Key(6, (0, 0, 5))]}, loop=True)
        rig.action("idle", 6, {"Root": [Key(0), Key(3, (0, 0, 5)), Key(6)]}, loop=True)
        with self.assertRaises(ValueError):
            rig.action("idle", 6, {"Root": [Key(0)]})


if __name__ == "__main__":
    unittest.main()
