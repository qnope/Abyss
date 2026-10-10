import 'dart:math';

import 'faction_personality.dart';

/// Draws the factions of a game from the ten personalities.
abstract final class FactionCatalogue {
  static const int minCount = 1;
  static const int maxCount = 10;

  /// [count] different personalities, in the order they are given the
  /// free bases; the same [seed] always draws the same ones.
  static List<FactionPersonality> draw(int count, {required int seed}) {
    if (count < minCount || count > maxCount) {
      throw ArgumentError.value(count, 'count', 'must be 1 to $maxCount');
    }
    final deck = List<FactionPersonality>.of(FactionPersonality.values)
      ..shuffle(Random(seed ^ 0x5FAC7));
    return deck.take(count).toList();
  }
}
