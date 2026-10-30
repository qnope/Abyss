import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/building/building_type.dart';
import '../../theme/abyss_motion.dart';
import 'base_buildings_painter.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_snapshot.dart';
import 'base_sprites.dart';

/// The buildings of the base in their own repaint boundary (see
/// [BaseBuildingsPainter]), alive on the ambience [clock]; each one whose
/// level goes up pops once, as an icon does in a list (IncreasePop).
///
/// Nothing pops when first shown, nor when a level stays or goes down,
/// nor when the platform reduces motion.
class BaseBuildingsLayer extends StatefulWidget {
  final BaseLayout layout;
  final BaseFit fit;
  final BaseSnapshot snapshot;
  final BaseSprites? sprites;
  final ValueListenable<double>? clock;

  const BaseBuildingsLayer({
    super.key,
    required this.layout,
    required this.fit,
    required this.snapshot,
    this.sprites,
    this.clock,
  });

  @override
  State<BaseBuildingsLayer> createState() => _BaseBuildingsLayerState();
}

class _BaseBuildingsLayerState extends State<BaseBuildingsLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rise = AnimationController(
    vsync: this,
    duration: AbyssMotion.emphasis,
    value: 1,
  );
  Set<BuildingType> _rising = const {};
  late Map<BuildingType, int> _shown;

  @override
  void initState() {
    super.initState();
    _shown = widget.snapshot.levels;
  }

  @override
  void didUpdateWidget(BaseBuildingsLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final levels = widget.snapshot.levels;
    final risen = {
      for (final MapEntry(:key, :value) in levels.entries)
        if (value > (_shown[key] ?? value)) key,
    };
    _shown = levels;
    if (risen.isEmpty) return;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) return;
    _rising = risen;
    _rise.forward(from: 0);
  }

  @override
  void dispose() {
    _rise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: BaseBuildingsPainter(
            layout: widget.layout,
            snapshot: widget.snapshot,
            fit: widget.fit,
            sprites: widget.sprites,
            clock: widget.clock,
            rise: _rise,
            rising: _rising,
          ),
        ),
      );
}
