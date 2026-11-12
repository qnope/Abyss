"""Le Léviathan: the colossal guardian that comes back to the human's Faille
with its Sentinelles (godot/domain/leviathan/, GuardianFactory.for_faille), a
recurring threat and a boss. A sea serpent as long as a harbour: dark teal
scales and a pale belly, lying in a great S on the sea floor, its neck rising
into a horned head with ghostly pale eyes and a hinged jaw hung with fangs, a
ridge of bone spines down its back and a line of pale lights along each flank,
two broad flippers. It is not a family of the map (no portrait): it comes to
the base, or to a Faille, on its own.

Faces +Y in Blender (Godot's forward, -Z). Origin on the floor at the middle of
the body: about 13 cells from the tip of its tail to its snout, 3.5 wide across
its flippers, 4.3 high at its horns when its neck is raised: the biggest thing
of the game, far more than a cell. Bones: Body (the root), Aft1..5 (toward the
tail), Fwd1..4 (up the neck), Head, Jaw, FlipperR and FlipperL."""

from catalog import monster_palette
from catalog.leviathan import actions, body, head
from catalog.textures import monster
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "leviathan"
SEED = 7606
MATERIALS = monster_palette.MONSTER
ATLAS = monster.atlas(SEED)
BUDGET = Budget(triangles=7_000, materials=3, texture_px=512, bones=16, keyframes=3_500)
OCCLUSION = Occlusion(rays=12, distance=1.4, floor=0.3, strength={"lamp": 0.0, "shell": 0.6})
NODES = ["Rig"]
FAMILY = "monster"


def build(model):
    order = body.skeleton(model.rig)
    body.shape(model, order)
    head.shape(model)
    actions.declare(model.rig, order)
