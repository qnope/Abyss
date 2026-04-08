# Improve Reveal Feature Specification

## 1. Feature Overview

Cette fonctionnalité corrige un défaut de la mécanique de révélation des cases
de la carte. Aujourd'hui, deux problèmes sont visibles pour le joueur :

1. **À l'initialisation d'une partie**, la base du joueur n'est pas au centre
   de la zone révélée : elle se trouve dans le coin inférieur gauche du carré
   révélé. Le joueur ne voit donc que les cases situées au-dessus et à droite
   de sa base, jamais celles à gauche ou en dessous.
2. **Lors de l'envoi d'un explorateur**, la zone révélée autour de la cible
   n'est pas un carré complet centré sur l'explorateur. Comme pour la base,
   seules les cases du haut et de droite sont révélées pour les niveaux à
   taille paire (2x2, 4x4).

L'objectif est que la zone révélée soit **toujours un carré complet centré sur
la cible** (la base à l'initialisation, ou la case visée par l'explorateur).
Pour garantir un centrage parfait, toutes les tailles de zones révélées
deviennent **impaires**.

La zone initiale autour de la base sera élargie à **5x5** pour mieux orienter
le joueur dès le démarrage de la partie.

## 2. User Stories

### US1 — Vision symétrique autour de la base au démarrage

**En tant que** joueur démarrant une nouvelle partie,
**je veux** voir la zone autour de ma base de manière symétrique,
**afin de** pouvoir m'orienter dans toutes les directions dès le début.

**Critères d'acceptation :**
- À la création d'un nouveau joueur avec une base, un carré de 5x5 cases
  centré sur la base est révélé.
- La base est exactement au centre de cette zone : il y a 2 cases révélées
  à gauche, 2 à droite, 2 au-dessus et 2 en dessous de la base.
- Si la base est proche d'un bord de la carte, la zone est tronquée
  naturellement (les cases hors carte ne sont pas ajoutées) — aucun décalage
  n'est appliqué.

### US2 — Révélation symétrique autour d'un explorateur

**En tant que** joueur envoyant un explorateur sur une case,
**je veux** que la zone révélée soit un carré complet centré sur la cible,
**afin de** découvrir équitablement les cases dans toutes les directions
autour du point exploré.

**Critères d'acceptation :**
- Quel que soit le niveau de l'explorateur, la zone révélée est un carré
  d'une taille impaire centré sur la case cible.
- Le nombre de cases révélées dans chaque direction (haut, bas, gauche,
  droite) à partir de la cible est identique.
- Si la zone déborde de la carte, les cases hors carte sont ignorées
  (comportement actuel conservé).
- Les cases déjà révélées ne sont pas comptées comme nouvellement
  découvertes.

### US3 — Progression des niveaux d'explorateur

**En tant que** joueur progressant dans la branche technologique des
explorateurs, **je veux** que chaque niveau augmente la taille de la zone
révélée de manière cohérente,
**afin de** ressentir une progression claire sans casse de mécanique.

**Critères d'acceptation :**
- Les tailles de zones révélées par niveau d'explorateur sont :

  | Niveau | Taille du carré | Cases révélées (max) |
  |--------|------------------|----------------------|
  | 0      | 3x3              | 9                    |
  | 1      | 3x3              | 9                    |
  | 2      | 5x5              | 25                   |
  | 3      | 5x5              | 25                   |
  | 4      | 7x7              | 49                   |
  | 5      | 9x9              | 81                   |

- Toutes les tailles sont impaires : la cible est toujours exactement au
  centre du carré révélé.
- Aucun niveau ne révèle une zone asymétrique.

## 3. Testing and Validation

### Tests unitaires
- `RevealAreaCalculator.squareSideForLevel` : un test par niveau (0 à 5 et
  niveau hors plage) vérifiant la nouvelle progression (3, 3, 5, 5, 7, 9).
- `RevealAreaCalculator.cellsToReveal` :
  - Carré 3x3 centré sur (5,5) : 9 cases attendues, de (4,4) à (6,6).
  - Carré 5x5 centré sur (10,10) : 25 cases attendues, de (8,8) à (12,12).
  - Carré 7x7 et 9x9 centrés : nombres et bornes correctes.
  - Centrage strict : pour chaque taille impaire, vérifier qu'il y a autant
    de cases à gauche/droite et au-dessus/en-dessous de la cible.
- Bords de carte :
  - Cible en (0,0) niveau 0 : seulement 4 cases révélées (le quart bas-gauche).
  - Cible sur un bord (par ex. (19,10) niveau 1) : nombre attendu correct.
  - Cible dans un coin opposé : zone correctement tronquée sans débordement.
- Initialisation du joueur :
  - `Player.withBase` révèle un carré 5x5 centré sur la base.
  - Vérifier que la base est bien au centre des cases révélées.
  - Vérifier la troncature naturelle si la base est proche d'un bord.

### Tests d'intégration
- `ExplorationResolver.resolve` : envoyer un explorateur de chaque niveau et
  vérifier que les cases révélées correspondent au nouveau calcul (carré
  centré, taille impaire).
- Vérifier que `Player.addRevealedCell` ne duplique pas les cases déjà
  connues lorsqu'un explorateur est envoyé sur une zone partiellement
  révélée.

### Tests de non-régression
- Mettre à jour les tests existants `reveal_area_calculator_cells_test.dart`
  et `reveal_area_calculator_side_test.dart` pour refléter les nouvelles
  tailles et le centrage strict.
- Mettre à jour `player_test.dart` et `exploration_resolver_test.dart` pour
  les nouvelles tailles attendues à l'initialisation et lors d'une
  exploration.

### Critères de succès
- `flutter analyze` ne renvoie aucune erreur ni warning.
- `flutter test` passe à 100 %.
- En lançant l'application, la base est visuellement au centre de la zone
  révélée à l'initialisation.
- En envoyant un explorateur, la zone révélée est visuellement un carré
  symétrique centré sur la cible.
