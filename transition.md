# Progression Verticale — Les Failles Abyssales

> **Etape PRD** : 11 — Progression verticale
> **Dependances** : Etape 6 (Technologies), Etape 7 (Factions IA)
> **Objectif** : Etendre le monde en niveaux de profondeur successifs, relies par des points de passage gardes. Le joueur progresse vers le Noyau en capturant ces passages.

---

## 1. Hypotheses

Ce document presuppose que les systemes suivants sont deja implementes :

- **Factions IA** (Etape 7) : plusieurs factions IA hostiles peuplent la carte et agissent de facon autonome.
- **Combat standard** : le `FightEngine` resout un combat en un seul appel.
- **Technologies** : la branche `military` supporte 5 niveaux de recherche.
- **QG** : le QG peut atteindre le niveau 10.
- **Ressources** : les 5 ressources (Algae, Corail, Minerai, Energie, Perles) existent avec un stock global unique.
- **Unites** : Eclaireur, Harponneur, Gardien, Briseur de Dome, Amiral des Abysses (ex-Siphonneur) et Saboteur existent.

---

## 2. Lore

### Qu'est-ce qu'une Faille Abyssale ?

Les **Failles Abyssales** sont des formations geologiques naturelles — des gouffres beants dans le plancher oceanique, des fissures tectoniques profondes creees par l'activite sismique des profondeurs. Ce sont les seuls passages physiques entre les niveaux de profondeur.

### Deux types selon le niveau

| Passage | Nom | Description |
|---------|-----|-------------|
| Niveau 1 -> 2 | **Faille Abyssale** | Crevasse sombre dans le fond corallien, entouree de recifs brises. Des courants descendants violents aspirent tout vers les profondeurs. La bioluminescence des creatures gardiennes eclaire l'entree d'une lueur inquietante. |
| Niveau 2 -> 3 | **Cheminee du Noyau** | Cheminee volcanique massive crachant de la fumee noire. La temperature augmente, le sol vibre. Des creatures de lave et de roche gardent l'acces. Pression extreme, visibilite quasi nulle sauf par la lueur volcanique. |

### Pourquoi sont-elles gardees ?

Les creatures des profondeurs remontent naturellement par ces failles pour chasser dans les eaux superieures. Des especes puissantes s'y sont installees comme predateurs dominants, controlant le flux entre les niveaux. La faille est leur territoire — et quiconque veut descendre doit d'abord les vaincre.

---

## 3. Placement sur la carte

### Niveau 1 (Surface) — Failles Abyssales

- **Nombre** : proportionnel a la taille de la carte — 1 faille par quadrant 10x10. Sur la carte 20x20 actuelle : **4 failles**
- **Placement** : reparties sur les bords exterieurs de la carte (distance > 8 cases du centre), une par quadrant
- **Espacement** : minimum 5 cases entre deux failles
- **Visibilite** : cachees par le fog of war, decouvertes par exploration
- **Contenu de la case** : nouveau type `CellContentType.transitionBase`

### Niveau 2 (Profondeurs) — Cheminees du Noyau

- **Nombre** : **3 cheminees** (nombre fixe)
- **Placement** : meme logique de bord de carte mais encore plus eloignees (distance > 10 du centre)
- **Espacement** : minimum 5 cases entre deux cheminees

---

## 4. Decouverte

1. Le joueur explore la carte normalement avec des Eclaireurs
2. Quand une faille est revelee, un **marqueur special** apparait sur la carte (icone de gouffre avec lueur pulsante)
3. **Informations affichees a la decouverte** :
   - Nom de la faille (genere : ex. "Faille de l'Ombre Profonde", "Cheminee du Serpent Noir")
   - Difficulte estimee : **statique par niveau** (Faille Abyssale : 4/5, Cheminee du Noyau : 5/5)
   - Statut : neutre / capturee par le joueur

---

## 5. Prerequis pour l'assaut

### Faille Abyssale (Niveau 1 -> 2)

| Prerequis | Valeur |
|-----------|--------|
| QG | Niveau 7+ |
| Tech Militaire | Niveau 3+ |
| Batiment special | "Module de descente" construit dans la base principale |

**Cout du Module de descente :**

| Ressource | Quantite |
|-----------|----------|
| Corail | 200 |
| Minerai | 150 |
| Energie | 80 |
| Perles | 5 |

### Cheminee du Noyau (Niveau 2 -> 3)

