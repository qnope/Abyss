"""The isopod's seven pairs of legs and its two long antennae."""

from catalog.armoured.shell import GROUP
from catalog.parts import creature_paint
from workshop import skin, sweep
from workshop.colors import linear

LEG = linear("#4e405a")
FOOT = linear("#b08e68")
FEELER = linear("#c09a6c")
LEG_Y = [0.4, 0.25, 0.1, -0.05, -0.2, -0.35, -0.5]
HEIGHT = 0.22


def antenna_points(side):
    return [(side * 0.1, 0.88, 0.3), (side * 0.3, 1.15, 0.4), (side * 0.58, 1.45, 0.36)]


def skeleton(rig):
    """The legs' bones (one a pair, pivoting under the body's axis) and the
    two antennae's, under the Head; gives the antennae's chains."""
    for i, y in enumerate(LEG_Y):
        rig.bone(f"Leg{i}", "Body", (0, y, 0.2), (0, y + 0.1, 0.2))
    return {side: rig.chain("Ant" + name, "Head", antenna_points(side))
            for side, name in ((1, "R"), (-1, "L"))}


def shape(model, feelers):
    """The legs, each of two segments splayed and leaning with its place; the
    antennae, blended along their bones."""
    rig = model.rig
    paint = creature_paint.tipped(FOOT, LEG, 0.02, 0.2, 2, 13)
    for i, y in enumerate(LEG_Y):
        lean = 0.07 * (1 - i / 3)
        for s in (1, -1):
            points = [(s * 0.42, y, 0.16), (s * 0.68, y + lean, 0.27), (s * 0.84, y + 2 * lean, 0.0)]
            model.add(GROUP, sweep.tube(points, [0.045, 0.035, 0.012], sides=5), "shell", paint,
                      bone=f"Leg{i}")
    for side, chain in feelers.items():
        tube = sweep.tube(antenna_points(side), [0.032, 0.02, 0.007], sides=5)
        model.add(GROUP, tube, "shell", FEELER, bone=skin.along(chain, rig.centres(chain)))
