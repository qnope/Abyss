# Game / Player Decoupling - Feature Specification

## 1. Feature Overview

Aujourd'hui, l'objet `Game` contient directement l'ensemble de l'état du joueur humain : ressources, bâtiments, unités, technologies, explorations en cours. L'objet `Player` ne contient que le nom. Cette structure rend impossible l'ajout de joueurs supplémentaires (factions IA) prévus par `ABYSS.md` (US-08 : 99 factions IA).

Ce projet est un **refactoring structurel uniquement** : il déplace l'état par-joueur depuis `Game` vers `Player`, isole le fog of war par joueur, et ajoute la notion de "collecté par" aux contenus partagés de la carte (trésors, ruines, monstres).

Aucun comportement IA n'est introduit dans ce projet. Après ce refactoring, le jeu reste fonctionnellement identique du point de vue de l'utilisateur : un seul joueur humain, mais la structure supporte jusqu'à 99 joueurs supplémentaires pour un futur projet.

Les sauvegardes Hive existantes sont **cassées** volontairement : le jeu est en développement, on repart à zéro.

### Règles de haut niveau

- Chaque `Player` possède son propre état privé : ressources, unités, bâtiments, technologies, explorations en cours, cases révélées, position de base.
- Chaque `Player` a un `UUID` (identifiant unique) et un `name`. L'UUID est la clef primaire pour retrouver un joueur.
- Les trésors, ruines et monstres sont **partagés** sur la carte : il n'existe qu'une instance par case. Dès qu'un joueur collecte un contenu, plus aucun autre joueur ne peut le collecter et il apparaît "grisé" dans l'UI de tous les autres joueurs (quand ils révèlent la case).
- Le fog of war est **privé** : le joueur humain ne voit pas les cases révélées par les IA, et inversement.
- Pour l'instant, `Game` n'instancie qu'**un seul** `Player` humain. Aucun `Player` IA n'est créé par défaut — la structure le permettra, c'est tout.

## 2. User Stories

### US-01 — Chaque joueur a son propre fog of war

**En tant que** joueur,
**je veux** que la carte n'affiche que les cases que *j'ai* révélées,
**afin que** les explorations des autres joueurs, humain ou non, est gardé secrète.

**Critères d'acceptation :**
- Au démarrage, les cases révélées du joueur correspondent à la zone de vision initiale autour de sa base (comportement actuel).
- Si un joueur révèle une case, cette case **n'apparaît pas** pour les autres joueurs.
- L'écran `MapScreen` (et `MapGridWidget`) consomme les cases révélées d'un joueur. Cela permettra de débuguer les IA facilement juste en changeant de joueur.
- Tous les tests existants du fog of war continuent à passer avec un joueur.

### US-02 — Chaque joueur a ses propres ressources

**En tant que** système de jeu,
**je veux** que chaque joueur ait sa propre réserve des 5 ressources (algues, corail, minerai, énergie, perles),
**afin que** les ressources d'un joueur ne puissent jamais être consommées ou lues par un autre.

**Critères d'acceptation :**
- `Player` possède `Map<ResourceType, Resource> resources`.
- `Game` ne possède plus de champ `resources`.
- Toutes les actions qui consomment ou produisent des ressources (construction, recrutement, recherche, collecte de trésor) lisent/écrivent sur le `Player` passé en paramètre.
- La barre de ressources (`ResourceBar`) affiche les ressources du joueur humain (`game.humanPlayer`).

### US-03 — Chaque joueur a ses propres unités

**En tant que** système de jeu,
**je veux** que chaque joueur ait sa propre liste d'unités et de types d'unités recrutées,
**afin que** les armées des joueurs soient strictement séparées.

**Critères d'acceptation :**
- `Player` possède `Map<UnitType, Unit> units` et `List<UnitType> recruitedUnitTypes`.
- `Game` ne possède plus ces champs.
- Toutes les actions de recrutement ciblent le `Player` concerné.
- Les écrans "Unités" et "Caserne" affichent les unités du joueur humain.

### US-04 — Chaque joueur a ses propres bâtiments et technologies

**En tant que** système de jeu,
**je veux** que chaque joueur ait ses propres bâtiments et son propre arbre technologique,
**afin que** les progrès de construction et de recherche d'un joueur n'influencent pas les autres.

