import 'package:abyss/presentation/widgets/map/map_content_fade.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MapContentFade fade;
  late int heard;
  setUp(() {
    fade = MapContentFade()..addListener(() => heard++);
    heard = 0;
  });
  tearDown(() => fade.dispose());

  test('shows every content whole at first', () {
    expect(fade.cells, isEmpty);
    expect(fade.opacity, 1);
  });

  test('fades the contents of some cells, telling only of a change', () {
    const cells = {(2, 3), (4, 1)};
    fade.fade(cells, 0);
    expect(fade.cells, cells);
    expect(fade.opacity, 0);
    fade.fade(cells, 0);
    expect(heard, 1);
    fade.fade(cells, 0.4);
    expect(fade.opacity, 0.4);
    expect(heard, 2);
  });

  test('shows every content whole again once cleared', () {
    fade
      ..fade(const {(2, 3)}, 0.5)
      ..clear();
    expect(fade.cells, isEmpty);
    expect(fade.opacity, 1);
    expect(heard, 2);
    fade.clear();
    expect(heard, 2);
  });
}
