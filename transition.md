# Progression Verticale — Les Failles Abyssales

> **Etape PRD** : 11 — Progression verticale
> **Dependances** : Etape 6 (Technologies), Etape 7 (Factions IA)
> **Objectif** : Etendre le monde en niveaux de profondeur successifs, relies par des points de passage gardes. Le joueur progresse vers le Noyau en capturant ces passages.

---

## 1. Hypotheses

Ce document presuppose que les systemes suivants sont deja implementes :

- **Factions IA** (Etape 7) : plusieurs factions IA hostiles peuplent la carte et agissent de facon autonome.
- **Combat standard** : le `FightEngine` resout un combat en un seul appel (pas de combat multi-tours).
- **Technologies** : la branche `military` supporte 5 niveaux de recherche.
- **QG** : le QG peut atteindre le niveau 10 (suffisant pour les prerequis 7 et 9).
- **Ressources** : les 4 ressources (Corail, Minerai, Energie, Perles) existent avec un stock global unique.
- **Unites** : Eclaireur, Harponneur, Gardien, Briseur de Dome et Siphonneur existent.

---

## 2. Lore

### Qu'est-ce qu'une Faille Abyssale ?

Les **Failles Abyssales** sont des formations geologiques naturelles — des gouffres beants dans le plancher oceanique, des fissures tectoniques profondes creees par l'activite sismique des profondeurs. Ce sont les seuls passages physiques entre les niveaux de profondeur.

### Deux types selon le niveau

| Passage | Nom | Description |
|---------|-----|-------------|
| Niveau 1 → 2 | **Faille Abyssale** | Crevasse sombre dans le fond corallien, entouree de recifs brises. Des courants descendants violents aspirent tout vers les profondeurs. La bioluminescence des creatures gardiennes eclaire l'entree d'une lueur inquietante. Les parois sont couvertes de cristaux mineraux et de concretions anciennes. |
| Niveau 2 → 3 | **Cheminee du Noyau** | Cheminee volcanique massive crachant de la fumee noire. La temperature augmente, le sol vibre. Des creatures de lave et de roche gardent l'acces. Pression extreme, courants thermiques, visibilite quasi nulle sauf par la lueur volcanique. |

### Pourquoi sont-elles gardees ?

Les creatures des profondeurs remontent naturellement par ces failles pour chasser dans les eaux superieures. Des especes puissantes s'y sont installees comme predateurs dominants, controlant le flux entre les niveaux. La faille est leur territoire — et quiconque veut descendre doit d'abord les vaincre.

---

## 3. Placement sur la carte

### Niveau 1 (Surface) — Failles Abyssales

- **Nombre** : proportionnel a la taille de la carte — 1 faille par quadrant 10x10. Sur la carte 20x20 actuelle : **4 failles**
- **Placement** : reparties sur les bords exterieurs de la carte (distance > 8 cases du centre), une par quadrant
- **Espacement** : minimum 5 cases entre deux failles
- **Visibilite** : cachees par le fog of war, decouvertes par exploration
- **Terrain adjacent** : les 4 cases cardinales adjacentes a la faille sont du terrain "Fault" (-3 PV si traverse) — signalant une zone dangereuse au joueur
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
   - Difficulte estimee : **statique par niveau** (Faille Abyssale : difficulte 4/5, Cheminee du Noyau : difficulte 5/5)
   - Statut : neutre / capturee par le joueur / capturee par [faction IA]

---

## 5. Prerequis pour l'assaut

Avant de pouvoir attaquer une faille, le joueur doit remplir des conditions :

### Faille Abyssale (Niveau 1 → 2)

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

### Cheminee du Noyau (Niveau 2 → 3)

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

Les gardiens de faille utilisent le systeme de combat standard avec deux specificites :

- **Flag `isBoss`** : les creatures marquees `isBoss` sont les gardiens principaux de la faille.
- **Bonus de siege** : le Briseur de Dome inflige **x2 degats** contre les unites `isBoss`.

### Gardiens de la Faille Abyssale (Niveau 1 → 2)

**"Leviathan des Abysses"** — 1 boss + escorte

| Creature | PV | ATK | DEF | Nombre | isBoss |
|----------|----|-----|-----|--------|--------|
| Leviathan | 100 | 15 | 10 | 1 | oui |
| Sentinelle abyssale | 30 | 8 | 5 | 5 | non |

