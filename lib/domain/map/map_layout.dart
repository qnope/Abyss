/// How a map grows with the number of players.
class MapLayout {
  static const minPlayers = 1;
  static const maxPlayers = 11;

  /// Side of the square map: 20 up to 3 players, 26 up to 6, 32 up to 11.
  static int sizeFor(int playerCount) {
    _check(playerCount);
    if (playerCount <= 3) return 20;
    return playerCount <= 6 ? 26 : 32;
  }

  /// Failles, and as many Cheminées, added to the usual ones: one for
  /// each two players past the first.
  static int extraPostsFor(int playerCount) {
    _check(playerCount);
    return (playerCount - 1) ~/ 2;
  }

  /// Lairs a map may hold: 5 to 10 on a 20 x 20 map, more on a larger one.
  static (int, int) lairRangeFor(int size) {
    final area = size * size;
    return (5 * area ~/ 400, 10 * area ~/ 400);
  }

  static void _check(int playerCount) {
    if (playerCount < minPlayers || playerCount > maxPlayers) {
      throw ArgumentError.value(
        playerCount,
        'playerCount',
        'must be 1 to $maxPlayers',
      );
    }
  }
}
