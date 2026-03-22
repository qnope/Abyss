# ABYSSES - Plan d'implementation

## Architecture en 5 couches

```
┌─────────────────────────────────────────────┐
│  Layer 5 - UI (Presentation)                │
│  Widgets Flutter, ecrans, navigation        │
├─────────────────────────────────────────────┤
│  Layer 4 - State Management                 │
│  Providers/Cubits, etat reactif de l'app    │
├─────────────────────────────────────────────┤
│  Layer 3 - Use Cases (Application)          │
│  Logique d'orchestration des actions        │
├─────────────────────────────────────────────┤
│  Layer 2 - Domain (Metier)                  │
│  Modeles, regles metier, entites pures      │
├─────────────────────────────────────────────┤
│  Layer 1 - Data (Persistance)               │
│  Hive adapters, repositories concrets       │
└─────────────────────────────────────────────┘
```

### Dependances entre couches

- **UI → State → Use Cases → Domain ← Data**
- Le Domain ne depend de rien (couche pure)
- Data implemente les interfaces definies dans Domain
- Chaque couche ne connait que la couche en dessous

### Structure de dossiers cible

```
lib/
├── main.dart
├── app.dart
│
├── data/                    # Layer 1 - Persistance
│   ├── repositories/        # Implementations concretes
│   ├── adapters/            # Hive TypeAdapters
│   └── datasources/         # Sources de donnees locales
│
├── domain/                  # Layer 2 - Metier
│   ├── models/              # Entites (Resource, Building, Unit...)
│   ├── rules/               # Regles metier pures
│   └── repositories/        # Interfaces (contrats abstraits)
│
├── use_cases/               # Layer 3 - Application
│   ├── turn/                # Gestion des tours
│   ├── building/            # Construction
│   ├── combat/              # Resolution de combats
│   ├── exploration/         # Exploration de la carte
│   ├── technology/          # Recherche technologique
│   └── alliance/            # Diplomatie et alliances
│
├── state/                   # Layer 4 - State Management
│   ├── game/                # Etat global du jeu
│   ├── map/                 # Etat de la carte
│   └── ui/                  # Etat des ecrans
│
└── ui/                      # Layer 5 - Presentation
    ├── screens/             # Ecrans principaux
    ├── widgets/             # Widgets reutilisables
    └── theme/               # Theme graphique
```

---

## Plan d'implementation par etapes

Chaque etape est independamment testable. On ne passe a l'etape suivante que quand les tests de l'etape en cours passent.

---

### Etape 1 : Squelette du projet

**Objectif** : Projet Flutter fonctionnel avec l'architecture en place.

**Taches** :
1. `flutter create` avec le bon nom de package
2. Ajouter les dependances dans `pubspec.yaml` : `hive`, `hive_flutter`, `flutter_bloc` (ou `provider`)
3. Creer l'arborescence de dossiers (data, domain, use_cases, state, ui)
4. Creer `app.dart` avec MaterialApp et un ecran vide
5. Configurer les plateformes cibles (iOS, Android, Web)

**Tests** :
- [ ] `flutter analyze` passe sans erreur
- [ ] `flutter test` passe (test par defaut)
- [ ] L'app se lance et affiche un ecran vide

---

### Etape 2 : Modeles de domaine - Ressources

**Objectif** : Definir les 5 ressources et leur gestion en memoire.

**Taches** :
1. Creer `domain/models/resource_type.dart` : enum des 5 ressources
2. Creer `domain/models/resource_stock.dart` : stock de ressources (Map<ResourceType, int>)
3. Creer `domain/rules/resource_rules.dart` : fonctions pures (ajouter, retirer, verifier suffisance)

**Tests** :
- [ ] Creer un stock, ajouter des ressources, verifier les montants
- [ ] Retirer des ressources d'un stock suffisant → OK
- [ ] Retirer des ressources d'un stock insuffisant → echec
- [ ] Verifier `canAfford(cost, stock)` retourne true/false correctement

---

### Etape 3 : Modeles de domaine - Batiments

**Objectif** : Definir les batiments, leur cout et leur production.

**Taches** :
1. Creer `domain/models/building_type.dart` : enum des batiments
2. Creer `domain/models/building.dart` : entite Building (type, niveau, en construction?)
3. Creer `domain/models/building_template.dart` : donnees statiques (cout par niveau, production, temps)
4. Creer `domain/rules/building_rules.dart` : regles (peut construire?, cout amelioration, production par tour)

**Tests** :
- [ ] Un batiment de niveau 1 produit X ressources
- [ ] Un batiment de niveau 2 produit plus qu'au niveau 1
- [ ] Le cout d'amelioration augmente avec le niveau
- [ ] Impossible de construire si le QG est de niveau trop bas
- [ ] Impossible de construire sans ressources suffisantes

---

