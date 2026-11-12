"""The turtle's parts: its domed shell (scutes painted as cracks between
plates, a pale belly), its head and its flippers, bound to their bones."""

import math

from workshop import noise, shapes
from workshop.colors import linear, mix, scale

SHELL, SCUTE = linear("#5f8143"), linear("#2f4a2a")
BELLY, SKIN = linear("#dccd92"), linear("#9fae56")
FLIPPER = linear("#6f8d4b")
EYE = linear("#10180f")


def carapace(model, group):
    """The shell: a dome whose upper half is plates, whose lower half is the
    pale belly, a rim of pale scutes between."""
    dome = shapes.sphere(1.0, subdivisions=2)
    dome.transform((0, -0.01, 0.0), scale=(0.2, 0.27, 0.095))

    def paint(p, normal):
        if normal.z < -0.1:
            return scale(BELLY, 0.92 + 0.1 * noise.fbm(p * 9, 3, octaves=2))
        plates = noise.cracks(p * 7.0, 4, 1.0, 0.22)
        top = mix(SHELL, scale(SHELL, 1.25), 0.5 + 0.5 * noise.fbm(p * 6, 5, octaves=2))
        rim = max(0.0, 1.0 - max(0.0, normal.z + 0.1) * 5)
        return mix(mix(top, SCUTE, plates * 0.8), mix(SHELL, BELLY, 0.45), rim * 0.7)
    model.add(group, dome, "coral", paint, bone="Body")


def head(model, group):
    """A small head on a neck, with two dark eyes."""
    neck = shapes.cylinder(0.04, 0.12, sides=6, bottom=False)
    neck.transform((0, 0.17, 0.0), (math.radians(-80), 0, 0))
    model.add(group, neck, "coral", SKIN, bone="Head")
    skull = shapes.sphere(0.065, subdivisions=2)
    skull.transform((0, 0.31, 0.03), scale=(0.9, 1.25, 0.85))
    model.add(group, skull, "coral", lambda p, n: mix(SKIN, linear("#d6dc84"), max(0.0, -n.z) * 0.8),
              bone="Head")
    for side in (-1, 1):
        eye = shapes.sphere(0.014, subdivisions=1).transform((side * 0.045, 0.34, 0.06))
        model.add(group, eye, "coral", EYE, bone="Head")


def flipper(model, group, side, weights):
    """A front flipper on [side] (-1 left): a long flat paddle trailing back,
    paler on its edge, blended along its two bones by [weights]."""
    paddle = shapes.sphere(1.0, subdivisions=2)
    paddle.transform((side * 0.26, 0.09, -0.05), (0, 0, side * 0.25), scale=(0.18, 0.065, 0.014))

    def paint(p, normal):
        edge = min(1.0, (abs(p.x) - 0.09) / 0.3)
        return mix(scale(FLIPPER, 0.85 if normal.z > 0 else 1.2), BELLY, 0.5 * max(0.0, edge) ** 3)
    model.add(group, paddle, "coral", paint, bone=weights)


def rear(model, group, side, bone):
    """A small rear flipper on [side] (-1 left), rigid to [bone]."""
    paddle = shapes.sphere(1.0, subdivisions=1)
    paddle.transform((side * 0.15, -0.22, -0.05), (0, 0, -side * 0.6), scale=(0.075, 0.04, 0.012))
    model.add(group, paddle, "coral", FLIPPER, bone=bone)
