# Task 10 — HistoryEntryCard Widget

## Summary

Create the `HistoryEntryCard` widget that renders a single entry as a colored `Card` with an icon, title, optional subtitle, and turn number. Combat cards get an `InkWell` tap handler + trailing chevron; the other categories render as static `Cards`.

## Implementation Steps

1. Create folder `lib/presentation/widgets/history/`.
2. Create `lib/presentation/widgets/history/history_entry_card.dart`:
   ```dart
   class HistoryEntryCard extends StatelessWidget {
     final HistoryEntry entry;
     final VoidCallback? onTap;
     const HistoryEntryCard({super.key, required this.entry, this.onTap});

     @override
     Widget build(BuildContext context) {
       final theme = AbyssTheme.of(context);
       final accent = entry.accentColor(theme);
       final card = Card(
         color: accent.withOpacity(0.15),
         child: ListTile(
           leading: Icon(entry.category.icon),
           title: Text(entry.title),
           subtitle: entry.subtitle == null ? null : Text(entry.subtitle!),
           trailing: entry.isTappable
               ? const Icon(Icons.chevron_right)
               : Text('Tour ${entry.turn}'),
         ),
       );
       if (!entry.isTappable || onTap == null) return card;
       return InkWell(onTap: onTap, child: card);
     }
   }
   ```
   - Show the turn number even on tappable entries — put it in the subtitle line prepended (`'Tour N · ${subtitle}'`) if `isTappable` is true, so the trailing chevron has room.
3. Keep the file strictly under 150 lines. If layout grows, extract layout helpers to `history_entry_card_sections.dart`.

## Dependencies

- Blocks: task 11 (HistoryScreen).
- Blocked by: tasks 01–03, 09.

## Test Plan

- `test/presentation/widgets/history/history_entry_card_test.dart`:
  - `BuildingEntry` renders with its icon, title, subtitle, and `Tour N` text. Tap does nothing.
  - `CombatEntry(victory: true)` renders with chevron, green-tinted card, `onTap` fires when provided.
  - `CombatEntry` with `onTap = null` does not crash and is not tappable visually.

## Notes

- Only reads domain data via the extensions from task 09 — no direct color logic here.
- All text in French.
