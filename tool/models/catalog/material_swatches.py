"""The palette's materials side by side, each on a one-cell tile with a ball,
and a one-unit cube for scale: the reference to judge materials and lights
in the preview."""

from catalog import palette
from workshop import shapes
from workshop.budget import Budget
from workshop.colors import linear
from workshop.occlusion import Occlusion

NAME = "material_swatches"
SEED = 1
MATERIALS = palette.ALL
BUDGET = Budget(triangles=6_000, materials=len(palette.ALL))
OCCLUSION = Occlusion(rays=16)
NODES = ["Swatches", "Unit"]

COLORS = {"rock": "#3a4658", "stone": "#5d6b7e", "metal": "#8d9bb0", "coral": "#e2507a",
          "algae": "#2f8f5b", "glow": "#7ff6ff", "glow_pink": "#ff9cc8"}


def build(model):
    count = len(MATERIALS)
    for i, material in enumerate(MATERIALS):
        x = i - (count - 1) / 2
        color = linear(COLORS[material.name])
        tile = shapes.box((0.94, 0.94, 0.12), bevel=0.03, segments=2).transform((x, 0, -0.12))
        model.add("Swatches", tile, material.name, color)
        ball = shapes.sphere(0.3, subdivisions=3).transform((x, 0, 0.3))
        model.add("Swatches", ball, material.name, color)
    cube = shapes.box((1, 1, 1), bevel=0.04, segments=2)
    model.piece("Unit", (0, 1.5, 0)).add(cube, "stone", linear(COLORS["stone"]))
