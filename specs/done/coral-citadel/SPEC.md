# Coral Citadel - Feature Specification

## 1. Feature Overview

Cette feature introduit un nouveau bâtiment défensif d'endgame dans ABYSSES : la **Citadelle corallienne** (`BuildingType.coralCitadel`). C'est une forteresse massive construite en corail rose et renforcée d'acier abyssal, dont l'unique fonction est d'appliquer un multiplicateur de défense aux unités du joueur **lorsqu'elles défendent la base**.

Principes clés :
- **Bâtiment unique** : une seule Citadelle par base (comme le QG).
- **5 niveaux** : bonus multiplicateur DEF de ×1.20 à ×2.00 (+20% à +100%).
- **Défense uniquement** : le bonus s'applique exclusivement aux combats défensifs. Le système de combat défensif (attaque de base par IA/monstres) **n'est pas introduit dans cette feature** — il arrivera avec les factions ennemies. La Citadelle est donc constructible et visible dès maintenant mais son bonus reste dormant tant que le système d'attaque de base n'existe pas. Un message clair dans l'UI indique ce statut.
- **End-game** : coûts élevés en Corail, Minerai, Énergie **et Perles** dès le niveau 1, avec prérequis QG croissants (niv 3 pour débloquer la Citadelle niv 1, jusqu'à QG 10 pour niv 5).
- **Visible dans l'UI** : le bonus défensif courant doit être affiché dans le détail du bâtiment et dans le récapitulatif d'armée/QG.
- **Nouveau SVG détaillé** : forteresse fortifiée avec tourelles, piques coralliennes, hublots éclairés, emblème gravé, cristaux défensifs et algues-bannières, palette corail rose + bleu profond.

Cette feature étend :
- `BuildingType` avec un nouveau cas `coralCitadel`.
- `BuildingCostCalculator` (coûts, prérequis, niveau max).
- Le rendu de la base pour afficher le nouveau bâtiment et son bonus.
- L'asset pipeline avec un nouveau fichier SVG `assets/icons/buildings/coral_citadel.svg`.

## 2. User Stories

### US-1 : Construire la Citadelle corallienne

**En tant que** joueur ayant atteint un QG de niveau 3,
**je veux** pouvoir construire une Citadelle corallienne dans ma base,
**afin de** préparer la défense de ma base contre les futures menaces abyssales.

**Critères d'acceptation :**
- Un nouveau bâtiment **Citadelle corallienne** apparaît dans la liste des bâtiments constructibles.
- Le bâtiment est verrouillé tant que le QG n'a pas atteint le niveau 3 ; l'UI indique clairement le prérequis manquant.
- Une seule instance de la Citadelle peut exister dans la base : une fois construite, l'option de construction disparaît et la Citadelle apparaît parmi les bâtiments existants.
- Les coûts de construction du niveau 1 sont élevés et incluent des Perles :
  - Corail : 120
  - Minerai : 120
  - Énergie : 60
  - Perles : 5
- Les ressources sont débitées à la construction, comme pour les autres bâtiments.
- Construite, la Citadelle apparaît dans la vue de la base avec son SVG dédié.

### US-2 : Améliorer la Citadelle corallienne jusqu'au niveau 5

**En tant que** joueur,
**je veux** pouvoir améliorer ma Citadelle corallienne du niveau 1 jusqu'au niveau 5,
**afin d'augmenter** progressivement le bonus de défense de ma base.

**Critères d'acceptation :**
- Le niveau maximum de la Citadelle est **5**.
- Chaque niveau applique un multiplicateur sur la stat DEF des unités du joueur en défense :

  | Niveau | Bonus DEF      | Multiplicateur |
  |--------|----------------|----------------|
  | 1      | +20%           | ×1.20          |
  | 2      | +40%           | ×1.40          |
  | 3      | +60%           | ×1.60          |
  | 4      | +80%           | ×1.80          |
  | 5      | +100%          | ×2.00          |

- Chaque niveau a un prérequis de QG croissant :

  | Niveau cible | QG requis |
  |--------------|-----------|
  | 1            | 3         |
  | 2            | 5         |
  | 3            | 7         |
  | 4            | 9         |
  | 5            | 10        |

- Coûts d'amélioration (à compléter par la formule standard `n² + 1` pour les ressources classiques, valeurs fixes pour les Perles) :

  | Niveau | Corail | Minerai | Énergie | Perles |
  |--------|--------|---------|---------|--------|
  | 1 (construction) | 120 | 120 | 60  | 5  |
  | 2      | 240    | 240     | 120     | 10     |
  | 3      | 500    | 500     | 250     | 20     |
  | 4      | 850    | 850     | 425     | 35     |
  | 5      | 1300   | 1300    | 650     | 60     |

  > Rationale : les ressources suivent approximativement `base × (level² + 1)`, les Perles suivent une progression extrême (5, 10, 20, 35, 60 = total 130 perles pour atteindre le niveau max), ce qui en fait un vrai choix de fin de partie en concurrence avec les technologies avancées.
- Si le joueur n'a pas les ressources ou le prérequis QG, l'amélioration est désactivée avec un message clair (ressources manquantes, niveau de QG insuffisant).

### US-3 : Voir l'effet défensif dans l'interface

**En tant que** joueur,
**je veux** comprendre clairement quel est l'effet de ma Citadelle et qu'elle est prête à défendre la base,
**afin de** mesurer l'intérêt d'investir dans ses améliorations.

**Critères d'acceptation :**
- La fiche détaillée de la Citadelle (panneau/bottom sheet) affiche :
  - Son niveau actuel.
  - Le bonus DEF courant (ex. "+60% DEF en défense").
  - Le bonus du prochain niveau et son coût.
  - Une mention **"En attente du système d'attaque de base — effet dormant"** (ou équivalent visuel, p.ex. icône d'horloge ou texte grisé) tant que le système défensif n'est pas introduit. Le bonus est correctement stocké et calculable, mais aucune mécanique ne le consomme encore.
- La fiche détaillée du QG (ou le panneau d'armée de la base) affiche également le bonus défensif actif apporté par la Citadelle, de manière synthétique (ex. ligne "Bouclier de la base : +60%").
- Aucun changement visible en combat offensif : la stat DEF des unités reste inchangée quand le joueur envoie des unités attaquer une tanière.

### US-4 : Nouveau SVG de la Citadelle corallienne

**En tant que** joueur,
**je veux** voir un bâtiment visuellement impressionnant et cohérent avec l'univers abyssal,
**afin de** ressentir le poids et la valeur de ma Citadelle.

**Critères d'acceptation :**
- Un nouveau fichier `assets/icons/buildings/coral_citadel.svg` est créé, viewBox `0 0 64 64`, style cohérent avec les autres SVG du dossier (gradients, `stroke`, filtre `feGaussianBlur` pour glow doux).
- **Palette obligatoire** : corail rose (`#F48FB1` / `#EC407A` / `#AD1457`) + bleu profond (`#1A237E` / `#283593` / `#3949AB`) + accents blancs/ivoire pour les hublots et cristaux.
- Le SVG contient **tous** les éléments décoratifs suivants (composition unifiée, pas une liste d'icônes indépendantes) :
  1. **Forteresse centrale massive** (corps principal) en corail rose, forme trapézoïdale ou pentagonale large à la base, avec des blocs de pierre stylisés (lignes de stroke).
  2. **Tourelles d'angle crénelées** (minimum 2, idéalement 4) : colonnes en corail rose sortant au-dessus du corps principal, surmontées de créneaux carrés évoquant un rempart.
  3. **Piques coralliennes défensives** : 3 à 5 excroissances pointues sortant des côtés ou du sommet de la forteresse, suggérant un organisme vivant et hostile.
  4. **Emblème gravé central** : un blason stylisé (bouclier ou étoile de mer) au centre de la façade principale, en relief bleu profond sur corail rose.
  5. **Hublots éclairés** : 3 à 5 petites ouvertures rondes ou carrées sur le corps principal, fond sombre bleu nuit et halo clair (blanc/cyan pâle) suggérant des postes de garde lumineux.
  6. **Cristaux défensifs lumineux** : 2 à 4 petits cristaux incrustés dans les murs, utilisant un gradient bleu-cyan avec opacité partielle pour suggérer une lueur magique.
  7. **Algues-bannières** : 2 longues algues stylisées qui flottent verticalement de part et d'autre de la forteresse (ou accrochées aux tourelles), en dégradé vert sombre vers bleu, évoquant des bannières de forteresse.
- Le SVG ne dépasse pas le budget de complexité des autres SVG du dossier (≈5 Ko). Toute complexité excessive doit être simplifiée pour rester lisible à petite taille sur la carte de la base.
- Le bâtiment est reconnaissable en une demi-seconde : silhouette massive avec créneaux et un corps coloré rose sur fond bleu, différent du QG (dôme violet).
- Le SVG doit être fonctionnel à toutes les tailles utilisées par le jeu (icône de liste + tuile sur la base).

## 3. Testing and Validation

### Tests unitaires

- **`BuildingType`** : le nouveau cas `coralCitadel` est correctement sérialisé via Hive (nouveau `HiveField(7)`), et peut être désérialisé depuis une save existante sans casser les bâtiments précédents.
- **`BuildingCostCalculator`** :
  - `maxLevel(BuildingType.coralCitadel) == 5`.
  - `upgradeCost` retourne exactement les valeurs du tableau ci-dessus pour chaque niveau courant (0 → 4).
  - `upgradeCost` retourne `{}` au niveau 5.
  - `prerequisites` retourne `{headquarters: 3}` pour cible niv 1, puis 5, 7, 9, 10 pour niv 2→5.
  - `checkUpgrade` échoue si le QG est insuffisant, si les ressources sont insuffisantes, ou si les Perles sont insuffisantes, avec les champs `missingResources`/`missingPrerequisites` correctement remplis.
- **Unicité** : on ne peut pas construire deux Citadelles coralliennes dans la même base (règle métier vérifiée côté builder/action).
- **Calcul du bonus de défense** : un helper (p.ex. `CoralCitadelDefenseBonus.multiplier(level)`) retourne les multiplicateurs exacts (1.0 sans Citadelle, puis 1.2, 1.4, 1.6, 1.8, 2.0).
  - Niveau 0 (pas construit) → 1.0 (neutre).
  - Niveaux 1 à 5 → valeurs exactes.

### Tests d'intégration

- **Construction + amélioration dans le flux de tour complet** : partie de test où le joueur construit la Citadelle au tour N, l'améliore au tour N+k, et les ressources/Perles sont correctement débitées, les prérequis validés.
- **Persistance Hive** : sauvegarder une partie avec une Citadelle de niveau 3, recharger, vérifier que la Citadelle est bien présente avec son niveau.
- **Régression saves existantes** : une save créée avant l'ajout de `coralCitadel` doit toujours se charger sans exception (le bâtiment est simplement absent, le bonus est 1.0).

### Tests UI / widget

- **Affichage du bâtiment** dans la vue base : l'icône SVG est correctement rendue.
- **Fiche détaillée** : le bonus courant, le bonus du prochain niveau et le coût sont affichés correctement pour chaque niveau (0 → 5).
- **Mention "effet dormant"** : visible tant qu'aucun système d'attaque de base n'est actif.
- **Fiche QG** : le bonus apporté par la Citadelle est affiché correctement (ligne "Bouclier de la base : +X%" ou similaire).

### Vérifications qualité

- `flutter analyze` : zéro warning introduit par cette feature.
- `flutter test` : tous les tests (existants + nouveaux) passent.
- Aucun fichier ne dépasse **150 lignes** (règle projet).
- Tous les widgets utilisent le thème défini dans `lib/presentation/theme/`.
- Les couleurs utilisées dans le SVG respectent la palette imposée (pas de violet QG ni de vert barracks).
- Le SVG est validé visuellement à plusieurs tailles (petite icône, tuile de base).
