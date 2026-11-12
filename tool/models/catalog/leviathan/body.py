"""The Léviathan's body: a colossal serpent lying in an S on the sea floor, its
neck rising into a horned head with a hinged jaw of fangs, a ridge of bone
spines down its back and lines of pale lights along its flanks."""

import math

from catalog import monster_palette as pal
from catalog.parts import creature, creature_paint
from workshop import skin, sweep
from workshop.colors import linear

BACK = linear("#35605a")
BELLY = linear("#86a98a")
BONE = linear("#cfc8a8")
FIN = linear("#2c4d4b")
GROUP = "Leviathan"
# The spine from the tail to the base of the neck: x, y, z and the body's radius there.
SPINE = [(-1.6, -6.2, 0.12, 0.05), (-1.5, -5.2, 0.3, 0.2), (-1.1, -4.0, 0.5, 0.4),
         (-0.2, -2.8, 0.66, 0.65), (0.8, -1.5, 0.76, 0.92), (1.0, -0.3, 0.86, 1.05),
         (0.6, 1.0, 0.96, 1.05), (-0.2, 2.2, 1.12, 0.95), (-0.6, 3.2, 1.8, 0.85),
         (-0.5, 4.1, 2.6, 0.82), (0.0, 4.8, 3.0, 0.9)]
ROOT = 5  # the point where the Body bone starts
HEAD_BASE = SPINE[-1][:3]  # where the neck ends and the skull begins
HEAD_TAIL = (0.0, 6.9, 2.9)


def skeleton(rig):
    """Body at the middle, a chain of five Aft bones toward the tail, one of four
    Fwd bones up the neck, then the Head, the Jaw and the two Flippers; gives
    the chains' names, tail to head."""
    pts = [p[:3] for p in SPINE]
    rig.bone("Body", None, pts[ROOT], pts[ROOT + 1])
    aft = rig.chain("Aft", "Body", pts[ROOT::-1])
    fwd = rig.chain("Fwd", "Body", pts[ROOT + 1:])
    rig.bone("Head", fwd[-1], pts[-1], HEAD_TAIL)
    rig.bone("Jaw", "Head", (0.0, 5.0, 2.4), (0.0, 6.8, 2.35))
    for name, side in (("FlipperR", 1), ("FlipperL", -1)):
        rig.bone(name, "Body", (side * 0.8, 1.6, 0.9), (side * 2.2, 1.2, 0.4))
    return aft[::-1] + ["Body"] + fwd


def _weights(rig, order):
    return skin.along(order, rig.centres(order))


def shape(model, order):
    rig = model.rig
    along = _weights(rig, order)
    hide = model.atlas.tiled("hide", 1.6)
    paint = creature_paint.shaded(BACK, BELLY, 0.9, 1.0, 71, 0.12, 1.2, (linear("#a9c9a8"), 1.0))
    path = creature.curve([p[:3] for p in SPINE], 36)
    radii = creature.curve([p[3] for p in SPINE], 36)
    model.add(GROUP, sweep.tube(path, radii, sides=14), "flesh", paint, uv=hide, bone=along)
    _ridge(model, path, radii, along)
    _lights(model, path, radii, along)
    _flippers(model, hide)


def _ridge(model, path, radii, along):
    """A ridge of bone spines down the back, taller over the shoulders."""
    bases, tips = [], []
    for i in range(2, len(path) - 1, 2):
        x, y, z = path[i]
        size = 0.25 + 0.35 * math.sin(math.pi * i / len(path))
        bases.append((x, y, z + radii[i] * 0.9))
        tips.append((x, y - 0.25, z + radii[i] * 0.9 + size))
    model.add(GROUP, creature.spikes(bases, tips, 0.11, 4), "shell", BONE, bone=along)


def _lights(model, path, radii, along):
    """Pale lights in a line down each flank."""
    beads = []
    for i in range(3, len(path) - 3, 2):
        x, y, z = path[i]
        dx, dy = (path[i + 1][0] - path[i - 1][0], path[i + 1][1] - path[i - 1][1])
        size = math.hypot(dx, dy)
        for side in (1, -1):
            beads.append((x - side * dy / size * radii[i] * 0.97, y + side * dx / size * radii[i] * 0.97,
                          z - 0.05))
    creature.glow(model, GROUP, "pale", creature.dots(beads, 0.1), along)


def _flippers(model, hide):
    for name, side in (("FlipperR", 1), ("FlipperL", -1)):
        flipper = creature.loft([(side * 0.9, 1.6, 0.85), (side * 1.5, 1.4, 0.55), (side * 2.3, 1.1, 0.35)],
                                [0.4, 0.3, 0.05], [0.08, 0.05, 0.02], sides=6)
        model.add(GROUP, flipper, "flesh", FIN, uv=hide, bone=name)
