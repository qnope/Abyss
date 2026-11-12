"""What makes the scout the scout: a thruster pack with dorsal fins and a cyan
nozzle, big flippers, an antenna with a red bulb, pauldrons, a forearm gadget
and the shock prod in its hand."""

import math

from catalog.unit_kit import forms
from catalog.unit_kit.body import SIDES


def pack(dress, b, metal, fin, lamp):
    """The thruster on its back: a barrel, a nozzle with a cyan flame, and
    three swept dorsal fins."""
    z = b.leg + b.torso * 0.55
    dress.add(forms.rod((0, -0.1, z), (0, -0.34, z), 0.065, 0.058, sides=8), metal, "Pack")
    dress.add(forms.rod((0, -0.34, z), (0, -0.4, z), 0.07, 0.05, sides=8), metal, "Pack")
    dress.add(forms.cone((0, -0.4, z), (0, -0.56, z), 0.045, sides=6), lamp, "Pack")
    outline = [(0.03, 0.0), (-0.24, 0.0), (-0.3, 0.2), (-0.14, 0.16), (0.0, 0.3)]
    for side, yaw, lift in ((-1, -14, 0.0), (1, 14, 0.0), (0, 0, 0.05)):
        shape = forms.plate_prism(outline, 0.018, rotation=(math.pi / 2, 0, math.pi / 2))
        shape.transform((side * 0.08, -0.06, z + 0.03 + lift), (0, 0, math.radians(yaw)))
        dress.add(shape, fin, "Pack")


def flippers(dress, fin, rib):
    """A wide fan of a flipper on each foot, a pale rib down its middle."""
    outline = [(-0.045, -0.05), (0.045, -0.05), (0.12, 0.2), (0.0, 0.3), (-0.12, 0.2)]
    for letter, side in SIDES.items():
        blade = forms.plate_prism(outline, 0.022, (side * 0.07, 0.04, 0.03))
        dress.add(blade, fin, "Shin" + letter)
        dress.add(forms.slab((side * 0.07, 0.17, 0.044), (0.014, 0.2, 0.012), 0.003), rib, "Shin" + letter)


def head_gear(dress, b, metal, bulb, ring):
    """An antenna with a red bulb, and a ring round the neck."""
    c = b.head_centre()
    base, tip = (c[0] - 0.1, c[1], c[2] + b.head * 0.8), (c[0] - 0.17, c[1] - 0.02, b.top + 0.09)
    dress.add(forms.rod(base, tip, 0.012, 0.008, sides=5), metal, "Head")
    dress.add(forms.ball(tip, 0.03, subdivisions=1), bulb, "Head")
    dress.add(forms.torso(0.12, 0.12, 0.045, b.neck - 0.03, 1.0), ring, "Head")


def arms(dress, b, plate, gadget, lamp):
    """Pauldrons, the gadget and its lamp on the right forearm, the prod in the
    right hand with a cyan tip."""
    for letter, side in SIDES.items():
        dress.add(forms.ball(b.shoulder_joint(side), 0.062, (1, 1, 0.8), 2), plate, "UpperArm" + letter)
    elbow, wrist = b.elbow(1), b.wrist(1)
    mid = tuple((e + w) / 2 for e, w in zip(elbow, wrist))
    dress.add(forms.slab((mid[0] + 0.03, mid[1], mid[2]), (0.04, 0.06, 0.1), 0.01), gadget, "ForearmR")
    dress.add(forms.ball((mid[0] + 0.052, mid[1], mid[2]), 0.016), lamp, "ForearmR")
    tip = (wrist[0], wrist[1] + 0.2, wrist[2] + 0.14)
    dress.add(forms.rod((wrist[0], wrist[1] - 0.03, wrist[2] - 0.03), tip, 0.014, 0.012), gadget, "HeldR")
    dress.add(forms.ball(tip, 0.028, subdivisions=1), lamp, "HeldR")
