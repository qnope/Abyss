"""Splits GDScript source into statements, as the engine's tokenizer does.

A statement ends at a line break outside brackets, strings and a trailing
backslash. A lambda whose body starts on the next line inside brackets
opens a frame where line breaks and indentation count again, until a line
indented less than its body or a bracket the body never opened.
"""

from gdscript_coverage.statement import Statement, Token

OPENERS, CLOSERS = "([{", ")]}"
QUOTES = "\"'"


class _Frame:
    def __init__(self, indent):
        self.indent = indent  # None until the first line of a lambda body
        self.depth = 0
        self.statement = None
        self.headers = []  # [depth, params closed] of each func not yet at ':'


def tokenize(source):
    return _Scanner().run(source)


class _Scanner:
    def __init__(self):
        self.frames = [_Frame(0)]
        self.statements = []
        self.string = None  # the closing quote of an open string

    def run(self, source):
        for number, text in enumerate(source.split("\n"), 1):
            self._line(number, text.rstrip("\r"))
        return self.statements

    def _line(self, number, text):
        indent = len(text) - len(text.lstrip(" \t"))
        goes_on = self.string is not None or self._frame().statement is not None
        if not goes_on:
            if text[indent:indent + 1] in ("", "#"):
                return  # blank or a comment
            self._start(number, indent)
        if self._scan(number, text, 0 if goes_on else indent):
            return  # a trailing backslash or an open string
        frame = self._frame()
        last = frame.statement.tokens[-1] if frame.statement.tokens else None
        if last is not None and last.ends_header and last.line == number:
            frame.statement.opens_function = True
            if frame.depth > 0:
                self.frames.append(_Frame(None))
                return
        if frame.depth == 0:
            frame.statement = None

    def _start(self, number, indent):
        frame = self._frame()
        if frame.indent is None:
            frame.indent = indent  # the first line of a lambda body
        elif indent < frame.indent:
            self.frames.pop()
            return  # the line goes on with the brackets around the lambda
        frame.headers = []
        frame.statement = Statement(number, indent)
        self.statements.append(frame.statement)

    def _frame(self):
        return self.frames[-1]

    def _scan(self, number, text, i):
        """Scans the rest of a line; True when the statement goes on."""
        while i < len(text):
            if self.string is not None:
                i = self._in_string(text, i)
                continue
            c = text[i]
            if c in " \t":
                i += 1
            elif c == "#":
                break
            elif c == "\\" and not text[i + 1:].strip():
                return True
            elif c in QUOTES or (c in "&^r" and text[i + 1:i + 2] in ("'", '"')
                                 and not _is_name_char(text[i - 1:i])):
                start = i + (c not in QUOTES)
                quote = text[start] * (3 if text.startswith(text[start] * 3, start) else 1)
                self._add("string", text[i:start + len(quote)], number, i)
                self.string = quote
                i = start + len(quote)
            elif _is_name_char(c):
                end = i
                while end < len(text) and (_is_name_char(text[end]) or
                                           (c.isdigit() and text[end] == ".")):
                    end += 1
                self._add("number" if c.isdigit() else "name", text[i:end], number, i)
                i = end
            else:
                op = text[i:i + 2] if text[i:i + 2] in ("->", ":=") else c
                self._op(op, number, i)
                i += len(op)
        return self.string is not None

    def _in_string(self, text, i):
        if text[i] == "\\":
            return i + 2
        if not text.startswith(self.string, i):
            return i + 1
        i, self.string = i + len(self.string), None
        return i

    def _op(self, op, number, col):
        frame = self._frame()
        if op in CLOSERS:
            if frame.depth == 0 and len(self.frames) > 1:
                self.frames.pop()  # the bracket closes the lambda's call
                frame = self._frame()
            frame.depth = max(frame.depth - 1, 0)
            if frame.headers and frame.headers[-1][0] == frame.depth:
                frame.headers[-1][1] = True
        token = self._add("op", op, number, col)
        if op in OPENERS:
            frame.depth += 1
        elif op == ":" and frame.headers and frame.headers[-1] == [frame.depth, True]:
            frame.headers.pop()
            token.ends_header = True

    def _add(self, kind, text, number, col):
        frame = self._frame()
        token = Token(kind, text, number, col, frame.depth)
        frame.statement.tokens.append(token)
        if kind == "name" and text == "func":
            frame.headers.append([frame.depth, False])
        return token


def _is_name_char(c):
    return c != "" and (c.isalnum() or c == "_")