### Gardiens de la Cheminee du Noyau (Niveau 2 → 3)

**"Titan Volcanique"** — 1 boss + escorte renforcee

| Creature | PV | ATK | DEF | Nombre | isBoss |
|----------|----|-----|-----|--------|--------|
| Titan Volcanique | 200 | 25 | 15 | 1 | oui |
| Golem de magma | 50 | 12 | 8 | 8 | non |

### Deroulement du combat

1. Le joueur selectionne les unites a envoyer (au moins **1 Siphonneur** obligatoire)
2. Le combat utilise le systeme de combat standard (avec bonus x2 du Briseur de Dome contre `isBoss`)
3. **Chaine d'assaut recommandee** :
   - **Eclaireur** : reperage (bonus de precision pour le groupe)
   - **Briseur de Dome** : degats de siege x2 contre le boss
   - **Harponneurs** : degats principaux
   - **Gardiens** : absorbent les degats du boss
   - **Siphonneur** : capture la faille une fois les gardiens vaincus

### Capture

- Une fois les gardiens vaincus, le **Siphonneur** capture la faille
- Si tous les Siphonneurs sont morts pendant le combat : le combat est **gagne** mais la **capture echoue**. Le joueur doit relancer un assaut avec au moins 1 Siphonneur vivant (les gardiens sont vaincus, pas de nouveau combat necessaire)
- La faille passe sous controle du joueur
- Evenement narratif : *"Les creatures se dispersent dans les profondeurs... La faille est a vous. Un gouffre sans fond s'ouvre devant vos forces. Les profondeurs vous attendent."*

### En cas d'echec

- L'armee envoyee est **perdue** (unites detruites)
- Les gardiens **se reforment a pleine sante** a la tentative suivante
- Le joueur doit recruter une nouvelle armee et retenter

---

## 7. Defense de la faille capturee

### Garnison

| Propriete | Faille Abyssale | Cheminee du Noyau |
|-----------|-----------------|-------------------|
| Capacite max | 15 unites | 20 unites |
| Bonus defensif | +50% DEF | +50% DEF |

- Le joueur affecte des unites en garnison via l'interface de la faille
- Les unites en garnison ne sont **plus disponibles** pour d'autres actions
- Le bonus de +50% DEF represente l'avantage du terrain (goulot d'etranglement naturel)

### Batiments defensifs

Trois batiments constructibles **uniquement dans les failles capturees** :

#### Bouclier de courant

> Genere un champ de force qui absorbe les degats avant que la garnison soit touchee. Peut etre desactive par un Briseur de Dome ennemi.

| Niveau | Degats absorbes | Cout | Entretien/tour |
|--------|-----------------|------|----------------|
| 1 | 50 | 80 Corail, 60 Minerai, 30 Energie | 5 Energie |
| 2 | 100 | 160 Corail, 120 Minerai, 60 Energie | 10 Energie |
| 3 | 200 | 320 Corail, 240 Minerai, 120 Energie | 15 Energie |

#### Tourelle a harpon

> Inflige des degats automatiques aux attaquants **avant** le debut du combat de garnison.

| Niveau | Degats infliges | Cout | Entretien/tour |
|--------|-----------------|------|----------------|
| 1 | 20 | 60 Corail, 80 Minerai, 20 Energie | 5 Energie |
| 2 | 40 | 120 Corail, 160 Minerai, 40 Energie | 10 Energie |
| 3 | 80 | 240 Corail, 320 Minerai, 80 Energie | 15 Energie |

#### Sonar de detection

> Detecte les armees ennemies en approche et avertit le joueur X tours avant l'attaque.

| Niveau | Tours d'avance | Cout | Entretien/tour |
|--------|----------------|------|----------------|
| 1 | 1 tour | 40 Corail, 30 Minerai, 50 Energie | 5 Energie |
| 2 | 2 tours | 80 Corail, 60 Minerai, 100 Energie | 10 Energie |
| 3 | 3 tours | 160 Corail, 120 Minerai, 200 Energie | 15 Energie |

### Regles des batiments defensifs

- Construction : 1 tour par niveau
- Limite : 1 de chaque type par faille (maximum 3 batiments)
- L'entretien en Energie est preleve depuis le stock global du joueur
- **Si l'energie globale est insuffisante** : les batiments defensifs sont **desactives** (pas detruits) tant que l'energie manque. Ils se reactivent automatiquement quand l'energie redevient suffisante

