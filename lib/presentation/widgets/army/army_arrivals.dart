import 'package:flutter/widgets.dart';

import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_motion.dart';
import 'squad_arrival.dart';

/// Builds the parade ground with the recruits [arriving] as [arrival]
/// runs from 0 to 1.
typedef ArmyArrivalsBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> arrival,
      Map<UnitType, SquadArrival> arriving,
    );

/// Watches the [counts] of the squads standing at [place] and, each time
/// some of them grow there, hands [builder] their recruits (see
/// [SquadArrival]) with an animation running for less than a second.
///
/// Nothing arrives when first shown, when a squad stays or shrinks, when
/// another place is shown, nor when the platform reduces motion. The
/// last counts seen are kept, so counts mutated in place still arrive.
class ArmyArrivals extends StatefulWidget {
  final Map<UnitType, int> counts;

  /// The place the [counts] are taken at, whatever names it.
  final Object? place;

  final ArmyArrivalsBuilder builder;

  const ArmyArrivals({
    super.key,
    required this.counts,
    required this.builder,
    this.place,
  });

  @override
  State<ArmyArrivals> createState() => _ArmyArrivalsState();
}

class _ArmyArrivalsState extends State<ArmyArrivals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrival = AnimationController(
    vsync: this,
    duration: AbyssMotion.recruitArrival,
    value: 1,
  )..addStatusListener(_settle);
  Map<UnitType, SquadArrival> _arriving = const {};
  late Map<UnitType, int> _shown;
  late Object? _place;

  @override
  void initState() {
    super.initState();
    _shown = Map.of(widget.counts);
    _place = widget.place;
  }

  @override
  void didUpdateWidget(ArmyArrivals oldWidget) {
    super.didUpdateWidget(oldWidget);
    final arriving =
        widget.place == _place
            ? SquadArrival.between(_shown, widget.counts)
            : const <UnitType, SquadArrival>{};
    _shown = Map.of(widget.counts);
    _place = widget.place;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (arriving.isEmpty || reduced) return;
    _arriving = arriving;
    _arrival.forward(from: 0);
  }

  /// Lets the recruits go once landed.
  void _settle(AnimationStatus status) {
    if (status.isCompleted && _arriving.isNotEmpty) {
      setState(() => _arriving = const {});
    }
  }

  @override
  void dispose() {
    _arrival.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _arrival, _arriving);
}
