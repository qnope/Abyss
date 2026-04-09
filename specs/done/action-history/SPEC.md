# Action History - Feature Specification

## 1. Feature Overview

Cette feature introduit un **système d'historique** qui enregistre les actions du joueur et les événements marquants d'une partie. Le joueur peut consulter cet historique depuis le menu Paramètres (même menu que la sauvegarde) et revoir notamment les **détails d'un combat** en tapant sur l'entrée correspondante.

Principes clés :

- **Chaque action joueur génère une entrée** : construction/upgrade de bâtiment, déblocage de branche tech, recherche tech, recrutement d'unité, exploration de case, collecte de trésor/ruines, combat contre une tanière.
- **Chaque fin de tour génère une entrée de résumé** (une seule ligne par tour, récapitulant la production et les événements de fin de tour).
- **Persistance** : l'historique est sauvegardé via **Hive** avec la partie, et survit aux cycles sauvegarde/chargement.
- **Limite** : les **100 dernières entrées** sont conservées (les plus anciennes sont supprimées automatiquement en dépassement — FIFO).
- **Affichage** : liste chronologique plate (plus récent en haut), sous forme de **Cards colorées par catégorie** (combat, construction, recherche, recrutement, exploration, collecte, fin de tour).
- **Filtres par catégorie** en tête de liste : Tous / Combats / Construction / Recherche / Autres.
- **Tap uniquement sur les combats** : seuls les entrées de type combat sont tappables et ouvrent un détail. Les autres entrées sont purement informatives.
- **Détail d'un combat** : réutilise le `FightSummaryDialog` existant et affiche le résultat, la composition engagée côté joueur, la composition adverse, les pertes (intacts/blessés/morts), le nombre de tours de combat, et le butin obtenu.
- **Accès UI** : via le dialogue `Parametres` actuel (qui contient déjà `Sauvegarder et quitter`), en y ajoutant un bouton **`Voir l'historique`**.
- **Compatibilité savegame** : charger une ancienne sauvegarde sans champ `history` démarre avec un historique vide ; les actions suivantes viendront le peupler.

Cette feature est transverse : chaque `Action` existante doit produire une entrée d'historique lorsque son exécution réussit, de même que le `TurnResolver` pour la fin de tour.

## 2. User Stories

### US-1 : Consulter l'historique depuis le menu Paramètres

**En tant que** joueur,
**je veux** ouvrir l'historique de mes actions depuis le menu Paramètres accessible depuis la barre inférieure du jeu,
**afin de** consulter ce que j'ai fait récemment sans quitter la partie.

