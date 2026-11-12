"""A sea turtle, the gentle swimmer of the sunlit reef shallows (level 1): a
domed olive shell with its scutes, a pale belly, a small head on a neck, four
flippers. It swims over the map for life, harmless and small (half a cell
long), with the two loops every moving model has, idle and swim.

Faces +Y in Blender (Godot's forward, -Z), its origin at the centre of its
body: the game flies it at the height it likes. The front flippers beat
(rolling about the body's axis, each of two bones so it bends), the rear
ones paddle, the head sways. Skeleton: Body, Head, FL1-2, FR1-2, RL, RR."""

from catalog import palette
from catalog.ambient import chain_swing, swing
from catalog.map_turtle import shell
from workshop import skin
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "map_turtle"
SEED = 61
FAMILY = "monster"
MATERIALS = [palette.CORAL]
BUDGET = Budget(triangles=1_200, materials=1, bones=9, keyframes=900)
OCCLUSION = Occlusion(rays=8, distance=0.3, floor=0.45)
NODES = ["Rig"]
GROUP = "Turtle"

FRONT = [(0.10, 0.13, -0.04), (0.26, 0.09, -0.05), (0.42, 0.05, -0.06)]  # a flipper, right side


def build(model):
    rig = model.rig
    rig.bone("Body", None, (0, -0.2, 0), (0, 0.2, 0))
    rig.bone("Head", "Body", (0, 0.2, 0.02), (0, 0.38, 0.04))
    left = rig.chain("FL", "Body", [(-x, y, z) for x, y, z in FRONT])
    right = rig.chain("FR", "Body", FRONT)
    rig.bone("RL", "Body", (-0.1, -0.17, -0.04), (-0.2, -0.27, -0.05))
    rig.bone("RR", "Body", (0.1, -0.17, -0.04), (0.2, -0.27, -0.05))
    _actions(rig, left, right)
    shell.carapace(model, GROUP)
    shell.head(model, GROUP)
    for side, chain in ((-1, left), (1, right)):
        shell.flipper(model, GROUP, side, skin.along(chain, rig.centres(chain)))
        shell.rear(model, GROUP, side, "RL" if side < 0 else "RR")


def _actions(rig, left, right):
    """Swim: the front flippers beat in time, the rear ones paddle against
    them. Idle: the same, slow and shallow."""
    for name, frames, beat, drift in (("swim", 24, 24, 0.02), ("idle", 56, 7, 0.012)):
        tracks = chain_swing(left, frames, (0, beat, 0), 0.07, 1.2)
        chain_swing(right, frames, (0, -beat, 0), 0.07, 1.2, tracks=tracks)
        tracks["RL"] = swing(frames, (0, 0, beat * 0.5), phase=0.3)
        tracks["RR"] = swing(frames, (0, 0, -beat * 0.5), phase=0.3)
        tracks["Head"] = swing(frames, (beat * 0.2, 0, beat * 0.3), phase=0.2)
        tracks["Body"] = swing(frames, (beat * 0.08, 0, 0), (0, 0, drift), phase=0.25)
        rig.action(name, frames, tracks, loop=True)
