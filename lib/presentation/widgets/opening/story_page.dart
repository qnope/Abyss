import 'package:flutter/widgets.dart';

/// One card of a story told card after card: its [picture], its [title]
/// and the few [lines] telling it.
class StoryPage {
  /// Drawn in a wide frame above the title, e.g. a crop of a backdrop or
  /// a centred sprite.
  final Widget picture;
  final String title;
  final List<String> lines;

  const StoryPage({
    required this.picture,
    required this.title,
    required this.lines,
  });
}
