import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/game/game.dart';
import '../../../domain/game/save_sections.dart';
import '../../../domain/game/save_summary.dart';
import '../../l10n/l10n_extension.dart';
import 'save_card.dart';
import 'save_section_header.dart';

/// The saves in progress then the finished ones, each section under its
/// header, in one lazily built scroll view centered on wide screens.
///
/// The game in progress played last is highlighted: the one a player most
/// likely resumes.
class SaveList extends StatelessWidget {
  final SaveSections sections;

  /// The time the last played dates are told against.
  final DateTime now;
  final ValueChanged<Game> onOpen;
  final ValueChanged<Game> onDelete;

  static const double maxWidth = 560;
  static const double _gutter = 16;
  static const double _gap = 10;

  const SaveList({
    super.key,
    required this.sections,
    required this.now,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.max(_gutter, (constraints.maxWidth - maxWidth) / 2);
        final l10n = context.l10n;
        return CustomScrollView(
          slivers: [
            ..._section(l10n.saveInProgress, sections.inProgress, side),
            ..._section(l10n.saveFinished, sections.finished, side),
            SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
          ],
        );
      },
    );
  }

  List<Widget> _section(String title, List<Game> games, double side) {
    if (games.isEmpty) return const [];
    final padding = EdgeInsets.symmetric(horizontal: side);
    return [
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(child: SaveSectionHeader(label: title)),
      ),
      SliverPadding(
        padding: padding,
        sliver: SliverList.separated(
          itemCount: games.length,
          separatorBuilder: (_, _) => const SizedBox(height: _gap),
          itemBuilder: (_, index) => _card(games[index]),
        ),
      ),
    ];
  }

  Widget _card(Game game) => SaveCard(
    key: ObjectKey(game),
    summary: SaveSummary.of(game),
    now: now,
    highlighted: identical(game, sections.mostRecentInProgress),
    onTap: () => onOpen(game),
    onDelete: () => onDelete(game),
  );
}
