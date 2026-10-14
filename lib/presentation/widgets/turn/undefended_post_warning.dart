import 'package:flutter/material.dart';

import '../../../domain/faction/undefended_posts.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/map/post_holder.dart';
import '../../../domain/map/transition_base.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

/// Warning shown before ending a turn, one line per post the player holds
/// with nobody on the level below to defend it. It never blocks the turn.
class UndefendedPostWarning extends StatelessWidget {
  final List<TransitionBase> posts;

  const UndefendedPostWarning({super.key, required this.posts});

  /// The warning for [player], or `null` when every post it holds is
  /// defended, or it holds none.
  static UndefendedPostWarning? of(Game game, Player player) {
    final List<TransitionBase> posts = UndefendedPosts.of(game, player);
    return posts.isEmpty ? null : UndefendedPostWarning(posts: posts);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        for (final TransitionBase post in posts)
          Row(
            children: [
              RasterSvg(
                assetPath: post.type.svgPathFor(PostHolder.human),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.undefendedPostWarning(
                    post.type.name,
                    post.targetLevel,
                  ),
                  style: const TextStyle(color: AbyssColors.warning),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