**Critères d'acceptation :**
- Le dialogue `Parametres` actuel (`settings_dialog.dart`) affiche, en plus du bouton `Sauvegarder et quitter`, un nouveau bouton **`Voir l'historique`**.
- Cliquer sur `Voir l'historique` ouvre l'écran (ou sheet) **`HistoryScreen`** qui affiche la liste des entrées du joueur humain, du plus récent au plus ancien.
- Un bouton **`Retour`** (ou `Fermer`) ferme cet écran et revient au jeu sans modifier l'état.
- Si l'historique est vide, un message `Aucune action enregistrée pour l'instant.` est affiché.

### US-2 : Voir chaque action enregistrée sous forme de Card colorée

**En tant que** joueur,
**je veux** voir mes actions sous forme de cartes visuellement distinctes selon leur type,
**afin de** repérer rapidement le type d'événement qui m'intéresse.

**Critères d'acceptation :**
- Chaque entrée est affichée comme une **`Card`** qui contient au minimum :
  - Une **icône** représentant le type d'action (ex : épée pour combat, marteau pour construction, livre pour recherche, etc.).
  - Un **titre** court décrivant l'action (ex : `Victoire vs Tanière niv 2`, `Caserne améliorée au niv 3`, `Recherche Métallurgie terminée`).
  - Une **ligne secondaire** facultative avec un détail (ex : butin, coût, unités recrutées).
  - Le **numéro de tour** auquel l'action s'est produite, affiché de manière lisible.
- La **couleur de fond / d'accent** de la Card dépend de la catégorie :
  - Combat (victoire : vert / défaite : rouge), Construction, Recherche, Recrutement, Exploration, Collecte, Fin de tour.
- Les couleurs utilisées proviennent du thème (`lib/presentation/theme/`).

### US-3 : Filtrer l'historique par catégorie

**En tant que** joueur,
**je veux** pouvoir filtrer les entrées de l'historique par grande catégorie,
**afin de** retrouver rapidement un certain type d'événement.

**Critères d'acceptation :**
- En tête de l'écran historique, une rangée de chips/boutons de filtre permet de sélectionner : **Tous** / **Combats** / **Construction** / **Recherche** / **Autres**.
- Le filtre `Tous` est sélectionné par défaut à l'ouverture.
- Sélectionner un filtre met à jour la liste en n'affichant que les entrées correspondantes.
- Le filtre `Autres` regroupe : recrutement, exploration, collecte, fin de tour.
- Changer de filtre ne modifie pas l'historique lui-même, seulement l'affichage.
- Le filtre courant est réinitialisé à `Tous` à chaque réouverture de l'écran.

### US-4 : Taper sur une entrée de combat pour revoir les détails

**En tant que** joueur,
**je veux** pouvoir taper sur une entrée de combat dans l'historique et revoir l'intégralité du résumé de ce combat,
**afin de** comprendre mes victoires / défaites et ajuster ma stratégie.

**Critères d'acceptation :**
- Les entrées de catégorie **Combat** sont visuellement tappables (ex : léger effet d'inkwell / chevron à droite).
- Taper sur une entrée de combat ouvre un **`FightSummaryDialog`** (le même composant que celui affiché à la fin d'un combat) avec l'intégralité des données du combat :
  - Résultat (Victoire / Défaite).
  - Nombre de tours de combat.
  - Composition engagée côté joueur (types et quantités envoyées).
  - Composition du monstre affronté (type et quantité d'unités monstres, niveau).
  - Pertes côté joueur : survivants intacts / blessés / morts définitivement, par type.
  - Butin obtenu (ressources et perles) en cas de victoire.
- Fermer ce dialogue revient à l'écran d'historique sans modifier l'état du jeu ni rejouer de combat.
- Les entrées des autres catégories (construction, recherche, recrutement, exploration, collecte, fin de tour) **ne sont pas tappables** : elles sont purement informatives.

### US-5 : Enregistrer automatiquement chaque action du joueur

**En tant que** joueur,
**je veux** que chaque action que j'effectue génère automatiquement une entrée dans l'historique,
**afin de** ne rien avoir à faire manuellement pour suivre ma progression.

**Critères d'acceptation :**
- Lorsqu'une `Action` (cf. `lib/domain/action/action.dart`) est exécutée **avec succès**, une entrée est ajoutée à l'historique du joueur humain :
  - `upgradeBuilding` → entrée `Construction` avec nom du bâtiment + nouveau niveau.
  - `unlockBranch` → entrée `Recherche` avec nom de la branche débloquée.
  - `researchTech` → entrée `Recherche` avec nom du nœud de tech + branche.
  - `recruitUnit` → entrée `Recrutement` avec type et quantité d'unités recrutées.
  - `explore` → entrée `Exploration` avec la case/zone explorée.
  - `collectTreasure` → entrée `Collecte` avec ressources récupérées.
  - `fightMonster` → entrée `Combat` avec résultat + détails complets (cf. US-4).
- Une action **qui échoue à la validation** (`ActionResult` d'erreur) **ne crée pas** d'entrée d'historique.
- Chaque entrée d'historique enregistre le **numéro de tour courant** (`game.turn`) au moment de l'action.
- À la fin d'un tour (`TurnResolver.resolve`), **une seule entrée de type `Fin de tour`** est ajoutée, récapitulant :
  - Le numéro du tour qui se termine.
  - La production nette (par ressource) du tour.
  - Les événements marquants du tour (ex : bâtiments désactivés, unités perdues faute d'entretien), sous forme de texte résumé.

### US-6 : Limiter l'historique à 100 entrées (FIFO)

**En tant que** joueur,
**je veux** que la taille de l'historique reste bornée,
**afin de** ne pas faire grossir indéfiniment ma sauvegarde.

**Critères d'acceptation :**
- L'historique conserve au maximum les **100 dernières entrées**.
- Lorsqu'une 101ème entrée est ajoutée, la plus ancienne (la 1ère de la file) est supprimée automatiquement (comportement FIFO).
- La suppression automatique ne déclenche pas de notification dans l'UI.
- Cette limite est une constante claire du domaine (`kHistoryMaxEntries = 100`).

### US-7 : Persister l'historique dans la sauvegarde

**En tant que** joueur,
**je veux** que mon historique survive à un cycle sauvegarde/chargement,
**afin de** retrouver mes combats et événements passés après avoir relancé le jeu.

**Critères d'acceptation :**
- L'historique fait partie intégrante de l'objet `Player` (ou `Game`, selon l'architecture choisie) et est sérialisé via **Hive** au moment de la sauvegarde.
- Après un cycle `save` + `load`, l'historique est identique à ce qu'il était avant la sauvegarde.
- Charger une **ancienne sauvegarde** qui ne contient pas encore de champ `history` doit réussir : l'historique est alors initialisé à une liste vide, et les actions suivantes commencent à le remplir normalement.
- Les `TypeAdapter` Hive existants sont mis à jour ou complétés pour inclure les nouvelles structures (entrées d'historique, détails de combat).

### US-8 : Réutiliser le FightSummaryDialog pour l'affichage du détail de combat

**En tant que** développeur,
**je veux** que le détail de combat affiché depuis l'historique utilise exactement le même composant `FightSummaryDialog` que celui affiché à la fin d'un combat,
**afin de** garantir une cohérence visuelle et éviter la duplication de code.

**Critères d'acceptation :**
- Le widget `FightSummaryDialog` (ou équivalent) existant est rendu réutilisable : il prend en entrée un objet `FightSummary` (ou similaire) contenant toutes les données nécessaires, sans dépendance à une exécution de combat en cours.
- L'entrée d'historique de type combat stocke un `FightSummary` complet (toutes les données requises par le dialogue).
- Aucun combat n'est rejoué/recalculé lors de l'affichage depuis l'historique : on relit simplement les données sauvegardées.

## 3. Testing and Validation

### Tests unitaires (domain)

- **Ajout d'entrée** : vérifier qu'après exécution réussie d'une action (upgradeBuilding, researchTech, recruitUnit, explore, collectTreasure, fightMonster), une entrée est bien ajoutée à l'historique du joueur humain, avec le bon type, le bon tour, et les champs attendus.
- **Action échouée** : vérifier qu'une action dont la validation échoue **ne crée aucune entrée**.
- **Fin de tour** : vérifier qu'après `TurnResolver.resolve`, exactement une entrée `Fin de tour` est ajoutée, contenant la production et les événements marquants (bâtiments désactivés, unités perdues).
- **Limite FIFO** : ajouter 150 entrées et vérifier qu'il n'en reste que 100, et que ce sont bien les 100 plus récentes.
- **Ordre chronologique** : vérifier que les entrées sont stockées et récupérables dans l'ordre chronologique (plus récent en dernier dans le stockage, plus récent en haut à l'affichage).
- **Contenu d'entrée combat** : vérifier qu'une entrée de combat contient bien le `FightSummary` complet (résultat, tours, composition joueur/monstre, pertes, butin).

### Tests unitaires (data / persistance)

- **Sérialisation Hive** : vérifier qu'une liste d'entrées d'historique (contenant les différents types) est correctement sérialisée et désérialisée via les `TypeAdapter`.
- **Compatibilité ancienne sauvegarde** : charger un `Player` sérialisé sans champ `history` doit fonctionner et produire un historique vide.
- **Round-trip complet** : save + load d'un `Game` contenant un historique avec chaque type d'entrée → les données sont identiques.

### Tests unitaires (présentation)

- **`HistoryScreen` vide** : s'affiche avec le message `Aucune action enregistrée pour l'instant.` quand l'historique est vide.
- **`HistoryScreen` avec entrées** : affiche les entrées sous forme de Cards, la plus récente en haut.
- **Couleur / icône par type** : chaque type d'entrée (combat, construction, recherche, recrutement, exploration, collecte, fin de tour) produit une Card avec la bonne couleur et la bonne icône.
- **Filtres** : taper sur chaque filtre (Tous, Combats, Construction, Recherche, Autres) filtre correctement la liste affichée.
- **Tap combat → dialog** : taper sur une entrée combat ouvre `FightSummaryDialog` avec les données stockées.
- **Tap non-combat → rien** : taper sur une entrée non-combat n'ouvre pas de dialog.
- **Intégration `settings_dialog`** : le dialogue `Parametres` contient bien le bouton `Voir l'historique` et ce bouton ouvre l'écran historique.

