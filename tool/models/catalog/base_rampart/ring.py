"""The rampart's line (pure Python, no bpy): a square ring around the
island's deck, in the band the island keeps flat for it, open where the
avenues leave the deck. Plan coordinates as the island's: x, y in cells
from the deck's centre, z up."""

from catalog.base_island import layout
from catalog.base_island.layout import HALF, RAMPART_FROM, RAMPART_TO

# The wall's axis, from the deck's centre; its thickness at the foot.
RADIUS = HALF + (RAMPART_FROM + RAMPART_TO) / 2 + 0.02
THICKNESS = 0.44
# Half the opening where an avenue leaves: the walkway and its rails pass.
GAP = 0.62

CORNERS = ((RADIUS, -RADIUS), (RADIUS, RADIUS), (-RADIUS, RADIUS), (-RADIUS, -RADIUS))


def gates():
    """Where each avenue crosses the wall's axis, in plan."""
    points = []
    for u, v in layout.GATES:
        x, y = layout.plan(u, v)
        points.append((RADIUS if x > 0 else -RADIUS, y) if abs(abs(x) - HALF) < 1e-6
                      else (x, RADIUS if y > 0 else -RADIUS))
    return points


def runs():
    """The straight stretches of wall, as (start, end): each side of the ring
    from corner to corner, cut by the gates on it."""
    stretches = []
    for k, start in enumerate(CORNERS):
        end = CORNERS[(k + 1) % 4]
        direction = _unit(start, end)
        cuts = sorted(_along(start, direction, gate) for gate in gates()
                      if _on_side(start, end, gate))
        position = 0.0
        for cut in cuts:
            stretches.append((_at(start, direction, position), _at(start, direction, cut - GAP)))
            position = cut + GAP
        stretches.append((_at(start, direction, position), end))
    return stretches


def gate_ends():
    """The wall's ends beside each gate, as (point, direction into the gap)."""
    ends = []
    for start, end in runs():
        direction = _unit(start, end)
        for point, sign in ((start, -1), (end, 1)):
            if point not in CORNERS:
                ends.append((point, (direction[0] * sign, direction[1] * sign)))
    return ends


def blocks(start, end, rng, shortest, longest):
    """The run cut into stones of random length: (centre, length) pairs."""
    total = _length(start, end)
    direction = _unit(start, end)
    cuts, position = [0.0], 0.0
    while total - position > longest:
        position += rng.uniform(shortest, longest)
        cuts.append(position)
    if total - position < shortest and len(cuts) > 1:
        cuts.pop()
    cuts.append(total)
    return [(_at(start, direction, (a + b) / 2), b - a) for a, b in zip(cuts, cuts[1:])]


def _on_side(start, end, point):
    return abs(_cross(_unit(start, end), (point[0] - start[0], point[1] - start[1]))) < 1e-6


def _along(start, direction, point):
    return (point[0] - start[0]) * direction[0] + (point[1] - start[1]) * direction[1]


def _at(start, direction, distance):
    return (start[0] + direction[0] * distance, start[1] + direction[1] * distance)


def _unit(start, end):
    size = _length(start, end)
    return ((end[0] - start[0]) / size, (end[1] - start[1]) / size)


def _length(start, end):
    return ((end[0] - start[0]) ** 2 + (end[1] - start[1]) ** 2) ** 0.5


def _cross(a, b):
    return a[0] * b[1] - a[1] * b[0]
