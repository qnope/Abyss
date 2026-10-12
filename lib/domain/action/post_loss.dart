import '../unit/unit_type.dart';

/// What the owner of a post lost when it was taken ([PostTakeover]).
class PostLoss {
  /// Nothing: the post held.
  static const PostLoss none = PostLoss();

  /// The units of the level below, lost with the post.
  final Map<UnitType, int> units;

  /// Whether its passage building stood, and was destroyed.
  final bool passage;

  const PostLoss({this.units = const <UnitType, int>{}, this.passage = false});
}
