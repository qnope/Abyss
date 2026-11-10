"""The coral gardens sunk into the deck where nothing is built: a stone
kerb around a bed of rippled sand, thick with corals, sponges and algae."""

import math

from mathutils import Vector

from catalog import colors, paints
from catalog.base_island.decor import place
from catalog.base_island.layout import BEDS, plan
from catalog.decor import algae, corals, creatures, rocks, sponges
from workshop import noise, shapes
from workshop.colors import mix, vary
from workshop.geometry import Geometry
from workshop.scatter import scatter

GROUP = "Island"
SAND_Z = -0.025
KINDS = ((corals.staghorn, (0.45, 0.7)), (corals.fan, (0.5, 0.7)), (corals.brain, (0.16, 0.26)),
         (sponges.tubes, (0.4, 0.65)), (sponges.ball, (0.25, 0.4)), (algae.kelp, (0.7, 1.1)),
         (algae.grass, (0.25, 0.4)), (creatures.anemone, (0.7, 1.0)),
         (creatures.scallop, (0.08, 0.12)), (creatures.sea_star, (0.08, 0.12)),
         (rocks.boulder, (0.12, 0.22)))


def beds(model):
    for index, (u0, v0, w, h) in enumerate(BEDS):
        x0, y1 = plan(u0, v0)
        x1, y0 = plan(u0 + w, v0 + h)
        _kerb(model, x0, y0, x1, y1)
        model.add(GROUP, _sand(x0 + 0.08, y0 + 0.08, x1 - 0.08, y1 - 0.08), "rock", _sand_paint(index))
        rng = model.rng
        spots = scatter(rng, lambda r: (r.uniform(x0 + 0.22, x1 - 0.22), r.uniform(y0 + 0.22, y1 - 0.22)),
                        count=int(w * h * 2.6), spacing=0.38, tries=2000)
        for k, (x, y) in enumerate(spots):
            maker, (low, high) = KINDS[(k * 7 + index) % len(KINDS)]
            place(model, maker(rng, rng.uniform(low, high)), x, y, SAND_Z, rng)


def _kerb(model, x0, y0, x1, y1):
    rng = model.rng
    t = 0.12
    for cx, cy, sx, sy in (((x0 + x1) / 2, y0 + t / 2, x1 - x0, t), ((x0 + x1) / 2, y1 - t / 2, x1 - x0, t),
                           (x0 + t / 2, (y0 + y1) / 2, t, y1 - y0 - 2 * t),
                           (x1 - t / 2, (y0 + y1) / 2, t, y1 - y0 - 2 * t)):
        block = shapes.box((sx - 0.02, sy - 0.02, 0.17), bevel=0.025, bottom=False)
        model.add(GROUP, block.transform((cx, cy, -0.14)), "stone",
                  paints.worked(vary(colors.STONE_DARK, rng, 0.08), 7, edge=1.6))


def _sand(x0, y0, x1, y1, step=0.17):
    nx, ny = max(2, round((x1 - x0) / step)), max(2, round((y1 - y0) / step))
    geometry = Geometry()
    for j in range(ny + 1):
        for i in range(nx + 1):
            x, y = x0 + (x1 - x0) * i / nx, y0 + (y1 - y0) * j / ny
            ripple = 0.006 * math.sin(x * 7 + 2 * noise.value((x, y), 77)) + 0.012 * noise.value((x * 2, y * 2), 78)
            geometry.verts.append((x, y, SAND_Z + ripple))
    for j in range(ny):
        for i in range(nx):
            a = j * (nx + 1) + i
            geometry.faces.append((a, a + 1, a + nx + 2, a + nx + 1))
    geometry.verts = [Vector(v) for v in geometry.verts]
    geometry.smooth = [True] * len(geometry.faces)
    return geometry


def _sand_paint(seed):
    def paint(p, normal):
        t = 0.5 + 0.5 * noise.fbm(p * 3, seed + 80)
        return mix(colors.SAND, colors.SEDIMENT, t * 0.6)
    return paint
