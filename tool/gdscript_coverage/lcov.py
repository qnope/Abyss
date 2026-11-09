"""The lcov tracefile, as `flutter test --coverage` writes it."""

from dataclasses import dataclass


@dataclass
class FileCoverage:
    path: str  # as the report shows it, from the repo root
    lines: list  # the executable lines, from 1
    hits: list  # hits by line number

    def found(self):
        return len(self.lines)

    def hit(self):
        return sum(1 for line in self.lines if self.hits[line] > 0)


def lcov(files):
    """A record per file, sorted by path."""
    out = []
    for file in sorted(files, key=lambda f: f.path):
        out.append("SF:%s\n" % file.path)
        out.extend("DA:%d,%d\n" % (line, file.hits[line]) for line in file.lines)
        out.append("LF:%d\nLH:%d\nend_of_record\n" % (file.found(), file.hit()))
    return "".join(out)
