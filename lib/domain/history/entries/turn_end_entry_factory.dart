import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/turn/turn_result.dart';

/// Factory helpers that build a [TurnEndEntry] from a [TurnResult].
///
/// Kept in its own library so [TurnEndEntry] stays a dumb data class.
class TurnEndEntryFactory {
  const TurnEndEntryFactory();

  /// Builds a [TurnEndEntry] for [turn] from the given [TurnResult].
  ///
  /// The turn number is passed explicitly because a [TurnResult] may carry
  /// both a previous and a new turn, and the caller decides which one the
  /// history entry belongs to.
  TurnEndEntry fromTurnResult(int turn, TurnResult result) {
    return TurnEndEntry(
      turn: turn,
      changes: List<TurnResourceChange>.unmodifiable(result.changes),
      deactivatedBuildings: List.unmodifiable(result.deactivatedBuildings),
      lostUnits: Map.unmodifiable(result.lostUnits),
    );
  }
}
