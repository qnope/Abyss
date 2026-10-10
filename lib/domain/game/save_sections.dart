import 'game.dart';
import 'save_outcome.dart';

/// The saves split into games in progress and finished games, each latest
/// played first.
class SaveSections {
  final List<Game> inProgress;
  final List<Game> finished;

  SaveSections._(this.inProgress, this.finished);

  factory SaveSections.of(Iterable<Game> games) {
    final inProgress = <Game>[];
    final finished = <Game>[];
    for (final game in games) {
      (SaveOutcome.of(game.status).isFinished ? finished : inProgress)
          .add(game);
    }
    return SaveSections._(_latestFirst(inProgress), _latestFirst(finished));
  }

  bool get isEmpty => inProgress.isEmpty && finished.isEmpty;

  /// The game a "continue" shortcut resumes, if any is still played.
  Game? get mostRecentInProgress =>
      inProgress.isEmpty ? null : inProgress.first;

  static List<Game> _latestFirst(List<Game> games) => List.unmodifiable(
    games..sort((a, b) => b.lastPlayedAt.compareTo(a.lastPlayedAt)),
  );
}
