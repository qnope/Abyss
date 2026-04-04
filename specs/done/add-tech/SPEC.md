# add-tech — Arbre Technologique

## 1. Feature Overview

Ajout de l'onglet "Tech" (4ème tab du jeu) avec un arbre technologique visuel en forme d'arbre vertical. Le joueur peut rechercher des technologies pour améliorer ses capacités militaires, de production de ressources et d'exploration.

L'arbre est structuré ainsi (de haut en bas) :

```
         [Labo]              ← Noeud racine (indicateur visuel)
        /   |   \
  [Milit] [Ress] [Explo]    ← 3 branches à débloquer
    |       |       |
   1-5     1-5     1-5      ← 5 noeuds linéaires par branche
```

## 2. User Stories

### US-01 : Visualiser l'arbre technologique

**En tant que** joueur, **je veux** voir l'arbre technologique dans l'onglet Tech **afin de** comprendre les améliorations disponibles.

**Critères d'acceptation :**
- L'onglet Tech affiche un arbre vertical scrollable
- Le noeud racine affiche l'icône du laboratoire (`laboratory.svg`)
- Si le laboratoire n'est pas construit (niveau 0), tout l'arbre est grisé
- Si le laboratoire est construit (niveau >= 1), le noeud racine est coloré et les branches sont visibles
- 3 branches partent du noeud racine : Militaire, Ressources, Explorateur
- Chaque branche a 5 sous-noeuds disposés verticalement

### US-02 : Débloquer une branche technologique

**En tant que** joueur, **je veux** débloquer une branche de l'arbre **afin de** commencer à rechercher ses technologies.

**Prérequis :** Laboratoire construit (niveau >= 1)

**Branches et icônes :**
| Branche | Icône | Description |
|---------|-------|-------------|
| Militaire | `barracks.svg` | Améliore l'attaque et la défense des unités |
| Ressources | `algae.svg` | Améliore la production de ressources |
| Explorateur | `scout.svg` | Améliore la capacité d'exploration de la carte |

**Coût de déblocage (par branche) :**
| Branche | Ressources requises |
|---------|-------------------|
| Militaire | Minerai: 30, Énergie: 20 |
| Ressources | Corail: 30, Algues: 20 |
| Explorateur | Énergie: 30, Minerai: 20 |

**Critères d'acceptation :**
- Le joueur peut cliquer sur un noeud de branche pour voir ses détails
- Un bottom sheet affiche le coût de déblocage et un bouton "Débloquer"
- Si le labo n'est pas construit, le bouton est désactivé avec un message explicatif
- Si les ressources sont insuffisantes, les coûts manquants sont affichés en rouge
- Le déblocage est instantané : les ressources sont déduites et la branche est active
- Une branche débloquée affiche son icône en couleur ; une branche verrouillée est grisée

### US-03 : Rechercher une technologie (noeud 1 à 5)

**En tant que** joueur, **je veux** rechercher les technologies d'une branche débloquée **afin d'** améliorer mes capacités.

**Prérequis pour chaque noeud :**
| Noeud | Niveau labo requis | Bonus cumulatif | Noeud précédent requis |
|-------|-------------------|-----------------|----------------------|
| 1 | 1 | +20% | Branche débloquée |
| 2 | 2 | +40% | Noeud 1 |
| 3 | 3 | +60% | Noeud 2 |
| 4 | 4 | +80% | Noeud 3 |
| 5 | 5 | +100% | Noeud 4 |

**Coûts en ressources (progressifs par branche) :**

*Branche Militaire (Minerai + Énergie) :*
| Noeud | Minerai | Énergie | Perles |
|-------|---------|---------|--------|
| 1 | 40 | 25 | — |
| 2 | 80 | 50 | — |
| 3 | 150 | 90 | — |
| 4 | 250 | 150 | 5 |
| 5 | 400 | 250 | 10 |

*Branche Ressources (Corail + Algues) :*
| Noeud | Corail | Algues | Perles |
|-------|--------|--------|--------|
| 1 | 40 | 25 | — |
| 2 | 80 | 50 | — |
| 3 | 150 | 90 | — |
| 4 | 250 | 150 | 5 |
| 5 | 400 | 250 | 10 |

