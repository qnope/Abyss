# Task 09 — Update widget tests

## Summary

Update `resource_bar_item_test.dart` and `resource_bar_test.dart` to remove `productionPerTurn` references and pass the new `production` parameter.

## Implementation Steps

### Step 1: Edit `test/presentation/widgets/resource_bar_item_test.dart`

Remove all `productionPerTurn:` params from Resource constructors and pass `production` to `ResourceBarItem` instead.

**Test `'renders amount text'`** (lines 23–33):
```dart
final resource = Resource(type: ResourceType.algae, amount: 100);
// ... createApp stays the same, production defaults to 0
```

**Test `'shows production rate when > 0'`** (lines 35–45):
```dart
final resource = Resource(type: ResourceType.coral, amount: 80);
await tester.pumpWidget(createApp(resource, production: 8));
```
Update `createApp` to accept optional `int production = 0`:
```dart
Widget createApp(Resource resource, {VoidCallback? onTap, int production = 0}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: ResourceBarItem(resource: resource, production: production, onTap: onTap),
    ),
  );
}
```

**Test `'hides production for pearl (rate = 0)'`** (lines 47–58):
```dart
final resource = Resource(type: ResourceType.pearl, amount: 5, maxStorage: 100);
// production defaults to 0 in createApp
```

**Test `'onTap callback fires'`** (lines 60–74):
```dart
final resource = Resource(type: ResourceType.energy, amount: 60);
await tester.pumpWidget(createApp(resource, production: 6, onTap: () => tapped = true));
```

### Step 2: Edit `test/presentation/widgets/resource_bar_test.dart`

`ResourceBar` now requires a `production` map. Update `createApp()`:

```dart
Widget createApp() {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: ResourceBar(resources: Game.defaultResources()),
    ),
  );
}
```

Since `Game.defaultResources()` no longer sets production, and `ResourceBar.production` defaults to `const {}`, production display is 0 for all. Tests only check amounts and divider — they still pass as-is except the `ResourceBar` constructor change (production defaults to `const {}`).

No test logic changes needed, only ensure it compiles with the updated `Game.defaultResources()`.

## Dependencies

- Task 02 (productionPerTurn removed from Resource)
- Task 04 (ResourceBarItem accepts `production`)
- Task 06 (ResourceBar accepts `production`)

## Test Plan

- `flutter test test/presentation/widgets/resource_bar_item_test.dart`
- `flutter test test/presentation/widgets/resource_bar_test.dart`
