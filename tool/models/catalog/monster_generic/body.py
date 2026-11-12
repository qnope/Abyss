"""The prowler's skeleton and shapes: a round body, an enormous underbite of a jaw
hung with fangs, a lure on a stalk, stumpy fins and a short tail."""

from catalog import monster_palette as pal
from catalog.parts import creature, creature_paint
from workshop import shapes, skin, sweep
from workshop.colors import linear

H = 0.4  # the body's axis above the floor
BACK = linear("#6d6c42")
BELLY = linear("#b2a874")
FIN = linear("#7d7a4a")
LURE = [(0, 0.2, H + 0.3), (0, 0.45, H + 0.55), (0, 0.72, H + 0.5)]
TAIL = [(0, -0.35, H), (0, -0.55, H + 0.02), (0, -0.78, H + 0.04)]
GROUP = "Prowler"


def skeleton(rig):
    """Body, the Jaw, two Fin bones, a Lure and a Tail of two bones each;
    gives the lure's and the tail's names."""
    rig.bone("Body", None, (0, -0.35, H), (0, 0.3, H))
    rig.bone("Jaw", "Body", (0, 0.05, H - 0.15), (0, 0.55, H - 0.2))
    for name, side in (("FinR", 1), ("FinL", -1)):
        rig.bone(name, "Body", (side * 0.2, 0.0, H - 0.2), (side * 0.4, -0.1, H - 0.3))
    return rig.chain("Lure", "Body", LURE), rig.chain("Tail", "Body", TAIL)


def shape(model, lure, tail):
    rig = model.rig
    skin_tile = model.atlas.tiled("skin", 0.3)
    paint = creature_paint.shaded(BACK, BELLY, H, 0.3, 81, 0.16, 3.0)
    trunk = creature.loft([(0, y, H) for y in (-0.4, -0.2, 0.05, 0.28, 0.42)],
                          [0.1, 0.32, 0.4, 0.34, 0.14], [0.12, 0.32, 0.36, 0.3, 0.1], sides=12,
                          caps=(False, True))
    model.add(GROUP, trunk, "flesh", paint, uv=skin_tile, bone="Body")
    jaw = creature.loft([(0, y, H - 0.2) for y in (0.0, 0.2, 0.4, 0.6)], [0.3, 0.3, 0.22, 0.06],
                        [0.1, 0.1, 0.07, 0.03], sides=10, caps=(False, True))
    model.add(GROUP, jaw, "flesh", paint, uv=skin_tile, bone="Jaw")
    stem = sweep.tube(LURE, [0.03, 0.022, 0.016], sides=5, cap=False)
    model.add(GROUP, stem, "flesh", paint, bone=skin.along(lure, rig.centres(lure)))
    creature.glow(model, GROUP, "lava", shapes.sphere(0.09, subdivisions=1).transform(LURE[-1]), lure[-1])
    along = skin.along(tail, rig.centres(tail))
    tailfin = creature.membrane([(0, -0.5, H + 0.02), (0, -0.82, H + 0.2), (0, -0.74, H), (0, -0.82, H - 0.18)])
    model.add(GROUP, tailfin, "membrane", FIN, uv=model.atlas.solid("plain"), bone=along)
    model.add(GROUP, sweep.tube([(0, -0.3, H), (0, -0.5, H + 0.01), (0, -0.7, H + 0.03)],
                                [0.1, 0.06, 0.03], sides=8, cap=False), "flesh", paint, bone=along)
    _fins(model)
    _teeth(model)
    creature.add_eyes(model, GROUP, "eye_sulfur", (0.17, 0.2, H + 0.27), 0.065, "Body", toe=20)


def _fins(model):
    for name, side in (("FinR", 1), ("FinL", -1)):
        stub = sweep.tube([(side * 0.2, 0.0, H - 0.2), (side * 0.32, -0.04, H - 0.28), (side * 0.42, -0.1, H - 0.38)],
                          [0.07, 0.06, 0.04], sides=6)
        model.add(GROUP, stub, "flesh", FIN, bone=name)
    dorsal = creature.membrane([(0, -0.25, H + 0.3), (0, -0.35, H + 0.5), (0, -0.4, H + 0.28)])
    model.add(GROUP, dorsal, "membrane", FIN, uv=model.atlas.solid("plain"), bone="Body")


def _teeth(model):
    """Long needle fangs in two rows that interlock when the jaw shuts."""
    upper = [(s * x, y, H - 0.1) for s in (1, -1) for x, y in ((0.2, 0.12), (0.22, 0.28), (0.14, 0.4))]
    model.add(GROUP, creature.spikes(upper, [(x * 0.9, y + 0.02, H - 0.34) for x, y, _ in upper], 0.03, 4),
              "shell", pal.BONE, bone="Body")
    lower = [(s * x, y, H - 0.2) for s in (1, -1) for x, y in ((0.18, 0.12), (0.2, 0.3), (0.1, 0.5))]
    model.add(GROUP, creature.spikes(lower, [(x * 0.95, y + 0.03, H + 0.1) for x, y, _ in lower], 0.03, 4),
              "shell", pal.BONE, bone="Jaw")
