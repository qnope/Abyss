"""What makes the dome breaker the dome breaker: a horned helmet with a wide
amber visor bar, one spiked pauldron and one armoured, hazard-striped gauntlets
and greaves, a hydraulic pack, and the breaching hammer on its shoulder: a
heavy flat face, a drill spike behind it, a lit collar."""

import math

from catalog.unit_kit import forms
from catalog.unit_kit.body import SIDES


def helmet(dress, b, plate, horn, visor):
    """Two horns swept up and out, a brow plate and a wide amber visor."""
    c = b.head_centre()
    for side in (-1, 1):
        dress.add(forms.cone((side * 0.13, c[1], c[2] + 0.13), (side * 0.28, c[1] - 0.02, c[2] + 0.3),
                             0.055, 6), horn, "Head")
    dress.add(forms.slab((c[0], c[1] + b.head * 0.78, c[2] + 0.015), (0.3, 0.05, 0.07), 0.012), visor, "Head")
    dress.add(forms.slab((c[0], c[1] + b.head * 0.7, c[2] + 0.085), (0.31, 0.1, 0.035), 0.01), plate, "Head")


def pauldrons(dress, b, spiked, armoured, horn):
    """The left pauldron a spiked boss, the right a plated dome."""
    left, right = b.shoulder_joint(-1), b.shoulder_joint(1)
    dress.add(forms.ball(left, 0.125, (1, 1, 0.85), 2), spiked, "UpperArmL")
    for tip in ((-0.1, 0, 0.14), (-0.18, 0.04, 0.08), (-0.1, 0.11, 0.1), (-0.12, -0.1, 0.1)):
        base = tuple(l + t * 0.55 for l, t in zip(left, tip))
        dress.add(forms.cone(base, tuple(l + t for l, t in zip(left, tip)), 0.035, 5), horn, "UpperArmL")
    dress.add(forms.ball(right, 0.125, (1, 1.05, 0.85), 2), armoured, "UpperArmR")


def stripes(dress, b, hazard, plate):
    """Striped gauntlets and greaves, a plate on the chest, a striped belt."""
    for letter, side in SIDES.items():
        mid = tuple((e + w) / 2 for e, w in zip(b.elbow(side), b.wrist(side)))
        dress.add(forms.slab(mid, (0.1, 0.12, 0.13), 0.02), hazard, "Forearm" + letter)
        dress.add(forms.slab((side * 0.12, 0.02, 0.12), (0.12, 0.12, 0.17), 0.02), hazard, "Shin" + letter)
        dress.add(forms.slab((side * 0.12, 0.05, 0.04), (0.15, 0.26, 0.08), 0.02), plate, "Shin" + letter)
    dress.add(forms.slab((0, 0.13, b.neck - 0.14), (0.34, 0.06, 0.22), 0.02), plate, "Chest")
    dress.add(forms.torso(0.17, 0.17, 0.06, b.leg + 0.06, 0.85), hazard, "Hips")


def pack(dress, b, block, tank, lamp):
    """The hydraulic pack: a block, a tank and a lit strip."""
    z = b.leg + b.torso * 0.5
    dress.add(forms.slab((0, -0.17, z), (0.3, 0.14, 0.26), 0.02), block, "Pack")
    dress.add(forms.rod((0.08, -0.26, z - 0.13), (0.08, -0.26, z + 0.17), 0.05, 0.05, 8), tank, "Pack")
    dress.add(forms.slab((-0.08, -0.245, z), (0.1, 0.012, 0.18), 0.004), lamp, "Pack")


def hammer(dress, b, haft, face, spike, lamp):
    """The breaching hammer on the right shoulder: a haft, a flat striking
    face and a drill spike behind it, a lit collar between."""
    w = b.wrist(1)
    tilt = math.radians(14)
    up = (0.0, -math.sin(tilt), math.cos(tilt))
    pt = lambda t: tuple(w[i] + up[i] * t for i in range(3))  # noqa: E731
    dress.add(forms.rod(pt(-0.16), pt(0.78), 0.028, 0.024, 6), haft, "HeldR")
    head = forms.slab((0, 0, 0), (0.17, 0.2, 0.19), 0.03, (tilt, 0, 0))
    dress.add(head.transform(pt(0.86)), face, "HeldR")
    dress.add(forms.rod(pt(0.8), pt(0.84), 0.055, 0.055, 8), lamp, "HeldR")
    back = tuple(pt(0.86)[i] - 0.1 * (0, math.cos(tilt), math.sin(tilt))[i] for i in range(3))
    tip = tuple(back[i] - 0.2 * (0, math.cos(tilt), math.sin(tilt))[i] for i in range(3))
    dress.add(forms.cone(back, tip, 0.055, 6), spike, "HeldR")
