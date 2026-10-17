import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../../widgets/backdrop/abyss_backdrop.dart';
import '../../widgets/opening/opening_story.dart';
import '../../widgets/opening/story_pager.dart';

/// Replaces every page of [navigator] with the opening story of a new
/// game, then, once it is told or skipped, with the page [next] builds.
void startWithOpeningStory(NavigatorState navigator, WidgetBuilder next) {
  navigator.pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder:
          (_) => OpeningStoryScreen(
            onDone:
                () => navigator.pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: next),
                  (_) => false,
                ),
          ),
    ),
    (_) => false,
  );
}

/// The opening story told over the dimmed menu backdrop as a new game
/// begins, before its first turn. Going back skips it, as « Passer »
/// does; [onDone] is called once only.
class OpeningStoryScreen extends StatefulWidget {
  final VoidCallback onDone;

  const OpeningStoryScreen({super.key, required this.onDone});

  @override
  State<OpeningStoryScreen> createState() => _OpeningStoryScreenState();
}

class _OpeningStoryScreenState extends State<OpeningStoryScreen> {
  bool _done = false;

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        body: AbyssBackdrop(
          dimmed: true,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StoryPager(
                  pages: openingStoryPages(l10n),
                  doneLabel: l10n.openingStoryDive,
                  onDone: _finish,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
