# Task 6: Add volcanic kernel guardians to `GuardianFactory`

## Summary

Add a `forVolcanicKernel()` factory method that creates the boss and minions guarding the volcanic kernel, stronger than cheminee guardians.

## Implementation Steps

### 1. Edit `lib/domain/fight/guardian_factory.dart`

Add new static method:

```dart
static List<Combatant> forVolcanicKernel() => [
  Combatant(
    side: CombatSide.monster,
    typeKey: 'seigneurNoyau',
    maxHp: 350,
    atk: 35,
    def: 20,
    isBoss: true,
  ),
  ...List.generate(
    10,
    (_) => Combatant(
      side: CombatSide.monster,
      typeKey: 'sentinelleNoyau',
      maxHp: 80,
      atk: 18,
      def: 12,
    ),
  ),
];
```

Guardian composition:
- **Boss** "Seigneur du Noyau": 350 HP, 35 ATK, 20 DEF (`isBoss: true`)
  - Stronger than Titan Volcanique (200 HP, 25 ATK, 15 DEF)
- **Minions** 10x "Sentinelle du Noyau": 80 HP, 18 ATK, 12 DEF
  - Stronger than Golems de Magma (50 HP, 12 ATK, 8 DEF)

Total guardian HP: 350 + 10*80 = 1150 (vs cheminee's 200 + 8*50 = 600)

## Dependencies

- None (uses existing `Combatant`, `CombatSide`)

## Test Plan

- **File**: `test/domain/fight/guardian_factory_test.dart` (add test group)
- Test: `forVolcanicKernel()` returns 11 combatants (1 boss + 10 minions)
- Test: exactly 1 combatant has `isBoss == true`
- Test: boss has typeKey `seigneurNoyau`, HP 350, ATK 35, DEF 20
- Test: all minions have typeKey `sentinelleNoyau`, HP 80, ATK 18, DEF 12
- Test: boss stats are strictly greater than Titan Volcanique (200, 25, 15)
- Test: minion stats are strictly greater than Golem de Magma (50, 12, 8)

## Notes

- The `forType()` switch is NOT updated here since the volcanic kernel is not a `TransitionBaseType`. The `AttackVolcanicKernelAction` (task 11) will call `forVolcanicKernel()` directly.
