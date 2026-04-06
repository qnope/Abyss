# Bases de Transition — Les Failles Abyssales

## 1. Lore

### Qu'est-ce qu'une Faille Abyssale ?

Les **Failles Abyssales** sont des formations geologiques naturelles — des gouffres beants dans le plancher oceanique, des fissures tectoniques profondes creees par l'activite sismique des profondeurs. Ce sont les seuls passages physiques entre les niveaux de profondeur.

### Deux types selon le niveau

| Passage | Nom | Description |
|---------|-----|-------------|
| Niveau 1 → 2 | **Faille Abyssale** | Crevasse sombre dans le fond corallien, entouree de recifs brises. Des courants descendants violents aspirent tout vers les profondeurs. La bioluminescence des creatures gardiennes eclaire l'entree d'une lueur inquietante. Les parois sont couvertes de cristaux mineraux et de concretions anciennes. |
| Niveau 2 → 3 | **Cheminee du Noyau** | Cheminee volcanique massive crachant de la fumee noire. La temperature augmente, le sol vibre. Des creatures de lave et de roche gardent l'acces. L'environnement est hostile — pression extreme, courants thermiques, visibilite quasi nulle sauf par la lueur volcanique. |

### Pourquoi sont-elles gardees ?

Les creatures des profondeurs remontent naturellement par ces failles pour chasser dans les eaux superieures. Des especes puissantes s'y sont installees comme **predateurs apex**, controlant le flux entre les niveaux. La faille est leur territoire — et quiconque veut descendre doit d'abord les vaincre.

---

## 2. Placement sur la carte

### Niveau 1 (Surface) — Failles Abyssales

- **Nombre** : 1 par alliance presente sur la carte
- **Placement** : Reparties sur les bords exterieurs de la carte (distance > 8 cases du centre)
- **Espacement** : Minimum 5 cases entre deux failles
- **Visibilite** : Cachees par le fog of war, decouvertes par exploration
- **Terrain adjacent** : Les 4 cases cardinales adjacentes a la faille sont du terrain "Fault" (faille, -3 PV si traverse) — signalant une zone dangereuse au joueur
- **Contenu de la case** : Nouveau type `CellContentType.transitionBase`

### Niveau 2 (Profondeurs) — Cheminees du Noyau

- **Nombre** : 1 pour 2 alliances (arrondi au superieur). Exemple : 5 alliances au niveau 2 = 3 cheminees
- **Placement** : Meme logique mais encore plus eloignees (distance > 10 du centre)
- **Consequence strategique** : 2 alliances se disputent chaque cheminee — capturer une cheminee bloque l'autre alliance, creant une competition directe pour l'acces au Noyau

---

## 3. Decouverte

1. Le joueur explore la carte normalement avec des Eclaireurs
2. Quand une faille est revelee, un **marqueur special** apparait sur la carte (icone de gouffre avec lueur pulsante)
3. **Informations affichees a la decouverte** :
   - Nom de la faille (genere : ex. "Faille de l'Ombre Profonde", "Cheminee du Serpent Noir")
   - Difficulte estimee des gardiens
   - Statut : non capturee / capturee par [faction/alliance]
4. Les failles sont attribuees aux alliances lors de la generation de la carte, mais cette attribution est invisible — c'est uniquement pour guider le comportement de l'IA

---

## 4. Prerequis pour l'assaut

Avant de pouvoir attaquer une faille, le joueur doit remplir des conditions :

### Faille Abyssale (Niveau 1 → 2)

| Prerequis | Valeur |
|-----------|--------|
| QG | Niveau 7+ |
| Tech Militaire | Niveau 3+ |
| Batiment special | "Module de descente" construit dans la base |

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
| Batiment special | "Capsule de pression" construite dans la base |

**Cout de la Capsule de pression :**

| Ressource | Quantite |
|-----------|----------|
| Corail | 400 |
| Minerai | 300 |
| Energie | 150 |
| Perles | 15 |

> Le batiment special represente la capacite technique a survivre dans les profondeurs. Il se construit dans la base principale du joueur.

---

## 5. Assaut initial — Combat de boss

### Gardiens de la Faille Abyssale (Niveau 1 → 2)

**"Leviathan des Abysses"** — 1 boss + escorte

| Creature | PV | ATK | DEF | Nombre |
|----------|----|-----|-----|--------|
| Leviathan | 100 | 15 | 10 | 1 |
| Sentinelle abyssale | 30 | 8 | 5 | 5 |

