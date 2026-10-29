import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_colors.dart';
import 'map_cell_visual.dart';
import 'map_glow_sprites.dart';

/// Pixel side of the bitmaps laid on the floor: they are soft, so small.
const floorSpriteSize = 128;

/// Opacity of the contact shadow at its darkest, under the content.
const _shadowOpacity = 0.7;

/// Opacity of a pool of light at its brightest, around the cell's centre.
const _poolOpacity = 0.55;

/// Share of a disc's radius where it has faded out: a hair inside its
/// edge, so no pixel of the bitmap's border is ever tinted.
const _fadedAt = 0.95;

/// Renders the soft contact shadow of a standing content once into a
/// square bitmap of [size] pixels: a dark disc fading out before its
/// edge, meant to be drawn flattened on the floor.
Future<ui.Image> rasterizeShadow([int size = floorSpriteSize]) =>
    _rasterizeDisc(size, AbyssColors.abyssBlack, const [
      _shadowOpacity,
      _shadowOpacity * 0.6,
      0,
    ], const [
      0,
      0.5,
      _fadedAt,
    ]);

/// Renders the pool of light [glow] casts on the floor once into a
/// square bitmap of [size] pixels, fading out before its edge so that
/// drawn flattened it shows no box.
Future<ui.Image> rasterizePool(MapGlow glow, [int size = floorSpriteSize]) =>
    _rasterizeDisc(size, glowColorOf(glow), const [
      _poolOpacity,
      _poolOpacity * 0.55,
      _poolOpacity * 0.15,
      0,
    ], const [
      0,
      0.35,
      0.7,
      _fadedAt,
    ]);

/// A disc of [color] filling a bitmap of [size], at each of [opacities]
/// at the matching share of its radius in [stops].
Future<ui.Image> _rasterizeDisc(
  int size,
  Color color,
  List<double> opacities,
  List<double> stops,
) {
  final recorder = ui.PictureRecorder();
  final half = size / 2;
  final centre = Offset(half, half);
  final paint = Paint()
    ..shader = ui.Gradient.radial(centre, half, [
      for (final opacity in opacities) color.withValues(alpha: opacity),
    ], stops);
  Canvas(recorder).drawCircle(centre, half, paint);
  final picture = recorder.endRecording();
  return picture.toImage(size, size).whenComplete(picture.dispose);
}
