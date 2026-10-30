import 'dart:math' as math;

/// The stretch from [from] to [to] of a span that [source] covers.
typedef SpanPiece<T> = ({T source, double from, double to});

/// Covers the span from [from] to [to] with the pieces of [layers], the
/// best first: the first layer where it reaches, each next one only in
/// the gaps the ones before leave, so that no point is covered twice.
/// Each piece is cut to what it covers; what no layer reaches stays
/// bare.
List<SpanPiece<T>> coverSpan<T>(
  double from,
  double to,
  List<List<SpanPiece<T>>> layers,
) {
  final pieces = <SpanPiece<T>>[];
  var gaps = [if (from < to) (from, to)];
  for (final layer in layers) {
    if (gaps.isEmpty) break;
    final sorted = [...layer]..sort((a, b) => a.from.compareTo(b.from));
    final left = <(double, double)>[];
    for (final (start, end) in gaps) {
      var cursor = start;
      for (final piece in sorted) {
        if (piece.to <= cursor || piece.from >= end) continue;
        if (piece.from > cursor) left.add((cursor, piece.from));
        final stop = math.min(piece.to, end);
        pieces.add((
          source: piece.source,
          from: math.max(piece.from, cursor),
          to: stop,
        ));
        cursor = stop;
      }
      if (cursor < end) left.add((cursor, end));
    }
    gaps = left;
  }
  return pieces;
}