### Gardiens de la Cheminee du Noyau (Niveau 2 → 3)

**"Titan Volcanique"** — 1 boss + escorte renforcee

| Creature | PV | ATK | DEF | Nombre |
|----------|----|-----|-----|--------|
| Titan Volcanique | 200 | 25 | 15 | 1 |
| Golem de magma | 50 | 12 | 8 | 8 |

### Deroulement du combat

1. Le joueur selectionne les unites a envoyer
2. Le combat utilise le systeme de combat standard
3. **Chaine d'assaut recommandee** :
   - **Eclaireur** : reperage (bonus de precision pour le groupe)
   - **Briseur de Dome** : bonus de degats de siege contre le boss
   - **Harponneurs** : degats principaux
   - **Gardiens** : absorbent les degats du boss
   - **Siphonneur** : capture la faille une fois les gardiens vaincus

### En cas d'echec

- L'armee envoyee est **perdue** (unites detruites)
- Les gardiens **regenerent 50% de leurs PV** chaque tour
- Le joueur doit recruter une nouvelle armee et retenter

### Capture

- Une fois les gardiens vaincus, le **Siphonneur** capture la faille
- **Au moins 1 Siphonneur** doit faire partie de l'armee d'assaut
- La faille passe sous controle du joueur
- Evenement narratif : *"Les creatures se dispersent dans les profondeurs... La faille est a vous. Un gouffre sans fond s'ouvre devant vos forces. Les profondeurs vous attendent."*

---

## 6. Defense de la faille capturee

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

**Regles des batiments defensifs :**

- Construction : 1 tour par niveau
- Limite : 1 de chaque type par faille (maximum 3 batiments)
- L'entretien en Energie est preleve depuis le stock global du joueur

---

## 7. Contre-attaques IA

Les factions IA hostiles (hors alliance du joueur) peuvent attaquer les failles capturees.

### Probabilite

| Tours depuis capture | Chance par tour |
|----------------------|-----------------|
| 1-5 | 5% |
| 6-10 | 10% |
| 11-15 | 20% |
| 16+ | 30% (plafond) |

### Deroulement

1. **Detection (si Sonar)** : Le joueur est prevenu X tours a l'avance → notification dans le resume de tour : *"Le sonar detecte un mouvement hostile vers la Faille de l'Ombre Profonde. Attaque estimee dans X tours."*
2. **Attaque** : L'armee IA attaque la faille
3. **Resolution** :
   - La tourelle inflige ses degats pre-combat
   - Le bouclier absorbe les premiers degats
   - Combat garnison (+50% DEF) vs armee IA
4. **Resultat** :
   - **Victoire defenseur** : L'armee IA est detruite, la faille reste au joueur
   - **Victoire attaquant** : La garnison est detruite, les batiments defensifs sont detruits, la faille redevient **neutre** (sans gardiens boss)

### Recapture apres perte

- Pas besoin de combattre un boss (les gardiens naturels ne reviennent pas)
- Le joueur doit envoyer un **Siphonneur** pour recapturer
- Si une faction IA a capture la faille, le joueur doit d'abord vaincre la garnison IA

---

## 8. Transition vers le niveau suivant

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
4. **Nouveau niveau** : Une nouvelle grille 20x20 est generee, entierement en fog of war
5. Le joueur demarre au **point d'arrivee** de la faille (position fixee lors de la generation)
6. Les unites selectionnees sont disponibles immediatement
7. **Pas de base au depart** : Le joueur doit capturer une base IA ou construire un avant-poste

### Gestion multi-niveaux

- Le joueur **conserve sa base** au niveau precedent (production continue)
- Les **ressources sont partagees** entre tous les niveaux (stock unique global)
- Le recrutement se fait depuis la base principale et les unites sont envoyees via la faille
- **Transport inter-niveaux** : Possible via les failles controlees, prend 1 tour, limite par la capacite du batiment

---

## 9. Articulation a l'ecran (UI/UX)

### Representation sur la carte

| Etat | Apparence |
|------|-----------|
| Non decouverte | Case fog of war normale |
| Decouverte, non capturee | Icone de gouffre + lueur rouge pulsante + halo de danger |
| Capturee par le joueur | Icone de gouffre + lueur cyan + badge alliance du joueur |
| Capturee par une faction IA | Icone de gouffre + lueur orange + badge faction |

### Bottom sheet — Faille non capturee

