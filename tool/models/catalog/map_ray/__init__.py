"""A lantern ray, the gentle glider of the abyssal trench (level 3): a
broad indigo diamond with swept wings, a pale belly, a row of glowing spots
down its back and a long thin tail ending in a lit bead. It glides over the
map for life, harmless and small (two thirds of a cell across), with the two
loops every moving model has, idle and swim.

Faces +Y in Blender (Godot's forward, -Z), its origin at the centre of its
body: the game flies it at the height it likes. The wings flap in a wave
running out to the tips (each of three bones), the tail follows behind.
Skeleton: Body, WL1-3, WR1-3, Tail1-3."""

from catalog import palette
from catalog.ambient import chain_swing, swing
from catalog.map_ray import body
from workshop import skin
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "map_ray"
SEED = 63
FAMILY = "monster"
MATERIALS = [palette.CORAL, palette.GLOW]
BUDGET = Budget(triangles=1_200, materials=2, bones=10, keyframes=1_200)
OCCLUSION = Occlusion(rays=8, distance=0.3, floor=0.45, strength={"glow": 0.0})
NODES = ["Rig"]
GROUP = "Ray"

WING = [(0.03, 0.0, 0.0), (0.13, -0.02, 0.0), (0.24, -0.06, 0.0), (0.35, -0.12, 0.0)]  # right side
TAIL = [(0, -0.2, 0), (0, -0.32, 0), (0, -0.44, 0), (0, -0.58, 0)]


def build(model):
    rig = model.rig
    rig.bone("Body", None, (0, -0.1, 0), (0, 0.14, 0))
    left = rig.chain("WL", "Body", [(-x, y, z) for x, y, z in WING])
    right = rig.chain("WR", "Body", WING)
    tail = rig.chain("Tail", "Body", TAIL)
    _actions(rig, left, right, tail)
    wings = {-1: _blend(rig, "Body", left), 1: _blend(rig, "Body", right)}
    body.wings(model, GROUP, wings)
    body.tail(model, GROUP, skin.along(["Body"] + tail, [(0, -0.1, 0)] + rig.centres(tail)), TAIL)


def _blend(rig, root, chain):
    """The weights over a wing: the body in the middle, then each bone out."""
    return skin.along([root] + chain, [(0, 0.0, 0)] + rig.centres(chain))


def _actions(rig, left, right, tail):
    """Swim: strong beats whose wave runs to the wingtips, the tail swaying
    late behind them. Idle: a slow, shallow glide."""
    for name, frames, beat, sway in (("swim", 30, 11, 14), ("idle", 64, 4, 5)):
        tracks = chain_swing(left, frames, (0, beat, 0), 0.07, 1.15)
        chain_swing(right, frames, (0, -beat, 0), 0.07, 1.15, tracks)
        chain_swing(tail, frames, (0, 0, sway), 0.09, 1.2, tracks)
        tracks["Body"] = swing(frames, (beat * 0.15, 0, 0), (0, 0, 0.02), phase=0.2)
        rig.action(name, frames, tracks, loop=True)