### Tests d'intégration

- **Scénario complet** : nouvelle partie → construire un bâtiment → rechercher une tech → recruter des unités → explorer une case → collecter un trésor → lancer un combat → terminer un tour → ouvrir l'historique : les **7 entrées** correspondantes sont bien présentes, dans le bon ordre, avec les bonnes données.
- **Persistance bout à bout** : dérouler le scénario ci-dessus, sauvegarder, recharger la partie, rouvrir l'historique : les entrées sont identiques.
- **Limite en situation réelle** : jouer / simuler suffisamment de tours pour dépasser 100 entrées, puis vérifier que seules les 100 dernières sont présentes après sauvegarde/chargement.
- **Tap combat depuis l'historique** : après un combat, rouvrir l'historique, taper sur l'entrée combat : le `FightSummaryDialog` s'ouvre avec exactement les mêmes données que celles affichées à la fin du combat initial.

### Critères de réussite

- `flutter analyze` passe sans erreur.
- `flutter test` passe à 100%.
- Chaque fichier reste sous **150 lignes**.
- Pas d'objet avec une fonction `initialize()` (règle projet).
- Les composants d'historique sont **réutilisables** : `HistoryScreen` prend en entrée une liste d'entrées et n'a aucune dépendance directe au `Player` ; le `FightSummaryDialog` est partagé entre le flux de combat et le flux d'historique.
- L'UI utilise le thème du projet (`lib/presentation/theme/`).
- Aucune régression sur les actions existantes : toutes les mécaniques actuelles continuent de fonctionner, l'historique est un effet de bord pur (ajout d'entrée) sans modification de la logique métier.
