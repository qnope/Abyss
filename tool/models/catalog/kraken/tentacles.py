"""The Kraken's eight tentacles: each a thick arm that heaves out of the skirt,
sweeps in a lazy S along the floor and curls up at its tip, its underside
lined with glowing suckers. The two in front are the ones that strike."""

import math

from catalog.kraken.body import GROUP
from catalog.parts import creature, creature_paint
from workshop import skin, sweep
from workshop.colors import linear

COUNT = 8
TOP = linear("#45366a")
UNDER = linear("#a07aa4")
CLAW = linear("#cfc3a4")
# A tentacle in its own frame: (out from the axis, to the side, height), and its width there.
ARCH = [(0.9, 0.0, 0.8), (1.8, 0.1, 1.2), (2.7, 0.45, 0.8), (3.6, -0.15, 0.4), (4.5, -0.4, 0.45)]
RADII = [0.5, 0.4, 0.3, 0.17, 0.04]
SAMPLES = 14
FRONT = (0, COUNT - 1)  # the two that strike


def direction(k):
    """The unit (x, y) a tentacle [k] points along: the first and the last
    are the two in front, a little to each side of +Y, the rest fan round."""
    a = math.radians(22.5 + 45 * k)
    return (-math.sin(a), math.cos(a))


def lift_axis(k):
    """The horizontal axis a tentacle bends in its own vertical plane about
    (a negative turn lifts its tip)."""
    dx, dy = direction(k)
    return (-dy, dx, 0.0)


def points(k):
    """The tentacle's skeleton points: its S bends one way, then the other, from
    one tentacle to the next."""
    dx, dy = direction(k)
    way = 1 if k % 2 else -1
    return [(dx * r - dy * s * way, dy * r + dx * s * way, z) for r, s, z in ARCH]


def skeleton(rig):
    """T<k>_1..4, each tentacle a chain of four bones under the Body."""
    return {k: rig.chain(f"T{k}_", "Body", points(k)) for k in range(COUNT)}


def shape(model, chains):
    rig = model.rig
    skin_tile = model.atlas.tiled("hide", 1.4)
    paint = creature_paint.shaded(TOP, UNDER, 0.7, 0.7, 63, 0.14, 1.5)
    for k, chain in chains.items():
        path = creature.curve(points(k), SAMPLES)
        radii = creature.curve(RADII, SAMPLES)
        along = skin.along(chain, rig.centres(chain))
        model.add(GROUP, sweep.tube(path, radii, sides=10), "flesh", paint, uv=skin_tile, bone=along)
        model.add(GROUP, _suckers(path, radii), "lamp", (1.0, 1.0, 1.0),
                  uv=model.atlas.solid("lava"), bone=along)
        tip = path[-1]
        claw = creature.spikes([tip], [(tip[0], tip[1], tip[2] + 0.45)], 0.06, 4)
        model.add(GROUP, claw, "shell", CLAW, bone=chain[-1])


def _suckers(path, radii):
    """Beads of lava along the underside of the tentacle, from its root to its tip."""
    beads = [(x, y, z - radius * 0.8) for (x, y, z), radius in zip(path[2:-2:2], radii[2:-2:2])]
    return creature.dots(beads, 0.07)
