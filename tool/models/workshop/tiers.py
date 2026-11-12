"""The tiers of a building in its glb, with the stdlib only: the nodes Tier1,
Tier2 and Tier3 add up (the game shows Tier1, then 1 and 2, then all three),
and what is under none of them is always shown."""

import re

_TIER = re.compile(r"Tier(\d+)$")


def tier_of(name):
    """The number of a node called Tier<N>, 0 for any other name."""
    found = _TIER.match(name)
    return int(found.group(1)) if found else 0


def costs(report):
    """{tier: (triangles, draw calls)} of what each tier holds itself, tier 0
    being what no tier holds, in the glb of [report] (a GlbReport)."""
    document = report.document
    nodes, accessors = document.get("nodes", []), document.get("accessors", [])
    totals = {}

    def walk(index, tier):
        node = nodes[index]
        tier = max(tier, tier_of(node["name"]))
        if "mesh" in node:
            primitives = document["meshes"][node["mesh"]]["primitives"]
            triangles = sum(accessors[p.get("indices", p["attributes"]["POSITION"])]["count"] // 3
                            for p in primitives if p.get("mode", 4) == 4)
            drawn, calls = totals.get(tier, (0, 0))
            totals[tier] = (drawn + triangles, calls + len(primitives))
        for child in node.get("children", []):
            walk(child, tier)

    scene = document.get("scenes", [{}])[document.get("scene", 0)]
    for root in scene.get("nodes", []):
        walk(root, 0)
    return totals


def count(report):
    """The highest tier the glb of [report] has, 0 for a model without tiers."""
    return max(costs(report), default=0)


def shown(report):
    """[(triangles, draw calls)] of the model shown up to tier 1, 2, ...: each
    tier's cost added to those below it and to what no tier holds."""
    totals = costs(report)
    result = []
    for top in range(1, count(report) + 1):
        parts = [totals.get(tier, (0, 0)) for tier in range(0, top + 1)]
        result.append((sum(p[0] for p in parts), sum(p[1] for p in parts)))
    return result
