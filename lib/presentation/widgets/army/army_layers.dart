import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/unit/unit_type.dart';
import '../../l10n/l10n_extension.dart';
import '../ambience/ambience_clock_scope.dart';
import '../base/base_fit.dart';
import '../base/base_sprites.dart';
import '../common/raster_paint.dart';
import 'army_arrivals.dart';
import 'army_guide_halo.dart';
import 'army_island_painter.dart';
import 'army_marks_painter.dart';
import 'army_roster.dart';
import 'army_sprites.dart';
import 'army_squads_painter.dart';
import 'squad_arrival.dart';

/// The parade ground of [roster] seen through [fit], from the back to
/// the front, each layer within its own repaint boundary: the still
/// island ([ArmyIslandPainter]), rasterized into a bitmap kept when the
/// army is left ([RasterPaint]); the guide's ring on the drill pad of
/// the unit it points at ([ArmyGuideHalo]); the squads and their banners
/// ([ArmySquadsPainter]), once their figures are loaded; their plaques
/// and the barracks' plaque ([ArmyMarksPainter]).
///
/// The squads live on an ambience clock of their own, standing still when
/// the platform reduces motion; recruits arrive on the squads growing at
/// the [place] shown ([ArmyArrivals]). Only the squads repaint as they
/// live, and the plaques while recruits arrive, never the island; until
/// the figures are loaded (rasterized once, see [ArmySprites]) there is
/// no squads' layer at all.
class ArmyLayers extends StatelessWidget {
  /// The name the island's bitmap is kept as when the army is left.
  static const islandName = 'army island';

  final BaseFit fit;
  final ArmyRoster roster;
  final bool barracksDegraded;

  /// Whether a missing prerequisite keeps the barracks from being built.
  final bool barracksLocked;

  /// The place the [roster] counts the army at, whatever names it.
  final Object? place;

  /// The island's bitmaps (its floor, decor and barracks) and the
  /// squads', none drawn while they load.
  final BaseSprites? base;
  final ArmySprites? army;

  const ArmyLayers({
    super.key,
    required this.fit,
    required this.roster,
    this.barracksDegraded = false,
    this.barracksLocked = false,
    this.place,
    this.base,
    this.army,
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return AmbienceClockScope(
      animate: !reduced,
      builder: (context, clock) => ArmyArrivals(
        counts: roster.counts,
        place: place,
        builder: (context, arrival, arriving) =>
            _layers(context, reduced ? null : clock, arrival, arriving),
      ),
    );
  }

  Widget _layers(
    BuildContext context,
    ValueListenable<double>? clock,
    Animation<double> arrival,
    Map<UnitType, SquadArrival> arriving,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: RasterPaint(
            keepAs: islandName,
            painter: ArmyIslandPainter(
              fit: fit,
              barracksLevel: roster.barracksLevel,
              barracksDegraded: barracksDegraded,
              unlocked: roster.unlocked,
              sprites: base,
            ),
          ),
        ),
        ArmyGuideHalo(fit: fit),
        if (army case final sprites?)
          RepaintBoundary(
            child: CustomPaint(
              painter: ArmySquadsPainter(
                fit: fit,
                roster: roster,
                sprites: sprites,
                clock: clock,
                arrival: arrival,
                arriving: arriving,
              ),
            ),
          ),
        RepaintBoundary(
          child: CustomPaint(
            painter: ArmyMarksPainter(
              fit: fit,
              roster: roster,
              l10n: context.l10n,
              barracksLocked: barracksLocked,
              arrival: arrival,
              arriving: arriving,
            ),
          ),
        ),
      ],
    );
  }
}
