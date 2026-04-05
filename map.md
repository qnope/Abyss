# Plan Fonctionnel : Carte 20x20 pour ABYSSES

## Contexte

L'onglet "Carte" (index 1) du GameScreen est actuellement un placeholder ("Bientot disponible"). Le joueur a besoin d'une carte en grille 20x20 scrollable pour explorer le monde sous-marin. C'est l'Etape 3 du roadmap, prerequis a toutes les fonctionnalites de combat, factions et niveaux de profondeur.

---

## 1. ASSETS VISUELS A CREER

### 1.1 Tuiles de terrain — `assets/icons/terrain/`

4 fichiers SVG representant les types de terrain. Chaque tuile doit fonctionner en juxtaposition sans bordure visible (rendu seamless).

| Fichier | Description visuelle | Couleur |
|---------|---------------------|---------|
| `reef.svg` | Formations coralliennes stylisees, branches de corail. Fond semi-transparent rose. Texture organique. | `reefPink (0x66FF6E91)` |
| `plain.svg` | Fond sous-marin ouvert, sable fin, quelques algues flottantes. Espace et passage libre. | `plainBlue (0x6642A5F5)` |
| `rock.svg` | Bloc de roche massif, anguleux, sombre. Mur impenetrable. Texture minerale compacte. | `rockGray (0xFF4A5568)` |
| `fault.svg` | Fissure profonde dans le sol oceanique, lueur rouge/orange de l'interieur. Particules en suspension. | `faultBlack (0xFF1A1A2E)` + accent rouge |

**Principes de design** :
- Recif et Plaine sont semi-transparents, laissant transparaitre le fond `abyssBlack`
- Roche et Faille sont opaques pour marquer leur nature speciale
- Prevoir 2-3 variantes par terrain (rotation/mirror du SVG) pour casser la repetition visuelle sur 400 cases

### 1.2 Contenu des cases — `assets/icons/map_content/`

5 marqueurs SVG superposes a la tuile de terrain quand la case est revelee.

| Fichier | Description visuelle |
|---------|---------------------|
| `resource_bonus.svg` | Coffre/caisse sous-marine entrouverte, eclat colore generique, particules dorees |
| `ruins.svg` | Vestige architectural — arc brise, colonnes renversees. Lueur violette/nacree (evocation perles) |
| `monster_easy.svg` | Petite caverne, silhouette de creature, aura/halo **vert** (`algaeGreen`). Badge 1 etoile |
| `monster_medium.svg` | Caverne plus grande, creature imposante, aura **orange** (`energyYellow`). Badge 2 etoiles |
| `monster_hard.svg` | Caverne massive, creature menacante avec tentacules, aura **rouge** (`error`). Badge 3 etoiles |

Le code couleur vert/orange/rouge + les etoiles (1/2/3) assurent l'accessibilite de l'indicateur de difficulte.

### 1.3 Base du joueur

| Fichier | Description |
|---------|-------------|
| `player_base.svg` | Dome sous-marin lumineux, eclat bioluminescent cyan (`biolumCyan`). Element visuel le plus dominant de la grille. Halo pulsant. |

### 1.4 Factions ennemies (preparation Etape 7)

| Fichier | Description |
|---------|-------------|
| `faction_neutral.svg` | Dome sous-marin en bleu terne (`oreBlue`), moins lumineux que la base joueur |
| `faction_hostile.svg` | Dome en rouge sombre (`error`), aspect menacant, pointes, lumieres rouges |

### 1.5 Brouillard de guerre (pas d'asset SVG)

Le fog of war est un traitement de rendu, pas un asset :
- **Case non revelee** : overlay `abyssBlack` a 95% d'opacite + texture subtile de particules
- **Bordure du brouillard** : degrade progressif avec lueur bioluminescente au bord (le joueur "repousse l'obscurite")
- **Case revelee** : aucun overlay, terrain et contenu pleinement visibles

### 1.6 Chrome UI (overlays de la carte)

| Element | Description |
|---------|-------------|
| Bouton "Centrer" | FAB rond, icone crosshair/cible en `biolumCyan`, coin bas-droite |
| Boutons zoom +/- | Overlay discret, coin bas-gauche, style `AbyssButtonTheme` |
| Selecteur de case | Bordure `biolumCyan` pulsante autour de la case selectionnee |
| Cases deplacement valide | Surbrillance `biolumTeal` semi-transparente + fleche directionnelle |
| Case dangereuse (Faille) | Surbrillance rouge semi-transparente + icone avertissement |
| Coordonnees | Numeros 1-20 discrets sur les bords haut et gauche, couleur `onSurfaceDim` |

---

## 2. OPERATIONS DE LA CARTE

### 2.1 Generation de la carte

