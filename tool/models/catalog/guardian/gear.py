"""What makes the guardian the guardian: the great helm with its glowing slit and
crest, broad pauldrons, a breastplate and greaves, and the tower shield on its
left arm, almost its own height, with the colony's emblem."""

import math

from catalog.unit_kit import forms
from catalog.unit_kit.body import SIDES
from workshop import shapes

# The shield's outline, across and up from its centre: a kite with a pointed foot.
KITE = [(-0.2, -0.17), (0.0, -0.31), (0.2, -0.17), (0.21, 0.28), (-0.21, 0.28)]
FRONT = (math.pi / 2, 0, math.pi)  # a flat plate stood up, its face toward +Y


def helm(dress, b, shell, slit, ridge):
    """A great helm: a glowing slit across the face, a crest ridge on top."""
    c = b.head_centre()
    dress.add(forms.slab((c[0], c[1] + b.head * 0.9, c[2] + 0.015), (0.24, 0.045, 0.05), 0.01),
              slit, "Head")
    fin = forms.plate_prism([(-0.14, 0.0), (0.12, 0.0), (0.08, 0.075), (-0.1, 0.1)], 0.03,
                            rotation=(math.pi / 2, 0, math.pi / 2))
    dress.add(fin.transform((0, c[1], c[2] + b.head * 0.88)), ridge, "Head")
    dress.add(forms.slab((c[0], c[1] + b.head * 0.7, c[2] - b.head * 0.55), (0.22, 0.1, 0.1), 0.02),
              shell, "Head")


def armour(dress, b, pauldron, plate, greave, lamp):
    """Pauldrons, a breastplate with a cyan gem, greaves and sabatons."""
    for letter, side in SIDES.items():
        dress.add(forms.ball(b.shoulder_joint(side), 0.1, (1.0, 1.05, 0.85), 2), pauldron, "UpperArm" + letter)
        dress.add(forms.slab((side * 0.1, 0.02, 0.13), (0.1, 0.11, 0.17), 0.02), greave, "Shin" + letter)
        dress.add(forms.slab((side * 0.1, 0.05, 0.04), (0.12, 0.24, 0.08), 0.02), greave, "Shin" + letter)
    z = b.neck - 0.15
    dress.add(forms.slab((0, 0.1, z), (0.27, 0.05, 0.2), 0.02), plate, "Chest")
    dress.add(forms.ball((0, 0.13, z + 0.01), 0.03, (1, 0.5, 1.3), 1), lamp, "Chest")


def shield(dress, b, face, rim, emblem, lamp):
    """The tower shield on the left forearm: a rim, a face, the emblem and a
    cyan strip along its edge."""
    w = b.wrist(-1)
    c = (w[0] - 0.03, w[1] + 0.12, w[2] + 0.1)
    for thick, look, push in ((0.07, rim, 0.0), (0.045, face, 0.03)):
        scale = 1.0 if push else 1.08
        plate = forms.plate_prism([(x * scale, z * scale) for x, z in KITE], thick, rotation=FRONT)
        dress.add(plate.transform((c[0], c[1] + push, c[2])), look, "HeldL")
    badge = shapes.cylinder(0.12, 0.012, sides=12, smooth=False)
    badge.transform((0, 0, -0.006), rotation=(-math.pi / 2, 0, 0))
    dress.add(badge.transform((c[0], c[1] + 0.058, c[2] + 0.09)), emblem, "HeldL")
    dress.add(forms.slab((c[0], c[1] + 0.056, c[2] - 0.22), (0.1, 0.012, 0.025), 0.005), lamp, "HeldL")


def maul(dress, b, haft, head, lamp):
    """A short maul in the right hand: a haft, a blunt head, a cyan band."""
    w = b.wrist(1)
    up = (0.0, 0.22, 0.97)
    pt = lambda t: tuple(w[i] + up[i] * t for i in range(3))  # noqa: E731
    dress.add(forms.rod(pt(-0.12), pt(0.3), 0.017, 0.015, 6), haft, "HeldR")
    dress.add(forms.rod(pt(0.3), pt(0.44), 0.06, 0.06, 8), head, "HeldR")
    dress.add(forms.rod(pt(0.36), pt(0.38), 0.064, 0.064, 8), lamp, "HeldR")


def back(dress, b, plate, tank, lamp):
    """A back plate with two small air tanks and a cyan strip, so that the
    defender is not a bare column from behind."""
    z = b.leg + b.torso * 0.5
    dress.add(forms.slab((0, -0.16, z + 0.02), (0.3, 0.07, 0.3), 0.02), plate, "Pack")
    for side in (-1, 1):
        dress.add(forms.rod((side * 0.075, -0.225, z - 0.1), (side * 0.075, -0.225, z + 0.14), 0.045, 0.045, 8),
                  tank, "Pack")
    dress.add(forms.slab((0, -0.2, z + 0.12), (0.12, 0.012, 0.025), 0.004), lamp, "Pack")