*Branche Explorateur (Énergie + Minerai) :*
| Noeud | Énergie | Minerai | Perles |
|-------|---------|---------|--------|
| 1 | 40 | 25 | — |
| 2 | 80 | 50 | — |
| 3 | 150 | 90 | — |
| 4 | 250 | 150 | 5 |
| 5 | 400 | 250 | 10 |

**Critères d'acceptation :**
- Le joueur clique sur un noeud pour voir ses détails (bottom sheet)
- Le bottom sheet affiche : icône de branche + numéro de niveau, bonus accordé, coût, prérequis
- Les noeuds sont recherchables séquentiellement (1 → 2 → 3 → 4 → 5)
- La recherche est instantanée : ressources déduites, bonus appliqué immédiatement
- Un noeud recherché est affiché en couleur vive
- Un noeud accessible (prérequis OK) mais non recherché est affiché en couleur atténuée
- Un noeud inaccessible (prérequis manquants) est grisé

### US-04 : Effets des technologies

**En tant que** joueur, **je veux** que les technologies recherchées aient un effet concret **afin que** ma progression soit récompensée.

**Branche Militaire :**
- Chaque noeud augmente l'attaque et la défense de toutes les unités de +20% (cumulatif)
- Noeud 5 = +100% attaque et défense
- L'effet sera appliqué quand le système de combat sera implémenté
- Le bonus est stocké dans le modèle de données

**Branche Ressources :**
- Chaque noeud augmente la production de toutes les ressources de +20% (cumulatif)
- Noeud 5 = +100% de production
- L'effet est appliqué immédiatement dans le calcul de production (`ProductionCalculator`)

**Branche Explorateur :**
- Chaque noeud augmente la portée d'exploration de +20% (cumulatif)
- Noeud 5 = +100% de portée d'exploration
- L'effet sera appliqué quand le système de carte sera implémenté
- Le bonus est stocké dans le modèle de données

**Critères d'acceptation :**
- La branche Ressources applique son bonus immédiatement sur la production
- Les bonus Militaire et Explorateur sont stockés et consultables
- La barre de ressources reflète le bonus de production si la branche Ressources est recherchée

### US-05 : Représentation visuelle des noeuds

**En tant que** joueur, **je veux** que l'arbre soit visuellement clair **afin de** comprendre ma progression.

**États visuels des noeuds :**
| État | Apparence |
|------|-----------|
| Verrouillé (prérequis manquants) | Icône grisée, opacité réduite, pas de connexion colorée |
| Accessible (prérequis OK, non recherché) | Icône en couleur atténuée, bordure pointillée ou pulsante |
| Recherché (complété) | Icône en couleur vive, bordure pleine, connexion colorée vers le suivant |

**Connexions entre noeuds :**
- Des lignes verticales relient les noeuds du haut vers le bas
- Les lignes sont colorées si le noeud source est recherché, grisées sinon

**Icônes des sous-noeuds :**
- Même icône que la branche parente (barracks.svg, algae.svg, scout.svg)
- Un indicateur de niveau (1 à 5) est affiché sur ou à côté du noeud

**Critères d'acceptation :**
- Les 3 états visuels sont clairement distinguables
- L'arbre est scrollable verticalement si nécessaire
- Le layout s'adapte à différentes tailles d'écran
- Les couleurs respectent le thème Abyss (bioluminescence)

## 3. Testing and Validation

### Tests unitaires
- Modèle de données : création, sérialisation/désérialisation Hive de l'arbre tech
- Calcul des coûts : vérification des coûts pour chaque noeud de chaque branche
- Validation des prérequis : niveau de labo, noeud précédent, branche débloquée
- Action de recherche : validation + exécution (déduction ressources, déblocage noeud)
- Effet sur la production : vérifier que le bonus Ressources s'applique au `ProductionCalculator`

### Tests de widgets
- Affichage de l'arbre avec différents états (labo non construit, branches débloquées, noeuds recherchés)
- Bottom sheet de détail d'un noeud
- États visuels des noeuds (verrouillé, accessible, recherché)

### Critères de succès
- L'onglet Tech remplace le placeholder actuel
- L'arbre s'affiche correctement avec tous les noeuds
- Le joueur peut débloquer des branches et rechercher des technologies
- La production de ressources est augmentée par la branche Ressources
- Les fichiers restent sous 150 lignes
- `flutter analyze` et `flutter test` passent sans erreur