### Etape 4 : Modeles de domaine - Carte et terrain

**Objectif** : Grille 20x20 avec types de terrain et fog of war.

**Taches** :
1. Creer `domain/models/position.dart` : coordonnees (x, y)
2. Creer `domain/models/terrain_type.dart` : enum (recif, plaine, roche, faille...)
3. Creer `domain/models/tile.dart` : case (terrain, visible?, contenu)
4. Creer `domain/models/game_map.dart` : grille de tiles
5. Creer `domain/rules/map_rules.dart` : regles (cases adjacentes, distance, visibilite)

**Tests** :
- [ ] Creer une carte 20x20, verifier les dimensions
- [ ] Les cases de depart autour de la base sont visibles
- [ ] Les cases eloignees sont en fog of war
- [ ] `adjacentTiles(position)` retourne les bonnes cases
- [ ] La distance entre 2 positions est correcte

---

### Etape 5 : Modeles de domaine - Unites

**Objectif** : Unites militaires et d'exploration avec leurs statistiques.

**Taches** :
1. Creer `domain/models/unit_type.dart` : enum (eclaireur, soldat, ingenieur, drone, sous-marin, torpille)
2. Creer `domain/models/unit.dart` : entite Unite (type, PV, position, stats)
3. Creer `domain/models/unit_template.dart` : donnees statiques (stats de base, cout, temps)
4. Creer `domain/rules/unit_rules.dart` : regles (peut recruter?, deplacement valide?)

**Tests** :
- [ ] Creer une unite, verifier ses stats
- [ ] Un eclaireur se deplace plus loin qu'un soldat
- [ ] Le cout de recrutement est correct par type
- [ ] Impossible de recruter sans caserne

---

### Etape 6 : Modeles de domaine - Technologies

**Objectif** : 3 arbres technologiques avec prerequis.

**Taches** :
1. Creer `domain/models/tech_tree.dart` : enum des 3 arbres
2. Creer `domain/models/technology.dart` : entite Technology (id, arbre, prerequis, cout, effet)
3. Creer `domain/models/tech_catalog.dart` : catalogue complet des technologies
4. Creer `domain/rules/tech_rules.dart` : regles (peut rechercher?, prerequis satisfaits?)

**Tests** :
- [ ] Impossible de rechercher sans laboratoire
- [ ] Impossible de rechercher une tech sans ses prerequis
- [ ] Rechercher une tech de base → OK
- [ ] Les technologies avancees coutent des Perles

---

### Etape 7 : Systeme de tours - Use Case principal

**Objectif** : Logique d'enchainement des tours (le coeur du jeu).

**Taches** :
1. Creer `domain/models/game_state.dart` : etat complet du jeu (tour, ressources, batiments, unites, carte)
2. Creer `use_cases/turn/end_turn.dart` : orchestration de fin de tour
3. Logique de production : chaque batiment produit ses ressources
4. Logique de construction : avancer les constructions en cours
5. Logique de recherche : avancer les recherches en cours

**Tests** :
- [ ] Fin de tour → les ressources sont produites
- [ ] Fin de tour → un batiment en construction avance d'1 tour
- [ ] Fin de tour → un batiment termine sa construction au bon tour
- [ ] Fin de tour → une recherche en cours avance
- [ ] Le compteur de tours s'incremente

---

### Etape 8 : Actions du joueur - Use Cases

**Objectif** : Toutes les actions possibles pendant un tour.

**Taches** :
1. `use_cases/building/build.dart` : construire un batiment
2. `use_cases/building/upgrade.dart` : ameliorer un batiment
3. `use_cases/exploration/explore.dart` : envoyer une unite explorer
4. `use_cases/technology/research.dart` : lancer une recherche

**Tests** :
- [ ] Construire un batiment → ressources deduites, construction demarre
- [ ] Ameliorer un batiment → cout correct, duree correcte
- [ ] Explorer une case → la case devient visible
- [ ] Explorer → decouverte de ressources/ruines
- [ ] Lancer une recherche → ressources deduites, recherche demarre

---

### Etape 9 : Systeme de combat

**Objectif** : Resolution des combats entre unites.

**Taches** :
1. Creer `domain/models/army.dart` : groupe d'unites
2. Creer `domain/rules/combat_rules.dart` : formule de combat (attaque vs defense, PV)
3. Creer `use_cases/combat/resolve_combat.dart` : resolution complete
4. Creer `use_cases/combat/attack.dart` : action d'attaque

**Tests** :
- [ ] Combat entre 2 armees → une gagne, l'autre perd
- [ ] Les degats sont calcules correctement
- [ ] Les unites detruites sont retirees
- [ ] Une armee plus forte gagne (pas de hasard pur)
- [ ] Combat contre base de monstres (boss)

---

### Etape 10 : Factions IA

