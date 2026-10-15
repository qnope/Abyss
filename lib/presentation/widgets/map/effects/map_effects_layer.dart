import 'package:flutter/widgets.dart';

import '../../common/svg_raster_cache.dart';
import '../map_sprites.dart';
import 'map_effect.dart';
import 'map_effect_painter.dart';
import 'map_effects.dart';

/// Plays the effects of [effects] over a map, in map coordinates.
///
/// One animation runs the effect playing; once it ends, the effect is
/// over. When the player asks for fewer animations, every effect is over
/// as soon as it starts. Never catches a tap.
class MapEffectsLayer extends StatefulWidget {
  final MapEffects effects;

  /// Size of the map.
  final Size size;

  /// The cell the player's units sent to a target set off from.
  final (int, int) Function((int, int) target) originOf;

  /// The map's sprites, or `null` while they load.
  final MapSprites? sprites;

  const MapEffectsLayer({
    super.key,
    required this.effects,
    required this.size,
    required this.originOf,
    this.sprites,
  });

  @override
  State<MapEffectsLayer> createState() => _MapEffectsLayerState();
}

class _MapEffectsLayerState extends State<MapEffectsLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  MapEffect? _effect;
  MapEffectRun? _run;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this)
      ..addListener(_shake)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.effects.finish();
      });
    _attach(widget.effects);
  }

  @override
  void didUpdateWidget(MapEffectsLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effects == widget.effects) return;
    _detach(oldWidget.effects);
    _attach(widget.effects);
  }

  void _attach(MapEffects effects) => effects
    ..addListener(_changed)
    ..attachStage();

  void _detach(MapEffects effects) => effects
    ..removeListener(_changed)
    ..detachStage();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  void _changed() {
    final effect = widget.effects.current;
    if (effect == _effect) return;
    if (effect != null && _reduced) return widget.effects.finish();
    _progress.stop();
    widget.effects.shake.value = Offset.zero;
    setState(() {
      _effect = effect;
      _run = effect?.stage(
          MapStage(originOf: widget.originOf, sprites: widget.sprites));
    });
    final run = _run;
    if (effect == null || run == null) return;
    for (final path in effect.imagePaths) {
      SvgRasterCache.load(path).ignore();
    }
    _progress
      ..duration = run.duration
      ..forward(from: 0);
  }

  void _shake() {
    final run = _run;
    if (run == null) return;
    widget.effects.shake.value =
        run.shakeAt(run.duration * _progress.value);
  }

  @override
  void dispose() {
    _detach(widget.effects);
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final run = _run;
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: widget.size,
          painter: run == null
              ? null
              : MapEffectPainter(run: run, progress: _progress),
        ),
      ),
    );
  }
}