La generation s'effectue a la creation d'une nouvelle partie (avant le tour 1), a partir d'une graine aleatoire (seed) sauvegardee.

#### Phase 1 : Placement du terrain
1. Creer une grille vide 20x20 (400 cases)
2. Placer la base du joueur au centre (case ~10,10) ou dans un rayon de 2 du centre
3. Garantir que la base et ses 8 voisines sont Recif ou Plaine (jamais Roche/Faille)
4. Pour chaque case restante, tirage aleatoire : Recif 40%, Plaine 30%, Roche 15%, Faille 15%
5. Validation : au moins un chemin libre (sans Roche) de la base vers chaque bord de la carte. Si absent, convertir des Roches en Plaine pour creer le passage.

#### Phase 2 : Placement du contenu
1. Exclure la base + rayon de 2 (zone initiale) : toujours vides
2. Exclure les cases Roche (pas de contenu recuperable)
3. Pour chaque case eligible : Vide 60%, Ressources bonus 20%, Ruines 10%, Repaire monstre 10%
4. Difficulte monstre : Facile 50%, Moyen 35%, Difficile 15%. Les difficiles sont biaises vers les bords (distance base > 7)
5. Verification : 5 a 10 repaires de monstres. Ajuster si hors bornes.

#### Phase 3 : Placement des factions IA (preparation Etape 7)
1. Determiner N factions (10-20)
2. Placer chaque faction sur une case libre (pas Roche, pas Faille, pas de contenu)
3. Contraintes : distance min 5 cases du joueur, distance min 4 cases entre factions
4. Disposition : 70% Neutre, 30% Hostile

#### Phase 4 : Initialisation du fog of war
1. Reveler toutes les cases dans un rayon de 2 autour de la base (rayon de Tchebychev = carre 5x5 = 25 cases)
2. Toutes les autres cases restent masquees

### 2.2 Gestion du fog of war

- Une case revelee le reste **indefiniment** (pas de re-fog)
- Declencheurs de revelation : position de la base (initial), deplacement d'une unite
- Chaque unite qui se deplace revele la case de destination + les 4 cases adjacentes (haut, bas, gauche, droite)
- L'etat `isRevealed` est un booleen par case, persiste dans Hive

### 2.3 Validation de deplacement

Pour l'Etape 3, le deplacement est simple (1 case/tour, 4 directions) :

1. L'unite est sur la case (x, y)
2. Le joueur designe une case cible adjacente (haut, bas, gauche, droite)
3. Verifications :
   - La case cible existe (pas hors grille)
   - La case cible n'est **pas Roche** (impassable)
   - La case cible n'est **pas un repaire de monstre** (bloque a l'Etape 3 ; combat a l'Etape 5)
   - Si la case cible est une **Faille** : mouvement autorise mais -3 PV a la resolution
4. L'ordre est enregistre (pas execute immediatement)

### 2.4 Integration avec le systeme de tours

Le TurnResolver devra etre etendu. Nouvelle sequence de resolution :

```
1. Production des ressources              (existant)
2. Deplacement des unites sur la carte    (NOUVEAU)
   - Executer chaque ordre de deplacement
   - Reveler les cases (destination + adjacentes)
   - Appliquer degats de Faille si applicable
   - Detruire les unites a 0 PV
3. Collecte automatique des contenus      (NOUVEAU)
   - Ressources bonus → ajout au stock, case videe
   - Ruines → ressources + chance perles, case videe
4. Reset recrutement                      (existant)
5. Incrementation du tour                 (existant)
```

**Extension du TurnResult** avec :
- Liste des deplacements effectues (unite, depart, arrivee)
- Liste des cases revelees ce tour
- Liste des decouvertes (type de contenu, ressources gagnees)
- Liste des unites detruites (par Faille)

### 2.5 Mecaniques de decouverte

| Contenu | Declencheur | Effet | Apres collecte |
|---------|-------------|-------|----------------|
| Ressources bonus | Unite arrive sur la case | +10-30 d'une ressource aleatoire (Algues/Corail/Minerai/Energie) | Case devient Vide |
| Ruines | Unite arrive sur la case | +20-50 d'une ressource + 30% de chance de 1-3 Perles | Case devient Vide |
| Repaire monstre | Visible quand revelee | Bloque le passage (Etape 3). Combat a l'Etape 5 | Reste tant que monstre vivant |

### 2.6 Persistence Hive

Nouvelles entites a persister (typeIds disponibles a partir de 10) :

| Entite | typeId | Champs cles |
|--------|--------|-------------|
| TerrainType (enum) | 10 | reef, plain, rock, fault |
| CellContentType (enum) | 11 | empty, resourceBonus, ruins, monsterLair |
| MonsterDifficulty (enum) | 12 | easy, medium, hard |
| MapCell | 13 | terrain, content, monsterDifficulty?, isRevealed, bonusResourceType?, bonusAmount? |
| GameMap | 14 | width, height, cells, depthLevel, playerBaseX, playerBaseY |
| GridPosition | 15 | x, y |