```
+-------------------------------------------+
|          [Icone gouffre rouge]             |
|     "Faille de l'Ombre Profonde"          |
|                                           |
|  Gardiens : Leviathan des Abysses         |
|  Difficulte : ★★★★☆                       |
|                                           |
|  Prerequis :                              |
|  ✅ QG niveau 7                            |
|  ✅ Tech Militaire niveau 3                |
|  ❌ Module de descente (non construit)     |
|                                           |
|  [ Lancer l'assaut ] (grise si ❌)         |
+-------------------------------------------+
```

### Bottom sheet — Faille capturee (joueur)

```
+-------------------------------------------+
|          [Icone gouffre cyan]              |
|     "Faille de l'Ombre Profonde"          |
|     Controlee par votre alliance          |
|                                           |
|  Garnison : 8/15 unites                   |
|  Defenses :                               |
|    Bouclier Niv 2 (100 degats)            |
|    Tourelle Niv 1 (20 degats)             |
|    Sonar Niv 1 (1 tour d'avance)          |
|                                           |
|  ⚠️ Attaque detectee dans 2 tours !        |
|                                           |
|  [ Gerer garnison ]                       |
|  [ Construire defenses ]                  |
|  [ Descendre au Niveau 2 ]               |
+-------------------------------------------+
```

### Bottom sheet — Faille capturee (IA)

```
+-------------------------------------------+
|          [Icone gouffre orange]            |
|     "Faille du Recif Brise"               |
|     Controlee par : Alliance du Nord      |
|                                           |
|  Garnison estimee : ~12 unites            |
|  Defenses estimees : Bouclier + Tourelle  |
|                                           |
|  [ Attaquer ]                             |
+-------------------------------------------+
```

### Selecteur de niveau (en haut de l'onglet carte)

```
[ Niv 1: Surface ]  [ 🔒 Niv 2: Profondeurs ]  [ 🔒 Niv 3: Noyau ]
     (actif)             (grise)                    (grise)
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
|  ☑ Eclaireurs      x5                    |
|  ☑ Harponneurs     x8                    |
|  ☐ Gardiens        x3                    |
|  ☑ Siphonneurs     x2                    |
|                                           |
|  Capacite : 15/20 unites                  |
|                                           |
|      [ Annuler ]  [ Descendre ]           |
+-------------------------------------------+
```

---

## 10. Specificite Niveau 2 → Niveau 3 (competition)

Au niveau 2, chaque Cheminee du Noyau est partagee entre **2 alliances**. C'est le climax strategique du jeu.

### Consequences

- **Course a la capture** : La premiere alliance a vaincre les gardiens prend le controle
- **Blocage** : L'alliance qui ne controle pas la cheminee ne peut pas descendre au Noyau
- **Le joueur a 3 options** :
  1. **Attaquer** la cheminee controlee par l'alliance rivale (guerre directe)
  2. **Negocier** avec l'alliance en controle (diplomatie, si implementee)
  3. **Eliminer** une autre alliance pour liberer une cheminee

### Tension narrative

> *Au Niveau 1, chaque alliance avait sa propre porte vers les profondeurs. Ici, dans les tenebres ecrasantes du Niveau 2, les cheminees sont rares. Deux alliances se retrouvent face a face devant le meme passage vers le Noyau. L'une descendra. L'autre restera dans l'obscurite.*

---

## 11. Integration avec les systemes existants

| Systeme | Impact |
|---------|--------|
| **Generation de carte** | Nouveau `CellContentType.transitionBase` + placement en bordure de carte |
| **Combat** | Reutilise le systeme de combat standard, boss = unites avec stats speciales |
| **Batiments** | Nouveaux types : `descentModule`, `pressureCapsule`, `currentShield`, `harpoonTurret`, `detectionSonar` |
| **Unites** | Siphonneur requis pour capture, chaine d'assaut complete utilisee |
| **Technologies** | Prerequis branche Militaire pour attaquer |
| **Ressources** | Couts de construction + entretien energie des defenses (stock partage multi-niveaux) |
| **Resolution de tour** | Nouveau step : resolution des contre-attaques sur failles + transport inter-niveaux |
| **Actions** | Nouvelles : `attackTransitionBase`, `manageGarrison`, `buildDefense`, `descend` |
| **Factions IA** | L'IA decide d'attaquer les failles, gere ses propres garnisons et descentes |
| **Persistence** | Nouveaux modeles Hive : TransitionBase, Garrison, failles par niveau |
