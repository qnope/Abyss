"""The squid's eight arms round its mouth and its two long hunting tentacles,
each with a club of hooks at its end."""

import math

from catalog.hunter.body import BELLY, GROUP, H
from catalog.parts import creature, creature_paint
from workshop import skin, sweep
from workshop.colors import linear

ARM = linear("#a8405c")
TIP = linear("#e0b8a8")
HOOK = linear("#e8dcc0")
ARMS = 8


def arm_points(k):
    """The points of arm [k], which leaves the head's front at an angle of
    its own round the mouth and fans out forward and down."""
    a = 2 * math.pi * k / ARMS + math.pi / ARMS
    out = (math.cos(a), math.sin(a))
    return [(out[0] * 0.09, 0.42, H + out[1] * 0.09 - 0.02),
            (out[0] * 0.17, 0.72, H + out[1] * 0.17 - 0.07),
            (out[0] * 0.3, 0.98, H + out[1] * 0.28 - 0.18)]


def tentacle_points(side):
    return [(side * 0.06, 0.42, H + 0.02), (side * 0.14, 0.85, H - 0.06),
            (side * 0.2, 1.3, H - 0.14), (side * 0.2, 1.72, H - 0.12)]


def skeleton(rig):
    """The arms' chains (Arm0_1, Arm0_2...) and the tentacles' (TentR1..3,
    TentL1..3), under the Head; gives both as {name: chain}."""
    arms = {k: rig.chain(f"Arm{k}_", "Head", arm_points(k)) for k in range(ARMS)}
    tents = {side: rig.chain(name, "Head", tentacle_points(side))
             for side, name in ((1, "TentR"), (-1, "TentL"))}
    return arms, tents


def shape(model, arms, tents):
    rig = model.rig
    paint = creature_paint.tipped(ARM, TIP, 0.42, 1.0, 1, 23)
    for k, chain in arms.items():
        tube = sweep.tube(arm_points(k), [0.05, 0.034, 0.008], sides=6)
        model.add(GROUP, tube, "flesh", paint, uv=model.atlas.tiled("skin", 0.4),
                  bone=skin.along(chain, rig.centres(chain)))
    for side, chain in tents.items():
        points = tentacle_points(side)
        tube = sweep.tube(points, [0.032, 0.024, 0.02, 0.022], sides=6, cap=False)
        along = skin.along(chain, rig.centres(chain))
        model.add(GROUP, tube, "flesh", paint, uv=model.atlas.tiled("skin", 0.4), bone=along)
        end = points[-1]
        club = sweep.tube([end, (end[0], end[1] + 0.16, end[2] + 0.01)], [0.06, 0.02], sides=6)
        model.add(GROUP, club, "flesh", TIP, uv=model.atlas.tiled("skin", 0.4), bone=chain[-1])
        hooks = creature.spikes([(end[0] + dx, end[1] + 0.05, end[2] + dz) for dx, dz in
                                 ((0.05, 0.0), (-0.05, 0.0), (0.0, 0.05), (0.0, -0.05))],
                                [(end[0] + 2.1 * dx, end[1] + 0.02, end[2] + 2.1 * dz) for dx, dz in
                                 ((0.05, 0.0), (-0.05, 0.0), (0.0, 0.05), (0.0, -0.05))], 0.014, 4)
        model.add(GROUP, hooks, "shell", HOOK, bone=chain[-1])
