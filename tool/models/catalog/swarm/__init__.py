"""A Dent-de-verre, one fish of the swarm (MonsterFamily.SWARM): many fragile
fish with teeth of glass; the game instances this one many times, so it is
light and small, and reads as a school member by its needle teeth, its
spiked back and its two acid eyes. A pale, sickly green fish, its back darker.

Faces +Y in Blender (Godot's forward, -Z). Origin on the floor under the
middle of the body, which hangs 0.3 above it; about 0.7 long with its tail,
0.4 high: well under a unit (a unit stands more than 1.5 high). Bones: Body, Jaw (hinged under the head), Tail1..3."""

from catalog import monster_palette
from catalog.swarm import actions, body
from catalog.textures import monster
from workshop.budget import Budget
from workshop.occlusion import Occlusion

NAME = "swarm"
SEED = 7101
MATERIALS = monster_palette.MONSTER
ATLAS = monster.atlas(SEED)
BUDGET = Budget(triangles=900, materials=4, texture_px=512, bones=5, keyframes=700)
OCCLUSION = Occlusion(rays=12, distance=0.25, floor=0.4,
                      strength={"lamp": 0.0, "membrane": 0.4})
NODES = ["Rig"]
FAMILY = "monster"
PORTRAIT = True


def build(model):
    chain = body.skeleton(model.rig)
    body.shape(model, chain)
    actions.declare(model.rig, chain)
