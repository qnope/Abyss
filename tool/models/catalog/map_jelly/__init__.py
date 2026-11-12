"""A moon jelly, the gentle drifter of the twilight mid-depths (level 2): a
pale violet bell, translucent, four glowing lobes in it, four tentacles of
thin trailing strands and a frill of oral arms under it. It drifts over the
map for life, harmless and small (a third of a cell across), with the two
loops every moving model has, idle and swim.

Its origin is the centre of its bell, upright (Godot's +Y up): the game floats
it at the height it likes. It swims by pulsing: the bell rises and settles
while the strands trail, bending out and in a little behind it. Skeleton:
Bell, then T1-T4 and Arm, three bones each, hanging down."""

import math

from catalog import palette
from catalog.ambient import chain_swing, swing
from catalog.map_jelly import bell
from workshop import skin
from workshop.budget import Budget
from workshop.materials import Material
from workshop.occlusion import Occlusion

NAME = "map_jelly"
SEED = 62
FAMILY = "monster"
JELLY = Material("jelly", roughness=0.35, translucent=True)
MATERIALS = [JELLY, palette.GLOW_PINK]
BUDGET = Budget(triangles=1_500, materials=2, bones=16, keyframes=1_800)
OCCLUSION = Occlusion(rays=4, strength={"jelly": 0.0, "glow_pink": 0.0})
NODES = ["Rig"]
GROUP = "Jelly"

REACH = 0.075  # how far a tentacle hangs from the axis
DROP = (0.0, -0.1, -0.22, -0.36)  # the heights of a strand's joints


def build(model):
    rig = model.rig
    rig.bone("Bell", None, (0, 0, -0.03), (0, 0, 0.12))
    chains = []
    for k in range(5):
        a = math.pi / 2 * k + math.pi / 4
        radius = REACH if k < 4 else 0.0
        points = [(radius * math.cos(a), radius * math.sin(a), z) for z in DROP]
        chains.append((a, rig.chain(f"T{k + 1}" if k < 4 else "Arm", "Bell", points)))
    _actions(rig, chains)
    bell.dome(model, GROUP)
    for a, chain in chains:
        weights = skin.along(chain, rig.centres(chain))
        (bell.strands if chain[0] != "Arm1" else bell.arms)(model, GROUP, a, weights)


def _actions(rig, chains):
    """Swim: a pulse every second, the strands trailing it. Idle: slow."""
    for name, frames, pulse, amount in (("swim", 28, 0.07, 8), ("idle", 64, 0.02, 3)):
        tracks = {"Bell": swing(frames, (0, 0, 0), (0, 0, pulse))}
        for a, chain in chains:
            tilt = (-math.sin(a) * amount, math.cos(a) * amount, 0)
            chain_swing(chain, frames, tilt, 0.09, 1.15, tracks)
        rig.action(name, frames, tracks, loop=True)
