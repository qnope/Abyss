# Task 05 — SelectionSummaryCard widget

## Summary

Create a new reusable presentation widget that displays:

- The **total ATK** of the current selection (with the military bonus
  already included).
- The **total DEF** of the current selection.
- A **military bonus label**: `Bonus militaire : +X% ATK (niveau Y)`,
  or `Bonus militaire : aucun` if `researchLevel == 0`.

This single widget covers both US-02 and US-03. It is purely
presentational — the parent (task 06) will compute the totals and
pass them in.

## Files

- `lib/presentation/widgets/fight/selection_summary_card.dart` — new
  file (new widget).
- `test/presentation/widgets/fight/selection_summary_card_test.dart`
  — new test file.

## Implementation steps

1. Create `lib/presentation/widgets/fight/selection_summary_card.dart`.
2. Define a `StatelessWidget` named `SelectionSummaryCard` with the
   following constructor parameters:
   ```dart
   final int totalAtk;        // already boosted
   final int totalDef;
   final int militaryLevel;   // 0 if no bonus
   ```
3. Build a `Card` (use `AbyssTheme` styling — `Theme.of(context).cardTheme`
   handles defaults already) containing a `Padding` with a `Column`:
   - Row with two `Expanded` columns:
     - Left: `ATK` label (small, dim) + value (titleMedium, bold).
     - Right: `DEF` label + value.
   - `SizedBox(height: 8)`.
   - Bonus label `Text` with the formatted string.
4. Implement the bonus label as a private getter:
   ```dart
   String get _bonusLabel {
     if (militaryLevel <= 0) return 'Bonus militaire : aucun';
     final int pct = militaryLevel * 20;
     return 'Bonus militaire : +$pct% ATK (niveau $militaryLevel)';
   }
   ```
5. Use `AbyssColors.onSurface` / `onSurfaceDim` for label colors and
   `Theme.of(context).textTheme` for the styles.
6. Verify the file is under 150 lines.

## Test plan

Create `test/presentation/widgets/fight/selection_summary_card_test.dart`:

```dart
group('SelectionSummaryCard', () {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget wrap(Widget child) => MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(body: child),
      );

  testWidgets('displays totals', (tester) async {
    await tester.pumpWidget(wrap(const SelectionSummaryCard(
      totalAtk: 12, totalDef: 7, militaryLevel: 0,
    )));
    expect(find.text('12'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('shows "aucun" when level is 0', (tester) async {
    await tester.pumpWidget(wrap(const SelectionSummaryCard(
      totalAtk: 0, totalDef: 0, militaryLevel: 0,
    )));
    expect(find.text('Bonus militaire : aucun'), findsOneWidget);
  });

  testWidgets('shows percent and level when > 0', (tester) async {
    await tester.pumpWidget(wrap(const SelectionSummaryCard(
      totalAtk: 0, totalDef: 0, militaryLevel: 3,
    )));
    expect(
      find.text('Bonus militaire : +60% ATK (niveau 3)'),
      findsOneWidget,
    );
  });

  testWidgets('updates when totals change', (tester) async {
    await tester.pumpWidget(wrap(const SelectionSummaryCard(
      totalAtk: 4, totalDef: 2, militaryLevel: 0,
    )));
    expect(find.text('4'), findsOneWidget);
    await tester.pumpWidget(wrap(const SelectionSummaryCard(
      totalAtk: 9, totalDef: 5, militaryLevel: 0,
    )));
    expect(find.text('9'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });
});
```

Add `import` lines for `package:flutter/material.dart`,
`flutter_test`, the new widget, `AbyssTheme`, and the
`test_svg_helper` (for consistency with sibling widget tests).

## Dependencies

- Internal: `lib/presentation/theme/abyss_colors.dart`,
  `lib/presentation/theme/abyss_theme.dart`.
- External: none.
- Blocks: task 06.

## Notes

- The widget is **dumb**: it does no domain math. The parent screen
  (task 06) computes `totalAtk` already boosted by the military level
  via the same code path used by combat resolution. Avoids drift
  between displayed and applied bonus.
- Reusable by any future "preview my army" screen — that's the
  CLAUDE.md "always design components that are reusable" rule.
