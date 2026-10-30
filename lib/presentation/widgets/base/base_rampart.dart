import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../../domain/building/building_type.dart';
import '../map/map_scatter.dart';
import 'base_layout.dart';
import 'base_pad_tier.dart';
import 'base_rampart_segment.dart';

export 'base_rampart_segment.dart';

/// The coral wall the Coral Citadel raises along the inner rim of a
/// plateau of [size] cells, taller at each [level] of the citadel; none
/// at level 0. A gap opens before the citadel at each of the [gates].
///
/// Pure geometry, in ground coordinates: the [back] edges stand behind
/// everything, the [front] ones, lower, before the buildings.
class BaseRampart {
  /// How far inside the plateau's edges the wall runs, in cells.
  static const inset = 0.35;

  /// Thickness of the wall, in cells.
  static const thickness = 0.32;

  /// Length of a block of the wall, about, in cells.
  static const block = 0.5;

  /// How near a gate a block is left out, along the grid, in cells.
  static const gateReach = 1.3;

  /// Share of the back edges' height the front ones rise to.
  static const frontShare = 0.7;

  final int size;
  final int level;

  /// The middle of each gap of the wall, on its edge.
  final List<Offset> gates;

  const BaseRampart({
    required this.size,
    required this.level,
    this.gates = const [],
  });

  /// No wall at all.
  const BaseRampart.none() : this(size: 0, level: 0);

  /// The wall of [layout] once its citadel is at [level], its gate on
  /// each edge the citadel stands by.
  factory BaseRampart.of(BaseLayout layout, int level) {
    final slot = layout.slots[BuildingType.coralCitadel];
    final n = layout.size.toDouble(), far = n - inset;
    final gates = <Offset>[
      if (slot != null)
        for (final gate in [
          Offset(slot.u, inset),
          Offset(inset, slot.v),
          Offset(slot.u, far),
          Offset(far, slot.v),
        ])
          if ((gate - slot.centre).distance < slot.footprint / 2 + 1) gate,
    ];
    return BaseRampart(size: layout.size, level: level, gates: gates);
  }

  /// Height of the back edges, in projection units, before each block
  /// varies a little around it.
  double get height => level <= 0 ? 0 : (5 + 1.5 * level) * basePadUnit;

  /// The blocks of the two back edges, back to front.
  List<BaseRampartSegment> get back => _blocksOf(front: false);

  /// The blocks of the two front edges, back to front, the gates open.
  List<BaseRampartSegment> get front => _blocksOf(front: true);

  List<BaseRampartSegment> _blocksOf({required bool front}) {
    if (level <= 0 || size <= 0) return const [];
    final near = front ? size - inset : inset;
    final edges = [
      (Offset(inset, near), Offset(size - inset, near), true),
      (Offset(near, inset), Offset(near, size - inset), false),
    ];
    final blocks = <BaseRampartSegment>[];
    for (final (e, (from, to, alongU)) in edges.indexed) {
      final steps = ((to - from).distance / block).floor();
      for (var k = 0; k < steps; k++) {
        final start = Offset.lerp(from, to, k / steps)!;
        if (front && _nearGate(start)) continue;
        final roll = mapScatter(k, e + (front ? 2 : 0), salt: size) / _range;
        blocks.add(BaseRampartSegment.along(
          start: start,
          end: Offset.lerp(from, to, (k + 1) / steps)!,
          alongU: alongU,
          front: front,
          height: height * (front ? frontShare : 1) * (0.85 + 0.3 * roll),
          seed: k + 64 * e,
          thickness: thickness,
        ));
      }
    }
    return blocks..sort((a, b) => a.depth.compareTo(b.depth));
  }

  bool _nearGate(Offset start) => gates.any((gate) =>
      (start.dx - gate.dx).abs() + (start.dy - gate.dy).abs() < gateReach);

  @override
  bool operator ==(Object other) =>
      other is BaseRampart &&
      other.size == size &&
      other.level == level &&
      listEquals(other.gates, gates);

  @override
  int get hashCode => Object.hash(size, level, Object.hashAll(gates));
}

const _range = 0x40000000;
