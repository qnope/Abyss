"""What makes the harpooner the harpooner: the brass dive helmet with its three
amber ports and its corselet collar, the air hose to the twin tanks on its
back, heavy lead-soled boots, a rope coil at the hip and the long harpoon."""

import math

from catalog.unit_kit import forms
from catalog.unit_kit.body import SIDES
from workshop import sweep


def helmet(dress, b, brass, port, dark):
    """Round ports front and sides, a flange round the neck, and a corselet
    of brass over the shoulders."""
    c = b.head_centre()
    dress.add(forms.ball((c[0], c[1] + b.head * 0.86, c[2] + 0.005), b.head, (0.36, 0.25, 0.36), 2),
              port, "Head")
    for side in (-1, 1):
        dress.add(forms.ball((c[0] + side * b.head * 0.92, c[1] + 0.02, c[2] + 0.01), b.head,
                             (0.22, 0.3, 0.3), 1), port, "Head")
    dress.add(forms.ball((c[0], c[1], c[2] + b.head * 0.55), b.head, (0.22, 0.22, 0.12), 1), dark, "Head")
    dress.add(forms.torso(0.205, 0.17, 0.07, b.neck - 0.05, 1.0), brass, "Chest")


def tanks(dress, b, tank, valve, hose):
    """Two air tanks on the back, their valves, and the hose looping from the
    helmet's back to them."""
    z = b.leg + b.torso * 0.5
    for side in (-1, 1):
        dress.add(forms.rod((side * 0.07, -0.17, z - 0.17), (side * 0.07, -0.17, z + 0.15), 0.06, 0.06, 8),
                  tank, "Pack")
        dress.add(forms.ball((side * 0.07, -0.17, z + 0.17), 0.045, (1, 1, 0.8)), valve, "Pack")
    c = b.head_centre()
    path = [(0.05, c[1] - b.head * 0.8, c[2] - 0.02), (0.14, -0.26, c[2] - 0.12),
            (0.12, -0.28, z + 0.12), (0.05, -0.2, z + 0.19)]
    dress.add(sweep.tube(path, [0.017] * 4, sides=5, cap=False), hose, "Chest")


def boots(dress, sole, upper):
    """A heavy boot with a thick lead sole on each foot."""
    for letter, side in SIDES.items():
        dress.add(forms.slab((side * 0.09, 0.05, 0.075), (0.11, 0.2, 0.075), 0.02), upper, "Shin" + letter)
        dress.add(forms.slab((side * 0.09, 0.055, 0.02), (0.13, 0.23, 0.04), 0.012), sole, "Shin" + letter)


def coil(dress, rope, leather):
    """A coil of rope and a pouch at the hips."""
    dress.add(forms.rod((-0.17, 0.0, 0.26), (-0.17, 0.0, 0.31), 0.065, 0.06, 8), rope, "Hips")
    dress.add(forms.slab((0.15, 0.04, 0.27), (0.09, 0.08, 0.08), 0.015), leather, "Hips")


def harpoon(dress, b, shaft, iron, lamp):
    """A long harpoon held in the right hand, its barbed head up and forward,
    a lit band at its grip."""
    w = b.wrist(1)
    tilt = math.radians(-16)
    up = (0.0, -math.sin(tilt), math.cos(tilt))
    point = lambda t: tuple(w[i] + up[i] * t for i in range(3))  # noqa: E731
    dress.add(forms.rod(point(-0.3), point(0.68), 0.017, 0.015, 6), shaft, "HeldR")
    dress.add(forms.rod(point(0.68), point(0.8), 0.03, 0.02, 6), iron, "HeldR")
    dress.add(forms.cone(point(0.8), point(0.98), 0.032, 6), iron, "HeldR")
    for side in (-1, 1):
        outline = [(0, 0), (0.07 * side, -0.05), (0.03 * side, 0.02)]
        barb = forms.plate_prism(outline[::side], 0.012, rotation=(math.pi / 2, 0, 0))
        barb.transform(point(0.8))
        dress.add(barb, iron, "HeldR")
    dress.add(forms.rod(point(0.04), point(0.1), 0.021, 0.021, 6), lamp, "HeldR")
