"""A probe, not a creature of the game: a fish of a body and a tail of three
bones, with the four actions the units and monsters have (idle, swim, attack,
hit). It proves the workshop's rigs: bones, weights, actions in the glb, and
the class that plays them in Godot. Nothing in the game shows it.

Faces +Y in Blender (Godot's forward, -Z), its origin on the floor under its
belly. The tail bends about Z, the body lunges along Y."""

from catalog import colors, palette
from catalog.probe_fish.actions import declare
from workshop import shapes, skin, sweep
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "probe_fish"
SEED = 5
MATERIALS = [palette.CORAL, palette.GLOW]
BUDGET = Budget(triangles=900, materials=2, bones=4, keyframes=600)
OCCLUSION = Occlusion(rays=8)
NODES = ["Rig"]
FAMILY = "unit"
GROUP = "ProbeFish"  # names the meshes under the Rig
HEIGHT = 0.5  # of the bones above the floor
TAIL = [(0, -0.35, HEIGHT), (0, -0.65, HEIGHT), (0, -0.95, HEIGHT), (0, -1.25, HEIGHT)]


def build(model):
    rig = model.rig
    rig.bone("Body", None, (0, -0.35, HEIGHT), (0, 0.45, HEIGHT))
    chain = rig.chain("Tail", "Body", TAIL)
    declare(rig, chain)
    body = shapes.sphere(0.4, subdivisions=2).transform((0, 0, HEIGHT), scale=(0.6, 1.1, 0.8))
    model.add(GROUP, body, "coral", colors.CORAL_PINK, bone="Body")
    for side in (-1, 1):
        eye = shapes.sphere(0.07, subdivisions=1).transform((side * 0.2, 0.3, HEIGHT + 0.12))
        model.add(GROUP, eye, "glow", colors.GLOW_CYAN, bone="Body")
    fin = sweep.tube(TAIL, [0.16, 0.12, 0.08, 0.02], sides=6)
    model.add(GROUP, fin, "coral", colors.CORAL_DEEP, bone=skin.along(chain, rig.centres(chain)))
