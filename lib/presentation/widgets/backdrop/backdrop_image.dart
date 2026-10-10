import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'backdrop_geometry.dart';
import 'backdrop_raster_cache.dart';

/// A full-screen SVG [asset] covering its box, centred on [focus] (in art
/// units), drawn from a bitmap rasterized once at the box's pixel size.
///
/// Draws nothing until the bitmap is ready, then fades it in, so what
/// lies below shows meanwhile. A bitmap already rasterized (by another
/// screen) shows on the first frame. Resizing rasterizes again only when
/// the size changes bucket, one rasterization at a time.
class BackdropImage extends StatefulWidget {
  final String asset;
  final Offset focus;

  static const fadeIn = Duration(milliseconds: 600);

  const BackdropImage({super.key, required this.asset, required this.focus});

  @override
  State<BackdropImage> createState() => _BackdropImageState();
}

class _BackdropImageState extends State<BackdropImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: BackdropImage.fadeIn,
    value: 1,
  );
  ui.Image? _image;
  Size _wanted = Size.zero;
  bool _loading = false;

  @override
  void didUpdateWidget(BackdropImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset || oldWidget.focus != widget.focus) {
      _wanted = Size.zero;
    }
  }

  /// Called while laying out: switches to a ready bitmap at once, else
  /// starts rasterizing unless a rasterization is already running.
  void _want(Size bucket) {
    if (bucket == _wanted || bucket.isEmpty) return;
    _wanted = bucket;
    final ready = BackdropRasterCache.cloneReady(
      widget.asset,
      widget.focus,
      bucket,
    );
    if (ready != null) return _swap(ready);
    if (!_loading) _load();
  }

  Future<void> _load() async {
    _loading = true;
    final (asset, focus, bucket) = (widget.asset, widget.focus, _wanted);
    try {
      final image = await BackdropRasterCache.load(asset, focus, bucket);
      if (!mounted) {
        image.dispose();
        return;
      }
      final first = _image == null;
      setState(() => _swap(image));
      final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (first && !reduced) _fade.forward(from: 0);
    } catch (_) {
      // Keeps what lies below: the backdrop is decoration only.
    } finally {
      _loading = false;
    }
    if (!mounted) return;
    // The size or art changed meanwhile: rasterize the latest one.
    if ((widget.asset, widget.focus, _wanted) != (asset, focus, bucket)) {
      _load();
    }
  }

  void _swap(ui.Image image) {
    _image?.dispose();
    _image = image;
  }

  @override
  void dispose() {
    _fade.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        _want(rasterBucket(constraints.biggest * ratio));
        return RawImage(
          image: _image,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          opacity: _fade,
        );
      },
    );
  }
}
