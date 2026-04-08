# Begin Fight - Task Dependency Graph

## Visual order

```
01 MonsterLair model
   |
   v
02 ContentPlacer rolls unit count
   |
   |    03 MonsterUnitStats
   |    04 Combatant + CombatSide
   |    05 DamageCalculator
   |    06 CritRoller
   |    07 TargetPicker + TurnOrder
   |    08 FightTurnSummary + FightResult
   |       (depends on 04)
   |    09 FightEngine
   |       (depends on 04, 05, 06, 07, 08)
   |    10 LootCalculator
   |    11 CasualtyCalculator + CasualtySplit
   |       (depends on 04)
   |    12 CombatantBuilder
   |       (depends on 01, 03, 04)
   |
   v
13 FightMonsterResult
   (depends on 08)
   |
   v
14 FightMonsterAction
   (depends on 01, 02, 09, 10, 11, 12, 13, ActionType)
   |
   v
15 MonsterLairSheet update
   (depends on 01, 03)
   |
   |   16 UnitQuantityRow widget
   |   17 MonsterPreview widget    (depends on 01, 03)
   |   19 FightTurnList widget     (depends on 08)
   |
   v
18 ArmySelectionScreen
   (depends on 12, 14, 16, 17, 20)
   |
   v
20 FightSummaryScreen
   (depends on 13, 17, 19)
   |
   v
21 Wire game_screen_map_actions
   (depends on 15, 18)
   |
   v
22 Integration tests
   (depends on 14, 21)
   |
   v
23 Update architecture docs
   (depends on every previous task)
```

## Dependency table

| Task | Depends on |
|------|------------|
| 01 Monster lair model | (none) |
| 02 ContentPlacer rolls unit count | 01 |
| 03 MonsterUnitStats | (none) |
| 04 Combatant + CombatSide | (none) |
| 05 DamageCalculator | (none) |
| 06 CritRoller | (none) |
| 07 TargetPicker + TurnOrder | 04 |
| 08 FightTurnSummary + FightResult | 04 |
| 09 FightEngine | 04, 05, 06, 07, 08 |
| 10 LootCalculator | (none, only `MonsterDifficulty`) |
| 11 CasualtyCalculator + CasualtySplit | 04 |
| 12 CombatantBuilder | 01, 03, 04 |
| 13 FightMonsterResult | 08 |
| 14 FightMonsterAction | 01, 02, 09, 10, 11, 12, 13 |
| 15 MonsterLairSheet update | 01, 03 |
| 16 UnitQuantityRow widget | (none) |
| 17 MonsterPreview widget | 01, 03 |
| 18 ArmySelectionScreen | 12, 14, 16, 17, 20 |
| 19 FightTurnList widget | 08 |
| 20 FightSummaryScreen | 13, 17, 19 |
| 21 Wire game_screen_map_actions | 15, 18 |
| 22 Integration tests | 14, 21 |
| 23 Update architecture docs | every previous task |

## Suggested execution order

A linear sequence that respects every dependency:

1. **01** Monster lair model
2. **02** ContentPlacer rolls unit count
3. **03** MonsterUnitStats
4. **04** Combatant + CombatSide
5. **05** DamageCalculator
6. **06** CritRoller
7. **07** TargetPicker + TurnOrder
8. **08** FightTurnSummary + FightResult
9. **09** FightEngine
10. **10** LootCalculator
11. **11** CasualtyCalculator + CasualtySplit
12. **12** CombatantBuilder
13. **13** FightMonsterResult
14. **14** FightMonsterAction
15. **16** UnitQuantityRow widget
16. **17** MonsterPreview widget
17. **19** FightTurnList widget
18. **20** FightSummaryScreen
19. **15** MonsterLairSheet update
20. **18** ArmySelectionScreen
21. **21** Wire game_screen_map_actions
22. **22** Integration tests
23. **23** Update architecture docs

## Parallelization opportunities

After **01** is done, these can be tackled in parallel by different
sessions/developers:

- **02** (content placer) is isolated from the engine pipeline.
- **03**, **04**, **05**, **06**, **10** are all leaf tasks with no
  internal dependencies and can land in any order.
- **16** (UnitQuantityRow) is a leaf widget independent of every
  domain task, except that **01** is what supplies the lair model
  it eventually pairs with.

External dependencies (Hive code generation) only matter for tasks
that touch persisted types: **01** triggers a `build_runner` cycle.