---

## 8. Contre-attaques IA

Les factions IA hostiles peuvent attaquer les failles capturees par le joueur.

### Probabilite

| Tours depuis capture | Chance par tour |
|----------------------|-----------------|
| 1-5 | 5% |
| 6-10 | 10% |
| 11-15 | 20% |
| 16+ | 30% (plafond) |

### Deroulement

1. **Detection (si Sonar actif)** : le joueur est prevenu X tours a l'avance. Notification dans le resume de tour : *"Le sonar detecte un mouvement hostile vers la Faille de l'Ombre Profonde. Attaque estimee dans X tours."*
2. **Attaque** : l'armee IA attaque la faille
3. **Resolution** :
   - La tourelle inflige ses degats pre-combat
   - Le bouclier absorbe les premiers degats
   - Combat garnison (+50% DEF) vs armee IA
4. **Resultat** :
   - **Victoire defenseur** : l'armee IA est detruite, la faille reste au joueur
   - **Victoire attaquant** : la garnison est detruite, les batiments defensifs sont **endommages** (ramenes au niveau 1 ; detruits si deja au niveau 1), la faille redevient **neutre** (sans gardiens boss)

### Recapture apres perte

- Pas besoin de combattre un boss (les gardiens naturels ne reviennent pas)
- Le joueur doit envoyer un **Siphonneur** pour recapturer
- Si une faction IA a capture la faille entre-temps, le joueur doit d'abord vaincre la garnison IA

---

## 9. Transition vers le niveau suivant

### Conditions pour descendre

1. Faille capturee et sous controle du joueur
2. Batiment special construit (Module de descente / Capsule de pression)
3. Selection des unites a envoyer

### Capacite de transport

| Batiment | Unites transportables |
|----------|----------------------|
| Module de descente | 20 unites max |
| Capsule de pression | 30 unites max |

### Mecanique de descente

1. Le joueur appuie sur **"Descendre"** depuis l'interface de la faille
2. Il selectionne les unites a emmener (dans la limite de capacite)
3. Animation de descente
4. **Nouveau niveau** : une nouvelle grille 20x20 est generee, entierement en fog of war
5. Le joueur demarre au **point d'arrivee** de la faille (position fixee lors de la generation)
6. Les unites selectionnees sont disponibles immediatement

### Station d'arrivee

Au point d'arrivee, un emplacement de **Station d'arrivee** est present (niveau 0 = non construite). Le joueur doit la construire pour securiser sa position :

- **Batiment unique** de type `transitionStation`, constructible uniquement au point d'arrivee
- **Entretien energetique tres eleve** (preleve sur le stock global partage)
- **Garnison** : la Station peut recevoir des unites en defense
- **Si non construite** : le point d'arrivee reste vulnerable et le joueur n'a aucune defense

> *Les couts exacts et l'entretien energetique de la Station d'arrivee seront definis lors de la phase d'equilibrage (Etape 13).*

### Gestion multi-niveaux

- Le joueur **conserve sa base** au niveau precedent (production continue)
- Les **ressources sont partagees** entre tous les niveaux (stock unique global)
- Le recrutement se fait depuis la base principale et les unites sont envoyees via la faille
- **Transport inter-niveaux** : possible via les failles controlees, prend 1 tour, limite par la capacite du batiment

---

## 10. Articulation a l'ecran (UI/UX)

### Representation sur la carte

| Etat | Apparence |
|------|-----------|
| Non decouverte | Case fog of war normale |
| Decouverte, non capturee | Icone de gouffre + lueur rouge pulsante + halo de danger |
| Capturee par le joueur | Icone de gouffre + lueur cyan |
| Capturee par une faction IA | Icone de gouffre + lueur orange + badge faction |

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

### Bottom sheet — Faille capturee (joueur)

```
+-------------------------------------------+
|          [Icone gouffre cyan]              |
|     "Faille de l'Ombre Profonde"          |
|     Sous votre controle                   |
|                                           |
|  Garnison : 8/15 unites                   |
|  Defenses :                               |
|    Bouclier Niv 2 (100 degats)            |
|    Tourelle Niv 1 (20 degats)             |
|    Sonar Niv 2 (2 tours d'avance)         |
|                                           |
|  ! Attaque detectee dans 2 tours          |
|                                           |
|  [ Gerer garnison ]                       |
|  [ Construire defenses ]                  |
|  [ Descendre au Niveau 2 ]               |
+-------------------------------------------+
```

