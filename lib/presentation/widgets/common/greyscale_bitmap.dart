import 'dart:ui' as ui;

/// Luminance greyscale (Rec. 709 weights), alpha preserved.
const _greyscale = ui.ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// A greyscale copy of [image], the same size.
///
/// The filter is applied once here, so drawing the copy later costs a
/// single plain image draw, without any colour filter or extra layer.
Future<ui.Image> greyscaleBitmap(ui.Image image) {
  final recorder = ui.PictureRecorder();
  final paint = ui.Paint()..colorFilter = _greyscale;
  ui.Canvas(recorder).drawImage(image, ui.Offset.zero, paint);
  final picture = recorder.endRecording();
  return picture
      .toImage(image.width, image.height)
      .whenComplete(picture.dispose);
}