| Prerequis | Valeur |
|-----------|--------|
| QG | Niveau 9+ |
| Tech Militaire | Niveau 5 |
| Batiment special | "Capsule de pression" construite dans la base principale |

**Cout de la Capsule de pression :**

| Ressource | Quantite |
|-----------|----------|
| Corail | 400 |
| Minerai | 300 |
| Energie | 150 |
| Perles | 15 |

> Le batiment special represente la capacite technique a survivre dans les profondeurs. Il se construit dans la base principale du joueur.

---

## 6. Assaut initial — Combat de boss

### Definition mecanique du boss

Les gardiens de faille utilisent le systeme de combat standard. Le seul ajout : le flag `isBoss` sur les creatures gardiennes principales, utilise pour le ciblage narratif et les conditions de victoire.

### Gardiens de la Faille Abyssale (Niveau 1 -> 2)

**"Leviathan des Abysses"** — 1 boss + escorte

| Creature | PV | ATK | DEF | Nombre | isBoss |
|----------|----|-----|-----|--------|--------|
| Leviathan | 100 | 15 | 10 | 1 | oui |
| Sentinelle abyssale | 30 | 8 | 5 | 5 | non |

### Gardiens de la Cheminee du Noyau (Niveau 2 -> 3)

**"Titan Volcanique"** — 1 boss + escorte renforcee

| Creature | PV | ATK | DEF | Nombre | isBoss |
|----------|----|-----|-----|--------|--------|
| Titan Volcanique | 200 | 25 | 15 | 1 | oui |
| Golem de magma | 50 | 12 | 8 | 8 | non |

### Deroulement du combat

1. Le joueur selectionne les unites a envoyer (au moins **1 Amiral des Abysses** obligatoire)
2. Le combat utilise le `FightEngine` standard
3. **Resultat** :
   - **Victoire + Amiral vivant** : la faille est capturee. Evenement narratif : *"Les creatures se dispersent dans les profondeurs... La faille est a vous. Un gouffre sans fond s'ouvre devant vos forces."*
   - **Victoire + Amiral mort** : le combat est gagne mais la **capture echoue**. L'Amiral etait le seul a pouvoir securiser la faille. L'armee survivante rentre a la base. Les gardiens se reforment.
   - **Defaite** : l'armee envoyee est **perdue**. Les gardiens se reforment a pleine sante.

> L'Amiral des Abysses est la piece maitresse de l'assaut. Le joueur doit le proteger — sans lui, la faille ne peut pas etre capturee.

---

## 7. Descente vers le niveau suivant

### Conditions pour descendre

1. Faille capturee et sous controle du joueur
2. Batiment special construit (Module de descente / Capsule de pression)

### Mecanique de descente

1. Le joueur appuie sur **"Descendre"** depuis l'interface de la faille
2. Il selectionne les unites a envoyer (pas de limite de capacite)
3. Animation de descente
4. **Nouveau niveau** : une nouvelle grille 20x20 est generee, entierement en fog of war
5. Les unites arrivent au **point de spawn** de la faille (position fixee lors de la generation)
6. Les unites sont immediatement disponibles pour explorer, combattre et interagir avec le nouveau niveau

### Renforts

Le joueur peut envoyer des unites supplementaires a tout moment via une faille capturee. Le transport prend **1 tour**.

### Gestion multi-niveaux

- Le joueur **conserve sa base** au niveau precedent (production continue)
- Les **ressources sont partagees** entre tous les niveaux (stock unique global)
- Le recrutement se fait depuis la base principale ; les renforts transitent par les failles

---

## 8. Articulation a l'ecran (UI/UX)

### Representation sur la carte

| Etat | Apparence |
|------|-----------|
| Non decouverte | Case fog of war normale |
| Decouverte, non capturee | Icone de gouffre + lueur rouge pulsante + halo de danger |
| Capturee par le joueur | Icone de gouffre + lueur cyan |

### Bottom sheet — Faille non capturee

```
+-------------------------------------------+
|          [Icone gouffre rouge]             |
|     "Faille de l'Ombre Profonde"          |
|                                           |
|  Gardiens : Leviathan des Abysses         |
|  Difficulte : 4/5                         |
|                                           |
|  Prerequis :                              |
|  V QG niveau 7                            |
|  V Tech Militaire niveau 3               |
|  X Module de descente (non construit)     |
|                                           |
|  [ Lancer l'assaut ] (grise si X)         |
+-------------------------------------------+
```

