# domain

The game's rules, and nothing else: resources, buildings, technologies, units,
turns, the map, combat, factions. Plain typed classes that extend `RefCounted`
(or `Resource` for data they describe), complete once `_init` returns.

No `Node`, no scene tree, no rendering, input or file APIs: a rule here must
run the same in a test, on the web and on a phone.

Depends on nothing outside `domain/`.

The rules are ported from `lib/domain` to give the same game, to the last
die. A ported rule never uses `randi`, `randf`, `Array.shuffle`, `Array.sort`
or `sort_custom` with a comparator that can tie, `%` on a whole number that
can be negative, `/` between two whole numbers, `pow` nor `**`: it goes
through `DartRandom`, `DartSort`, `DartMath`, `DartBits` and `DartNum` of
[`dart/`](dart/README.md), which says what to write for each Dart
expression and what GDScript already does as Dart.
