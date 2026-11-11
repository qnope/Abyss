"""The ICU messages of the ARB files, parsed to check them.

    parse("{n, plural, one{{n} chat} other{{n} chats}}")

gives a list of nodes:

    ("text", "...")                      literal text, apostrophes included
    ("arg", "name")                      {name}
    ("plural", "name", {selector: nodes})
    ("select", "name", {selector: nodes})

The syntax is the one of Flutter's gen_l10n with its defaults: `{`, `}` and
`,` are the only special characters (no `'` escape, no `#`), a branch may
hold arguments and nested plurals and selects, and the plural selectors are
`=N`, `zero`, `one` and `other` (godot/presentation/ui/l10n/ formats them).
"""

import re

PLURAL_WORDS = ("zero", "one", "other")
_NAME = re.compile(r"[A-Za-z_]\w*$")
_EXACT = re.compile(r"=\d+$")


class IcuError(ValueError):
    pass


def parse(text):
    """The nodes of [text]; raises IcuError on a message that does not parse."""
    parser = _Parser(text)
    nodes = parser.nodes(top=True)
    return nodes


def arguments(nodes):
    """The names of every argument of [nodes], nested ones included."""
    names = set()
    for node in nodes:
        if node[0] == "text":
            continue
        names.add(node[1])
        if node[0] != "arg":
            for branch in node[2].values():
                names |= arguments(branch)
    return names


class _Parser:
    def __init__(self, text):
        self.text = text
        self.at = 0

    def nodes(self, top):
        """Nodes up to the end of the text, or up to the `}` closing a branch."""
        found = []
        start = self.at
        while self.at < len(self.text):
            char = self.text[self.at]
            if char == "}":
                if top:
                    raise IcuError(f"unexpected }} at {self.at}")
                break
            if char == "{":
                self._flush(found, start)
                found.append(self.argument())
                start = self.at
            else:
                self.at += 1
        else:
            if not top:
                raise IcuError("unclosed {")
        self._flush(found, start)
        return found

    def _flush(self, found, start):
        if self.at > start:
            found.append(("text", self.text[start:self.at]))

    def argument(self):
        self.at += 1  # the {
        name = self.word(",}")
        if not _NAME.match(name):
            raise IcuError(f"bad argument name {name!r}")
        if self.take() == "}":
            return ("arg", name)
        kind = self.word(",")
        if kind not in ("plural", "select"):
            raise IcuError(f"{name}: unsupported type {kind!r}")
        self.take()
        return (kind, name, self.branches(name, kind))

    def branches(self, name, kind):
        branches = {}
        while True:
            self.skip_space()
            if self.peek() == "}":
                break
            selector = self.word("{}")
            if not selector or self.peek() != "{":
                raise IcuError(f"{name}: bad selector {selector!r}")
            self.check_selector(name, kind, selector)
            if selector in branches:
                raise IcuError(f"{name}: selector {selector} twice")
            self.at += 1
            branches[selector] = self.nodes(top=False)
            self.at += 1  # the }
        self.at += 1
        if "other" not in branches:
            raise IcuError(f"{name}: no other branch")
        return branches

    @staticmethod
    def check_selector(name, kind, selector):
        if kind == "plural" and selector not in PLURAL_WORDS and not _EXACT.match(selector):
            raise IcuError(f"{name}: unsupported plural selector {selector!r}")

    def word(self, stops):
        """The text up to one of [stops] (left in place), stripped."""
        start = self.at
        while self.at < len(self.text) and self.text[self.at] not in stops:
            self.at += 1
        if self.at >= len(self.text):
            raise IcuError("unclosed {")
        return self.text[start:self.at].strip()

    def peek(self):
        if self.at >= len(self.text):
            raise IcuError("unclosed {")
        return self.text[self.at]

    def take(self):
        char = self.peek()
        self.at += 1
        return char

    def skip_space(self):
        while self.at < len(self.text) and self.text[self.at].isspace():
            self.at += 1
