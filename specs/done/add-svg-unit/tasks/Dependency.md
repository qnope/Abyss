# Dépendances — add-svg-unit

## Vue d'ensemble

Les 6 tâches sont **totalement indépendantes** les unes des autres. Chaque tâche crée un fichier SVG autonome dans `assets/icons/units/`. Elles peuvent être exécutées dans n'importe quel ordre ou en parallèle.

## Graphe de dépendances

```
Task 01 (scout.svg)         ──┐
Task 02 (harpoonist.svg)    ──┤
Task 03 (guardian.svg)      ──┤── Aucune dépendance entre elles
Task 04 (dome_breaker.svg)  ──┤
Task 05 (siphoner.svg)      ──┤
Task 06 (saboteur.svg)      ──┘
```

## Dépendance externe

- Toutes les tâches nécessitent la création du répertoire `assets/icons/units/` (fait par la première tâche exécutée).

## Prérequis communs

- Référence de style : `assets/icons/buildings/ore_extractor.svg` (le SVG existant le plus détaillé).
- Spécification visuelle : `Unite.md` et `specs/projects/add-svg-unit/SPEC.md`.
