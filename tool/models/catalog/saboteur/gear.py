"""What makes the saboteur the saboteur: a hooded cloak with a ragged hem and a
pointed hood tail, a gas mask with two red lenses and a green filter, wrapped
legs, a filter canister on its back, the dagger in its right hand and, on its
hip, the limpet mine that is its attack."""

import math

from catalog.unit_kit import forms
from catalog.unit_kit.body import SIDES

HIP_MINE = (-0.15, 0.02, 0.22)  # the mine, at the left hip, and its bone's tail below


def mine_bone(rig, b):
    """The limpet mine's own bone, at the left hip."""
    x, y, z = HIP_MINE
    rig.bone("Mine", "Hips", (x, y, z), (x, y, z - 0.06))


def cloak(dress, b, cloth, trim):
    """The cloak: a cone from the shoulders to the knees, a ragged hem of points,
    and a drape over the back."""
    base = b.leg - 0.06
    dress.add(forms.torso(0.27, 0.15, b.torso + 0.12, base, 0.85, sides=9), cloth, "Chest")
    for k in range(9):
        a = 2 * math.pi * (k + 0.5) / 9
        top = (0.27 * math.cos(a), 0.27 * 0.85 * math.sin(a), base + 0.02)
        dress.add(forms.cone(top, (top[0] * 1.02, top[1] * 1.02, base - 0.06), 0.036, 4), trim, "Chest")


def runes(dress, b, glow):
    """Two mint strips of light down the front of the cloak."""
    z = b.leg + 0.12
    front = (0.27 - (z - (b.leg - 0.06)) / (b.torso + 0.12) * 0.12) * 0.85 + 0.004  # the cloak's skin there
    for side in (-1, 1):
        dress.add(forms.slab((side * 0.06, front, z), (0.022, 0.012, 0.15), 0.004, (-0.3, 0, side * 0.1)),
                  glow, "Chest")


def boots(dress, rubber):
    """Soft dark boots under the hem."""
    for letter, side in SIDES.items():
        dress.add(forms.slab((side * 0.07, 0.05, 0.035), (0.09, 0.17, 0.07), 0.02), rubber, "Shin" + letter)


def hood(dress, b, cloth, mask, lens, ring, rubber):
    """A pointed hood over a gas mask: two red lenses, a filter canister with a
    green ring."""
    c = b.head_centre()
    dress.add(forms.ball((c[0], c[1] - 0.01, c[2] + 0.015), b.head * 1.12, (1.0, 1.05, 1.02), 2), cloth, "Head")
    dress.add(forms.cone((0, c[1] - 0.1, c[2] + 0.08), (0, c[1] - 0.3, c[2] + 0.02), 0.1, 6), cloth, "Head")
    dress.add(forms.ball((0, c[1] + b.head * 0.78, c[2] - 0.01), b.head, (0.58, 0.3, 0.55), 2), mask, "Head")
    for side in (-1, 1):
        dress.add(forms.ball((side * 0.058, c[1] + b.head * 1.0, c[2] + 0.025), 0.04, (1, 0.5, 1), 1), lens, "Head")
    start, end = (0, c[1] + b.head * 1.05, c[2] - 0.06), (0, c[1] + b.head * 1.5, c[2] - 0.09)
    dress.add(forms.rod(start, end, 0.042, 0.04, 7), rubber, "Head")
    dress.add(forms.rod((0, c[1] + b.head * 1.3, c[2] - 0.08), (0, c[1] + b.head * 1.38, c[2] - 0.085),
                        0.046, 0.046, 7), ring, "Head")


def wraps(dress, b, strap):
    """Wrapping bands on the shins and the forearms."""
    for letter, side in SIDES.items():
        for t in (0.3, 0.62):
            k, a = b.knee(side), b.ankle(side)
            p = tuple(k[i] + (a[i] - k[i]) * t for i in range(3))
            dress.add(forms.rod((p[0], p[1], p[2] - 0.015), (p[0], p[1], p[2] + 0.015), 0.045, 0.045, 7),
                      strap, "Shin" + letter)
        e, w = b.elbow(side), b.wrist(side)
        mid = tuple(e[i] + (w[i] - e[i]) * 0.55 for i in range(3))
        dress.add(forms.ball(mid, 0.04, (1, 1, 0.5), 1), strap, "Forearm" + letter)


def canister(dress, b, tank, ring):
    """A filter canister on the back with a green ring."""
    z = b.leg + b.torso * 0.5
    dress.add(forms.rod((0, -0.2, z - 0.1), (0, -0.2, z + 0.12), 0.06, 0.06, 8), tank, "Pack")
    dress.add(forms.rod((0, -0.2, z + 0.02), (0, -0.2, z + 0.05), 0.064, 0.064, 8), ring, "Pack")


def mine(dress, case, ring, core):
    """The limpet mine: a domed disc with a green ring, a red core and studs,
    lying against the left hip."""
    x, y, z = HIP_MINE
    dress.add(forms.ball((x - 0.02, y, z), 0.085, (0.55, 1, 1), 2), case, "Mine")
    dress.add(forms.rod((x + 0.02, y, z), (x - 0.04, y, z), 0.092, 0.092, 10), ring, "Mine")
    dress.add(forms.ball((x - 0.07, y, z), 0.032, (0.6, 1, 1), 1), core, "Mine")
    for k in range(5):
        a = 2 * math.pi * k / 5
        stud = (x - 0.03, y + 0.075 * math.cos(a), z + 0.075 * math.sin(a))
        dress.add(forms.cone(stud, (stud[0] - 0.05, stud[1] * 1.0, stud[2]), 0.018, 4), case, "Mine")


def dagger(dress, b, blade, glow):
    """A short dagger in the right fist, pointing forward and down, its pommel
    lit green."""
    w = b.wrist(1)
    d = (0.0, 0.94, -0.34)
    pt = lambda t: tuple(w[i] + d[i] * t for i in range(3))  # noqa: E731
    dress.add(forms.cone(pt(0.0), pt(0.27), 0.024, 4), blade, "HeldR")
    dress.add(forms.rod(pt(-0.07), pt(0.0), 0.016, 0.02, 6), blade, "HeldR")
    dress.add(forms.ball(pt(-0.08), 0.022, subdivisions=1), glow, "HeldR")