**Critères d'acceptation :**
- `Player` possède `Map<BuildingType, Building> buildings` et `Map<TechBranch, TechBranchState> techBranches`.
- `Game` ne possède plus ces champs.
- Les écrans "Bâtiments", "Laboratoire" et "QG" affichent l'état du joueur humain.

### US-05 — Chaque joueur a ses propres explorations en cours

**En tant que** système de jeu,
**je veux** que chaque joueur ait sa propre file d'explorations en cours,
**afin que** la résolution d'un tour applique les explorations au fog of war du bon joueur.

**Critères d'acceptation :**
- `Player` possède `List<ExplorationOrder> pendingExplorations`.
- `Game` ne possède plus ce champ.
- La résolution de tour itère sur chaque joueur et résout ses explorations dans son propre `revealedCells`.

### US-06 — Chaque joueur a ses propres cases révélées (fog of war privé)

**En tant que** joueur,
**je veux** que chaque joueur ait sa propre vue du fog of war,
**afin qu'**un joueur ne voie jamais les cases révélées par les autres.

**Critères d'acceptation :**
- `Player` possède `Set<GridPosition> revealedCells` (ou équivalent persistable).
- `MapCell` **n'a plus** de champ `isRevealed` — le champ est supprimé.
- Le calculateur de zone de vision initiale (`RevealAreaCalculator`) remplit `revealedCells` du joueur au démarrage.
- La résolution d'une exploration ajoute les nouvelles positions à `revealedCells` du joueur qui a commandé l'exploration.

### US-07 — Chaque joueur a sa propre position de base

**En tant que** joueur,
**je veux** que chaque joueur ait sa propre position de base sur la carte,
**afin que** la carte puisse afficher simultanément la base du joueur humain et, plus tard, celles des factions IA.

**Critères d'acceptation :**
- `Player` possède `baseX` et `baseY`.
- `GameMap` **n'a plus** de champs `playerBaseX` / `playerBaseY` — ils sont supprimés.
- Le générateur de carte (`MapGenerator`) place la base du joueur humain puis stocke les coordonnées dans son `Player`.
- L'UI de la carte parcourt les joueurs et dessine une base à la position de chacun (pour l'instant, seul le joueur humain est affiché puisqu'il est le seul).

### US-08 — Les contenus collectibles sont partagés, mais "qui les a collectés" est traçable

**En tant que** système de jeu,
**je veux** qu'un trésor, une ruine ou un monstre ne puisse être collecté qu'**une seule fois, par un seul joueur**, et apparaisse "grisé" pour tous les autres,
**afin de** préserver la cohérence du monde partagé.

**Critères d'acceptation :**
- `MapCell` remplace son champ booléen `isCollected` par `String? collectedBy`.
  - `null` ⇒ la case n'a pas encore été collectée.
  - non-null ⇒ UUID du joueur qui l'a collectée.
- Helper en lecture : `bool get isCollected => collectedBy != null`.
- Une action `CollectTreasureAction` (et futures actions de collecte) refuse de s'exécuter si `collectedBy != null`.
- Lors d'une collecte réussie, `collectedBy` est renseigné avec l'UUID du `Player` exécutant.
- L'UI affiche un état "grisé" lorsqu'une case est révélée par le joueur humain **et** que `collectedBy != null` **et** que le collecteur n'est pas le joueur humain lui-même.
- Si c'est le joueur humain qui a collecté, le comportement visuel actuel est conservé.

### US-09 — Les actions connaissent le joueur qui les exécute

**En tant que** développeur,
**je veux** que chaque `Action` reçoive explicitement le `Player` qui l'exécute,
**afin de** pouvoir faire agir plus tard des joueurs IA sans duplication de logique.

**Critères d'acceptation :**
- La signature d'exécution des actions existantes est mise à jour pour recevoir un `Player` (ou un contexte qui contient le `Player`).
- Aucune action ne lit plus directement `game.resources`, `game.units`, etc. — elles passent par le `Player`.
- Les appels actuels depuis l'UI passent `game.humanPlayer`.

### US-10 — `Game` devient un conteneur multi-joueurs

**En tant que** développeur,
**je veux** que `Game` soit un conteneur de joueurs plutôt qu'un conteneur d'état de joueur,
**afin de** pouvoir ajouter des joueurs IA sans modifier la structure.

