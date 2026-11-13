"""Compares the animations of two glbs channel by channel, each channel met by
its animation, its node and its path, and played on both sides at every key
time of either and halfway between them, within a tolerance.

Played rather than compared key by key: the exporter keeps only the first and
the last key of a channel that moves by less than 1e-4, which the last bits of
a float can decide on another machine, for the same motion to the eye."""

import bisect

from workshop.glb_accessors import accessor_keys


def animation_differences(expected, actual, tolerance=1e-4):
    """What differs between the animations of the reports [expected] and
    [actual], one line a channel; an empty list when they are the same."""
    ours, theirs = _channels(expected), _channels(actual)
    differences = missing_and_unexpected(ours, theirs)
    for name, channel in ours.items():
        if name in theirs:
            apart = _apart(channel, theirs[name], tolerance)
            if apart:
                differences.append(f"{name}: {len(apart)} values differ, "
                                   f"by up to {max(apart):.6g}")
    return differences


def missing_and_unexpected(ours, theirs):
    """A line for each key of [ours] missing from [theirs], then for each key of
    [theirs] that [ours] has not."""
    return ([f"{name}: missing" for name in ours if name not in theirs]
            + [f"{name}: unexpected" for name in theirs if name not in ours])


class _Channel:
    """A sampler's keys at their times, played with its interpolation."""

    def __init__(self, report, sampler):
        self.times = [time for (time,) in accessor_keys(report, sampler["input"])]
        self.keys = accessor_keys(report, sampler["output"])
        self.step = sampler.get("interpolation", "LINEAR") == "STEP"

    def at(self, time):
        """The value at [time]: the keys joined by straight lines, or held."""
        after = bisect.bisect_right(self.times, time)
        if after == 0:
            return self.keys[0]
        if after == len(self.times) or self.step:
            return self.keys[after - 1]
        start, end = self.times[after - 1], self.times[after]
        share = (time - start) / (end - start)
        return tuple(a + (b - a) * share for a, b in zip(self.keys[after - 1], self.keys[after]))


def _channels(report):
    """The channels of [report]'s animations, by animation, node and path."""
    nodes = report.document.get("nodes", [])
    channels = {}
    for animation in report.document.get("animations", []):
        for channel in animation["channels"]:
            target = channel["target"]
            name = (f"animation {animation.get('name', '')} "
                    f"{nodes[target['node']].get('name', '')} {target['path']}")
            channels[name] = _Channel(report, animation["samplers"][channel["sampler"]])
    return channels


def _apart(ours, theirs, tolerance):
    """The gaps over [tolerance] between [ours] and [theirs], played at every
    key time of either and halfway between them."""
    times = sorted(set(ours.times) | set(theirs.times))
    times += [(a + b) / 2 for a, b in zip(times, times[1:])]
    return [abs(a - b) for time in times
            for a, b in zip(ours.at(time), theirs.at(time)) if abs(a - b) > tolerance]
