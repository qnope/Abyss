"""What the tokenizer gives: statements made of tokens."""

from dataclasses import dataclass, field


@dataclass
class Token:
    kind: str  # name, number, string or op
    text: str
    line: int  # from 1
    col: int  # from 0
    depth: int  # brackets around it in its frame; a bracket's own is outside
    ends_header: bool = False  # the colon ending a func or lambda header


@dataclass
class Statement:
    line: int
    indent: int
    tokens: list = field(default_factory=list)
    opens_function: bool = False  # its last header colon ends the line
