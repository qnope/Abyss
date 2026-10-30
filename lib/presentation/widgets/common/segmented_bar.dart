import 'package:flutter/material.dart';

import '../../theme/abyss_segmented_theme.dart';

/// One choice of a [SegmentedBar]: its [value], the [label] shown with a
/// [detail] below it, and what a screen reader says of it.
@immutable
class Segment<T> {
  final T value;
  final String label;
  final String? detail;
  final String semanticsLabel;

  const Segment({
    required this.value,
    required this.label,
    required this.semanticsLabel,
    this.detail,
  });
}

/// A tray of [segments] sharing its width, the [selected] one lit; a
/// touch on another calls [onSelected] with its value. Each segment is a
/// selectable button for screen readers, one of a mutually exclusive
/// group (see [AbyssSegmentedTheme]). A label too wide for its segment
/// shrinks to fit.
class SegmentedBar<T> extends StatelessWidget {
  final List<Segment<T>> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  const SegmentedBar({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: AbyssSegmentedTheme.height,
    padding: const EdgeInsets.all(AbyssSegmentedTheme.inset),
    decoration: BoxDecoration(
      color: AbyssSegmentedTheme.tray,
      borderRadius: BorderRadius.circular(AbyssSegmentedTheme.radius),
      border: Border.all(color: AbyssSegmentedTheme.trayEdge),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final segment in segments)
          Expanded(child: _segment(segment, segment.value == selected)),
      ],
    ),
  );

  Widget _segment(Segment<T> segment, bool on) {
    final ink = on ? AbyssSegmentedTheme.onSelected : null;
    final detail = segment.detail;
    return Semantics(
      container: true,
      button: true,
      selected: on,
      inMutuallyExclusiveGroup: true,
      label: segment.semanticsLabel,
      onTap: () => onSelected(segment.value),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelected(segment.value),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: on ? AbyssSegmentedTheme.selected : null,
            borderRadius: BorderRadius.circular(
              AbyssSegmentedTheme.segmentRadius,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _text(segment.label, AbyssSegmentedTheme.label, ink),
                  if (detail != null)
                    _text(detail, AbyssSegmentedTheme.detail, ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A line of the segment, shrunk with it rather than cut when the text
  /// is large.
  static Widget _text(String text, TextStyle style, Color? ink) =>
      Text(text, maxLines: 1, style: style.copyWith(color: ink));
}
