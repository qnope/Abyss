"""What makes the admiral the admiral: a long coat with flared tails on their own
bones, gold buttons and epaulettes with fringe, tall boots, a violet-visored
helm under a gold-trimmed bicorne, a comms mast on its back and the gold
baton of command."""

import math

from catalog.unit_kit import forms
from catalog.unit_kit.body import SIDES

COAT = [(0, -0.12, 0.49), (0, -0.15, 0.3), (0, -0.17, 0.1)]  # the tails' bones, hip to hem


def coat_bones(rig):
    """The two bones of the coat's back tails, hanging from the hips."""
    rig.chain("Coat", "Hips", COAT)


def coat(dress, b, cloth, trim, braid):
    """The coat's skirt, its two back tails and a gold hem."""
    dress.add(forms.torso(0.25, 0.155, 0.4, b.leg - 0.33, 0.85, sides=10), cloth, "Hips")
    dress.add(forms.torso(0.256, 0.25, 0.025, b.leg - 0.33, 0.85, sides=10), braid, "Hips")
    for z, bone, look in ((0.4, "Coat1", cloth), (0.2, "Coat2", trim)):
        tail = forms.plate_prism([(-0.15, -0.1), (0.15, -0.1), (0.17, 0.1), (-0.17, 0.1)], 0.025,
                                 (0, -0.19, z), (math.pi / 2, 0, math.pi))
        dress.add(tail, look, bone)


def uniform(dress, b, button, braid):
    """Gold buttons down the coat, a medal, and epaulettes with fringe."""
    for side in (-1, 1):
        for k in range(3):
            dress.add(forms.ball((side * 0.05, 0.12, b.neck - 0.07 - k * 0.09), 0.018, (1, 0.6, 1), 1),
                      button, "Chest")
    dress.add(forms.ball((0.1, 0.12, b.neck - 0.1), 0.026, (1, 0.5, 1), 1), button, "Chest")
    for letter, side in SIDES.items():
        s = b.shoulder_joint(side)
        dress.add(forms.ball((s[0], s[1], s[2] + 0.04), 0.085, (1.1, 0.9, 0.35), 2), braid, "UpperArm" + letter)
        for k in (-1, 0, 1):
            top = (s[0] + side * 0.02 + k * 0.045, s[1], s[2] + 0.02)
            dress.add(forms.rod(top, (top[0], top[1], top[2] - 0.09), 0.012, 0.01, 5), braid, "UpperArm" + letter)


def boots(dress, b, leather, trim):
    """Tall boots with a gold band at the top."""
    for letter, side in SIDES.items():
        dress.add(forms.rod((side * 0.09, 0.0, 0.0), (side * 0.09, 0.01, 0.25), 0.07, 0.074, 8), leather, "Shin" + letter)
        dress.add(forms.rod((side * 0.09, 0.01, 0.24), (side * 0.09, 0.01, 0.27), 0.078, 0.078, 8), trim, "Shin" + letter)
        dress.add(forms.slab((side * 0.09, 0.055, 0.04), (0.11, 0.2, 0.08), 0.02), leather, "Shin" + letter)


def hat(dress, b, cloth, braid, lamp, visor):
    """A violet visor under a bicorne of cloth and gold with a lit badge."""
    c = b.head_centre()
    dress.add(forms.ball((c[0], c[1] + b.head * 0.8, c[2] + 0.01), b.head, (0.66, 0.34, 0.4), 2), visor, "Head")
    crescent = [(-0.28, 0.11), (-0.21, 0.0), (0.0, -0.03), (0.21, 0.0), (0.28, 0.11),
                (0.21, 0.065), (0.0, 0.035), (-0.21, 0.065)]
    dress.add(forms.plate_prism(crescent, 0.2, (0, c[1], c[2] + b.head * 0.78), (math.pi / 2, 0, 0)),
              cloth, "Head")
    dress.add(forms.plate_prism([(x * 1.02, z - 0.012) for x, z in crescent], 0.05,
                                (0, c[1] + 0.1, c[2] + b.head * 0.78), (math.pi / 2, 0, 0)), braid, "Head")
    dress.add(forms.ball((0, c[1] + 0.13, c[2] + b.head * 0.9), 0.027, (1, 0.5, 1), 1), lamp, "Head")


def mast(dress, b, rod, bulb):
    """A comms mast on its back, a violet light at its tip."""
    z = b.leg + b.torso * 0.5
    dress.add(forms.rod((0.06, -0.14, z - 0.1), (0.1, -0.2, z + 0.5), 0.014, 0.008, 5), rod, "Pack")
    dress.add(forms.ball((0.1, -0.2, z + 0.52), 0.03, subdivisions=1), bulb, "Pack")


def baton(dress, b, gold, lamp):
    """The baton of command: a gold rod forward and up from the right fist, a
    lit knob at its end."""
    w = b.wrist(1)
    d = (0.0, 0.93, 0.37)
    pt = lambda t: tuple(w[i] + d[i] * t for i in range(3))  # noqa: E731
    dress.add(forms.rod(pt(-0.08), pt(0.34), 0.017, 0.017, 6), gold, "HeldR")
    dress.add(forms.ball(pt(0.37), 0.035, subdivisions=1), lamp, "HeldR")