### Bottom sheet — Faille capturee

```
+-------------------------------------------+
|          [Icone gouffre cyan]              |
|     "Faille de l'Ombre Profonde"          |
|     Sous votre controle                   |
|                                           |
|  [ Envoyer des renforts ]                 |
|  [ Descendre au Niveau 2 ]               |
+-------------------------------------------+
```

### Selecteur de niveau (en haut de l'onglet carte)

```
[ Niv 1: Surface ]  [ Niv 2: Profondeurs ]  [ Niv 3: Noyau ]
     (actif)           (verrouille)           (verrouille)
```

- Les niveaux non debloques sont grises avec un cadenas
- Le niveau actif est surligne en `biolumCyan`
- Un indicateur sous chaque niveau montre le nombre de failles capturees

### Ecran de descente (dialog plein ecran)

```
+-------------------------------------------+
|         DESCENTE VERS LE NIVEAU 2         |
|           LES PROFONDEURS                 |
|                                           |
|  [Animation : gouffre qui s'ouvre]        |
|                                           |
|  Selectionnez les unites a envoyer :      |
|                                           |
|  [x] Eclaireurs      x5                  |
|  [x] Harponneurs     x8                  |
|  [x] Gardiens        x3                  |
|  [x] Amiral          x1                  |
|                                           |
|      [ Annuler ]  [ Descendre ]           |
+-------------------------------------------+
```

---

## 9. Specificite Niveau 2 vers Niveau 3

Au Niveau 2, les **3 Cheminees du Noyau** sont les seuls passages vers l'objectif final. Leur rarete en fait le point de tension strategique du jeu.

- **Rarete** : seulement 3 cheminees pour l'ensemble du Niveau 2
- **Course a la capture** : les factions IA peuvent tenter de capturer les cheminees pour bloquer le joueur
- **Defense critique** : une cheminee capturee doit etre protegee

> *Au Niveau 1, les failles etaient nombreuses. Ici, dans les tenebres ecrasantes du Niveau 2, les cheminees sont rares. Trois passages seulement vers le Noyau. La descente se merite.*

---

## 10. Integration avec les systemes existants

| Systeme | Impact |
|---------|--------|
| **Generation de carte** | Nouveau `CellContentType.transitionBase`, placement par quadrant en bordure |
| **Combat** | Reutilise le systeme standard. Ajout du flag `isBoss` pour identifier les gardiens |
| **Batiments** | Nouveaux types : `descentModule`, `pressureCapsule` |
| **Unites** | Amiral des Abysses (ex-Siphonneur) requis pour capture |
| **Technologies** | Prerequis branche Militaire niveaux 3 et 5 |
| **Ressources** | Couts de construction (pas d'Algae — thematiquement absente des profondeurs). Stock partage entre niveaux |
| **Resolution de tour** | Nouveau step : transport inter-niveaux (1 tour) |
| **Actions** | Nouvelles : `attackTransitionBase`, `descend`, `sendReinforcements` |
| **Factions IA** | L'IA peut capturer des failles et les defendre |
| **Persistence** | Nouveaux modeles Hive : TransitionBase, donnees par niveau |

---

## 11. Evolutions futures (hors scope etape 11)

Les points suivants sont prevus pour des etapes ulterieures :

- **Contre-attaques IA** : les factions IA pourront attaquer et reprendre les failles capturees par le joueur (necessite etape 7 complete)
- **Batiments defensifs** : bouclier de courant, tourelle a harpon, sonar de detection — constructibles dans les failles pour les defendre
- **Garnison defensive** : affecter des unites en defense permanente d'une faille
- **Station d'arrivee ameliorable** : transformer le point de spawn en mini-base avec production locale

---

## 12. Questions ouvertes

- **Contenu du Niveau 3 (Noyau)** : que trouve le joueur au Niveau 3 ? Objectif final ?
- **Mecanique de remontee** : le joueur peut-il renvoyer des unites d'un niveau inferieur vers un niveau superieur via la faille ?
- **Equilibrage des boss** : les stats des gardiens sont-elles coherentes avec la puissance militaire attendue du joueur a ce stade ?
- **Factions IA et failles** : comment les factions IA interagissent-elles avec les failles qu'elles decouvrent ? (dependance etape 7)
