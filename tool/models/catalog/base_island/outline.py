"""The plateau's natural outline around the square deck, and the height of its
rocky rim. A point of the outline is a point q of the deck's edge pushed out
along the edge's outward normal n by the margin m(q, n): the corners turn on
quarter circles, so the outline never folds."""

import math

from mathutils import Vector

from catalog.base_island.layout import GATES, HALF, RAMPART_TO, plan
from workshop import noise

SEED = 11
_CORNERS = ((HALF, HALF), (-HALF, HALF), (-HALF, -HALF), (HALF, -HALF))
_EDGE_NORMALS = ((1, 0), (0, 1), (-1, 0), (0, -1))
_GATES = [Vector(plan(*gate)) for gate in GATES]


def perimeter(step=0.36, corner_steps=7):
    """(q, n) pairs around the deck, counter-clockwise from the east edge."""
    pairs = []
    for side in range(4):
        nx, ny = _EDGE_NORMALS[side]
        start, end = Vector(_CORNERS[side - 1]), Vector(_CORNERS[side])
        count = round((end - start).length / step)
        for k in range(1, count):
            pairs.append((start.lerp(end, k / count), Vector((nx, ny))))
        a = math.atan2(ny, nx)
        for k in range(corner_steps + 1):
            t = a + (math.pi / 2) * k / corner_steps
            pairs.append((end.copy(), Vector((math.cos(t), math.sin(t)))))
    return pairs


def margin(q, n):
    """How far the plateau reaches beyond the deck's edge at q, toward n."""
    corner = max(0.0, 1.0 - _corner_distance(q) / 2.5)
    m = 1.12 + 0.4 * noise.fbm((q + n * 0.6) * 0.32, SEED, octaves=3) + 0.55 * corner
    m += 0.12 * noise.value(q * 1.7, SEED + 5)
    for gate in _GATES:
        if (q - gate).length < 0.9:
            m = max(m, 1.15)
    return max(m, 0.8)


def nearest(x, y):
    """The deck-edge point q, outward normal n and distance d of a plan point
    beyond the deck."""
    p = Vector((x, y))
    q = Vector((max(-HALF, min(HALF, x)), max(-HALF, min(HALF, y))))
    d = (p - q).length
    if d < 1e-9:
        n = Vector((1, 0)) if abs(x) >= abs(y) else Vector((0, 1))
        n *= 1 if (x if abs(x) >= abs(y) else y) >= 0 else -1
        return q, n, 0.0
    return q, (p - q) / d, d


def rim_height(q, n, d):
    """The height of the rim at distance d beyond q: flat under the rampart
    and on the avenues' way out, lumpy rock beyond, dropping at the lip."""
    m = margin(q, n)
    p = q + n * d
    flat = -0.02 + 0.006 * noise.value(p * 3, SEED + 2)
    start = RAMPART_TO + 0.06
    if d <= start or _on_way_out(p):
        return flat
    t = min(1.0, (d - start) / max(m - start, 0.05))
    bump = 0.5 + 0.5 * noise.fbm(p * 1.25, SEED + 3, octaves=3)
    lumps = 0.07 * bump * math.sin(math.pi * min(1.0, t * 1.15)) ** 0.7
    return flat + lumps - 0.06 * max(0.0, (t - 0.85) / 0.15)


def height_at(x, y):
    """The rim's height at a plan point beyond the deck."""
    q, n, d = nearest(x, y)
    return rim_height(q, n, d)


def _on_way_out(p):
    return any(abs((p - gate).dot(_along(gate))) < 0.45 and (p - gate).length < 3
               for gate in _GATES)


def _along(gate):
    """The unit vector along the deck's edge at a gate."""
    return Vector((0, 1)) if abs(abs(gate.x) - HALF) < 1e-6 else Vector((1, 0))


def _corner_distance(q):
    return min((q - Vector(c)).length for c in _CORNERS)
