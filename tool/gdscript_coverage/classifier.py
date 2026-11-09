"""Decides which statements are executable lines, and where each one's probe
goes: before the statement, or after the header colon of a one-line body.

Blocks are told apart by indentation, as GDScript does. Inside a function
(or a lambda, a property's set or get) every statement counts, except
`elif`, `else` and match patterns, which a probe cannot precede: their body's
first statement counts instead, after the colon when it is on the same line.
Class-level declarations never count.
"""

CLASS, PROPERTY, FUNCTION, BLOCK, MATCH = "class", "property", "function", "block", "match"


def executable_lines(statements):
    return [line for line, _ in probes(statements)]


def probes(statements):
    """The (line, column) of each probe, in source order."""
    stack = []  # (indent, context) of the blocks around the statement
    found = []
    for statement in statements:
        while stack and stack[-1][0] >= statement.indent:
            stack.pop()
        context = stack[-1][1] if stack else CLASS
        opened, probe = _classify(statement, context)
        if probe is not None:
            found.append(probe)
        if opened is not None:
            stack.append((statement.indent, opened))
    return found


def _classify(statement, context):
    """The block the statement opens, if any, and its probe, if any."""
    tokens = statement.tokens
    head = _head(tokens)
    ends_block = tokens[-1].text == ":"
    if context == CLASS:
        if statement.opens_function:
            return FUNCTION, None
        if head == "class" and ends_block:
            return CLASS, None
        if head == "var" and ends_block:
            return PROPERTY, None
        return None, _inline_body(tokens) if head == "func" else None
    if context == PROPERTY:
        return _header(tokens, ends_block, FUNCTION) if head in ("set", "get") else (None, None)
    if context == MATCH or head in ("elif", "else"):
        return _header(tokens, ends_block, BLOCK)
    if head is None:
        return None, None  # an annotation alone, for the next statement
    if head == "match" and ends_block:
        opened = MATCH
    else:
        opened = BLOCK if ends_block or statement.opens_function else None
    return opened, (statement.line, tokens[0].col)


def _header(tokens, ends_block, opened):
    """A line no probe may precede: it opens a block or ends with a body."""
    return (opened, None) if ends_block else (None, _inline_body(tokens))


def _inline_body(tokens):
    """The place of the first token after the header's colon, if any."""
    for index, token in enumerate(tokens[:-1]):
        if token.text == ":" and token.depth == 0:
            body = tokens[index + 1]
            return body.line, body.col
    return None


def _head(tokens):
    """The first word after the annotations and `static`, if any."""
    index = 0
    while index < len(tokens) and tokens[index].text == "@":
        index += 2
        if index < len(tokens) and tokens[index].text == "(":
            depth = tokens[index].depth
            index += 1
            while index < len(tokens) and tokens[index].depth > depth:
                index += 1
            index += 1  # the closing bracket
    if index < len(tokens) and tokens[index].text == "static":
        index += 1
    return tokens[index].text if index < len(tokens) else None