**Critères d'acceptation :**
- `Game` contient :
  - `Map<String, Player> players` indexé par UUID
  - `String humanPlayerId`
  - `int turn`
  - `DateTime createdAt`
  - `GameMap? gameMap`
- `Game.humanPlayer` est un getter qui retourne `players[humanPlayerId]!`.
- `Game` **n'a plus** de champs `resources`, `buildings`, `techBranches`, `units`, `recruitedUnitTypes`, `pendingExplorations`.
- Au démarrage d'une nouvelle partie, `Game` est construit avec un seul `Player` humain (UUID généré, nom par défaut ou fourni par l'utilisateur).
- Les 99 joueurs IA **ne sont pas** instanciés dans ce projet.

### US-11 — Les sauvegardes existantes sont cassées (intentionnellement)

**En tant que** développeur,
**je veux** supprimer les sauvegardes Hive existantes lors de cette migration,
**afin de** garder le code de persistance simple.

**Critères d'acceptation :**
- Aucun code de migration n'est écrit.
- Les `HiveField` sont réassignés sans souci de rétrocompatibilité.
- Une note est ajoutée au `README.md` (ou équivalent) indiquant que les sauvegardes antérieures à ce projet doivent être supprimées manuellement.
- Les adapters `.g.dart` sont régénérés via `build_runner`.

## 3. Testing and Validation

### Tests unitaires (domain, pur Dart)

- **Player**
  - Construction avec UUID + nom → état par défaut correct (ressources, unités, bâtiments, tech, revealedCells vide, pendingExplorations vide).
  - Deux joueurs construits indépendamment ont des UUID différents et des états isolés (modifier l'un ne modifie pas l'autre).
- **Game**
  - Construction avec un seul joueur humain → `humanPlayer` retourne ce joueur.
  - `Game.players` est indexé par UUID.
  - Aucun champ d'état par-joueur n'existe plus sur `Game` (vérification par absence de champ).
- **MapCell**
  - `collectedBy` par défaut `null`, helper `isCollected` retourne `false`.
  - Affectation de `collectedBy` → `isCollected` retourne `true`.
- **Actions**
  - `CollectTreasureAction` exécutée sur un `Player` crédite ses ressources et renseigne `collectedBy` avec son UUID.
  - `CollectTreasureAction` échoue si `collectedBy != null`, quel que soit le joueur appelant.
  - Les actions de construction/recrutement/recherche lisent et modifient le bon `Player`.
- **Exploration**
  - Résolution d'une `ExplorationOrder` ajoute les positions à `player.revealedCells` du joueur qui l'a commandée.
  - Un second joueur fictif n'a pas ces positions dans son `revealedCells`.
- **Reveal area initial**
  - La zone de vision initiale autour de la base est bien placée dans `player.revealedCells` et non plus sur `MapCell.isRevealed`.

### Tests d'intégration (data + domain)

- Sauvegarde puis chargement d'un `Game` avec un `Player` → état identique après round-trip Hive.
- Les adapters `.g.dart` générés compilent sans erreur.

### Tests de présentation

- `MapGridWidget` (ou équivalent) affiche une cellule comme fog quand elle n'est pas dans `humanPlayer.revealedCells`.
- `MapGridWidget` affiche une cellule révélée comme "grisée" quand `collectedBy != null` et que le collecteur n'est pas le joueur humain.
- `ResourceBar` affiche les ressources de `game.humanPlayer`.
- Les écrans existants (QG, Bâtiments, Unités, Laboratoire) continuent de fonctionner en lisant `game.humanPlayer`.

### Critères de succès global

- `flutter analyze` ne renvoie aucune erreur ni warning sur le code modifié.
- `flutter test` passe intégralement.
- Le jeu est jouable de bout en bout avec un seul joueur humain (parcours : nouvelle partie → exploration → collecte d'un trésor → construction → fin de tour) sans régression visible.
- Aucun fichier de domain ou presentation ne dépasse 150 lignes après refactoring (règle projet).
- L'architecture 5 couches est préservée ; `specs/architecture/domain/game/` est mis à jour pour refléter la nouvelle responsabilité de `Player` et `Game`.
