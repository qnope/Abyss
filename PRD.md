# ABYSSES - Product Requirements Document (PRD)

> Version 1.0
> Date : 2026-03-24
> Statut : Draft

---

## Table des matieres

1. [Vision & Objectifs](#1-vision--objectifs)
2. [Principes de conception](#2-principes-de-conception)
3. [Architecture technique](#3-architecture-technique)
4. [Modele de donnees global](#4-modele-de-donnees-global)
5. [Etape 1 — Le Noyau Minimal](#5-etape-1--le-noyau-minimal)
6. [Etape 2 — Energie & Contraintes](#6-etape-2--energie--contraintes)
7. [Etape 3 — Carte & Exploration](#7-etape-3--carte--exploration)
8. [Etape 4 — Kit de Depart & Nouvelle Partie](#8-etape-4--kit-de-depart--nouvelle-partie)
9. [Etape 5 — Unites de Combat & Monstres](#9-etape-5--unites-de-combat--monstres)
10. [Etape 6 — Technologies](#10-etape-6--technologies)
11. [Etape 7 — Factions IA](#11-etape-7--factions-ia)
12. [Etape 8 — Alliances](#12-etape-8--alliances)
13. [Etape 9 — Evenements Aleatoires](#13-etape-9--evenements-aleatoires)
14. [Etape 10 — Unites Avancees (Machines)](#14-etape-10--unites-avancees-machines)
15. [Etape 11 — Niveaux de Profondeur](#15-etape-11--niveaux-de-profondeur)
16. [Etape 12 — Ecran de Victoire & Statistiques](#16-etape-12--ecran-de-victoire--statistiques)
17. [Etape 13 — Equilibrage & Scaling](#17-etape-13--equilibrage--scaling)
18. [Etape 14 — Polish & Assets](#18-etape-14--polish--assets)
19. [Strategie de test globale](#19-strategie-de-test-globale)
20. [Glossaire](#20-glossaire)

---

## 1. Vision & Objectifs

### 1.1 Vision du produit

ABYSSES est un jeu de strategie tour par tour en single player dans un univers sous-marin.
Le joueur developpe une base, explore les profondeurs, forme des alliances et combat des factions
IA rivales. L'objectif final est d'atteindre le noyau volcanique au 3eme niveau de profondeur.

Le jeu s'inspire de Travian, OGame et Clash of Clans, mais en solo et tour par tour.
Au lieu d'attendre des heures, le joueur effectue ses actions puis appuie sur "Tour suivant".

### 1.2 Public cible

- Joueurs de jeux de strategie au tour par tour
- Joueurs mobile casual a mid-core
- Fans de jeux de gestion de base (Travian, OGame, Clash of Clans) preferant le solo

### 1.3 Objectifs mesurables

| Objectif | Metrique | Cible |
|----------|----------|-------|
| Duree de partie | Nombre de tours pour gagner | 50-100 tours |
| Rejouabilite | Kits de depart viables | 3/3 kits menent a la victoire |
| Engagement | Temps moyen par tour | 1-3 minutes |
| Stabilite | Crash rate | < 0.1% |

### 1.4 Plateformes cibles

- iOS (iPhone, iPad)
- Android (smartphones, tablettes)
- Web (navigateurs modernes)

### 1.5 Stack technique

- **Langage** : Dart
- **Framework** : Flutter
- **Persistance** : Hive (base de donnees locale)
- **Architecture** : 5 couches (presentation, application, domain, data, infrastructure)

---

## 2. Principes de conception

### 2.1 Principes de game design

1. **Jouable a chaque etape** : chaque increment du roadmap produit un jeu fonctionnel
2. **Pas de temps mort** : le joueur decide, appuie sur "Tour suivant", voit les resultats
3. **Choix significatifs** : chaque decision (construction, recherche, diplomatie) a un impact
4. **Progression visible** : le joueur voit sa base grandir, sa carte se reveler
5. **Difficulte progressive** : les niveaux de profondeur introduisent des defis croissants

### 2.2 Principes techniques

1. **Composants reutilisables** : chaque widget/composant est concu pour etre reutilise
2. **Pas de `initialize()`** : les objets sont construits completement ou pas du tout
3. **Fichiers < 150 lignes** : chaque fichier reste sous 150 lignes de code
4. **Architecture 5 couches** : separation stricte des responsabilites
5. **Tests obligatoires** : `flutter analyze` et `flutter test` doivent passer a chaque etape

### 2.3 Principes UX

1. **Information visible** : ressources, tour, etat de la base toujours accessibles
2. **Feedback immediat** : chaque action du joueur a un retour visuel
3. **Resume de tour** : le joueur voit exactement ce qui s'est passe
4. **Navigation simple** : maximum 2 taps pour acceder a n'importe quelle fonctionnalite

---

## 3. Architecture technique

### 3.1 Les 5 couches

```
+--------------------------------------------------+
| Presentation (UI)                                |
|  Widgets, ecrans, navigation                     |
+--------------------------------------------------+
| Application (Use Cases)                          |
|  Logique d'orchestration, commandes              |
+--------------------------------------------------+
| Domain (Metier)                                  |
|  Entites, value objects, regles metier            |
+--------------------------------------------------+
| Data (Repositories)                              |
|  Interfaces de persistance, transformations       |
+--------------------------------------------------+
| Infrastructure (Hive, etc.)                      |
|  Implementation concrete de la persistance        |
+--------------------------------------------------+
```

### 3.2 Conventions de nommage

| Element | Convention | Exemple |
|---------|-----------|---------|
| Fichiers Dart | snake_case | `resource_bar.dart` |
| Classes | PascalCase | `ResourceBar` |
| Variables/fonctions | camelCase | `currentTurn` |
| Constantes | lowerCamelCase | `maxBuildingLevel` |
| Dossiers | snake_case | `game_screen/` |

### 3.3 Structure de dossiers (cible)

```
lib/
  domain/
    entities/
    value_objects/
    rules/
  data/
    repositories/
    models/
  application/
    use_cases/
    services/
  infrastructure/
    hive/
    adapters/
  presentation/
    screens/
    widgets/
    theme/
```

---

## 4. Modele de donnees global

### 4.1 Entite : GameState

| Champ | Type | Description |
|-------|------|-------------|
| currentTurn | int | Numero du tour actuel |
| resources | ResourceSet | Ressources du joueur |
| buildings | List<Building> | Batiments construits |
| units | List<Unit> | Unites recrutees |
| map | GameMap | Carte du monde |
| technologies | TechTree | Technologies recherchees |
| factions | List<Faction> | Factions IA |
| alliance | Alliance | Alliance du joueur |
| depthLevel | int | Niveau de profondeur actuel (1-3) |
| starterKit | StarterKit | Kit de depart choisi |
| statistics | GameStatistics | Statistiques de la partie |

### 4.2 Entite : ResourceSet

| Champ | Type | Description |
|-------|------|-------------|
| algae | int | Quantite d'algues |
| coral | int | Quantite de corail |
| ore | int | Quantite de minerai oceanique |
| energy | int | Quantite d'energie |
| pearls | int | Quantite de perles |

### 4.3 Entite : Building

| Champ | Type | Description |
|-------|------|-------------|
| id | String | Identifiant unique |
| type | BuildingType | Type de batiment |
| level | int | Niveau actuel |
| isUnderConstruction | bool | En cours de construction |
| turnsRemaining | int | Tours restants pour finir la construction |

### 4.4 Entite : Unit

| Champ | Type | Description |
|-------|------|-------------|
| id | String | Identifiant unique |
| type | UnitType | Type d'unite |
| hp | int | Points de vie actuels |
| maxHp | int | Points de vie max |
| attack | int | Puissance d'attaque |
| defense | int | Puissance de defense |
| movement | int | Deplacement par tour |
| position | GridPosition | Position sur la carte |

### 4.5 Entite : GameMap

| Champ | Type | Description |
|-------|------|-------------|
| width | int | Largeur de la grille (20) |
| height | int | Hauteur de la grille (20) |
| cells | List<List<MapCell>> | Grille de cellules |
| depthLevel | int | Niveau de profondeur |

### 4.6 Entite : MapCell

| Champ | Type | Description |
|-------|------|-------------|
| terrain | TerrainType | Type de terrain |
| isRevealed | bool | Revele par le joueur |
| content | CellContent? | Contenu (ruines, monstres, etc.) |
| faction | Faction? | Faction occupante |
| units | List<Unit> | Unites presentes |

---

## 5. Etape 1 — Le Noyau Minimal

### 5.1 Objectif

Le joueur dispose d'un ecran de jeu fonctionnel avec des ressources, des batiments constructibles,
et un bouton "Tour suivant" qui fait avancer la partie. C'est le squelette jouable du jeu.

### 5.2 Fonctionnalites

#### F1.1 — Ecran principal

**Description** : L'ecran principal du jeu affiche toutes les informations essentielles.

**Elements affiches** :
- Numero du tour actuel (ex: "Tour 1")
- Barre de ressources en haut de l'ecran
- Liste des batiments construits avec leur niveau
- Zone de construction pour les nouveaux batiments
- Bouton "Tour suivant" toujours visible et accessible

**Criteres d'acceptation** :
- [ ] Le numero du tour est affiche en permanence
- [ ] Le numero du tour s'incremente a chaque appui sur "Tour suivant"
- [ ] Le tour commence a 1
- [ ] L'ecran est scrollable si le contenu depasse la taille de l'ecran

**Maquette conceptuelle** :
```
+--------------------------------------+
| Tour 1                               |
+--------------------------------------+
| Algues: 50 | Corail: 30 | Minerai: 20|
+--------------------------------------+
|                                      |
|  [QG - Niveau 1]                     |
|                                      |
|  Batiments :                         |
|  (vide)                              |
|                                      |
|  Construire :                        |
|  [Ferme d'algues] [Mine] [Extracteur]|
|                                      |
+--------------------------------------+
|        [ Tour Suivant ]              |
+--------------------------------------+
```

#### F1.2 — Systeme de ressources de base

**Description** : 3 ressources sont gerees par le jeu : Algues, Corail, Minerai oceanique.

**Ressources initiales** :

| Ressource | Stock initial | Icone | Couleur |
|-----------|--------------|-------|---------|
| Algues | 50 | Plante | Vert |
| Corail | 30 | Branche | Rose/Rouge |
| Minerai oceanique | 20 | Cristal | Bleu |

**Regles** :
- Les ressources ne peuvent pas etre negatives
- Les ressources sont affichees sous forme d'entiers
- La production s'ajoute au stock a chaque tour
- La barre de ressources est toujours visible en haut de l'ecran

**Criteres d'acceptation** :
- [ ] Les 3 ressources sont affichees dans la barre avec nom, icone et quantite
- [ ] Les ressources se mettent a jour apres chaque tour
- [ ] Il est impossible de depenser plus de ressources que le stock disponible
- [ ] Les ressources ne descendent jamais en dessous de 0

#### F1.3 — Le QG (Quartier General)

**Description** : Le QG est le batiment central, present des le debut, non destructible.

**Specifications** :

| Propriete | Valeur |
|-----------|--------|
| Niveau initial | 1 |
| Niveau max (etape 1) | 1 (non ameliorable a cette etape) |
| Destructible | Non |
| Production | Aucune |

**Regles** :
- Le QG est toujours present sur l'ecran principal
- Le QG affiche son niveau actuel
- A l'etape 1, le QG ne peut pas etre ameliore (fonctionnalite ajoutee a l'etape 2)

**Criteres d'acceptation** :
- [ ] Le QG est affiche au lancement de la partie
- [ ] Le QG affiche "Niveau 1"
- [ ] Le QG ne peut pas etre supprime
- [ ] Le QG n'a pas de bouton "Ameliorer" a l'etape 1

#### F1.4 — Batiments constructibles

**Description** : 3 batiments de production sont disponibles a la construction.

**Specifications des batiments** :

| Batiment | Cout construction | Temps | Prod/tour | Prod amelioree |
|----------|------------------|-------|-----------|----------------|
| Ferme d'algues | 15 Corail | 1 tour | +5 Algues | Niv2: +8, Niv3: +12 |
| Mine de corail | 10 Minerai | 1 tour | +4 Corail | Niv2: +7, Niv3: +11 |
| Extracteur de minerai | 15 Corail | 1 tour | +3 Minerai | Niv2: +5, Niv3: +8 |

**Niveaux d'amelioration** :

| Niveau | Cout amelioration | Temps |
|--------|------------------|-------|
| 1 -> 2 | 1.5x cout initial | 1 tour |
| 2 -> 3 | 2x cout initial | 1 tour |

**Regles de construction** :
- Un seul batiment peut etre construit a la fois (file de construction de taille 1)
- Le batiment en construction n'est pas operationnel (ne produit pas)
- La construction commence immediatement au tour ou l'ordre est donne
- Le batiment est operationnel au tour suivant (apres resolution)
- Le joueur ne peut construire que s'il a les ressources suffisantes

**Regles d'amelioration** :
- Un batiment ne peut etre ameliore que s'il n'est pas en construction
- Le batiment continue de produire pendant l'amelioration au taux de son niveau actuel
- Le nouveau taux de production s'applique au tour suivant la fin de l'amelioration

**Criteres d'acceptation** :
- [ ] Les 3 batiments sont disponibles a la construction
- [ ] Le cout est affiche avant la construction
- [ ] Le bouton "Construire" est grise si ressources insuffisantes
- [ ] Le batiment en construction affiche un indicateur visuel + tours restants
- [ ] Le batiment construit affiche son niveau et sa production
- [ ] Le batiment peut etre ameliore de niveau 1 a 3
- [ ] L'amelioration affiche le cout et le benefice attendu
- [ ] Plusieurs batiments du meme type peuvent etre construits

#### F1.5 — Bouton "Tour Suivant"

**Description** : Le bouton qui fait avancer le jeu d'un tour.

**Sequence de resolution d'un tour** :
1. Avancement des constructions en cours (turnsRemaining -= 1)
2. Finalisation des constructions terminees (turnsRemaining == 0)
3. Production des ressources par les batiments operationnels
4. Incrementation du compteur de tour

**Resume du tour** :
Apres la resolution, un resume est affiche au joueur :
- Batiments termines : "Ferme d'algues construite !"
- Production : "+5 Algues, +4 Corail, +3 Minerai"
- Nouveau total de ressources

**Criteres d'acceptation** :
- [ ] Le bouton "Tour Suivant" est toujours visible et cliquable
- [ ] Le resume du tour s'affiche apres chaque tour
- [ ] Le resume liste toutes les productions
- [ ] Le resume liste les constructions terminees
- [ ] Le joueur peut fermer le resume et continuer a jouer
- [ ] Le resume est une modale ou un panneau qui ne bloque pas le jeu plus que necessaire

#### F1.6 — Sauvegarde automatique via Hive

**Description** : Le jeu sauvegarde automatiquement l'etat de la partie.

**Declencheurs de sauvegarde** :
- Apres chaque resolution de tour
- Avant la fermeture de l'application (si possible)

**Donnees sauvegardees** :
- Numero du tour
- Stock de ressources (Algues, Corail, Minerai)
- Liste des batiments avec leur type, niveau et etat de construction
- Etat des constructions en cours

**Regles** :
- La sauvegarde est transparente pour le joueur (pas de bouton "Sauvegarder")
- Au lancement, si une sauvegarde existe, la partie reprend automatiquement
- Si aucune sauvegarde n'existe, une nouvelle partie demarre

**Criteres d'acceptation** :
- [ ] La partie est sauvegardee automatiquement apres chaque tour
- [ ] Fermer et relancer l'app restaure l'etat exact du jeu
- [ ] La sauvegarde inclut tous les champs du GameState (a ce stade)
- [ ] La sauvegarde/chargement est performant (< 100ms)

### 5.3 Tests requis — Etape 1

**Tests unitaires** :
- ResourceSet : ajout, soustraction, verification de suffisance
- Building : construction, amelioration, production
- TurnResolution : sequence correcte de resolution
- Sauvegarde/chargement : serialisation/deserialisation du GameState

**Tests d'integration** :
- Tour complet : construction -> tour suivant -> batiment operationnel -> production
- Amelioration : ameliorer -> tour suivant -> production augmentee
- Sauvegarde : jouer -> fermer -> rouvrir -> etat identique

---

## 6. Etape 2 — Energie & Contraintes

### 6.1 Objectif

Introduire l'Energie comme 4eme ressource et le concept de contrainte du QG pour
ajouter de la profondeur strategique a la gestion de base.

### 6.2 Fonctionnalites

#### F2.1 — Ressource Energie

**Description** : L'Energie est une nouvelle ressource produite par le Panneau solaire.

**Specifications** :

| Propriete | Valeur |
|-----------|--------|
| Stock initial | 10 |
| Icone | Eclair |
| Couleur | Jaune |

**Panneau solaire (batiment)** :

| Propriete | Valeur |
|-----------|--------|
| Cout | 20 Corail, 10 Minerai |
| Temps de construction | 1 tour |
| Production Niv 1 | +4 Energie/tour |
| Production Niv 2 | +7 Energie/tour |
| Production Niv 3 | +11 Energie/tour |

**Criteres d'acceptation** :
- [ ] L'Energie apparait dans la barre de ressources
- [ ] Le Panneau solaire est constructible
- [ ] Le Panneau solaire produit de l'Energie a chaque tour
- [ ] L'Energie peut etre depensee pour des constructions

#### F2.2 — Amelioration du QG

**Description** : Le QG peut etre ameliore du niveau 1 au niveau 5.

**Specifications d'amelioration** :

| Niveau QG | Cout | Temps | Max batiments | Max niveau batiment |
|-----------|------|-------|---------------|-------------------|
| 1 | - | - | 3 | 1 |
| 2 | 30 Corail, 20 Minerai, 10 Energie | 2 tours | 5 | 2 |
| 3 | 60 Corail, 40 Minerai, 20 Energie | 3 tours | 8 | 3 |
| 4 | 100 Corail, 70 Minerai, 40 Energie | 4 tours | 12 | 4 |
| 5 | 150 Corail, 100 Minerai, 60 Energie | 5 tours | 16 | 5 |

**Contraintes du QG** :
- Le nombre total de batiments (hors QG) ne peut pas depasser le max du niveau de QG
- Le niveau max des batiments est limite par le niveau du QG
- Il est impossible d'ameliorer un batiment au-dela du niveau permis par le QG

**Criteres d'acceptation** :
- [ ] Le QG affiche un bouton "Ameliorer" avec le cout
- [ ] L'amelioration prend le nombre de tours indique
- [ ] Pendant l'amelioration, le QG reste operationnel (contraintes maintenues)
- [ ] Le nombre max de batiments est affiche et respecte
- [ ] Le niveau max des batiments est affiche et respecte
- [ ] Construire un batiment au-dela du max est impossible (bouton grise + message)
- [ ] Ameliorer un batiment au-dela du max est impossible (bouton grise + message)

#### F2.3 — Couts diversifies

**Description** : Certains batiments et ameliorations coutent desormais de l'Energie.

**Mise a jour des couts** :

| Batiment | Cout Niv 1 | Cout Niv 2 | Cout Niv 3 |
|----------|-----------|-----------|-----------|
| Ferme d'algues | 15 Corail | 22 Corail, 5 Energie | 30 Corail, 10 Energie |
| Mine de corail | 10 Minerai | 15 Minerai, 5 Energie | 20 Minerai, 10 Energie |
| Extracteur de minerai | 15 Corail | 22 Corail, 8 Energie | 30 Corail, 15 Energie |
| Panneau solaire | 20 Corail, 10 Minerai | 30 Corail, 15 Minerai | 40 Corail, 20 Minerai |

**Criteres d'acceptation** :
- [ ] Les couts mis a jour sont affiches correctement
- [ ] L'Energie est verifiee lors de la construction/amelioration
- [ ] Le joueur voit clairement quelles ressources manquent

### 6.3 Tests requis — Etape 2

**Tests unitaires** :
- Contrainte max batiments : refus de construction au-dela du max
- Contrainte max niveau : refus d'amelioration au-dela du max
- Amelioration QG : cout, duree, deblocage des contraintes
- Energie : production, consommation, verification dans les couts

**Tests d'integration** :
- Ameliorer QG -> debloquer plus de batiments -> construire
- Ameliorer QG -> debloquer niveaux superieurs -> ameliorer batiments

---

## 7. Etape 3 — Carte & Exploration

### 7.1 Objectif

Le joueur sort de sa base et decouvre une carte en grille avec fog of war.
Il peut recruter des eclaireurs pour explorer le monde.

### 7.2 Fonctionnalites

#### F3.1 — Carte en grille 20x20

**Description** : Le monde est represente par une grille 20x20 avec fog of war.

**Types de terrain** :

| Terrain | Couleur | Effet | Frequence |
|---------|---------|-------|-----------|
| Recif | Rose clair | Aucun (terrain standard) | 40% |
| Plaine | Bleu clair | Aucun (terrain standard) | 30% |
| Roche | Gris | Bloque le passage (infranchissable) | 15% |
| Faille | Noir | Dangereux (degats aux unites qui traversent) | 15% |

**Generation de la carte** :
- La carte est generee aleatoirement au debut de la partie
- La base du joueur est placee au centre ou pres du centre
- Les cases adjacentes a la base (rayon de 2) sont revelees au depart
- La base ne peut pas etre placee sur une case Roche ou Faille
- Au moins un chemin libre existe vers chaque bord de la carte

**Navigation** :
- Le joueur peut zoomer et dezoomer sur la carte
- Le joueur peut deplacer la camera (pan) par glissement
- Un bouton "Centrer sur la base" est disponible
- Les cases non revelees affichent un brouillard opaque

**Criteres d'acceptation** :
- [ ] La grille 20x20 est affichee correctement
- [ ] Le fog of war masque les cases non revelees
- [ ] Les cases revelees affichent leur type de terrain
- [ ] Le zoom et le pan fonctionnent de maniere fluide
- [ ] Le bouton "Centrer" ramene la vue sur la base
- [ ] La carte est accessible depuis un onglet/bouton de l'ecran principal

#### F3.2 — Caserne et Eclaireur

**Description** : La Caserne est un nouveau batiment qui permet de recruter des Eclaireurs.

**Caserne** :

| Propriete | Valeur |
|-----------|--------|
| Cout | 20 Corail, 15 Minerai |
| Temps de construction | 1 tour |
| Fonction | Recruter des unites |
| Ameliorable | Oui (niveaux 1-3, reduit le cout de recrutement) |

**Eclaireur** :

| Propriete | Valeur |
|-----------|--------|
| Cout de recrutement | 10 Algues, 5 Corail |
| Temps de recrutement | 1 tour |
| PV | 10 |
| Attaque | 1 |
| Defense | 1 |
| Deplacement | 1 case/tour |
| Vision | Revele les cases adjacentes (rayon 1) |

**Regles de recrutement** :
- Le joueur doit avoir une Caserne operationnelle
- Un seul recrutement par Caserne par tour
- L'unite apparait a la base au tour suivant
- Le cout est paye immediatement

**Criteres d'acceptation** :
- [ ] La Caserne est constructible
- [ ] Le recrutement d'Eclaireur est possible depuis la Caserne
- [ ] L'Eclaireur apparait a la position de la base apres 1 tour
- [ ] Le cout est retire immediatement
- [ ] L'icone de l'Eclaireur est visible sur la carte

#### F3.3 — Deplacement et exploration

**Description** : Les Eclaireurs se deplacent sur la carte et revelent les cases.

**Regles de deplacement** :
- Deplacement de 1 case par tour dans les 4 directions (haut, bas, gauche, droite)
- Le joueur donne l'ordre de deplacement pendant sa phase d'action
- Le deplacement est execute a la resolution du tour
- Impossible de se deplacer sur une case Roche
- Se deplacer sur une Faille inflige 3 PV de degats
- Une unite avec 0 PV est detruite

**Regles de revelation** :
- Quand une unite se deplace sur une case, cette case est revelee
- Les cases adjacentes (haut, bas, gauche, droite) sont aussi revelees
- Une case revelee le reste indefiniment (pas de re-fog)

**Criteres d'acceptation** :
- [ ] Le joueur peut selectionner un Eclaireur sur la carte
- [ ] Les cases valides pour le deplacement sont surlignees
- [ ] Le deplacement s'execute a la resolution du tour
- [ ] Les cases sont revelees apres le deplacement
- [ ] Les cases adjacentes sont aussi revelees
- [ ] Le deplacement sur Roche est refuse
- [ ] Le deplacement sur Faille inflige des degats
- [ ] Une unite a 0 PV est retiree de la carte

#### F3.4 — Contenu des cases

**Description** : Certaines cases contiennent des elements decouverts a l'exploration.

**Types de contenu** :

| Contenu | Probabilite | Effet |
|---------|------------|-------|
| Vide | 60% | Aucun |
| Ressources bonus | 20% | Donne 10-30 d'une ressource aleatoire |
| Ruines | 10% | Donne 20-50 d'une ressource + chance de Perles |
| Base de monstres | 10% | Bloque la case (combat necessaire a l'etape 5) |

**Regles** :
- Le contenu est genere a la creation de la carte
- Le contenu est invisible tant que la case n'est pas revelee
- Les ressources bonus sont collectees automatiquement quand l'unite arrive sur la case
- Les ruines donnent des ressources et disparaissent
- Les bases de monstres restent (pas d'interaction a cette etape)

**Criteres d'acceptation** :
- [ ] Les cases avec contenu affichent une icone specifique une fois revelees
- [ ] Les ressources bonus sont ajoutees au stock du joueur
- [ ] Les ruines donnent des ressources et disparaissent apres collecte
- [ ] Un message dans le resume du tour indique les decouvertes
- [ ] Les bases de monstres sont visibles mais non interactibles (etape 5)

### 7.3 Tests requis — Etape 3

**Tests unitaires** :
- Generation de carte : distribution des terrains, chemin libre
- Fog of war : cases revelees/cachees, propagation de vision
- Deplacement : validation, degats de faille, destruction d'unite
- Collecte : ressources bonus, ruines

**Tests d'integration** :
- Construire Caserne -> recruter Eclaireur -> deplacer -> reveler -> collecter

---

## 8. Etape 4 — Kit de Depart & Nouvelle Partie

### 8.1 Objectif

Le joueur peut choisir un kit de depart pour personnaliser sa strategie initiale
et recommencer une nouvelle partie.

### 8.2 Fonctionnalites

#### F4.1 — Ecran de choix du kit de depart

**Description** : Avant de commencer une partie, le joueur choisit parmi 3 kits.

**Specifications des kits** :

| Kit | Ressources initiales | Batiments | Unites | Bonus |
|-----|---------------------|-----------|--------|-------|
| Militaire | 40A, 25C, 15M, 10E | QG, Caserne Niv1 | 2 Eclaireurs | +20% stats combat |
| Economique | 80A, 50C, 35M, 15E | QG, Ferme Niv1, Mine Niv1 | 0 | +20% production |
| Explorateur | 50A, 30C, 20M, 10E | QG, Caserne Niv1 | 3 Eclaireurs | Vision +1 rayon |

**Ecran de selection** :
- 3 cartes cote a cote (ou empilees sur mobile)
- Chaque carte affiche : nom du kit, illustration, contenu detaille
- Bouton "Choisir" sur chaque carte
- Confirmation avant de lancer la partie

**Criteres d'acceptation** :
- [ ] L'ecran de choix s'affiche au lancement d'une nouvelle partie
- [ ] Les 3 kits sont affiches avec leur contenu detaille
- [ ] Le joueur peut selectionner un kit et confirmer
- [ ] Les ressources et batiments du kit sont appliques au debut de la partie
- [ ] Le bonus du kit est actif pendant toute la partie
- [ ] Le kit choisi est sauvegarde dans le GameState

#### F4.2 — Menu principal et nouvelle partie

**Description** : Un menu principal permet de gerer les parties.

**Options du menu** :
- "Continuer" (si une sauvegarde existe)
- "Nouvelle partie" (lance l'ecran de choix du kit)
- "Parametres" (reserve pour plus tard)

**Regles** :
- "Continuer" charge la sauvegarde existante
- "Nouvelle partie" demande confirmation si une sauvegarde existe
- Une nouvelle partie ecrase la sauvegarde precedente (apres confirmation)

**Criteres d'acceptation** :
- [ ] Le menu principal s'affiche au lancement de l'app
- [ ] "Continuer" est disponible si une sauvegarde existe
- [ ] "Continuer" est grise sinon
- [ ] "Nouvelle partie" affiche une confirmation si une sauvegarde existe
- [ ] La nouvelle partie lance l'ecran de choix du kit

#### F4.3 — Ressource Perles

**Description** : Les Perles sont une ressource rare trouvee uniquement par exploration.

**Specifications** :

| Propriete | Valeur |
|-----------|--------|
| Stock initial | 0 |
| Icone | Perle |
| Couleur | Blanc nacre |
| Sources | Exploration (ruines, cases speciales), combat (butin) |
| Utilisation | Technologies avancees (etape 6) |

**Cases a Perles sur la carte** :
- 3 a 5 cases speciales "Gisement de perles" par carte
- Chaque gisement donne 2-5 Perles
- Les gisements sont repartis aleatoirement, avec un biais vers les bords de la carte

**Criteres d'acceptation** :
- [ ] Les Perles apparaissent dans la barre de ressources
- [ ] Les gisements de perles sont presents sur la carte
- [ ] Collecter un gisement ajoute les Perles au stock
- [ ] Les Perles ne sont pas produites par des batiments

### 8.3 Tests requis — Etape 4

**Tests unitaires** :
- Application des kits : ressources, batiments, unites, bonus
- Sauvegarde/chargement : nouveau game state avec kit
- Generation de perles : placement, collecte

**Tests d'integration** :
- Menu -> Nouvelle partie -> Choix kit -> Debut de partie avec le bon kit
- Menu -> Continuer -> Reprise de la partie sauvegardee

---

## 9. Etape 5 — Unites de Combat & Monstres

### 9.1 Objectif

Introduire les unites de combat et les bases de monstres pour ajouter
une dimension militaire au jeu.

### 9.2 Fonctionnalites

#### F5.1 — Unites de combat

**Description** : Le joueur peut recruter des Plongeurs soldats a la Caserne.

**Plongeur soldat** :

| Propriete | Valeur |
|-----------|--------|
| Cout de recrutement | 15 Algues, 10 Corail, 5 Minerai |
| Temps de recrutement | 1 tour |
| PV | 25 |
| Attaque | 8 |
| Defense | 5 |
| Deplacement | 1 case/tour |

**Regles** :
- Recrute a la Caserne (meme batiment que l'Eclaireur)
- Le niveau de la Caserne reduit le cout de recrutement (-10% par niveau)
- Plusieurs Plongeurs soldats peuvent etre recrutes (1 par Caserne par tour)
- Le Plongeur soldat revele les cases comme l'Eclaireur

**Criteres d'acceptation** :
- [ ] Le Plongeur soldat est recruitable depuis la Caserne
- [ ] Ses stats sont affichees lors du recrutement
- [ ] Il peut se deplacer sur la carte comme l'Eclaireur
- [ ] Il revele les cases comme l'Eclaireur

#### F5.2 — Bases de monstres

**Description** : Des bases de monstres sont presentes sur la carte et gardent des tresors.

**Niveaux de difficulte** :

| Difficulte | PV Monstre | Attaque | Defense | Butin | Probabilite |
|------------|-----------|---------|---------|-------|------------|
| Facile | 15 | 5 | 3 | 15-25 ressources | 50% |
| Moyen | 30 | 10 | 7 | 30-50 ressources | 35% |
| Difficile | 50 | 15 | 12 | 60-100 ressources + 1-3 Perles | 15% |

**Placement** :
- 5 a 10 bases de monstres par carte
- Pas de monstres dans le rayon initial du joueur (rayon 3)
- Les monstres difficiles sont plus eloignes de la base du joueur

**Criteres d'acceptation** :
- [ ] Les bases de monstres sont visibles sur les cases revelees
- [ ] Le niveau de difficulte est affiche (icone de couleur : vert/orange/rouge)
- [ ] Les monstres ne se deplacent pas
- [ ] Les monstres ne sont generes que lors de la creation de la carte

#### F5.3 — Systeme de combat

**Description** : Resolution automatique des combats au tour suivant.

**Formule de combat** :
```
degats_attaquant = max(1, attaque_attaquant - defense_defenseur)
degats_defenseur = max(1, attaque_defenseur - defense_attaquant)

// Appliques simultanement
pv_defenseur -= degats_attaquant
pv_attaquant -= degats_defenseur
```

**Regles** :
- Le joueur lance une attaque en deplacant une unite sur une case monstre
- Le combat se resout a la resolution du tour
- Les degats sont appliques simultanement
- Si le monstre est vaincu (PV <= 0), le butin est collecte
- Si l'unite est vaincue (PV <= 0), elle est detruite
- Si les deux survivent, le combat reprend au tour suivant automatiquement
- Plusieurs unites peuvent attaquer le meme monstre (degats cumules)

**Combat avec plusieurs unites** :
- Les degats des unites attaquantes s'additionnent
- Le monstre repartit ses degats equitablement entre les unites
- Formule : degats_monstre_par_unite = degats_monstre / nombre_unites (arrondi au superieur)

**Resume de combat** :
- Le resume du tour indique les combats et leurs resultats
- Degats infliges et recus
- PV restants de chaque participant
- Butin collecte en cas de victoire

**Criteres d'acceptation** :
- [ ] Le combat se declenche quand une unite entre sur une case monstre
- [ ] La resolution est automatique a la fin du tour
- [ ] Les degats sont calcules selon la formule
- [ ] Le butin est collecte en cas de victoire
- [ ] L'unite detruite est retiree de la carte
- [ ] Le resume du tour affiche les details du combat
- [ ] Plusieurs unites peuvent combattre le meme monstre

#### F5.4 — Butin

**Description** : Le butin est distribue apres la victoire contre un monstre.

**Table de butin** :

| Difficulte | Algues | Corail | Minerai | Energie | Perles |
|------------|--------|--------|---------|---------|--------|
| Facile | 10-15 | 5-10 | 3-8 | 0 | 0 |
| Moyen | 20-30 | 15-20 | 10-15 | 5-10 | 0 |
| Difficile | 30-50 | 25-35 | 15-25 | 10-20 | 1-3 |

**Regles** :
- Le butin est aleatoire dans les fourchettes indiquees
- Le butin est ajoute directement au stock du joueur
- La case devient vide apres la victoire

**Criteres d'acceptation** :
- [ ] Le butin est genere aleatoirement dans les fourchettes
- [ ] Le butin est ajoute au stock du joueur
- [ ] Le resume du tour detaille le butin obtenu
- [ ] La case monstre est nettoyee apres la victoire

### 9.3 Tests requis — Etape 5

**Tests unitaires** :
- Formule de combat : calcul de degats, cas limites (defense >= attaque)
- Combat multi-unites : repartition des degats
- Butin : generation aleatoire dans les fourchettes
- Mort d'unite : destruction a 0 PV

**Tests d'integration** :
- Recruter soldat -> deplacer sur monstre -> combat -> butin
- Multi-unites -> combat -> repartition des degats -> victoire

---

## 10. Etape 6 — Technologies

### 10.1 Objectif

L'arbre technologique ajoute de la profondeur strategique : le joueur
choisit comment specialiser sa base.

### 10.2 Fonctionnalites

#### F6.1 — Laboratoire

**Description** : Nouveau batiment necessaire pour la recherche.

| Propriete | Valeur |
|-----------|--------|
| Cout | 25 Corail, 20 Minerai, 15 Energie |
| Temps de construction | 2 tours |
| Ameliorable | Oui (niveaux 1-3) |
| Effet amelioration | Reduit le temps de recherche de 1 tour par niveau |
| Limite | 1 seul Laboratoire |

**Criteres d'acceptation** :
- [ ] Le Laboratoire est constructible
- [ ] Un seul Laboratoire peut exister
- [ ] Le Laboratoire debloque le menu de recherche
- [ ] L'amelioration reduit le temps de recherche

#### F6.2 — Arbre Economie

**Description** : 6 technologies ameliorant la production et reduisant les couts.

| Tech | Prerequis | Cout | Temps | Effet |
|------|-----------|------|-------|-------|
| Agriculture avancee | - | 20C, 10M | 2 tours | +25% prod Algues |
| Forage profond | - | 15C, 15M | 2 tours | +25% prod Minerai |
| Architecture corallienne | Agriculture avancee | 30C, 20M | 3 tours | +25% prod Corail |
| Optimisation energetique | Forage profond | 25C, 25M, 5E | 3 tours | +25% prod Energie |
| Recyclage | Architecture, Optimisation | 40C, 30M, 10E | 4 tours | -15% cout construction |
| Maitrise des ressources | Recyclage | 50C, 40M, 20E, 3P | 5 tours | +50% toutes productions |

#### F6.3 — Arbre Militaire

| Tech | Prerequis | Cout | Temps | Effet |
|------|-----------|------|-------|-------|
| Entrainement renforce | - | 15C, 15M | 2 tours | +20% attaque unites |
| Armure renforcee | - | 20C, 10M | 2 tours | +20% defense unites |
| Tactiques de combat | Entrainement | 30C, 20M, 5E | 3 tours | +2 PV toutes unites |
| Armes avancees | Armure renforcee | 25C, 25M, 10E | 3 tours | +30% attaque unites |
| Mecanique sous-marine | Tactiques, Armes | 40C, 35M, 15E | 4 tours | Debloque l'Atelier |
| Arsenal ultime | Mecanique | 60C, 50M, 25E, 5P | 5 tours | +50% stats combat |

#### F6.4 — Arbre Exploration

| Tech | Prerequis | Cout | Temps | Effet |
|------|-----------|------|-------|-------|
| Cartographie avancee | - | 15C, 10M | 2 tours | Vision +1 rayon |
| Sondes sous-marines | - | 20C, 15M | 2 tours | Eclaireur +1 deplacement |
| Navigation profonde | Cartographie | 25C, 20M, 5E | 3 tours | Ignore degats Faille |
| Radar oceanique | Sondes | 30C, 25M, 10E | 3 tours | Revele monstres a distance 2 |
| Expedition autonome | Navigation, Radar | 40C, 30M, 15E | 4 tours | Eclaireur +1 deplacement |
| Omniscience abyssale | Expedition | 50C, 40M, 20E, 3P | 5 tours | Vision +2 rayon |

**Regles generales de recherche** :
- Une seule recherche a la fois par Laboratoire
- Les prerequis doivent etre recherches avant
- Les Perles ne sont necessaires que pour les techs de niveau 5-6
- Les bonus s'appliquent immediatement a la fin de la recherche

**Criteres d'acceptation** :
- [ ] L'arbre technologique est affichable avec les 3 branches
- [ ] Les prerequis sont visibles (technologies grisees si non debloquees)
- [ ] Le cout et le temps sont affiches pour chaque tech
- [ ] La recherche en cours est indiquee avec le temps restant
- [ ] Les effets s'appliquent immediatement a la fin de la recherche
- [ ] Le resume du tour annonce les recherches terminees

### 10.3 Tests requis — Etape 6

**Tests unitaires** :
- Prerequis : validation des chaines de prerequis
- Effets : application correcte des bonus de production/combat/exploration
- Cout Perles : verification pour les techs avancees

**Tests d'integration** :
- Construire Labo -> rechercher tech -> appliquer bonus -> verifier production

---

## 11. Etape 7 — Factions IA

### 11.1 Objectif

Le joueur n'est plus seul sur la carte. Des factions IA occupent le monde,
progressent et peuvent etre hostiles.

### 11.2 Fonctionnalites

#### F7.1 — Presence des factions IA

**Description** : 10 a 20 factions IA sont presentes sur la carte.

**Specifications d'une faction** :

| Propriete | Valeur |
|-----------|--------|
| Nom | Genere aleatoirement (thematique sous-marine) |
| Base | 1 case sur la carte |
| Ressources | Simplifiees (1 score de puissance) |
| Armee | Simplifiee (1 score militaire) |
| Disposition | Neutre ou Hostile |

**Placement** :
- Les factions sont reparties sur la carte a distance minimale les unes des autres
- Distance minimale entre deux factions : 4 cases
- Distance minimale du joueur : 5 cases
- Les factions sont cachees par le fog of war

**Progression IA** :
- Chaque tour, la faction IA gagne +1 puissance et +1 score militaire
- La puissance influence la force des unites IA
- La progression est lineaire et previsible (pas d'IA complexe a cette etape)

**Criteres d'acceptation** :
- [ ] 10-20 factions IA sont generees sur la carte
- [ ] Les factions sont decouvertes via l'exploration
- [ ] Une faction decouverte affiche son nom et sa disposition
- [ ] Les factions IA progressent chaque tour
- [ ] Les factions sont cachees par le fog of war

#### F7.2 — Diplomatie basique

**Description** : Les factions sont soit Neutres soit Hostiles.

**Regles** :
- 70% des factions commencent Neutres
- 30% des factions commencent Hostiles
- Les factions Hostiles peuvent attaquer le joueur
- Les factions Neutres ne font rien (a cette etape)
- La disposition est fixe (pas de changement a cette etape)

**Criteres d'acceptation** :
- [ ] La disposition est affichee (Neutre en bleu, Hostile en rouge)
- [ ] Les factions Hostiles attaquent le joueur si a portee
- [ ] Les factions Neutres ne declenchent pas de combat

#### F7.3 — Combat PvE contre factions

**Description** : Le combat contre les factions utilise le meme systeme que les monstres.

**Regles** :
- Le joueur peut attaquer les factions Hostiles
- Les factions Hostiles peuvent attaquer le joueur (si a 3 cases de la base joueur)
- Le combat utilise le score militaire de la faction comme stats
- Score militaire = attaque ET defense de la faction
- Vaincre une faction rapporte un butin proportionnel a sa puissance
- La faction vaincue est retiree de la carte

**Defense de la base** :
- Les unites du joueur a la base defendent automatiquement
- Si aucune unite a la base, le QG a une defense de base : 10 PV, 3 defense
- Si le QG est vaincu, la partie est perdue (game over)

**Criteres d'acceptation** :
- [ ] Le joueur peut attaquer les factions Hostiles
- [ ] Les factions Hostiles attaquent le joueur a portee
- [ ] Le combat suit les memes regles que le combat monstre
- [ ] La faction vaincue disparait et donne du butin
- [ ] La defense de la base est automatique
- [ ] Game over si le QG tombe a 0 PV
- [ ] Ecran de game over avec option de recommencer

### 11.3 Tests requis — Etape 7

**Tests unitaires** :
- Generation factions : placement, disposition, progression
- Combat PvE : score militaire -> stats, butin
- Defense de base : automatique, game over

**Tests d'integration** :
- Explorer -> decouvrir faction hostile -> combat -> victoire/defaite
- Faction hostile a portee -> attaque de la base -> defense

---

## 12. Etape 8 — Alliances

### 12.1 Objectif

Le joueur peut former une alliance avec des factions IA et leur donner des ordres.

### 12.2 Fonctionnalites

#### F8.1 — Systeme d'alliance

**Description** : Le joueur est le meneur d'une alliance pouvant contenir jusqu'a 10 factions.

**Regles** :
- Le joueur cree son alliance automatiquement (il en est le meneur)
- Maximum 10 membres (joueur inclus)
- Seules les factions Neutres peuvent etre invitees
- L'invitation est envoyee depuis l'ecran de diplomatie

**Probabilite d'acceptation** :

| Facteur | Modificateur |
|---------|-------------|
| Base | 50% |
| Puissance du joueur > puissance faction | +20% |
| Joueur a deja des allies | +10% |
| Faction a haute puissance | -15% |

**Criteres d'acceptation** :
- [ ] Le joueur peut inviter des factions Neutres dans son alliance
- [ ] La faction peut accepter ou refuser
- [ ] L'alliance affiche ses membres et leur disposition
- [ ] Maximum 10 membres
- [ ] Les factions Alliees changent de couleur sur la carte (vert)

#### F8.2 — Humeur des allies

**Description** : Chaque allie a une humeur qui influence ses decisions.

**Echelle d'humeur** :
- Enthousiaste (80-100) : accepte presque tout
- Cooperatif (60-79) : accepte la plupart des ordres
- Neutre (40-59) : accepte 50/50
- Reticent (20-39) : refuse souvent
- Hostile (0-19) : peut quitter l'alliance

**Facteurs d'humeur** :

| Action | Effet sur l'humeur |
|--------|-------------------|
| Envoyer des ressources a l'allie | +10 |
| Ordre raisonnable accepte et reussi | +5 |
| Ordre suicide (attaquer ennemi tres fort) | -15 |
| Ne pas aider un allie attaque | -10 |
| Tour sans interaction | -1 |

**Criteres d'acceptation** :
- [ ] L'humeur de chaque allie est affichee (barre ou texte)
- [ ] L'humeur evolue selon les actions du joueur
- [ ] Un allie dont l'humeur tombe a 0 quitte l'alliance
- [ ] Le joueur peut voir les facteurs d'humeur

#### F8.3 — Ordres aux allies

**Description** : Le joueur peut donner des ordres a ses allies.

**Types d'ordres** :

| Ordre | Description | Cout | Proba acceptation |
|-------|------------|------|------------------|
| Attaquer | Attaque une cible designee | - | Humeur - 20 si cible forte |
| Defendre | Defend une position | - | Humeur |
| Envoyer ressources | Envoie des ressources au joueur | - | Humeur - 10 |
| Explorer | Explore une zone | - | Humeur + 10 |

**Regles** :
- 1 ordre par allie par tour
- L'allie repond au tour suivant (accepte ou refuse)
- L'execution de l'ordre prend 1-3 tours supplementaires
- Le resultat est affiche dans le resume du tour

**Criteres d'acceptation** :
- [ ] Le joueur peut donner 1 ordre par allie par tour
- [ ] La reponse est affichee au tour suivant
- [ ] L'execution prend 1-3 tours
- [ ] Le resultat est affiche dans le resume du tour
- [ ] Les ordres suicidaires degradent l'humeur

### 12.3 Tests requis — Etape 8

**Tests unitaires** :
- Probabilite d'acceptation invitation : calcul avec modificateurs
- Humeur : evolution, limites, depart d'alliance
- Ordres : validation, probabilite d'acceptation, execution

**Tests d'integration** :
- Inviter faction -> accepte -> donner ordre -> execution -> humeur evolue

---

## 13. Etape 9 — Evenements Aleatoires

### 13.1 Objectif

Des evenements aleatoires surviennent pour varier le gameplay et rendre chaque partie unique.

### 13.2 Fonctionnalites

#### F9.1 — Evenements negatifs

| Evenement | Probabilite/tour | Effet | Duree |
|-----------|-----------------|-------|-------|
| Courant marin violent | 5% | Deplace unites aleatoirement de 1-2 cases | Instantane |
| Eruption volcanique | 3% | -10 PV a toutes les unites sur 1 zone (3x3) | Instantane |
| Maree toxique | 4% | -50% production Algues | 3 tours |
| Tempete de pression | 4% | Aucun deplacement possible | 1 tour |

#### F9.2 — Evenements positifs

| Evenement | Probabilite/tour | Effet | Duree |
|-----------|-----------------|-------|-------|
| Epave ancienne | 5% | +20-40 ressources aleatoires | Instantane |
| Ruines mysterieuses | 3% | +2-5 Perles | Instantane |
| Creature rare | 3% | Unite speciale (15PV, 10ATK, 8DEF, 2MOV) | Permanente |
| Gisement cache | 4% | Revele une case riche (50+ ressources) | Instantane |

**Regles generales** :
- Un seul evenement par tour maximum
- Probabilite totale d'un evenement : ~31% par tour
- Les evenements positifs et negatifs sont equilibres (16% negatif, 15% positif)
- L'evenement est choisi aleatoirement parmi les possibles
- Si un evenement positif ET un negatif auraient du se declencher, un seul est choisi

**Notification** :
- L'evenement est affiche en debut de resume du tour
- Description de l'evenement avec illustration
- Consequences detaillees
- Evenement negatif : bordure rouge
- Evenement positif : bordure doree

**Criteres d'acceptation** :
- [ ] Les evenements se declenchent aleatoirement
- [ ] Maximum 1 evenement par tour
- [ ] Les effets sont appliques correctement
- [ ] La notification est claire et detaillee
- [ ] Les effets de duree sont suivis et se terminent
- [ ] La creature rare est ajoutee comme unite controlee par le joueur

#### F9.3 — Creatures rares apprivoisables

**Description** : La creature rare est une unite speciale bonus.

**Specifications** :

| Propriete | Valeur |
|-----------|--------|
| PV | 15 |
| Attaque | 10 |
| Defense | 8 |
| Deplacement | 2 cases/tour |
| Capacite speciale | Regenere 2 PV/tour |
| Recrutement | Non (uniquement via evenement) |

**Criteres d'acceptation** :
- [ ] La creature apparait a la base du joueur
- [ ] La creature est controlable comme une unite normale
- [ ] La regeneration fonctionne chaque tour
- [ ] La creature peut combattre normalement

### 13.3 Tests requis — Etape 9

**Tests unitaires** :
- Probabilites : distribution des evenements
- Effets : application de chaque type d'evenement
- Duree : suivi et expiration des effets temporaires

**Tests d'integration** :
- Tour -> evenement negatif -> effet applique -> resume affiches
- Tour -> creature rare -> unite ajoutee -> controlable

---

## 14. Etape 10 — Unites Avancees (Machines)

### 14.1 Objectif

Debloquer le tier superieur d'unites via la technologie "Mecanique sous-marine".

### 14.2 Fonctionnalites

#### F10.1 — Atelier mecanique

**Description** : Nouveau batiment debloque par la technologie "Mecanique sous-marine".

| Propriete | Valeur |
|-----------|--------|
| Prerequis | Technologie "Mecanique sous-marine" |
| Cout | 40 Corail, 30 Minerai, 20 Energie |
| Temps de construction | 3 tours |
| Ameliorable | Oui (niveaux 1-3) |
| Effet amelioration | Reduit le cout de recrutement de 10% par niveau |
| Limite | 1 seul Atelier |

**Criteres d'acceptation** :
- [ ] L'Atelier est constructible uniquement apres la tech "Mecanique sous-marine"
- [ ] L'Atelier permet de recruter des machines
- [ ] Un seul Atelier peut exister
- [ ] Le recrutement se fait depuis l'Atelier

#### F10.2 — Drone de reconnaissance

| Propriete | Valeur |
|-----------|--------|
| Cout | 20 Minerai, 15 Energie |
| Temps de recrutement | 2 tours |
| PV | 5 |
| Attaque | 0 |
| Defense | 0 |
| Deplacement | 3 cases/tour |
| Vision | Rayon 3 |
| Capacite | Exploration longue distance, fragile |

**Criteres d'acceptation** :
- [ ] Le Drone est recruitable depuis l'Atelier
- [ ] Le Drone a une vision de rayon 3
- [ ] Le Drone se deplace de 3 cases/tour
- [ ] Le Drone ne peut pas combattre (fuit si attaque)

#### F10.3 — Mini sous-marin

| Propriete | Valeur |
|-----------|--------|
| Cout | 30 Minerai, 25 Energie |
| Temps de recrutement | 2 tours |
| PV | 40 |
| Attaque | 15 |
| Defense | 10 |
| Deplacement | 2 cases/tour |
| Capacite | Combat moyen, mobilite elevee |

**Criteres d'acceptation** :
- [ ] Le Mini sous-marin est recruitable depuis l'Atelier
- [ ] Le Mini sous-marin peut combattre
- [ ] Le Mini sous-marin se deplace de 2 cases/tour

#### F10.4 — Torpille automatique

| Propriete | Valeur |
|-----------|--------|
| Cout | 25 Minerai, 20 Energie |
| Temps de recrutement | 1 tour |
| PV | 1 (detruite apres usage) |
| Attaque | 50 |
| Defense | 0 |
| Deplacement | 1 case/tour |
| Capacite | Usage unique, degats massifs |

**Regles** :
- La Torpille est detruite apres son attaque (que le monstre/ennemi survive ou non)
- La Torpille ne peut cibler qu'une seule entite
- La Torpille inflige ses degats en premier (avant la riposte)

**Criteres d'acceptation** :
- [ ] La Torpille est recruitable depuis l'Atelier
- [ ] La Torpille est detruite apres son attaque
- [ ] La Torpille inflige 50 degats (avant reduction par defense)
- [ ] La Torpille frappe en premier (pas de riposte possible si cible tuee)

### 14.3 Tests requis — Etape 10

**Tests unitaires** :
- Prerequis Atelier : verification de la technologie
- Stats machines : valeurs correctes
- Torpille : destruction apres usage, frappe en premier

**Tests d'integration** :
- Tech "Mecanique" -> construire Atelier -> recruter machines -> combat

---

## 15. Etape 11 — Niveaux de Profondeur

### 15.1 Objectif

Le monde s'agrandit verticalement. Le joueur descend a travers 3 niveaux
pour atteindre l'objectif final.

### 15.2 Fonctionnalites

#### F11.1 — Niveau 2 : Profondeur

**Description** : Deuxieme grille 20x20 avec des conditions differentes.

**Acces** :
- Construire l'Ascenseur abyssal (batiment special)
- Vaincre le Boss de niveau 1

**Ascenseur abyssal** :

| Propriete | Valeur |
|-----------|--------|
| Prerequis | QG niveau 4 |
| Cout | 80 Corail, 60 Minerai, 40 Energie, 5 Perles |
| Temps de construction | 5 tours |
| Limite | 1 seul |

**Boss de niveau 1** :

| Propriete | Valeur |
|-----------|--------|
| Position | Case speciale sur la carte niveau 1 |
| PV | 100 |
| Attaque | 20 |
| Defense | 15 |
| Butin | 50 de chaque ressource + 10 Perles |

**Differences du niveau 2** :
- Panneaux solaires non fonctionnels (pas de lumiere)
- Nouvelle source d'energie : Geothermie
- Terrains differents : abysses, cheminee volcanique, fosse, caverne
- Monstres plus puissants (stats x1.5)
- Factions IA supplementaires (5-10)

**Geothermie (batiment)** :

| Propriete | Valeur |
|-----------|--------|
| Cout | 30 Corail, 25 Minerai |
| Temps de construction | 2 tours |
| Production Niv 1 | +6 Energie/tour |
| Production Niv 2 | +10 Energie/tour |
| Production Niv 3 | +15 Energie/tour |
| Disponibilite | Niveau 2 et 3 uniquement |

**Criteres d'acceptation** :
- [ ] L'Ascenseur abyssal est constructible au QG niveau 4
- [ ] Le Boss de niveau 1 est present sur la carte
- [ ] Vaincre le boss + Ascenseur construit = acces niveau 2
- [ ] Le niveau 2 est une nouvelle grille 20x20
- [ ] Les Panneaux solaires ne fonctionnent pas au niveau 2
- [ ] La Geothermie est disponible au niveau 2
- [ ] La base du niveau 1 est conservee et continue de produire

#### F11.2 — Niveau 3 : Noyau

**Description** : Troisieme et derniere grille 20x20, environnement extreme.

**Acces** :
- Construire le Tunnel de pression (batiment special au niveau 2)
- Vaincre le Boss de niveau 2

**Tunnel de pression** :

| Propriete | Valeur |
|-----------|--------|
| Prerequis | QG niveau 5 (au niveau 2) |
| Cout | 120 Corail, 100 Minerai, 60 Energie, 10 Perles |
| Temps de construction | 7 tours |
| Limite | 1 seul |

**Boss de niveau 2** :

| Propriete | Valeur |
|-----------|--------|
| PV | 200 |
| Attaque | 35 |
| Defense | 25 |
| Butin | 100 de chaque ressource + 20 Perles |

**Differences du niveau 3** :
- Environnement extreme : toutes les unites perdent 1 PV/tour
- Terrains : magma, roche fondue, cristaux, noyau
- Monstres tres puissants (stats x2.5)
- Le Boss final est au centre de la carte

**Criteres d'acceptation** :
- [ ] Le Tunnel de pression est constructible au niveau 2
- [ ] Le Boss de niveau 2 est present
- [ ] Le niveau 3 est une nouvelle grille 20x20
- [ ] Les unites perdent 1 PV/tour au niveau 3
- [ ] Les monstres sont plus puissants

#### F11.3 — Navigation entre niveaux

**Description** : Le joueur peut naviguer librement entre les niveaux debloques.

**Regles** :
- Un bouton de navigation affiche les niveaux accessibles
- Les unites peuvent descendre/monter (1 tour de transit)
- La base de chaque niveau est independante mais les ressources sont partagees
- Les constructions continuent sur tous les niveaux a chaque tour

**Criteres d'acceptation** :
- [ ] Le joueur peut switcher entre les niveaux debloques
- [ ] Les ressources sont partagees entre les niveaux
- [ ] Les constructions avancent sur tous les niveaux
- [ ] Les unites peuvent transiter entre niveaux (1 tour)

#### F11.4 — Boss final et condition de victoire

**Description** : Le Boss final se trouve au centre du niveau 3.

**Boss final** :

| Propriete | Valeur |
|-----------|--------|
| Position | Centre de la carte niveau 3 |
| PV | 500 |
| Attaque | 50 |
| Defense | 40 |
| Capacite | Regenere 10 PV/tour |
| Butin | Victoire du jeu |

**Criteres d'acceptation** :
- [ ] Le Boss final est au centre du niveau 3
- [ ] Le Boss final a des stats tres elevees
- [ ] Vaincre le Boss final declenche la victoire
- [ ] Le Boss regenere des PV chaque tour

### 15.3 Tests requis — Etape 11

**Tests unitaires** :
- Transition de niveaux : conditions, deblocage
- Boss : stats, combat, victoire
- Geothermie : production, disponibilite par niveau
- Panneau solaire : desactive au niveau 2+

**Tests d'integration** :
- Construire Ascenseur -> vaincre Boss 1 -> acceder niveau 2
- Niveau 2 -> Geothermie -> progression -> Boss 2 -> niveau 3
- Niveau 3 -> Boss final -> victoire

---

## 16. Etape 12 — Ecran de Victoire & Statistiques

### 16.1 Objectif

Conclure l'experience avec un ecran de victoire et des statistiques detaillees.

### 16.2 Fonctionnalites

#### F12.1 — Ecran de victoire

**Description** : Ecran anime affiche apres avoir vaincu le Boss final.

**Contenu** :
- Animation de victoire (thematique sous-marine)
- Message de felicitations
- Statistiques de la partie
- Score final
- Bouton "Rejouer"
- Bouton "Menu principal"

**Criteres d'acceptation** :
- [ ] L'ecran de victoire s'affiche apres avoir vaincu le Boss final
- [ ] L'animation est fluide et thematique
- [ ] Le joueur peut consulter ses statistiques
- [ ] Le joueur peut rejouer ou retourner au menu

#### F12.2 — Statistiques de fin de partie

**Description** : Statistiques completes de la partie.

| Statistique | Description |
|-------------|-------------|
| Tours joues | Nombre total de tours |
| Kit choisi | Kit de depart utilise |
| Algues collectees | Total sur toute la partie |
| Corail collecte | Total sur toute la partie |
| Minerai collecte | Total sur toute la partie |
| Energie produite | Total sur toute la partie |
| Perles trouvees | Total sur toute la partie |
| Batiments construits | Nombre total |
| Niveau max QG atteint | Plus haut niveau de QG |
| Unites recrutees | Nombre total |
| Unites perdues | Nombre total |
| Monstres vaincus | Nombre total |
| Factions vaincues | Nombre total |
| Factions alliees | Nombre en fin de partie |
| Technologies recherchees | Nombre total |
| Cases explorees | Nombre total |
| Niveaux debloques | 1, 2, ou 3 |

**Criteres d'acceptation** :
- [ ] Toutes les statistiques sont calculees et affichees
- [ ] Les statistiques sont accumulees pendant toute la partie
- [ ] Le GameStatistics est mis a jour a chaque tour

#### F12.3 — Score final

**Description** : Un score numerique resume la performance du joueur.

**Formule de score** :
```
score = base_score
      + (100 - tours) * 10          // bonus de rapidite
      + cases_explorees * 2          // bonus exploration
      + monstres_vaincus * 50        // bonus combat
      + factions_vaincues * 100      // bonus conquete
      + factions_alliees * 75        // bonus diplomatie
      + technologies * 30            // bonus recherche
      - unites_perdues * 20          // malus pertes

base_score = 1000
```

**Criteres d'acceptation** :
- [ ] Le score est calcule selon la formule
- [ ] Le score est affiche sur l'ecran de victoire
- [ ] Le score ne peut pas etre negatif (minimum 0)

#### F12.4 — Option "Rejouer"

**Description** : Le joueur peut relancer une partie depuis l'ecran de victoire.

**Regles** :
- "Rejouer" ramene a l'ecran de choix du kit
- La sauvegarde precedente est supprimee
- Une nouvelle carte est generee

**Criteres d'acceptation** :
- [ ] Le bouton "Rejouer" ramene au choix du kit
- [ ] La sauvegarde est nettoyee
- [ ] La nouvelle partie est completement fraiche

### 16.3 Tests requis — Etape 12

**Tests unitaires** :
- Score : calcul avec differentes valeurs, minimum 0
- Statistiques : accumulation correcte

**Tests d'integration** :
- Victoire -> ecran de victoire -> statistiques -> score -> rejouer -> nouveau kit

---

## 17. Etape 13 — Equilibrage & Scaling

### 17.1 Objectif

Scaler le jeu a 99 factions IA et equilibrer l'experience complete.

### 17.2 Fonctionnalites

#### F13.1 — 99 factions IA

**Description** : La carte accueille 99 factions IA reparties sur les 3 niveaux.

**Repartition** :
- Niveau 1 : 40 factions
- Niveau 2 : 35 factions
- Niveau 3 : 24 factions

**Regles de placement** :
- Distance minimale entre factions : 3 cases
- Repartition equilibree sur la carte
- Les factions des niveaux inferieurs sont plus faibles au depart

**Criteres d'acceptation** :
- [ ] 99 factions sont generees
- [ ] Les factions sont reparties sur les 3 niveaux
- [ ] Les performances restent acceptables (< 500ms par tour)

#### F13.2 — IA amelioree

**Description** : Les factions IA ont un comportement plus complexe.

**Comportements IA** :
- Construction de batiments (choix base sur la situation)
- Recrutement d'unites (proportionnel a la menace)
- Exploration (progressive, aleatoire)
- Diplomatie (alliances entre factions IA)
- Attaque (contre les voisins faibles)

**Alliances IA** :
- Les factions IA peuvent former des alliances entre elles
- Maximum 5 factions par alliance IA
- Les alliances IA cooperent contre les menaces

**Criteres d'acceptation** :
- [ ] Les factions IA construisent et recrutent
- [ ] Les factions IA explorent progressivement
- [ ] Les factions IA forment des alliances
- [ ] Les factions IA attaquent les voisins faibles
- [ ] Le comportement IA est configurable (difficulte)

#### F13.3 — Equilibrage

**Description** : Chaque kit de depart permet de gagner en 50-100 tours.

**Objectifs d'equilibrage** :

| Kit | Tours cible (victoire) | Difficulte ressentie |
|-----|----------------------|---------------------|
| Militaire | 60-80 tours | Combat intense, economie tendue |
| Economique | 70-90 tours | Economie confortable, combat a preparer |
| Explorateur | 50-70 tours | Exploration rapide, combat difficile |

**Metriques a suivre** :
- Nombre de tours moyen pour atteindre chaque niveau
- Taux de game over par kit
- Ressources collectees par tour (moyenne)
- Nombre d'unites perdues par partie

**Criteres d'acceptation** :
- [ ] Les 3 kits permettent de gagner
- [ ] La duree de partie est dans la fourchette 50-100 tours
- [ ] Le game over est possible mais pas frequent (< 20% des parties)
- [ ] La difficulte augmente progressivement

### 17.3 Tests requis — Etape 13

**Tests de performance** :
- Tour complet avec 99 factions : < 500ms
- Sauvegarde avec 99 factions : < 200ms
- Chargement avec 99 factions : < 500ms

**Tests d'equilibrage** :
- Simulation automatique : 100 parties par kit, mesure des metriques

---

## 18. Etape 14 — Polish & Assets

### 18.1 Objectif

Le jeu est visuellement attrayant, sonore et agreable a utiliser.

### 18.2 Fonctionnalites

#### F14.1 — Assets graphiques

**Description** : Illustrations sous-marines pour tous les elements du jeu.

**Assets requis** :

| Categorie | Elements | Format |
|-----------|----------|--------|
| Terrains | Recif, plaine, roche, faille, abysses, magma | Tiles 64x64 PNG |
| Batiments | QG, Ferme, Mine, Extracteur, Panneau, Labo, Caserne, Atelier | Sprites 96x96 PNG |
| Unites | Eclaireur, Soldat, Ingenieur, Drone, Sous-marin, Torpille | Sprites 48x48 PNG |
| Ressources | Algues, Corail, Minerai, Energie, Perles | Icones 32x32 PNG |
| UI | Boutons, panneaux, bordures, fonds | 9-slice PNG |
| Monstres | 3 niveaux de monstres + 3 boss | Sprites 96x96 PNG |
| Factions | Bases IA (variantes) | Sprites 96x96 PNG |

**Criteres d'acceptation** :
- [ ] Tous les elements du jeu ont un asset graphique
- [ ] Les assets sont coherents visuellement (meme style)
- [ ] Les assets sont optimises pour le mobile (poids < 50KB/image)
- [ ] Les assets supportent les resolutions @1x, @2x, @3x

#### F14.2 — Animations

**Description** : Animations pour les actions principales.

| Animation | Duree | Declencheur |
|-----------|-------|-------------|
| Construction | 0.5s | Batiment termine |
| Amelioration | 0.5s | Batiment ameliore |
| Combat | 1s | Resolution de combat |
| Exploration | 0.3s | Case revelee |
| Deplacement | 0.3s | Unite deplacee |
| Evenement | 1s | Evenement aleatoire |
| Victoire | 3s | Boss final vaincu |

**Criteres d'acceptation** :
- [ ] Les animations sont fluides (60 FPS)
- [ ] Les animations sont skippables (tap pour passer)
- [ ] Les animations ne bloquent pas le gameplay
- [ ] Les animations peuvent etre desactivees dans les parametres

#### F14.3 — Sons et musique

**Description** : Ambiance sonore sous-marine.

| Element | Type | Description |
|---------|------|-------------|
| Musique de fond | Boucle | Ambiance sous-marine, calme et immersive |
| Construction | SFX | Son de construction metallique sous l'eau |
| Combat | SFX | Sons d'impact, d'explosion etouffee |
| Exploration | SFX | Son de sonar, decouverte |
| Tour suivant | SFX | Son de transition |
| Evenement | SFX | Son d'alerte ou de decouverte |
| Victoire | SFX + musique | Musique triomphale |
| Game over | SFX + musique | Musique sombre |

**Criteres d'acceptation** :
- [ ] La musique de fond joue en boucle
- [ ] Les SFX se declenchent aux bons moments
- [ ] Le volume est reglable (musique et SFX separement)
- [ ] Le son peut etre coupe completement
- [ ] Les fichiers audio sont en format OGG ou MP3

#### F14.4 — Tutoriel integre

**Description** : Guide le joueur pendant les premiers tours.

**Etapes du tutoriel** :
1. "Bienvenue dans ABYSSES ! Voici votre base sous-marine." (Tour 1)
2. "Construisez votre premiere Ferme d'algues." (Tour 1, mise en surbrillance)
3. "Appuyez sur Tour Suivant pour avancer." (Tour 1)
4. "Votre Ferme produit des Algues ! Construisez plus de batiments." (Tour 2)
5. "Explorez la carte avec un Eclaireur." (Tour 3, si Caserne construite)
6. "Ameliorez votre QG pour debloquer plus de batiments." (Tour 5)

**Regles** :
- Le tutoriel se declenche uniquement a la premiere partie
- Chaque etape est une bulle/tooltip pointant sur l'element concerne
- Le joueur peut passer le tutoriel a tout moment ("Passer le tutoriel")
- Le tutoriel ne se relance pas apres avoir ete passe

**Criteres d'acceptation** :
- [ ] Le tutoriel se lance a la premiere partie
- [ ] Chaque etape pointe sur le bon element
- [ ] Le tutoriel est passable
- [ ] Le tutoriel ne revient pas aux parties suivantes

#### F14.5 — Responsive design

**Description** : Le jeu s'adapte a toutes les tailles d'ecran.

| Plateforme | Taille cible | Orientation |
|------------|-------------|-------------|
| iPhone | 375-430px largeur | Portrait |
| iPad | 768-1024px largeur | Portrait + Paysage |
| Android phone | 360-412px largeur | Portrait |
| Android tablet | 600-800px largeur | Portrait + Paysage |
| Web | 1024-1920px largeur | Paysage |

**Regles d'adaptation** :
- La carte utilise tout l'espace disponible
- Les panneaux s'adaptent (panneau lateral en paysage, onglets en portrait)
- Les boutons ont une taille minimale de 44x44 points (accessibilite)
- Le texte est lisible sans zoom

**Criteres d'acceptation** :
- [ ] Le jeu fonctionne sur toutes les plateformes cibles
- [ ] L'interface s'adapte a l'orientation
- [ ] Les elements sont cliquables/tappables facilement
- [ ] Pas de depassement ou de contenu coupe

### 18.3 Tests requis — Etape 14

**Tests visuels** :
- Captures d'ecran sur toutes les plateformes cibles
- Verification des animations (pas de saccade)
- Verification des assets (pas de pixel casse)

**Tests d'accessibilite** :
- Taille minimale des boutons : 44x44 pts
- Contraste des couleurs : ratio minimum 4.5:1
- Support du mode sombre (si applicable)

---

## 19. Strategie de test globale

### 19.1 Pyramide de tests

```
          /\
         /  \     Tests E2E (manuels)
        /    \    - Parcours complet de jeu
       /------\
      /        \  Tests d'integration
     /          \ - Enchainement de fonctionnalites
    /------------\
   /              \ Tests unitaires
  /                \ - Chaque entite, chaque regle
 /------------------\
```

### 19.2 Couverture cible

| Type | Couverture cible | Priorite |
|------|-----------------|----------|
| Tests unitaires (domain) | > 90% | Critique |
| Tests unitaires (application) | > 80% | Haute |
| Tests d'integration | > 60% | Haute |
| Tests widgets | > 50% | Moyenne |
| Tests E2E | Parcours critiques | Moyenne |

### 19.3 Tests de non-regression

Chaque etape du roadmap doit inclure :
- Tests de non-regression sur les etapes precedentes
- Verification que la sauvegarde reste compatible
- Verification que les performances ne degradent pas

### 19.4 Tests de performance

| Metrique | Cible | Seuil d'alerte |
|----------|-------|----------------|
| Temps de resolution d'un tour | < 500ms | > 1s |
| Temps de sauvegarde | < 200ms | > 500ms |
| Temps de chargement | < 500ms | > 1s |
| FPS animations | 60 FPS | < 30 FPS |
| Memoire utilisee | < 200MB | > 300MB |

---

## 20. Glossaire

| Terme | Definition |
|-------|-----------|
| **Algues** | Ressource de base servant de nourriture et d'entretien des unites |
| **Alliance** | Groupe de factions (max 10) cooperant sous la direction du joueur |
| **Ascenseur abyssal** | Batiment special permettant d'acceder au niveau 2 |
| **Atelier mecanique** | Batiment debloque par technologie, recrute des machines |
| **Boss** | Monstre puissant gardant l'acces a un niveau inferieur |
| **Caserne** | Batiment permettant de recruter des unites humaines |
| **Corail** | Ressource servant de materiau de construction |
| **Disposition** | Etat diplomatique d'une faction (Neutre, Allie, Hostile) |
| **Drone** | Unite machine d'exploration longue distance |
| **Eclaireur** | Unite humaine d'exploration |
| **Energie** | Ressource necessaire aux batiments avances et machines |
| **Faction IA** | Entite controlee par l'ordinateur, presente sur la carte |
| **Faille** | Type de terrain dangereux infligeant des degats |
| **Ferme d'algues** | Batiment produisant des Algues |
| **Fog of war** | Brouillard masquant les cases non explorees |
| **GameState** | Etat complet de la partie (sauvegardable) |
| **Geothermie** | Source d'energie alternative pour les niveaux profonds |
| **Humeur** | Score d'un allie determinant sa cooperation (0-100) |
| **Kit de depart** | Choix initial du joueur (Militaire, Economique, Explorateur) |
| **Laboratoire** | Batiment permettant la recherche de technologies |
| **Minerai oceanique** | Ressource metallique pour les unites et batiments avances |
| **Mini sous-marin** | Unite machine de combat moyen a haute mobilite |
| **Panneau solaire** | Batiment produisant de l'Energie (niveau 1 uniquement) |
| **Perles** | Ressource rare obtenue par exploration et combat |
| **Plongeur soldat** | Unite humaine de combat basique |
| **QG** | Quartier General, batiment central limitant la progression |
| **Recif** | Type de terrain standard |
| **Roche** | Type de terrain infranchissable |
| **Score** | Note numerique evaluant la performance du joueur |
| **Torpille automatique** | Unite machine a usage unique infligeant des degats massifs |
| **Tour** | Unite de temps du jeu, pendant lequel le joueur agit |
| **Tunnel de pression** | Batiment special permettant d'acceder au niveau 3 |

---

> **Note** : Ce PRD est un document vivant. Chaque etape sera detaillee davantage
> lors de sa phase d'implementation. Les valeurs numeriques (couts, stats, probabilites)
> sont des valeurs initiales sujettes a l'equilibrage de l'etape 13.
