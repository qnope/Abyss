import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../../theme/abyss_motion.dart';
import 'story_card.dart';
import 'story_page.dart';

/// Tells [pages] card after card: « Suivant » or a swipe turns them, the
/// button of the last one, labelled [doneLabel], ends the story and
/// « Passer » ends it from any card. [onDone] is called once only.
class StoryPager extends StatefulWidget {
  final List<StoryPage> pages;
  final String doneLabel;
  final VoidCallback onDone;

  const StoryPager({
    super.key,
    required this.pages,
    required this.doneLabel,
    required this.onDone,
  });

  /// Widest a card grows, on a tablet or a desktop window.
  static const double maxWidth = 440;

  @override
  State<StoryPager> createState() => _StoryPagerState();
}

class _StoryPagerState extends State<StoryPager> {
  static const double _swipeSpeed = 200;
  int _index = 0;
  bool _done = false;

  int get _last => widget.pages.length - 1;

  void _go(int index) {
    if (index < 0 || index > _last) return;
    setState(() => _index = index);
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  void _onSwipe(DragEndDetails details) {
    final speed = details.primaryVelocity ?? 0;
    if (speed <= -_swipeSpeed) _go(_index + 1);
    if (speed >= _swipeSpeed) _go(_index - 1);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: StoryPager.maxWidth),
      child: GestureDetector(
        onHorizontalDragEnd: _onSwipe,
        child: AnimatedSwitcher(
          duration: AbyssMotion.quick,
          child: StoryCard(
            key: ValueKey(_index),
            page: widget.pages[_index],
            footer: _footer(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _footer(BuildContext context) {
    final l10n = context.l10n;
    final last = _index == _last;
    return [
      _Dots(count: widget.pages.length, current: _index),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: last ? _finish : () => _go(_index + 1),
        child: Text(last ? widget.doneLabel : l10n.commonNext),
      ),
      if (!last)
        TextButton(onPressed: _finish, child: Text(l10n.openingStorySkip)),
      if (last) const SizedBox(height: 8),
    ];
  }
}

/// Where the story stands: one dot a card, the current one lit.
class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < count; i++)
        Container(
          width: i == current ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == current ? AbyssColors.biolumCyan : AbyssColors.disabled,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
    ],
  );
}
