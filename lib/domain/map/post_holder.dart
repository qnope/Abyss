import 'game_map.dart';
import 'grid_position.dart';
import 'passage_extractor.dart';
import 'transition_base.dart';

/// Who holds a Faille or a Cheminée, as the human sees it: its guardians
/// until someone takes it, then the human or a rival faction.
enum PostHolder {
  guardians,
  human,
  faction;

  /// Who holds [base], seen by the player [humanId].
  static PostHolder of(TransitionBase base, String humanId) =>
      switch (base.capturedBy) {
        null => PostHolder.guardians,
        final String id when id == humanId => PostHolder.human,
        _ => PostHolder.faction,
      };

  /// Who holds each base of the level [above], by its position: the level
  /// below holds its passage at the same place.
  static Map<GridPosition, PostHolder> passagesBelow(
    GameMap? above,
    String humanId,
  ) {
    if (above == null) return const {};
    return {
      for (final position in PassageExtractor.from(above).keys)
        position: of(
          above.cellAt(position.x, position.y).transitionBase!,
          humanId,
        ),
    };
  }
}
