# Display Map - Feature Specification

## 1. Feature Overview

Remplacer le placeholder "Bientot disponible" de l'onglet Carte (tab index 1) du GameScreen par une carte en grille 20x20 generee proceduralement, scrollable et zoomable, avec fog of war.

Ce scope couvre uniquement la **generation** et l'**affichage** de la carte. Les interactions (selection de case, bottom sheet, deplacement d'unites, bouton centrer) seront traitees dans un projet ulterieur.

---

## 2. User Stories

### US-1 : Generation de la carte a la premiere consultation

**En tant que** joueur,
**je veux** qu'une carte soit generee automatiquement quand j'ouvre l'onglet Carte,
**afin de** pouvoir explorer le monde sous-marin.

**Criteres d'acceptation :**
- Si `gameMap` est null dans le Game (nouvelle partie ou partie existante), une carte 20x20 est generee automatiquement au premier affichage de l'onglet.
- La carte generee est immediatement persistee en Hive.
- Les rechargements suivants affichent la carte sauvegardee sans regeneration.

### US-2 : Terrain procedural coherent

**En tant que** joueur,
**je veux** que la carte ait un terrain varie et jouable,
**afin de** decouvrir un monde interessant a chaque partie.

**Criteres d'acceptation :**
- La base du joueur est placee au centre (~10,10) ou dans un rayon de 2 du centre.
- Les 8 cases adjacentes a la base sont toujours Recif ou Plaine (jamais Roche/Faille).
- Distribution du terrain : Recif 40%, Plaine 30%, Roche 15%, Faille 15%.
- Au moins un chemin libre (sans Roche) relie la base a chaque bord de la carte.
- La generation utilise une seed aleatoire sauvegardee pour reproductibilite.

### US-3 : Contenu des cases

**En tant que** joueur,
**je veux** que la carte contienne des ressources, ruines et repaires de monstres,
**afin d'** avoir des objectifs d'exploration.

**Criteres d'acceptation :**
- La base + rayon de 2 (zone initiale 5x5) est toujours vide de contenu.
- Les cases Roche n'ont jamais de contenu.
- Distribution sur cases eligibles : Vide 60%, Ressources bonus 20%, Ruines 10%, Repaire monstre 10%.
- Difficulte monstre : Facile 50%, Moyen 35%, Difficile 15%.
- Les monstres difficiles sont biaises vers les bords (distance base > 7).
- La carte contient entre 5 et 10 repaires de monstres.

### US-4 : Fog of war initial

**En tant que** joueur,
**je veux** que seules les cases proches de ma base soient visibles au depart,
**afin de** ressentir la progression de l'exploration.

**Criteres d'acceptation :**
- A la generation, les cases dans un rayon de Tchebychev de 2 autour de la base sont revelees (carre 5x5 = 25 cases).
- Toutes les autres cases (375) sont masquees par le fog of war.
- Une case revelee le reste indefiniment (pas de re-fog).

### US-5 : Affichage de la grille scrollable et zoomable

**En tant que** joueur,
**je veux** naviguer sur la carte en la faisant glisser et en zoomant,
**afin de** voir les differentes zones de la carte.

**Criteres d'acceptation :**
- La carte est affichee dans un InteractiveViewer Flutter (scroll 2D + pinch-to-zoom).
- Taille de case : 48x48 points logiques (grille complete = 960x960).
- Zoom minimum : toute la carte visible a l'ecran.
- Zoom maximum : 4-5 cases visibles.
- Zoom par defaut : ~8-10 cases visibles, centre sur la base.
- Bornes de scroll : grille + demi-case de padding.
- Scroll molette sur web, pinch sur mobile.

### US-6 : Rendu visuel du terrain

**En tant que** joueur,
**je veux** voir les differents types de terrain avec leurs visuels distincts,
**afin de** comprendre la topographie de la carte.

**Criteres d'acceptation :**
- Chaque type de terrain affiche son SVG correspondant (`assets/icons/terrain/`).
- Recif et Plaine sont semi-transparents (fond `abyssBlack` visible).
- Roche et Faille sont opaques.
- Les assets SVG existants sont utilises tels quels.

### US-7 : Rendu du fog of war

**En tant que** joueur,
**je veux** que les cases non revelees soient visuellement masquees,
**afin de** distinguer les zones explorees des zones inconnues.

**Criteres d'acceptation :**
- Case non revelee : overlay `abyssBlack` a 95% d'opacite.
- Case revelee : terrain et contenu pleinement visibles, aucun overlay.
- La transition est nette (pas d'animation pour l'instant).

### US-8 : Rendu du contenu des cases

**En tant que** joueur,
**je veux** voir les marqueurs de contenu sur les cases revelees,
**afin de** savoir ce qui se trouve a chaque endroit.

