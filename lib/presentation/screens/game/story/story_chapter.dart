import '../../../widgets/map/effects/map_effect.dart';

/// One step of the story of a turn: an [effect] played on the map of
/// [level].
class StoryChapter {
  final int level;
  final MapEffect effect;

  const StoryChapter({required this.level, required this.effect});
}
