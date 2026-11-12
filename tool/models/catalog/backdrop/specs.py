"""The three backdrops: what each level's rim is made of, what grows on its
shelf and the silhouettes beyond. Colours are the trench's: the lit rock of
the slab theme, going to the black of the abyss."""

from dataclasses import dataclass

from catalog.backdrop import silhouettes
from catalog.decor import algae, corals, creatures, rocks, sponges
from workshop.colors import linear


def anemone(rng, size):
    """An anemone without the glowing tips (the model has no pink lamp)."""
    return creatures.anemone(rng, size, glowing=False)


@dataclass(frozen=True)
class Spec:
    """[palette] is the rim's (sand, rock, band, dark); [kinds] what grows on
    its shelf; [far] the silhouettes: (node, how to make it, its arguments)."""

    number: int
    seed: int
    palette: tuple
    kinds: tuple
    count: int
    far: tuple


REEF = Spec(
    1, 41,
    (linear("#8f9c93"), linear("#5f737d"), linear("#7d8478"), linear("#0e2a3a")),
    ((algae.kelp, 2.5, (0.7, 1.2)), (algae.grass, 2.5, (0.25, 0.4)), (corals.staghorn, 1.5, (0.35, 0.55)),
     (corals.brain, 2.0, (0.12, 0.2)), (sponges.tubes, 1.2, (0.3, 0.45)), (rocks.boulder, 1.5, (0.25, 0.4))),
    9, (("Kelp", silhouettes.kelp_forest, {}), ("Outcrop", silhouettes.kelp_forest, {"count": 4, "tallest": 1.8})))

TWILIGHT = Spec(
    2, 42,
    (linear("#7b869c"), linear("#415677"), linear("#5c6c8e"), linear("#050b16")),
    ((corals.fan, 2.0, (0.4, 0.6)), (sponges.tubes, 2.0, (0.3, 0.5)), (sponges.ball, 1.5, (0.2, 0.35)),
     (rocks.boulder, 2.0, (0.25, 0.4)), (algae.kelp, 0.8, (0.6, 1.0)), (anemone, 1.0, (0.4, 0.6))),
    8, (("Whale", silhouettes.whale, {}), ("Kelp", silhouettes.kelp_forest, {"count": 6, "tallest": 2.6})))

TRENCH = Spec(
    3, 43,
    (linear("#4a5266"), linear("#2a3347"), linear("#38425a"), linear("#02040a")),
    ((rocks.boulder, 3.0, (0.25, 0.45)), (rocks.slab, 2.0, (0.2, 0.35)), (rocks.pebbles, 1.5, (0.3, 0.5)),
     (sponges.tubes, 0.8, (0.25, 0.4))),
    8, (("Spires", silhouettes.spires, {}), ("Chimney", silhouettes.chimney, {})))
