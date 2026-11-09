# domain

The game's rules, and nothing else: resources, buildings, technologies, units,
turns, the map, combat, factions. Plain typed classes that extend `RefCounted`
(or `Resource` for data they describe), complete once `_init` returns.

No `Node`, no scene tree, no rendering, input or file APIs: a rule here must
run the same in a test, on the web and on a phone.

Depends on nothing outside `domain/`.
