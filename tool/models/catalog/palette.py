"""The materials every model draws from. Each carries the shading of a kind
of stuff (roughness, metal, glow); its colours come from the vertex colours,
so one material serves every rock or every coral of the game."""

from workshop.materials import Material

ROCK = Material("rock", roughness=0.92)
STONE = Material("stone", roughness=0.8)
METAL = Material("metal", roughness=0.45, metallic=0.35)
CORAL = Material("coral", roughness=0.6)
ALGAE = Material("algae", roughness=0.7, double_sided=True)
GLOW = Material("glow", roughness=0.4, emission="#2fd8f0", strength=1.8)
GLOW_PINK = Material("glow_pink", roughness=0.4, emission="#ff5c9e", strength=1.8)

ALL = [ROCK, STONE, METAL, CORAL, ALGAE, GLOW, GLOW_PINK]
