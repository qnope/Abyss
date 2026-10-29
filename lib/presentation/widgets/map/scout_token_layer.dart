import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../common/svg_raster_cache.dart';
import 'token/map_token_trip.dart';
import 'token/map_tokens_painter.dart';

/// The scouts sent to explore cells of a map, standing upright over it in
/// projection coordinates.
///
/// A scout sent while the layer is shown swims from [originOf] its target
/// to that target, then waits on its edge; scouts already sent when
/// the layer appears wait there at once, as they do when the player asks
/// for fewer animations. A scout whose target is no longer among
/// [targets] (its exploration is over) leaves the layer at once: the
/// story of the turn (`MapFogLift`) fades it out.
///
/// New scouts are told apart from the targets the layer saw last, not
/// from the previous widget, as the game changes its lists in place.
class ScoutTokenLayer extends StatefulWidget {
  /// Cells the scouts were sent to, still waiting to be explored.
  final Set<(int, int)> targets;

  /// The cell a scout sent to a target sets off from.
  final (int, int) Function((int, int) target) originOf;

  /// Size of the map.
  final Size size;

  const ScoutTokenLayer({
    super.key,
    required this.targets,
    required this.originOf,
    required this.size,
  });

  @override
  State<ScoutTokenLayer> createState() => _ScoutTokenLayerState();
}

class _ScoutTokenLayerState extends State<ScoutTokenLayer>
    with TickerProviderStateMixin {
  static final _iconPath = UnitType.scout.iconPath;

  late Set<(int, int)> _seen;
  final _swims = <(int, int), MapTokenTrip>{};
  ui.Image? _image = SvgRasterCache.peek(_iconPath);
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _seen = {...widget.targets};
    if (_image == null) {
      SvgRasterCache.load(_iconPath).then((image) {
        if (mounted) setState(() => _image = image);
      }, onError: (Object error) => debugPrint('Scout token: $error'));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void didUpdateWidget(ScoutTokenLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targets = widget.targets;
    _seen.difference(targets).forEach(_leave);
    if (!_reduced) targets.difference(_seen).forEach(_swim);
    _seen = {...targets};
  }

  void _swim((int, int) target) {
    final origin = widget.originOf(target);
    final progress = AnimationController(
      vsync: this,
      duration: MapTokenTrip.durationOf(origin, target),
    );
    progress.addStatusListener((status) {
      if (status == AnimationStatus.completed) _settle(target);
    });
    _swims[target] = MapTokenTrip.swimming(
        from: origin, to: target, progress: progress);
    progress.forward();
  }

  /// The scout arrived: it waits at rest, painted once.
  void _settle((int, int) target) {
    if (!mounted) return;
    setState(() => _drop(target));
  }

  /// The scout's exploration is over: it leaves this layer at once, as
  /// the story of the turn fades it out with the fog it lifts.
  void _leave((int, int) target) => _drop(target);

  void _drop((int, int) target) {
    final progress = _swims.remove(target)?.progress;
    if (progress is AnimationController) {
      WidgetsBinding.instance.addPostFrameCallback((_) => progress.dispose());
    }
  }

  @override
  void dispose() {
    for (final trip in _swims.values) {
      (trip.progress as AnimationController?)?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            size: widget.size,
            painter: MapTokensPainter(
              image: _image,
              trips: [
                for (final target in widget.targets)
                  _swims[target] ?? MapTokenTrip.atRest(target),
              ],
            ),
          ),
        ),
      );
}
