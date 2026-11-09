# presentation/ui

The 2D interface: `Control` scenes and their scripts (resource bar, cards,
menus, sheets, dialogs), and the shared theme.

Depends on `domain/` to read the state it shows and to call the rules on the
player's actions. Never on `data/`, `app/` or `presentation/world/`.
