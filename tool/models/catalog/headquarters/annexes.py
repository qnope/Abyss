"""What stands around the keep at the diagonals: twin pressure tanks piped
into the hull (back right), a generator with its exhaust (back left), and
the reef growing at the foot of it all, by clusters a tier at a time."""

import math

from catalog import colors
from catalog.headquarters.keep import PLINTH, radius_at
from catalog.paints import machined
from catalog.parts import Into, light, place, plumbing, reef
from workshop import shapes

# The reef at the foot: (angle in degrees, distance, size), the biggest at
# the front corner, toward the game's camera.
CLUSTERS = ((-45, 1.36, 1.15), (-20, 1.32, 0.7), (-70, 1.33, 0.75), (200, 1.34, 0.8),
            (160, 1.38, 0.9), (110, 1.3, 0.6), (250, 1.3, 0.6))


def reefs(model, group, which):
    """The clusters of CLUSTERS numbered [which] at the keep's foot."""
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    for index in which:
        angle, distance, size = CLUSTERS[index]
        a = math.radians(angle)
        reef.cluster(into, rng, atlas, (distance * math.cos(a), distance * math.sin(a), 0), size, 3)


def works(model, group):
    atlas, rng, into = model.atlas, model.rng, Into(model, group)
    _tanks(into, atlas, math.radians(45))
    _generator(into, atlas, math.radians(135))
    ledge = reef.around(rng, radius_at(0.2) + 0.04, PLINTH[0] - 0.08, 6, 0.16,
                        arcs=((-80, -10), (100, 170), (190, 260)), z=PLINTH[1] * 0.95)
    reef.grow(into, rng, atlas, ledge, reef.SMALL)


def _tanks(into, atlas, angle):
    """Two spheres on cradles, banded, piped into the hull."""
    for k, offset in enumerate((-0.27, 0.27)):
        d = 1.42
        x = d * math.cos(angle) - math.sin(angle) * offset
        y = d * math.sin(angle) + math.cos(angle) * offset
        sphere = shapes.sphere(0.2, subdivisions=2).transform((0, 0, 0.27))
        band = shapes.cylinder(0.205, 0.05, sides=16, smooth=True).transform((0, 0, 0.245))
        parts = [(sphere, "hull", machined(colors.LIMESTONE, 40 + k, soot=0.5, height=0.3),
                  atlas.tiled("weathered", 0.5)(sphere)),
                 (band, "hull", colors.CORAL_ORANGE, atlas.fit("bolt")(band))]
        for leg in range(4):
            a = math.pi / 4 + leg * math.pi / 2
            strut = shapes.box((0.035, 0.035, 0.16), bottom=False).transform(
                (0.13 * math.cos(a), 0.13 * math.sin(a), -0.03))
            parts.append((strut, "hull", colors.METAL_DARK, None))
        lamp = shapes.octahedron(0.025).transform((0, 0, 0.48))
        parts.append((lamp, *light(atlas, "amber")))
        place(into, parts, (x, y, 0))
        hull = radius_at(0.4) * 0.93
        inlet = (hull * math.cos(angle) - math.sin(angle) * offset * 0.6,
                 hull * math.sin(angle) + math.cos(angle) * offset * 0.6, 0.42)
        place(into, plumbing.pipe(atlas, [(x * 0.9, y * 0.9, 0.3), (x * 0.82, y * 0.82, 0.42), inlet],
                                  0.035, colors.PIPE, flanges=1, seed=k))


def _generator(into, atlas, angle):
    """A boxy generator with louvred flanks, an exhaust stack and a cable."""
    d = 1.36
    x, y = d * math.cos(angle), d * math.sin(angle)
    body = shapes.box((0.42, 0.3, 0.3), bevel=0.02, bottom=False)
    vents = shapes.box((0.36, 0.31, 0.18), bevel=0.0).transform((0, 0, 0.06))
    vents.faces = [f for i, f in enumerate(vents.faces) if abs(vents.face_normal(i).y) > 0.9]
    vents.smooth = [False] * len(vents.faces)
    stack = shapes.cylinder(0.045, 0.32, sides=8, bottom=False).transform((0.12, 0.05, 0.28))
    cap = shapes.cylinder(0.065, 0.03, sides=8).transform((0.12, 0.05, 0.6))
    parts = [(body, "hull", machined(colors.CORAL_ORANGE, 50, soot=0.4), atlas.fit("plate_wide")(body)),
             (vents, "hull", colors.STONE_WORN, atlas.fit("vent")(vents)),
             (stack, "hull", machined(colors.METAL_DARK, 51), atlas.tiled("weathered", 0.5)(stack)),
             (cap, "hull", colors.METAL_DARK, None),
             (shapes.octahedron(0.022).transform((-0.15, -0.155, 0.24)), *light(atlas, "amber"))]
    place(into, parts, (x, y, 0), (0, 0, angle + math.pi / 2))
    hull = radius_at(0.3) * 0.92
    place(into, plumbing.cable([(x * 0.9, y * 0.9, 0.12), (x * 0.82, y * 0.82, 0.06),
                                (hull * math.cos(angle), hull * math.sin(angle), 0.3)],
                               0.018, colors.GROOVE))
