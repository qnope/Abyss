"""The plan of the base's island, in cells (pure Python, no bpy): the 12 x 12
deck, the building slots of lib/presentation/widgets/base/base_layout.dart, the
walkways from the headquarters and the gates where the avenues leave the deck.

A cell (u, v) of the Flutter game lies at plan (x, y) = (u - 6, 6 - v) in
Blender, which the glTF export turns into Godot's (u - 6, height, v - 6): the
front corner of the 3/4 camera, u = v = 12, is +x +z in Godot."""

from dataclasses import dataclass

SIZE = 12
HALF = SIZE / 2

# The top of a pad above the deck's surface (z = 0): where a building stands.
PAD_TOP = 0.12

WALKWAY_WIDTH = 0.56

# The rampart's band, beyond the deck's edge: kept flat and free of decor.
RAMPART_FROM, RAMPART_TO = 0.04, 0.6


@dataclass(frozen=True)
class Slot:
    building: str
    u: float
    v: float
    footprint: int

    @property
    def node(self):
        """The pad's node: the building in PascalCase."""
        return "".join(word.capitalize() for word in self.building.split("_"))


SLOTS = (
    Slot("volcanic_kernel", 2.0, 2.0, 2),
    Slot("laboratory", 2.2, 6.6, 2),
    Slot("solar_panel", 6.6, 2.2, 2),
    Slot("coral_mine", 3.7, 9.0, 2),
    Slot("headquarters", 6.4, 6.4, 3),
    Slot("algae_farm", 9.0, 3.7, 2),
    Slot("barracks", 7.4, 10.4, 2),
    Slot("ore_extractor", 10.4, 7.4, 2),
    Slot("pressure_capsule", 4.6, 11.0, 2),
    Slot("descent_module", 11.0, 4.6, 2),
    Slot("coral_citadel", 10.2, 10.2, 2),
)

# The ends of each straight walkway, in cells, from pad edge to pad edge. Four
# avenues leave the headquarters for the deck's edges; the pads beside an
# avenue touch it, the others get a spur.
WALKWAYS = (
    ((6.4, 4.9), (6.4, 3.2)), ((6.4, 1.2), (6.4, 0.0)),    # north, through the solar panel
    ((4.9, 6.4), (3.2, 6.4)), ((1.2, 6.4), (0.0, 6.4)),    # west, through the laboratory
    ((6.0, 7.9), (6.0, 12.0)),                             # south, by the barracks
    ((7.9, 6.0), (12.0, 6.0)),                             # east, by the ore extractor
    ((6.68, 3.7), (8.0, 3.7)),                             # to the algae farm
    ((5.72, 9.0), (4.7, 9.0)),                             # to the coral mine
    ((4.9, 4.9), (3.0, 3.0)),                              # to the volcanic kernel
    ((7.9, 7.9), (9.2, 9.2)),                              # to the coral citadel
)

GATES = ((6.4, 0.0), (0.0, 6.4), (6.0, 12.0), (12.0, 6.0))

# Coral gardens sunk in the deck where no slot nor walkway reaches, as
# (first u, first v, cells across u, cells across v).
BEDS = ((0, 10, 2, 2), (8, 0, 4, 2))


def in_bed(u, v):
    return any(u0 <= u < u0 + w and v0 <= v < v0 + h for u0, v0, w, h in BEDS)


def plan(u, v):
    """The Blender plan position (x, y) of the cell point (u, v)."""
    return (u - HALF, HALF - v)


def cell(x, y):
    """The cell point (u, v) of the plan position (x, y)."""
    return (x + HALF, HALF - y)


def beyond_deck(x, y):
    """How far the plan point (x, y) lies outside the deck; 0 on it."""
    dx, dy = max(abs(x) - HALF, 0.0), max(abs(y) - HALF, 0.0)
    return (dx * dx + dy * dy) ** 0.5


def on_pad(x, y, margin=0.0):
    u, v = cell(x, y)
    return any(abs(u - s.u) < s.footprint / 2 + margin and abs(v - s.v) < s.footprint / 2 + margin
               for s in SLOTS)


def near_walkway(x, y, margin=0.0):
    """Whether (x, y) is within [margin] of a walkway's side, the avenues
    running on to the plateau's edge beyond their gate."""
    u, v = cell(x, y)
    reach = WALKWAY_WIDTH / 2 + margin
    legs = list(WALKWAYS) + [(gate, _outward(gate)) for gate in GATES]
    return any(_distance_to_leg((u, v), a, b) < reach for a, b in legs)


def free_for_decor(x, y):
    """Whether decor may stand at (x, y): off the pads, the walkways and the
    rampart's band. The plateau's outline is the decor's own business."""
    d = beyond_deck(x, y)
    if (0 < d <= RAMPART_TO + 0.05) or (d == 0 and _near_edge(x, y)):
        return False
    return not on_pad(x, y, 0.2) and not near_walkway(x, y, 0.18)


def _near_edge(x, y):
    return max(abs(x), abs(y)) > HALF - 0.12


def _outward(gate):
    u, v = gate
    return (u + (2.5 if u == SIZE else -2.5 if u == 0 else 0),
            v + (2.5 if v == SIZE else -2.5 if v == 0 else 0))


def _distance_to_leg(point, a, b):
    (px, py), (ax, ay), (bx, by) = point, a, b
    dx, dy = bx - ax, by - ay
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
    return ((px - ax - t * dx) ** 2 + (py - ay - t * dy) ** 2) ** 0.5
