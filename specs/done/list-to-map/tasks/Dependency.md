# Task Dependencies

```
01 Game domain model
├── 02 Game tests
├── 03 BuildingCostCalculator
│   └── 04 BuildingCostCalculator tests
└── 05 Presentation widgets
    └── 06 Widget tests
        └── 07 Final validation
```

- **Task 01** has no dependencies (foundation).
- **Tasks 02, 03, 05** depend on Task 01.
- **Task 04** depends on Task 03.
- **Task 06** depends on Task 05.
- **Task 07** depends on all previous tasks.
