import 'package:abyss/presentation/widgets/common/span_cover.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<(String, double, double)> flat(List<SpanPiece<String>> pieces) =>
      [for (final p in pieces) (p.source, p.from, p.to)];

  test('covers the span with the first layer, cut to the span', () {
    expect(
      flat(coverSpan(5, 25, [
        [(source: 'a', from: 0, to: 10), (source: 'b', from: 10, to: 30)],
      ])),
      [('a', 5, 10), ('b', 10, 25)],
    );
  });

  test('fills the gaps of a layer with the next ones, never twice', () {
    expect(
      flat(coverSpan(0, 40, [
        [(source: 'fine', from: 10, to: 20)],
        [(source: 'mid', from: 0, to: 15), (source: 'mid2', from: 30, to: 35)],
        [(source: 'coarse', from: -100, to: 100)],
      ])),
      unorderedEquals([
        ('fine', 10, 20),
        ('mid', 0, 10),
        ('mid2', 30, 35),
        ('coarse', 20, 30),
        ('coarse', 35, 40),
      ]),
    );
  });

  test('leaves bare what no layer reaches, and an empty span empty', () {
    expect(
      flat(coverSpan(0, 10, [
        [(source: 'b', from: 6, to: 8), (source: 'a', from: 1, to: 3)],
      ])),
      [('a', 1, 3), ('b', 6, 8)],
    );
    expect(coverSpan<String>(4, 4, [
      [(source: 'a', from: 0, to: 10)],
    ]), isEmpty);
  });
}
