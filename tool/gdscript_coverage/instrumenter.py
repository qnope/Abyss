"""Puts a probe before each executable statement, on the statement's line,
so that every line keeps its number and an engine error its place."""

from dataclasses import dataclass

from gdscript_coverage.classifier import probes
from gdscript_coverage.tokenizer import tokenize

PROBE = "CoverageProbe.hit(%d, %d); "


@dataclass
class Instrumented:
    text: str
    lines: list  # the executable lines, from 1
    line_count: int


def instrument(source, file_index):
    """The source with its probes, which count hits as (file_index, line)."""
    rows = source.split("\n")
    places = probes(tokenize(source))
    for line, col in places:
        row = rows[line - 1]
        rows[line - 1] = row[:col] + PROBE % (file_index, line) + row[col:]
    return Instrumented("\n".join(rows), [line for line, _ in places], len(rows))
