# rise-resource-prod — Feature Specification

## 1. Feature Overview

Rééquilibrage permanent des formules de production de ressources pour rendre le jeu plus généreux. La production de toutes les ressources (sauf l'énergie) est multipliée par 10. La production d'énergie est multipliée par 2. Le stockage max est ajusté proportionnellement. Les coûts de construction et les ressources de départ restent inchangés.

## 2. User Stories

### US-01 : Production de ressources augmentée

En tant que joueur, la production de mes bâtiments est significativement plus élevée afin de fluidifier la progression.

**Nouvelles formules de production :**

| Bâtiment | Ressource | Formule actuelle | Nouvelle formule | Multiplicateur |
|---|---|---|---|---|
| Ferme d'algues | Algues | `3 × level² + 2` | `30 × level² + 20` | ×10 |
| Mine de corail | Corail | `2 × level² + 2` | `20 × level² + 20` | ×10 |
| Extracteur de minerai | Minerai | `2 × level² + 1` | `20 × level² + 10` | ×10 |
| Panneau solaire | Énergie | `2 × level² + 1` | `4 × level² + 2` | ×2 |

**Exemples de production par niveau :**

| Niveau | Algues (avant → après) | Corail | Minerai | Énergie |
|---|---|---|---|---|
| 1 | 5 → 50 | 4 → 40 | 3 → 30 | 3 → 6 |
| 2 | 14 → 140 | 10 → 100 | 9 → 90 | 9 → 18 |
| 3 | 29 → 290 | 20 → 200 | 19 → 190 | 19 → 38 |
| 4 | 50 → 500 | 34 → 340 | 33 → 330 | 33 → 66 |
| 5 | 77 → 770 | 52 → 520 | 51 → 510 | 51 → 102 |

Critères d'acceptation :
- Les bâtiments de niveau 0 produisent toujours 0
- Le QG ne produit toujours rien
- La production d'énergie est bien multipliée par 2 (et non 10)

### US-02 : Stockage max augmenté proportionnellement

En tant que joueur, mon stockage max est augmenté pour accompagner la hausse de production et éviter un plafonnement trop rapide.

**Nouveaux plafonds de stockage :**

| Ressource | Stockage actuel | Nouveau stockage | Multiplicateur |
|---|---|---|---|
| Algues | 500 | 5000 | ×10 |
| Corail | 500 | 5000 | ×10 |
| Minerai | 500 | 5000 | ×10 |
| Énergie | 500 | 1000 | ×2 |
| Perles | 100 | 100 | inchangé |

Critères d'acceptation :
- Le stockage des perles reste à 100 (non concerné)
- Le mécanisme de plafonnement (cap) fonctionne toujours correctement
- Les ressources qui dépassent le max sont toujours perdues (pas de changement de comportement)

### Éléments inchangés

- **Ressources de départ** : Algues 100, Corail 80, Minerai 50, Énergie 60, Perles 5
- **Coûts de construction/amélioration** : identiques (le jeu est volontairement plus généreux)
- **Perles** : ni production ni stockage modifiés

## 3. Testing and Validation

### Tests unitaires
- Vérifier chaque nouvelle formule de production pour les niveaux 0 à 5
- Vérifier que le niveau 0 produit toujours 0 pour chaque bâtiment
- Vérifier les nouveaux plafonds de stockage pour chaque type de ressource
- Vérifier que le plafonnement fonctionne avec les nouvelles valeurs

### Tests d'intégration
- Simuler un tour complet et vérifier que la production est correctement appliquée avec les nouvelles formules
- Vérifier que le stockage est bien plafonné aux nouvelles valeurs lors de la résolution d'un tour