**Objectif** : 99 factions IA qui evoluent a chaque tour.

**Taches** :
1. Creer `domain/models/faction.dart` : entite Faction (base, ressources, armee, alliance)
2. Creer `domain/rules/ai_rules.dart` : decisions de l'IA (priorites, strategies)
3. Creer `use_cases/turn/ai_turn.dart` : tour de l'IA (construction, recrutement, exploration)

**Tests** :
- [ ] Une faction IA construit un batiment si elle a les ressources
- [ ] Une faction IA recrute des unites
- [ ] Une faction IA explore des cases adjacentes
- [ ] Les factions IA progressent sur 10 tours

---

### Etape 11 : Alliances et diplomatie

**Objectif** : Systeme d'alliances avec ordres et humeur.

**Taches** :
1. Creer `domain/models/alliance.dart` : entite Alliance (meneur, membres, max 10)
2. Creer `domain/models/disposition.dart` : humeur d'une faction alliee
3. Creer `use_cases/alliance/invite.dart` : inviter une faction
4. Creer `use_cases/alliance/give_order.dart` : donner un ordre a un allie
5. Creer `domain/rules/alliance_rules.dart` : regles de reponse (accepte/refuse selon humeur)

**Tests** :
- [ ] Inviter une faction → elle rejoint l'alliance
- [ ] Alliance pleine (10) → impossible d'inviter
- [ ] Donner un ordre → l'allie accepte ou refuse selon disposition
- [ ] L'humeur diminue si les ordres sont abusifs

---

### Etape 12 : Evenements aleatoires

**Objectif** : Evenements positifs et negatifs entre les tours.

**Taches** :
1. Creer `domain/models/game_event.dart` : entite Evenement (type, effet, description)
2. Creer `domain/models/event_catalog.dart` : liste des evenements possibles
3. Creer `domain/rules/event_rules.dart` : probabilite et conditions de declenchement
4. Integrer dans `use_cases/turn/end_turn.dart`

**Tests** :
- [ ] Un evenement peut survenir en fin de tour
- [ ] Les evenements negatifs ont un impact (reduction de production, degats)
- [ ] Les evenements positifs donnent des bonus
- [ ] Les evenements sont specifiques au niveau de profondeur

---

### Etape 13 : Niveaux de profondeur

**Objectif** : 3 niveaux avec transitions et regles specifiques.

**Taches** :
1. Creer `domain/models/depth_level.dart` : enum (Surface, Profondeur, Noyau)
2. Modifier `game_map.dart` : carte par niveau
3. Modifier `game_state.dart` : niveau actuel + cartes multiples
4. Creer `use_cases/exploration/change_depth.dart` : transition de niveau
5. Regles d'energie par niveau (pas de solaire en profondeur)

**Tests** :
- [ ] Impossible de descendre sans batiment special
- [ ] Impossible de descendre sans vaincre le boss
- [ ] Le nouveau niveau est entierement en fog of war
- [ ] Les panneaux solaires ne produisent pas au niveau 2+
- [ ] Le joueur conserve sa base du niveau precedent

---

### Etape 14 : Kits de depart

**Objectif** : 3 kits de depart avec contenu different.

**Taches** :
1. Creer `domain/models/starter_kit.dart` : enum + contenu de chaque kit
2. Creer `use_cases/game/new_game.dart` : creer une nouvelle partie avec un kit
3. Generation de la carte initiale

**Tests** :
- [ ] Kit Militaire → caserne + unites supplementaires
- [ ] Kit Economique → batiments de production + ressources bonus
- [ ] Kit Explorateur → unites d'exploration + vision etendue
- [ ] Chaque kit demarre une partie jouable

---

### Etape 15 : Persistance (Layer 1 - Data)

**Objectif** : Sauvegarder et charger une partie avec Hive.

**Taches** :
1. Creer les Hive TypeAdapters pour chaque modele
2. Creer `domain/repositories/game_repository.dart` : interface
3. Creer `data/repositories/hive_game_repository.dart` : implementation
4. Creer `use_cases/game/save_game.dart` et `load_game.dart`

**Tests** :
- [ ] Sauvegarder une partie → fichier cree
- [ ] Charger une partie → etat restaure identique
- [ ] Sauvegarder apres 10 tours → tout est preserve
- [ ] Charger une partie inexistante → erreur propre

---

### Etape 16 : State Management (Layer 4)

**Objectif** : Connecter la logique metier a l'UI via des Cubits/Providers.

**Taches** :
1. Creer `state/game/game_cubit.dart` : etat global du jeu
2. Creer `state/map/map_cubit.dart` : etat de la carte affichee
3. Creer `state/ui/selected_action_cubit.dart` : action en cours de selection

**Tests** :
- [ ] Le cubit emet le bon etat apres une action
- [ ] Le cubit gere le chargement d'une partie
- [ ] Le cubit met a jour la carte apres exploration

