"""The sleeping shark's body: a blunt head, a trunk and a tail lofted along its
length, and its fins, on a belly that rests on the floor."""

from catalog.parts import creature, creature_paint
from workshop import skin
from workshop.colors import linear

BACK = linear("#5f5e7a")
BELLY = linear("#bdb7a2")
FIN = linear("#7a7894")
CRUST = linear("#8f8a78")
GROUP = "Colossus"
TAIL = [(0, -0.2, 0.5), (0, -0.9, 0.5), (0, -1.5, 0.52), (0, -2.1, 0.55)]


def skin_paint():
    """The shark's counter-shaded, scarred hide."""
    return creature_paint.shaded(BACK, BELLY, 0.5, 0.3, 41, 0.12, 2.5, (linear("#d4c8cc"), 1.6))


def skeleton(rig):
    """Body, Head with its Jaw and its two Lids, the pectoral fins and a Tail of
    three bones; gives the tail's names."""
    rig.bone("Body", None, (0, 0.95, 0.52), (0, -0.2, 0.5))
    rig.bone("Head", "Body", (0, 0.95, 0.5), (0, 1.8, 0.3))
    rig.bone("Jaw", "Head", (0, 1.05, 0.2), (0, 1.7, 0.18))
    for name, side in (("R", 1), ("L", -1)):
        rig.bone("Lid" + name, "Head", (side * 0.42, 1.38, 0.62), (side * 0.42, 1.3, 0.62))
        rig.bone("Pec" + name, "Body", (side * 0.45, 0.65, 0.2), (side * 1.3, 0.3, 0.1))
    return rig.chain("Tail", "Body", TAIL)


def shape(model, tail):
    rig = model.rig
    hide = model.atlas.tiled("hide", 0.7)
    paint = skin_paint()
    head = creature.loft([(0, y, 0.0) for y in (1.88, 1.78, 1.55, 1.3, 0.95)],
                         [0.04, 0.27, 0.42, 0.52, 0.58], [0.04, 0.2, 0.32, 0.42, 0.5], sides=16,
                         caps=(True, False), lift=[0.36, 0.42, 0.5, 0.58, 0.52])
    model.add(GROUP, head, "flesh", paint, uv=hide, bone="Head")
    trunk = creature.loft([(0, y, 0.0) for y in (0.95, 0.4, -0.2)], [0.58, 0.6, 0.5],
                          [0.5, 0.55, 0.46], sides=16, caps=(False, False), lift=[0.52, 0.55, 0.5])
    model.add(GROUP, trunk, "flesh", paint, uv=hide, bone="Body")
    stem = creature.loft([(0, y, 0.0) for y in (-0.2, -0.9, -1.5, -2.15)], [0.5, 0.32, 0.18, 0.05],
                         [0.46, 0.3, 0.2, 0.08], sides=16, caps=(False, True),
                         lift=[0.5, 0.5, 0.52, 0.55])
    along = skin.along(tail, rig.centres(tail))
    model.add(GROUP, stem, "flesh", paint, uv=hide, bone=along)
    _fins(model, along)
    _crust(model)


def _fins(model, along):
    """The dorsal fins, the caudal with its long upper lobe, the pectoral wings
    lying on the floor."""
    fin = creature.fin([(0.85, 0.95), (0.35, 1.68), (0.12, 1.56), (-0.12, 0.95)], 0.07)
    model.add(GROUP, fin, "flesh", FIN, uv=model.atlas.tiled("hide", 0.7), bone="Body")
    small = creature.fin([(-0.95, 0.55), (-1.15, 0.95), (-1.3, 0.55)], 0.05)
    model.add(GROUP, small, "flesh", FIN, uv=model.atlas.tiled("hide", 0.7), bone=along)
    tail = creature.fin([(-1.85, 0.5), (-2.1, 1.05), (-2.7, 1.6), (-2.5, 1.0), (-2.8, 0.35),
                         (-2.45, 0.22), (-1.95, 0.42)], 0.06)
    model.add(GROUP, tail, "flesh", FIN, uv=model.atlas.tiled("hide", 0.7), bone=along)
    for name, side in (("PecR", 1), ("PecL", -1)):
        wing = creature.loft([(side * 0.4, 0.7, 0.2), (side * 0.85, 0.5, 0.14), (side * 1.4, 0.2, 0.08)],
                             [0.3, 0.2, 0.04], [0.05, 0.03, 0.012], sides=6)
        model.add(GROUP, wing, "flesh", FIN, uv=model.atlas.tiled("hide", 0.7), bone=name)


def _crust(model):
    """Barnacles and reef growth on the shark's back: it has slept there a long time."""
    spots = [(0.25, 0.2), (-0.2, 0.4), (0.1, 0.0), (-0.3, 0.05), (0.2, 0.75), (-0.15, 0.7), (0.3, 0.5),
             (-0.1, -0.15), (0.0, 0.85)]
    bases = [(x, y, 0.5 + 0.55 * (1 - (x / 0.6) ** 2) ** 0.5 - 0.04) for x, y in spots]
    tips = [(x * 1.1, y - 0.03, z + 0.18) for x, y, z in bases]
    model.add(GROUP, creature.spikes(bases, tips, 0.07, 5), "shell", CRUST, bone="Body")