Ajout au Game : champ `gameMap` (nullable pour retrocompatibilite).

---

## 3. INTERACTIONS UTILISATEUR

### 3.1 Navigation sur la carte

**Scrolling / Pan** :
- La carte est affichee dans un conteneur scrollable 2D (InteractiveViewer Flutter)
- Glisser du doigt pour deplacer la vue (la carte "suit le doigt")
- Inertie de defilement apres geste rapide
- Bornes : la grille 20x20 + un demi-case de padding autour

**Zoom** :
- Pinch-to-zoom pour zoomer/dezoomer (mobile)
- Boutons +/- en overlay (accessibilite web/desktop)
- Scroll molette pour zoomer (web)
- **Zoom minimum** : toute la carte 20x20 visible a l'ecran
- **Zoom maximum** : 4-5 cases visibles
- **Zoom par defaut** : ~8-10 cases visibles, centre sur la base
- Zoom progressif et fluide (pas par paliers)

**Taille de case** : 48x48 points logiques de base → grille complete = 960x960 points

### 3.2 Selection d'une case

**Geste** : Tap simple sur une case.

| Etat | Comportement |
|------|-------------|
| Aucune selection | Etat par defaut |
| Case selectionnee | Bordure biolumCyan pulsante + bottom sheet d'info |
| Unite selectionnee | Meme + cases adjacentes valides surbrillees |
| Deselection | Re-tap sur la meme case, ou tap hors grille |

### 3.3 Bottom Sheet de detail de case (Tile Detail Sheet)

En coherence avec les patterns existants (BuildingDetailSheet, UnitDetailSheet) :

**Structure** : Icone 64px → Titre → Sous-titre (coordonnees) → Description → Divider → Section d'action

**Contenu selon le type de case :**

| Type de case | Titre | Section d'action |
|-------------|-------|-----------------|
| Non revelee (fog) | "Zone inexploree" | Aucune |
| Revelee vide | Nom du terrain (ex: "Recif") + effet si special | "Aucun contenu" |
| Ressources bonus | "Depot de ressources" | "Envoyez une unite pour collecter" |
| Ruines | "Ruines anciennes" | "Envoyez une unite pour explorer" |
| Repaire monstre | "Repaire de monstre" + difficulte (etoiles + couleur) | Stats PV/ATQ/DEF + "Combat non disponible" (Etape 3) |
| Unite du joueur | Nom unite + PV/max | Bouton "Deplacer" + Bouton "Annuler l'ordre" si ordre en attente |
| Base du joueur | "Votre base" | Liste des unites presentes + Bouton "Centrer" |
| Faction IA (futur) | Nom faction + disposition | Info puissance/disposition |

### 3.4 Flux d'envoi d'unite en exploration

1. Le joueur tape sur une case contenant son unite (ex: eclaireur a la base)
2. Le bottom sheet s'ouvre avec les infos de l'unite
3. Le joueur tape **"Deplacer"**
4. Le bottom sheet se ferme → la carte passe en **"mode deplacement"** :
   - Case de l'unite : bordure `biolumCyan` epaisse
   - 4 cases adjacentes valides : surbrillance `biolumTeal` + fleche directionnelle
   - Cases invalides (Roche, monstre) : pas surbrillees
   - Cases Faille : surbrillance rouge + icone danger
   - Cases en fog adjacentes : surbrillance + "?" (exploration)
5. Le joueur tape une case valide surbrillees
6. **Ordre enregistre** : fleche directionnelle semi-transparente apparait sur l'unite, pointant vers la destination
7. Badge "Ordres en attente" sur le bouton Tour Suivant
8. Au tour suivant : deplacement execute, resultats dans le resume

**Annulation** : Taper sur l'unite → "Annuler l'ordre" dans le bottom sheet.

**Contrainte** : Un seul ordre par unite par tour. Un nouvel ordre remplace le precedent.

### 3.5 Combat (Etape 3 = visuel seulement)

- Les repaires de monstre sont visibles mais les cases sont infranchissables
- Le bottom sheet affiche : stats du monstre + difficulte + "Combat disponible prochainement"
- Le joueur ne peut pas envoyer d'unite sur cette case

### 3.6 Bouton "Centrer sur la base"

- FAB en bas-droite de la vue carte
- Icone crosshair en `biolumCyan`
- Animation smooth (300ms) pour centrer + retour au zoom par defaut
- Si deja centre : leger rebond de confirmation

---

## 4. PROPOSITIONS FONCTIONNELLES

### 4.1 Pas de mini-carte