---

### Etape 17 : UI - Ecran principal et carte

**Objectif** : Afficher la carte avec fog of war et les informations de base.

**Taches** :
1. Creer `ui/screens/game_screen.dart` : ecran principal avec la carte
2. Creer `ui/widgets/tile_widget.dart` : widget d'une case
3. Creer `ui/widgets/resource_bar.dart` : barre de ressources en haut
4. Creer `ui/widgets/turn_button.dart` : bouton "Tour suivant"
5. Fog of war visuel (cases grises/noires)

**Tests** :
- [ ] La carte s'affiche avec les bonnes dimensions
- [ ] Les cases visibles montrent le terrain
- [ ] Les cases cachees sont en fog of war
- [ ] La barre de ressources affiche les stocks
- [ ] Le bouton "Tour suivant" declenche la fin de tour

---

### Etape 18 : UI - Gestion de la base

**Objectif** : Ecrans pour construire, ameliorer, recruter.

**Taches** :
1. Creer `ui/screens/base_screen.dart` : vue de la base
2. Creer `ui/widgets/building_card.dart` : carte d'un batiment
3. Creer `ui/screens/build_menu.dart` : menu de construction
4. Creer `ui/screens/recruit_screen.dart` : ecran de recrutement

**Tests** :
- [ ] Les batiments de la base sont affiches
- [ ] Le menu de construction montre les options disponibles
- [ ] Les options impossibles sont grisees (cout, prerequis)
- [ ] Le recrutement affiche les unites disponibles

---

### Etape 19 : UI - Technologies et alliances

**Objectif** : Ecrans pour la recherche et la diplomatie.

**Taches** :
1. Creer `ui/screens/tech_screen.dart` : arbre technologique
2. Creer `ui/screens/alliance_screen.dart` : gestion de l'alliance
3. Creer `ui/widgets/tech_node.dart` : noeud de technologie
4. Creer `ui/widgets/faction_card.dart` : carte d'une faction alliee

**Tests** :
- [ ] L'arbre techno affiche les 3 branches
- [ ] Les technologies recherchees sont visuellement differentes
- [ ] L'ecran d'alliance affiche les membres et leur humeur
- [ ] On peut donner des ordres depuis l'ecran d'alliance

---

### Etape 20 : UI - Menu principal et fin de partie

**Objectif** : Menu de demarrage, choix du kit, ecran de victoire.

**Taches** :
1. Creer `ui/screens/main_menu_screen.dart` : menu principal
2. Creer `ui/screens/kit_selection_screen.dart` : choix du kit de depart
3. Creer `ui/screens/victory_screen.dart` : ecran de fin avec statistiques
4. Creer `ui/screens/turn_summary_screen.dart` : resume de fin de tour

**Tests** :
- [ ] Le menu principal permet de commencer une partie ou charger
- [ ] Le choix du kit affiche les 3 options avec details
- [ ] L'ecran de victoire affiche les stats de la partie
- [ ] Le resume de tour montre les evenements

---

### Etape 21 : Integration et equilibrage

**Objectif** : Le jeu complet est jouable et equilibre.

**Taches** :
1. Test d'integration : jouer 50 tours complets automatiquement
2. Verifier que chaque kit peut mener a la victoire en 50-100 tours
3. Ajuster les couts, productions et stats si necessaire
4. Tester les 3 niveaux de profondeur en enchainement

**Tests** :
- [ ] Partie complete automatisee avec le kit Militaire
- [ ] Partie complete automatisee avec le kit Economique
- [ ] Partie complete automatisee avec le kit Explorateur
- [ ] Les factions IA sont un defi equilibre
- [ ] Aucune strategie dominante evidente

---

## Resume des priorites

| Phase | Etapes | Description | Couche |
|-------|--------|-------------|--------|
| Fondation | 1-2 | Projet + Ressources | Domain |
| Modeles | 3-6 | Batiments, carte, unites, techs | Domain |
| Logique | 7-9 | Tours, actions, combats | Use Cases |
| IA | 10-12 | Factions, alliances, evenements | Use Cases + Domain |
| Monde | 13-14 | Profondeurs, kits de depart | Domain + Use Cases |
| Persistance | 15 | Sauvegarde Hive | Data |
| Etat | 16 | Cubits/Providers | State |
| Interface | 17-20 | Ecrans Flutter | UI |
| Final | 21 | Integration et equilibrage | Toutes |

## Principes a respecter

1. **< 150 lignes par fichier** : decouper si necessaire
2. **Pas de `initialize()`** : constructeurs complets ou factory
3. **Composants reutilisables** : widgets et regles generiques
4. **Tests a chaque etape** : `flutter analyze` + `flutter test`
5. **Domain pur** : aucune dependance Flutter dans la couche Domain
