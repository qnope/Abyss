/// The digests of a game, turn after turn, written without repeating a
/// digest that did not change: a section whose digest is the one of the
/// row before is written [same].
abstract final class DigestRows {
  /// Stands for "the digest this section had in the row before".
  static const String same = '=';

  static List<List<String>> compact(List<List<String>> rows) => <List<String>>[
    for (int r = 0; r < rows.length; r++)
      <String>[
        for (int i = 0; i < rows[r].length; i++)
          r > 0 && rows[r][i] == rows[r - 1][i] ? same : rows[r][i],
      ],
  ];

  static List<List<String>> expand(List<List<String>> rows) {
    final List<List<String>> full = <List<String>>[];
    for (final List<String> row in rows) {
      full.add(<String>[
        for (int i = 0; i < row.length; i++)
          row[i] == same ? full.last[i] : row[i],
      ]);
    }
    return full;
  }
}
