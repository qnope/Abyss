import 'package:flutter/material.dart';
import 'history_filter.dart';

/// Horizontal row of [ChoiceChip]s, one per [HistoryFilter] value.
///
/// Stateless — the selected filter is owned by the parent and passed in
/// via [current]. [onChanged] fires when the user taps a different chip.
class HistoryFilterChips extends StatelessWidget {
  const HistoryFilterChips({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final HistoryFilter current;
  final ValueChanged<HistoryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final filter in HistoryFilter.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: filter == current,
                onSelected: (selected) {
                  if (selected) {
                    onChanged(filter);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
