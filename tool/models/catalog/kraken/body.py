"""The Kraken's body: a thick skirt where the tentacles root, a tall leaning
dome of a head cracked with molten veins, two huge ember eyes under horned
brows, a hooked beak and a collar of spikes."""

import math

from catalog import monster_palette as pal
from catalog.parts import creature, creature_paint
from workshop.colors import linear

BACK = linear("#4a3a70")
BELLY = linear("#7a5a92")
VEIN = linear("#ff8a2a")
HORN = linear("#cfc3a4")
GROUP = "Kraken"
# The dome, from the skirt up: height, the radius and how far back its axis leans.
DOME = [(1.5, 1.1, 0.0), (2.2, 1.3, -0.3), (3.0, 1.1, -0.6), (3.55, 0.55, -0.85), (3.8, 0.12, -0.9)]


def skeleton(rig):
    """The Body (the skirt, where every tentacle roots) and the Head (the dome)."""
    rig.bone("Body", None, (0, 0, 0.3), (0, 0, 1.5))
    rig.bone("Head", "Body", (0, 0, 1.5), (0, -0.5, 3.6))


def surface(z, angle):
    """The point on the dome at height [z] and [angle] round it, from the profile."""
    for (z0, r0, y0), (z1, r1, y1) in zip(DOME, DOME[1:]):
        if z0 <= z <= z1:
            t = (z - z0) / (z1 - z0)
            r, y = r0 + (r1 - r0) * t, y0 + (y1 - y0) * t
            return (r * math.cos(angle), y + r * math.sin(angle), z)
    return (0, 0, z)


def shape(model):
    hide = model.atlas.tiled("hide", 1.4)
    paint = creature_paint.shaded(BACK, BELLY, 1.0, 1.4, 61, 0.14, 1.5, (VEIN, 1.1))
    skirt = creature.loft([(0, 0, z) for z in (0.2, 0.6, 1.1, 1.6)], [1.0, 1.35, 1.25, 1.1],
                          [1.0, 1.35, 1.25, 1.1], sides=18, caps=(True, False))
    model.add(GROUP, skirt, "flesh", paint, uv=hide, bone="Body")
    dome = creature.loft([(0, y, z) for z, _, y in DOME], [r for _, r, _ in DOME],
                         [r for _, r, _ in DOME], sides=18, caps=(False, True))
    model.add(GROUP, dome, "flesh", paint, uv=hide, bone="Head")
    creature.add_eyes(model, GROUP, "eye_lava", (0.66, 0.8, 2.2), 0.38, "Head", toe=40, flat=0.6)
    _horns(model)
    _embers(model)


def _horns(model):
    """Horned brows over the eyes, a hooked beak under the head, a collar of
    spikes round the skirt."""
    brows = [(s * x, 0.8, 2.6) for s in (1, -1) for x in (0.45, 0.8)]
    model.add(GROUP, creature.spikes(brows, [(x * 1.3, 1.2, 3.0) for x, _, _ in brows], 0.09, 5),
              "shell", HORN, bone="Head")
    beak = creature.spikes([(s * 0.16, 1.2, 1.2) for s in (1, -1)],
                           [(s * 0.02, 1.75, 0.6) for s in (1, -1)], 0.14, 5)
    model.add(GROUP, beak, "shell", pal.BONE, bone="Body")
    ring = [(1.2 * math.sin(a), 1.2 * math.cos(a), 1.6) for a in
            (2 * math.pi * i / 10 for i in range(10))]
    model.add(GROUP, creature.spikes(ring, [(x * 1.2, y * 1.2, 2.0) for x, y, _ in ring], 0.09, 5),
              "shell", HORN, bone="Body")


def _embers(model):
    """Embers glowing in the skin of the dome, where the lava cracks it."""
    points = [surface(1.7 + 1.6 * model.rng.random(), model.rng.uniform(0.0, 6.28)) for _ in range(22)]
    creature.glow(model, GROUP, "lava", creature.dots(points, 0.07), "Head")