Pas de mini-carte ni de vue d'ensemble. Le joueur navigue uniquement via scroll/zoom + le bouton "Centrer sur la base". Cela garde l'interface epuree et simple.

### 4.2 Integration Tour — Confirmation et Resume

**Dialogue de confirmation** (avant resolution) :
- Section existante : production prevue
- **Nouvelle section** : "Ordres de carte : 1 eclaireur en deplacement vers (12, 8)"

**Dialogue de resume** (apres resolution) :
- Section existante : ressources produites
- **Nouvelle section "Exploration"** :
  - Cases revelees ce tour (nombre)
  - Decouvertes (coffre, ruines) avec ressources gagnees
  - Degats subis (failles)
  - Unites detruites

### 4.3 Animations de decouverte

**Premiere iteration (animations minimales)** :

| Evenement | Animation | Duree |
|-----------|-----------|-------|
| Case revelee | Fade-in du terrain depuis le noir (fog qui se dissipe) | 300ms |
| Deplacement unite | Glissement de case a case | 300ms |

**Phase polish (plus tard)** : particules collecte, flash degats, shake monstre, bounce contenu, destruction en particules.

Les animations se jouent en sequence lors de la resolution du tour.

### 4.4 Adaptation multi-ecrans

| Ecran | Comportement |
|-------|-------------|
| iPhone SE / petit | Mini-carte masquee par defaut. Boutons plus petits. ~6-8 cases visibles. |
| iPhone 14+ | Zoom par defaut ~8-10 cases. Mini-carte optionnelle. |
| iPad / tablette | ~12-15 cases. Mini-carte affichee. Bottom sheet possiblement en side panel. |
| Web / desktop | Scroll molette pour zoom. Clic-drag pour pan. Boutons zoom toujours visibles. |

### 4.5 Preparation niveaux de profondeur (future-proof)

Le modele GameMap contient un champ `depthLevel`. Architecture prevue :

| Niveau | Theme | Palette |
|--------|-------|---------|
| 1 — Surface | Eaux claires, recifs | Rose, bleu clair (actuel) |
| 2 — Profondeur | Eaux sombres, pression | Violets, bleu-noirs, orange volcanique |
| 3 — Noyau | Zone volcanique extreme | Rouges, oranges, noirs |

Navigation entre niveaux : selecteur/tabs en haut de la carte. Chaque niveau = instance separee de GameMap. Pour l'instant, un seul GameMap suffit ; la structure evoluera vers `List<GameMap>`.

---

## 5. FICHIERS CRITIQUES A MODIFIER

| Fichier | Modification |
|---------|-------------|
| `lib/presentation/screens/game_screen.dart` | Remplacer TabPlaceholder (tab 1) par le widget de carte |
| `lib/domain/game.dart` | Ajouter champ `gameMap` (HiveField 8) |
| `lib/domain/turn_resolver.dart` | Etendre pour deplacements, revelations, collectes, degats |
| `lib/domain/action.dart` | Pattern a suivre pour MoveUnitAction |
| `lib/presentation/theme/abyss_colors.dart` | Couleurs terrain deja presentes (lignes 30-33) |
| `lib/data/game_repository.dart` | Enregistrer les nouveaux adapters Hive (typeIds 10-15) |

---

## 6. PHASES D'IMPLEMENTATION

### Phase 1 — Carte visible et navigable
1. Modeles domaine : TerrainType, CellContentType, MonsterDifficulty, MapCell, GameMap, GridPosition
2. Generateur de carte (4 phases)
3. Widget de grille avec InteractiveViewer (scroll + zoom)
4. Rendu fog of war
5. Selection de case + bottom sheet
6. Integration dans GameScreen (remplacement TabPlaceholder)
7. Bouton "Centrer sur la base"
8. Assets SVG (terrain x4, contenu x5, base x1)
9. Persistence Hive (6 nouveaux typeIds)

### Phase 2 — Deplacement et exploration
1. MoveUnitAction (validate/execute)
2. Mode deplacement interactif (surbrillance)
3. Resolution deplacements dans TurnResolver
4. Collecte automatique ressources/ruines
5. Extension TurnResult + TurnSummaryDialog
6. Animations revelation/collecte

### Phase 3 — Polish
1. Animations avancees (particules, shake, etc.)
2. Tests unitaires + widget + integration

---

## 7. VERIFICATION

- `flutter analyze` : zero warning
- `flutter test` : tous les tests passent
- Tests unitaires : generation carte, fog of war, validation deplacement, collecte
- Tests widget : rendu grille, selection case, bottom sheet, bouton centrer
- Tests integration : recruter eclaireur → deplacer → reveler → collecter → resume tour
- Test visuel : carte scrollable/zoomable sur iOS, Android, Web
