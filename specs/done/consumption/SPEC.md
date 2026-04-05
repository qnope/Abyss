# Consumption — Feature Specification

## 1. Feature Overview

Les bâtiments consomment de l'énergie chaque tour et les unités consomment des algues chaque tour. Cette mécanique de maintenance ajoute une dimension stratégique : le joueur doit équilibrer sa production et sa consommation pour éviter la désactivation de bâtiments ou la perte d'unités.

### Résumé des règles

- **Bâtiments** : chaque bâtiment construit (niveau ≥ 1) consomme de l'énergie par tour, proportionnellement à son niveau.
- **Unités** : chaque unité vivante consomme des algues par tour, proportionnellement au type d'unité.
- La consommation est d'abord déduite de la **production du tour**. Si la consommation dépasse la production, le surplus est déduit du **stock**.
- Si le stock tombe à 0, des **pénalités** s'appliquent.

---

## 2. User Stories

### US-1 : Consommation d'énergie par les bâtiments

**En tant que** joueur,
**je veux** que mes bâtiments consomment de l'énergie chaque tour,
**afin de** devoir gérer stratégiquement ma production d'énergie.

**Critères d'acceptation :**

- Tous les bâtiments de niveau ≥ 1 consomment de l'énergie (y compris le QG et le panneau solaire).
- La consommation augmente avec le niveau du bâtiment.
- La consommation est calculée et appliquée lors de la résolution du tour.

### US-2 : Consommation d'algues par les unités

**En tant que** joueur,
**je veux** que mes unités consomment des algues chaque tour,
**afin de** devoir équilibrer la taille de mon armée avec ma production alimentaire.

**Critères d'acceptation :**

- Chaque unité vivante consomme des algues par tour.
- Les unités plus avancées consomment davantage d'algues.
- La consommation est calculée et appliquée lors de la résolution du tour.

### US-3 : Désactivation de bâtiments en cas de pénurie d'énergie

**En tant que** joueur,
**je veux** que mes bâtiments soient désactivés quand je n'ai plus assez d'énergie,
**afin de** subir les conséquences d'une mauvaise gestion énergétique.

**Critères d'acceptation :**

- Quand l'énergie (production + stock) est insuffisante pour alimenter tous les bâtiments, certains sont désactivés.
- Les bâtiments désactivés ont une production de 0 pour le tour.
- L'ordre de désactivation suit une priorité fixe (les derniers sont désactivés en premier) :
  1. QG (jamais désactivé)
  2. Panneau Solaire
  3. Caserne
  4. Laboratoire
  5. Ferme d'Algues
  6. Mine de Corail
  7. Extracteur de Minerai
- Les bâtiments sont réactivés automatiquement si l'énergie redevient suffisante au tour suivant.

### US-4 : Perte d'unités en cas de pénurie d'algues

**En tant que** joueur,
**je veux** que mes unités meurent quand je n'ai plus assez d'algues,
**afin de** subir les conséquences d'une armée trop grande pour ma production.

**Critères d'acceptation :**

- Quand les algues (production + stock) sont insuffisantes pour nourrir toutes les unités, des unités meurent.
- Les pertes sont réparties **proportionnellement** sur tous les types d'unités (chaque type perd le même pourcentage de ses effectifs, arrondi vers le haut pour les pertes).
- Les unités mortes sont définitivement perdues.

### US-5 : Affichage de la production nette dans la barre de ressources

**En tant que** joueur,
**je veux** voir la production brute ET la consommation séparément dans la barre de ressources,
**afin de** comprendre immédiatement mon bilan énergétique et alimentaire.

**Critères d'acceptation :**

- Pour l'énergie : affichage du type `+10 / -8` (production / consommation).
- Pour les algues : affichage du type `+50 / -12` (production / consommation).
- Les autres ressources (corail, minerai, perles) affichent uniquement leur production comme actuellement.
- Si la consommation dépasse la production, l'affichage est visuellement distinct (couleur d'alerte).

### US-6 : Avertissement avant et après le tour

**En tant que** joueur,
**je veux** être averti des problèmes de consommation avant et après la résolution du tour,
**afin de** pouvoir anticiper et comprendre les conséquences.

**Critères d'acceptation :**

- **Avant le tour (confirmation)** : si la consommation dépasse la production + stock, un avertissement liste les bâtiments qui seront désactivés et/ou les unités qui mourront.
- **Après le tour (résumé)** : le résumé affiche les bâtiments désactivés et les unités perdues à cause de la consommation.

---

## 3. Testing and Validation

### Tests unitaires (domain)

- **ConsumptionCalculator** : vérifier le calcul de consommation par bâtiment (par niveau) et par unité (par type).
- **TurnResolver** : vérifier que la consommation est déduite correctement (d'abord de la production, puis du stock).
- **Désactivation de bâtiments** : vérifier l'ordre de priorité et que les bâtiments désactivés ne produisent plus.
- **Perte d'unités** : vérifier la répartition proportionnelle des pertes.
- **Cas limites** : consommation = production exacte, stock = 0, aucune unité, aucun bâtiment.

### Tests de widgets (presentation)

- **Barre de ressources** : vérifier l'affichage `+X / -Y` pour énergie et algues.
- **Confirmation de tour** : vérifier l'apparition des avertissements en cas de déficit.
- **Résumé de tour** : vérifier l'affichage des bâtiments désactivés et unités perdues.

### Tests d'intégration

- Scénario complet : construire des bâtiments, recruter des unités, passer des tours, vérifier que la consommation s'applique correctement et que les pénalités se déclenchent.

### Critères de succès

- `flutter analyze` passe sans erreur.
- `flutter test` passe à 100%.
- Les fichiers respectent la limite de 150 lignes.
