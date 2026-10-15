import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Makes the shader sampling [image].
typedef ImageShaderOf = ui.ImageShader Function(ui.Image image);

/// An [ui.ImageShader] over a copy of an image the caller keeps, such as a
/// bitmap shared through a cache.
///
/// On the web, disposing an image shader also disposes its image: built
/// on the shared bitmap, it would free it for every widget still drawing
/// it. The shader samples its own copy instead, released with it on every
/// platform.
class CopiedImageShader {
  final ui.Image _copy;
  final ui.ImageShader shader;

  CopiedImageShader._(this._copy, this.shader);

  factory CopiedImageShader(
    ui.Image image, {
    ImageShaderOf shaderOf = clamped,
  }) {
    final copy = image.clone();
    return CopiedImageShader._(copy, shaderOf(copy));
  }

  /// A shader sampling [image] at its own size, clamped at its edges.
  static ui.ImageShader clamped(ui.Image image) => ui.ImageShader(
        image,
        TileMode.clamp,
        TileMode.clamp,
        Matrix4.identity().storage,
        filterQuality: FilterQuality.medium,
      );

  /// Releases the shader and the copy it samples.
  void dispose() {
    shader.dispose();
    if (!kIsWeb) _copy.dispose();
  }
}
