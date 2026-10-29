import 'package:flutter/widgets.dart';

import '../../common/svg_raster_cache.dart';
import '../map_sprites.dart';
import 'map_effect.dart';
import 'map_effect_painter.dart';
import 'map_effects.dart';

/// Plays the effects of [effects] on a map, in projection coordinates,
/// around the layers of [child]: what an effect lays on the floor under
/// them, the rest over them, the contents it fades told to the map.
///
/// One animation runs the effect playing; once it ends, the effect is
/// over. When the player asks for fewer animations, every effect is over
/// as soon as it starts. Never catches a tap itself.
class MapEffectsLayer extends StatefulWidget {
  final MapEffects effects;

  /// Size of the map, and in cells if known.
  final Size size;
  final int? columns, rows;

  /// The layers of the map the effects play around, if any.
  final Widget? child;

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
    this.columns,
    this.rows,
    this.child,
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
      ..addListener(_tick)
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
    // An effect may wait for this layer to come on screen.
    if (widget.effects.current != _effect) _changed();
  }

  void _changed() {
    final effect = widget.effects.current;
    if (effect == _effect) return;
    if (effect != null && _reduced) return widget.effects.finish();
    _progress.stop();
    widget.effects.shake.value = Offset.zero;
    widget.effects.fade.clear();
    setState(() {
      _effect = effect;
      _run = effect?.stage(MapStage(originOf: widget.originOf,
          sprites: widget.sprites, columns: widget.columns, rows: widget.rows));
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

  /// Shakes the map and fades its contents as the effect plays.
  void _tick() {
    final run = _run;
    if (run == null) return;
    final elapsed = run.duration * _progress.value;
    widget.effects.shake.value = run.shakeAt(elapsed);
    widget.effects.fade.fade(run.fadedCells, run.contentOpacityAt(elapsed));
  }

  @override
  void dispose() {
    _detach(widget.effects);
    widget.effects.fade.clear();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final run = _run, child = widget.child;
    return Stack(
        alignment: Alignment.topLeft, clipBehavior: Clip.none, children: [
      _paint(run == null
          ? null
          : MapEffectFloorPainter(run: run, progress: _progress)),
      if (child != null) child,
      _paint(run == null
          ? null
          : MapEffectPainter(run: run, progress: _progress)),
    ]);
  }

  Widget _paint(CustomPainter? painter) => IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(size: widget.size, painter: painter),
        ),
      );
}
