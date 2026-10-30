import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_motion.dart';
import 'squad_size.dart';

/// A recruit arriving on the drill pad of a squad that grew by [gained]
/// units: it falls in a column of bubbles onto the slot of [figure] (see
/// SquadSlots.arrival), lands with a ring while the plaque pops with a
/// floating « +N », then stands there if it [stays], else melts into the
/// ranks. The whole of it runs over [AbyssMotion.recruitArrival], its
/// steps given at a progress from 0 to 1.
@immutable
class SquadArrival {
  /// Progress at which the recruit touches the deck.
  static const landing = .45;

  static const _fall = Interval(0, landing, curve: Curves.easeInQuad);
  static const _ring = Interval(landing, .85, curve: AbyssMotion.enter);
  static const _pop = Interval(landing, 1);
  static const _float = Interval(.35, 1);
  static const _fade = Interval(.6, .9);

  final int figure;
  final bool stays;
  final int gained;

  const SquadArrival({
    required this.figure,
    required this.stays,
    required this.gained,
  });

  /// The recruit of a squad going from [before] to [after] units: on the
  /// slot of its new figure, else on the next free slot, else, the squad
  /// full, on its front slot; none unless the squad grew.
  static SquadArrival? of(int before, int after) {
    if (after <= before) return null;
    final was = SquadSize.of(before), now = SquadSize.of(after);
    final gained = after - before;
    final (figure, stays) =
        now > was
            ? (now - 1, true)
            : now < SquadSize.max
            ? (now, false)
            : (0, true);
    return SquadArrival(figure: figure, stays: stays, gained: gained);
  }

  /// The recruits of every squad grown from [before] to [after].
  static Map<UnitType, SquadArrival> between(
    Map<UnitType, int> before,
    Map<UnitType, int> after,
  ) => {
    for (final type in UnitType.values)
      if (of(before[type] ?? 0, after[type] ?? 0) case final arrival?)
        type: arrival,
  };

  /// How high the recruit still is at [t], from 1 (the top of its
  /// column) to 0 (landed).
  static double fallAt(double t) => 1 - _fall.transform(t);

  /// How far the landing ring has spread at [t], from 0 to 1 (gone).
  static double ringAt(double t) => _ring.transform(t);

  /// Progress of the plaque's pop at [t] (see RiseMotion).
  static double popAt(double t) => _pop.transform(t);

  /// Progress of the floating gain at [t] (see DeltaFloat).
  static double floatAt(double t) => _float.transform(t);

  /// Opacity at [t] of a recruit that does not stay.
  static double fadeAt(double t) => 1 - _fade.transform(t);

  @override
  bool operator ==(Object other) =>
      other is SquadArrival &&
      other.figure == figure &&
      other.stays == stays &&
      other.gained == gained;

  @override
  int get hashCode => Object.hash(figure, stays, gained);

  @override
  String toString() => 'SquadArrival($figure, stays: $stays, +$gained)';
}
