import '../../domain/map/game_map.dart';
import '../../domain/objective/objective_id.dart';
import '../../domain/map/post_holder.dart';
import '../../domain/map/transition_base_name.dart';
import '../../domain/map/transition_base_type.dart';

const _folder = 'assets/icons/posts';

extension PostHolderExtensions on PostHolder {
  /// How its illustrations name it: lit green for the human, red for a
  /// faction, in the natural light of the place while still guarded.
  String get svgSuffix => switch (this) {
    PostHolder.guardians => 'guarded',
    PostHolder.human => 'player',
    PostHolder.faction => 'faction',
  };
}

extension TransitionBasePostSprites on TransitionBaseType {
  /// The post itself, as [holder] keeps it.
  String svgPathFor(PostHolder holder) =>
      '$_folder/${name}_${holder.svgSuffix}.svg';

  /// Where its passage arrives on the level below, as [holder] keeps it.
  String passageSvgPathFor(PostHolder holder) =>
      '$_folder/passage_${name}_${holder.svgSuffix}.svg';
}

/// Every post and passage illustration, to preload them all.
final List<String> postSvgPaths = [
  for (final type in TransitionBaseType.values)
    for (final holder in PostHolder.values) ...[
      type.svgPathFor(holder),
      type.passageSvgPathFor(holder),
    ],
];

/// The arrival of the passage named [passageName], as [holder] keeps the
/// post above; a passage of an unknown post arrives from a Faille.
String passageSvgPath(String? passageName, PostHolder holder) =>
    (TransitionBaseName.parse(passageName ?? '')?.type ??
            TransitionBaseType.faille)
        .passageSvgPathFor(holder);

/// The arrival of the passage at ([x], [y]), lit by whoever holds the post
/// at the same place on the level [above], as [humanId] sees it.
String passageIllustration(
  GameMap? above,
  int x,
  int y,
  String humanId,
  String? passageName,
) {
  final base = above?.cellAt(x, y).transitionBase;
  return passageSvgPath(
    passageName,
    base == null ? PostHolder.guardians : PostHolder.of(base, humanId),
  );
}

extension ObjectivePostIllustration on ObjectiveId {
  /// The post an objective asks to take, still guarded, if it is one.
  String? get postIllustration => switch (this) {
    ObjectiveId.takeFaille =>
      TransitionBaseType.faille.svgPathFor(PostHolder.guardians),
    ObjectiveId.takeCheminee =>
      TransitionBaseType.cheminee.svgPathFor(PostHolder.guardians),
    _ => null,
  };
}
