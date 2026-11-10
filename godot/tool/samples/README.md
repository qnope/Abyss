# tool/samples

What the tests of `godot/domain` build again and again: the buildings of a
base, an army, a stock of resources. Test infrastructure, not game code, left
out of exports and of the coverage.

`DomainSamples` holds the helpers the Dart tests repeat in each file
(`_buildings`, `_units`, `_base`, `_resources`): each takes a map by enum
value and gives the typed map the rules take, with the entries given and
only them, in the order given.

    var buildings := DomainSamples.buildings({BuildingType.Value.HEADQUARTERS: 2})

The tests driven by `reference/vectors/` build theirs from the Dart names a
case writes, with `VectorInputs` (`godot/tool/reference/README.md`).
