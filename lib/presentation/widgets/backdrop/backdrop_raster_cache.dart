import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'backdrop_geometry.dart';

typedef _Key = (String asset, Offset focus, Size pixels);

/// Bitmaps of full-screen illustrations, rasterized once per screen size.
///
/// A backdrop holds about a thousand shapes: replaying them every frame
/// would be costly, so each art is parsed once, then drawn into a bitmap
/// of exactly the pixels a screen shows ([coverCrop]). The latest few
/// sizes are kept, so the menu screens share their bitmap.
///
/// Callers own the images they receive: they are clones of the cached
/// bitmap, to dispose once drawn no more.
abstract final class BackdropRasterCache {
  /// Sizes kept at once: enough for a rotation or a resize back and forth.
  static const maxEntries = 3;

  static final _pictures = <String, Future<PictureInfo>>{};
  static final _pending = <_Key, Future<ui.Image>>{};
  static final _ready = <_Key, ui.Image>{};

  /// A clone of the bitmap of [asset] at [pixels], if already rasterized.
  static ui.Image? cloneReady(String asset, Offset focus, Size pixels) =>
      _ready[(asset, focus, pixels)]?.clone();

  /// A clone of the bitmap of [asset] at [pixels] centred on [focus] (in
  /// art units), rasterized on first use only.
  static Future<ui.Image> load(String asset, Offset focus, Size pixels) {
    final key = (asset, focus, pixels);
    final pending =
        _pending[key] ??= _rasterize(key).then(
          (image) => _keep(key, image),
          onError: (Object error) {
            _pending.remove(key);
            throw error;
          },
        );
    return pending.then((image) => image.clone());
  }

  static ui.Image _keep(_Key key, ui.Image image) {
    _ready[key] = image;
    while (_ready.length > maxEntries) {
      final oldest = _ready.keys.first;
      _pending.remove(oldest);
      _ready.remove(oldest)!.dispose();
    }
    return image;
  }

  static Future<PictureInfo> _picture(String asset) {
    return _pictures[asset] ??= vg
        .loadPicture(SvgAssetLoader(asset), null)
        .catchError((Object error) {
          _pictures.remove(asset);
          throw error;
        });
  }

  static Future<ui.Image> _rasterize(_Key key) async {
    final (asset, focus, pixels) = key;
    final info = await _picture(asset);
    final crop = coverCrop(info.size, pixels, focus);
    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..scale(pixels.width / crop.width, pixels.height / crop.height)
      ..translate(-crop.left, -crop.top)
      ..drawPicture(info.picture);
    final picture = recorder.endRecording();
    return picture
        .toImage(pixels.width.round(), pixels.height.round())
        .whenComplete(picture.dispose);
  }
}
