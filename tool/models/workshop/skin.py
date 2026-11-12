"""Weights from simple rules, as functions of a vertex's position that give
{bone name: weight}: a rigid part is bound to one bone, a ribbon or a tail is
blended along a chain of bones. Pure Python: no Blender here."""


def centre(a, b):
    return tuple((x + y) / 2 for x, y in zip(a, b))


def rigid(bone):
    """Every vertex bound to [bone] alone."""
    return lambda position: {bone: 1.0}


def along(names, centres):
    """Blended along the chain [names], whose bones have their middles at
    [centres]: a vertex between two middles (measured along the chain's
    axis, from the first to the last) shares its weight between those two,
    and past either end it belongs to the end bone."""
    if len(names) != len(centres) or len(names) < 2:
        raise ValueError("a chain takes at least two bones and a centre for each")
    start = centres[0]
    axis = [e - s for s, e in zip(start, centres[-1])]
    length = sum(c * c for c in axis)
    if not length:
        raise ValueError("a chain whose bones are all at one point")

    def at(point):
        return sum((p - s) * a for p, s, a in zip(point, start, axis)) / length

    stops = [at(c) for c in centres]
    if stops != sorted(stops):
        raise ValueError("a chain must go forward along its axis")

    def weights(position):
        s = at(position)
        if s <= stops[0]:
            return {names[0]: 1.0}
        for i in range(1, len(names)):
            if s <= stops[i]:
                t = (s - stops[i - 1]) / (stops[i] - stops[i - 1])
                return {names[i - 1]: 1.0 - t, names[i]: t}
        return {names[-1]: 1.0}

    return weights