### Bottom sheet — Faille capturee (faction IA)

```
+-------------------------------------------+
|          [Icone gouffre orange]            |
|     "Faille du Recif Brise"               |
|     Controlee par : Faction Abyssale      |
|                                           |
|  Garnison estimee : ~12 unites            |
|  Defenses estimees : Bouclier + Tourelle  |
|                                           |
|  [ Attaquer ]                             |
+-------------------------------------------+
```

### Bottom sheet — Station d'arrivee (Niveau 2)

```
+-------------------------------------------+
|          [Icone station]                   |
|     "Station d'arrivee"                   |
|     Point de descente depuis Niveau 1     |
|                                           |
|  Niveau : 0 (non construite)              |
|  Garnison : 0 unites                      |
|  Entretien : -- Energie/tour              |
|                                           |
|  [ Construire la station ]                |
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
|  [x] Siphonneurs     x2                  |
|                                           |
|  Capacite : 18/20 unites                  |
|                                           |
|      [ Annuler ]  [ Descendre ]           |
+-------------------------------------------+
```

---

## 11. Specificite Niveau 2 vers Niveau 3 (rarete)

Au Niveau 2, les **3 Cheminees du Noyau** sont les seuls passages vers l'objectif final. Leur rarete en fait le point de tension strategique du jeu.

### Consequences

- **Rarete** : seulement 3 cheminees pour l'ensemble du Niveau 2 — le joueur et les factions IA se les disputent
- **Course a la capture** : les factions IA peuvent tenter de capturer les cheminees pour bloquer le joueur
- **Defense critique** : une cheminee capturee par le joueur doit etre fortement defendue, car les factions IA tenteront de la reprendre

### Tension narrative

> *Au Niveau 1, les failles etaient nombreuses. Ici, dans les tenebres ecrasantes du Niveau 2, les cheminees sont rares. Trois passages seulement vers le Noyau. Le joueur et les factions rivales convergent vers les memes points. La descente vers le Noyau se merite.*

---

## 12. Integration avec les systemes existants

| Systeme | Impact |
|---------|--------|
| **Generation de carte** | Nouveau `CellContentType.transitionBase`, nouveau `TerrainType.fault` (-3 PV), placement par quadrant en bordure |
| **Combat** | Reutilise le systeme standard. Ajout du flag `isBoss` + multiplicateur x2 pour le Briseur de Dome contre `isBoss` |
| **Batiments** | Nouveaux types : `descentModule`, `pressureCapsule`, `currentShield`, `harpoonTurret`, `detectionSonar`, `transitionStation` |
| **Unites** | Siphonneur requis pour capture. Chaine d'assaut recommandee |
| **Technologies** | Prerequis branche Militaire niveaux 3 et 5 |
| **Ressources** | Couts de construction + entretien energie des defenses + entretien station (stock partage multi-niveaux) |
| **Resolution de tour** | Nouveau step : resolution des contre-attaques sur failles + transport inter-niveaux + desactivation batiments si energie insuffisante |
| **Actions** | Nouvelles : `attackTransitionBase`, `manageGarrison`, `buildDefense`, `descend`, `buildStation` |
| **Factions IA** | L'IA decide d'attaquer les failles, gere ses propres garnisons et descentes |
| **Persistence** | Nouveaux modeles Hive : TransitionBase, Garrison, TransitionStation, donnees par niveau |

---

## 13. Questions ouvertes

Les points suivants restent a definir dans des documents dedies ou lors de la phase d'equilibrage :

- **Contenu du Niveau 3 (Noyau)** : que trouve le joueur au Niveau 3 ? Objectif final ?
- **Valeurs numeriques de la Station d'arrivee** : cout de construction, entretien energetique, capacite de garnison par niveau
- **Mecanique de remontee** : le joueur peut-il renvoyer des unites du Niveau 2 vers le Niveau 1 via la faille ? (Le transport inter-niveaux le sous-entend, mais ce n'est pas explicite)
- **Politique de destruction des defenses** : a valider — ramener au niveau 1 (actuel) vs destruction totale
- **Equilibrage des contre-attaques** : frequence, composition et force des armees IA en fonction du tour et du niveau
