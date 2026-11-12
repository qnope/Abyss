"""The fish of the swarm: its skeleton and its shapes."""

from catalog import monster_palette as pal
from catalog.parts import creature, creature_paint
from workshop import skin, sweep
from workshop.colors import linear

H = 0.3  # the body's axis above the floor
TAIL = [(0, -0.1, H), (0, -0.2, H), (0, -0.3, H), (0, -0.42, H)]
BACK = linear("#587a66")
BELLY = linear("#c2d0a8")
FIN = linear("#7fa08a")
GROUP = "Swarm"


def skeleton(rig):
    """Body, the Jaw under its head, and a Tail of three bones; the tail's names."""
    rig.bone("Body", None, (0, -0.1, H), (0, 0.2, H))
    rig.bone("Jaw", "Body", (0, 0.1, H - 0.05), (0, 0.26, H - 0.075))
    return rig.chain("Tail", "Body", TAIL)


def shape(model, tail):
    rig, atlas = model.rig, model.atlas
    flesh = creature_paint.shaded(BACK, BELLY, H, 0.1, 3)
    scales = atlas.tiled("scales", 0.1)
    trunk = creature.loft([(0, y, H) for y in (-0.1, -0.03, 0.04, 0.12, 0.19)],
                          [0.04, 0.062, 0.072, 0.066, 0.04], [0.075, 0.108, 0.118, 0.1, 0.06],
                          sides=10, caps=(False, True))
    model.add(GROUP, trunk, "flesh", flesh, uv=scales, bone="Body")
    stem = creature.loft([(0, y, H) for y in (-0.1, -0.18, -0.26, -0.32)],
                         [0.04, 0.025, 0.015, 0.01], [0.075, 0.045, 0.03, 0.025], sides=8,
                         caps=(False, True))
    along = skin.along(tail, rig.centres(tail))
    model.add(GROUP, stem, "flesh", flesh, uv=scales, bone=along)
    jaw = creature.loft([(0, y, H - 0.07) for y in (0.1, 0.17, 0.26)], [0.04, 0.036, 0.016],
                        [0.024, 0.02, 0.014], sides=6)
    model.add(GROUP, jaw, "flesh", flesh, uv=scales, bone="Jaw")
    _teeth(model)
    _fins(model, tail, along)
    creature.add_eyes(model, GROUP, "eye_acid", (0.052, 0.12, H + 0.025), 0.034, "Body", toe=30)


def _teeth(model):
    """Needles of glass: the upper row hangs from the lip, the lower stands up."""
    upper = [(x, y, H - 0.04) for y in (0.09, 0.125, 0.16, 0.19) for x in (-0.038, 0.038)]
    model.add(GROUP, creature.spikes(upper, [(x * 0.8, y + 0.015, H - 0.125) for x, y, _ in upper],
                                     0.012, 4), "shell", pal.GLASS_TOOTH, bone="Body")
    lower = [(x, y, H - 0.065) for y in (0.11, 0.16, 0.215) for x in (-0.03, 0.03)]
    model.add(GROUP, creature.spikes(lower, [(x * 0.8, y + 0.01, H + 0.005) for x, y, _ in lower],
                                     0.011, 4), "shell", pal.GLASS_TOOTH, bone="Jaw")


def _fins(model, tail, along):
    atlas = model.atlas
    solid = atlas.solid("plain")
    caudal = creature.membrane([(0, -0.28, H + 0.02), (0, -0.44, H + 0.15), (0, -0.385, H),
                                (0, -0.44, H - 0.15), (0, -0.28, H - 0.02)])
    model.add(GROUP, caudal, "membrane", FIN, uv=solid, bone=along)
    dorsal = creature.membrane([(0, -0.09, H + 0.09), (0, -0.05, H + 0.21), (0, 0.0, H + 0.12),
                                (0, 0.045, H + 0.24), (0, 0.08, H + 0.1)])
    model.add(GROUP, dorsal, "membrane", FIN, uv=solid, bone="Body")
    for side in (1, -1):
        pectoral = creature.membrane([(side * 0.07, 0.07, H - 0.04), (side * 0.15, -0.02, H - 0.09),
                                      (side * 0.06, 0.0, H - 0.06)])
        model.add(GROUP, pectoral, "membrane", FIN, uv=solid, bone="Body")
    anal = creature.membrane([(0, -0.07, H - 0.1), (0, -0.12, H - 0.2), (0, -0.01, H - 0.11)])
    model.add(GROUP, anal, "membrane", FIN, uv=solid, bone="Body")
