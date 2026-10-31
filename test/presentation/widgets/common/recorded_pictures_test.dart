import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/common/recorded_pictures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const red = Color(0xFFFF0000);

  /// Draws what [pictures] replays under [key] on a fresh canvas.
  ui.Picture replayed(
    RecordedPictures<String> pictures,
    String key,
    void Function(Canvas canvas) draw, {
    Object? source,
  }) {
    final recorder = ui.PictureRecorder();
    pictures.replay(Canvas(recorder), key, draw, source: source);
    return recorder.endRecording();
  }

  void square(Canvas canvas) =>
      canvas.drawRect(const Rect.fromLTWH(0, 0, 2, 2), Paint()..color = red);

  test('records a drawing once, then replays it as it is', () {
    final pictures = RecordedPictures<String>();
    var draws = 0;
    void counted(Canvas canvas) {
      draws++;
      square(canvas);
    }

    replayed(pictures, 'flag', counted);
    replayed(pictures, 'flag', counted);
    replayed(pictures, 'flag', counted);
    expect(draws, 1);
    expect(pictures.recordings, 1);
    expect(pictures.length, 1);
  });

  test('records each key apart', () {
    final pictures = RecordedPictures<String>();
    replayed(pictures, 'flag', square);
    replayed(pictures, 'pole', square);
    expect(pictures.recordings, 2);
    expect(pictures.length, 2);
  });

  test('records again for another source, one picture per key', () {
    final pictures = RecordedPictures<String>();
    final first = Object(), second = Object();
    replayed(pictures, 'flag', square, source: first);
    replayed(pictures, 'flag', square, source: second);
    replayed(pictures, 'flag', square, source: second);
    expect(pictures.recordings, 2);
    expect(pictures.length, 1);
  });

  test('forgets every picture and recording once reset', () {
    final pictures = RecordedPictures<String>();
    var draws = 0;
    void counted(Canvas canvas) => draws++;
    replayed(pictures, 'flag', counted);

    pictures.debugReset();

    expect(pictures.length, 0);
    expect(pictures.recordings, 0);
    replayed(pictures, 'flag', counted);
    expect(draws, 2, reason: 'recorded anew');
  });

  testWidgets('replays what the drawing draws', (tester) async {
    final pictures = RecordedPictures<String>();
    replayed(pictures, 'flag', square);
    final again = replayed(pictures, 'flag', (canvas) {});
    final image = (await tester.runAsync(() => again.toImage(2, 2)))!;
    final pixels = (await tester.runAsync(image.toByteData))!;
    expect(pixels.getUint32(0), 0xFF0000FF);
  });
}