**Criteres d'acceptation :**
- Les marqueurs SVG (`assets/icons/map_content/`) sont superposes au terrain.
- Ressources bonus : `resource_bonus.svg`.
- Ruines : `ruins.svg`.
- Repaires de monstres : `monster_easy.svg`, `monster_medium.svg`, `monster_hard.svg` selon la difficulte.
- La base du joueur affiche `player_base.svg`.
- Les marqueurs ne sont visibles que sur les cases revelees.

### US-9 : Persistence Hive de la carte

**En tant que** joueur,
**je veux** que ma carte soit sauvegardee et restauree entre les sessions,
**afin de** ne pas perdre ma progression d'exploration.

**Criteres d'acceptation :**
- 6 nouveaux typeIds Hive enregistres (10 a 15).
- Le champ `gameMap` est ajoute au modele Game (HiveField, nullable).
- La carte est persistee a chaque modification (generation, futur : revelation).
- Les parties existantes (gameMap null) declenchent une generation automatique.

### US-10 : Integration dans le GameScreen

**En tant que** joueur,
**je veux** voir la carte quand je clique sur l'onglet "Carte",
**afin d'** acceder a l'exploration depuis l'interface principale.

**Criteres d'acceptation :**
- Le TabPlaceholder de l'onglet Carte (index 1) est remplace par le widget de carte.
- Si gameMap est null, la carte est generee puis affichee.
- Le widget de carte respecte le theme Abyss (fond `abyssBlack`).

---

## 3. Modeles domaine

### Enums

| Enum | Valeurs | Hive typeId |
|------|---------|-------------|
| `TerrainType` | reef, plain, rock, fault | 10 |
| `CellContentType` | empty, resourceBonus, ruins, monsterLair | 11 |
| `MonsterDifficulty` | easy, medium, hard | 12 |

### Classes

| Classe | Champs | Hive typeId |
|--------|--------|-------------|
| `MapCell` | terrain (TerrainType), content (CellContentType), monsterDifficulty (MonsterDifficulty?), isRevealed (bool), bonusResourceType (ResourceType?), bonusAmount (int?) | 13 |
| `GameMap` | width (int), height (int), cells (List\<MapCell\>), depthLevel (int), playerBaseX (int), playerBaseY (int), seed (int) | 14 |
| `GridPosition` | x (int), y (int) | 15 |

### Modification existante

- `Game` : ajout champ `gameMap` (GameMap?, HiveField 8, nullable).

---

## 4. Algorithme de generation

### Phase 1 : Placement du terrain
1. Creer grille vide 20x20.
2. Placer la base au centre (rayon 0-2 du centre, aleatoire avec seed).
3. Forcer les 8 voisines de la base en Recif ou Plaine.
4. Tirage aleatoire pour chaque case restante : Recif 40%, Plaine 30%, Roche 15%, Faille 15%.
5. Validation de connectivite : au moins un chemin libre (sans Roche) de la base vers chaque bord. Si absent, convertir des Roches en Plaine.

### Phase 2 : Placement du contenu
1. Exclure base + rayon 2 (toujours vides).
2. Exclure Roche (pas de contenu).
3. Tirage : Vide 60%, Ressources 20%, Ruines 10%, Monstre 10%.
4. Difficulte monstre : Facile 50%, Moyen 35%, Difficile 15% (difficiles biaises vers bords).
5. Validation : 5-10 repaires de monstres. Ajuster si hors bornes.

### Phase 3 : Fog of war initial
1. Reveler cases dans rayon de Tchebychev 2 autour de la base (carre 5x5).
2. Tout le reste masque.

**Note :** Pas de Phase factions IA dans ce scope (reportee a l'Etape 7).

---

## 5. Testing and Validation

### Tests unitaires (domaine)

- **Generation terrain** : verifier distributions, base au centre, voisines safe, connectivite bords.
- **Placement contenu** : zone initiale vide, Roche sans contenu, bornes 5-10 monstres, biais difficulte.
- **Fog of war** : 25 cases revelees initialement, les autres masquees.
- **Seed reproductibilite** : meme seed → meme carte.
- **Modeles** : constructeurs MapCell, GameMap, GridPosition, acces cellule par coordonnees.

### Tests widget (presentation)

- **Rendu grille** : 400 cases affichees, tailles correctes.
- **Terrain** : SVG correct par type de terrain.
- **Fog of war** : overlay noir sur cases non revelees, absent sur cases revelees.
- **Contenu** : marqueurs SVG presents sur cases revelees avec contenu.
- **Base joueur** : SVG player_base visible sur la case de base.
- **InteractiveViewer** : widget scrollable et zoomable present.

### Tests integration

- **Onglet carte** : ouvrir l'onglet → carte generee et affichee.
- **Persistence** : generer carte → sauvegarder → recharger → carte identique.
- **Retrocompatibilite** : charger partie sans carte → generation auto.

### Criteres de succes

- `flutter analyze` : zero warning.
- `flutter test` : tous les tests passent.
- Carte visible et navigable sur iOS, Android, Web.
- Chaque fichier < 150 lignes.
