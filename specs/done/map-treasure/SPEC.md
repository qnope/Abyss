# Map Treasure - Feature Specification

## 1. Feature Overview

Actuellement, cliquer sur n'importe quelle case de la carte ouvre systématiquement le panneau d'exploration. Cette feature introduit des **interactions contextuelles** selon le type et l'état de la case cliquée :

- **Trésor (resourceBonus)** : bouton "Collecter le trésor" pour récupérer des ressources gratuitement.
- **Ruines (ruins)** : bouton "Collecter le trésor" pour récupérer des ressources aléatoires + des perles.
- **Monstre (monsterLair)** : affichage de la difficulté du monstre et message "Combat non disponible".
- **Plaine révélée vide (empty)** : message "Il n'y a rien à voir ici".
- **Case déjà collectée** : l'icône reste visible mais grisée, message "Vous êtes déjà venu par ici".
- **Base du joueur** : affiche des informations sur la base.
- **Case non révélée** : comportement actuel (envoi d'éclaireurs).

## 2. User Stories

### US-1 : Collecter un bonus de ressources

**En tant que** joueur,
**je veux** cliquer sur une case révélée contenant un bonus de ressources et collecter le trésor,
**afin de** récupérer les ressources indiquées.

**Critères d'acceptation :**
- Un bottom sheet s'ouvre avec l'icône de ressource, les coordonnées, le type et le montant de ressources.
- Un bouton "Collecter le trésor" est affiché.
- La collecte est **gratuite** (aucun coût en éclaireur ou autre).
- La collecte est **immédiate** (pas de résolution au tour suivant).
- Les ressources sont ajoutées au stock du joueur instantanément.
- Après collecte, la case reste visible sur la carte mais son icône est **grisée**.
- Si on reclique sur la case, le message "Vous êtes déjà venu par ici" s'affiche (pas de bouton de collecte).

### US-2 : Collecter des ruines

**En tant que** joueur,
**je veux** cliquer sur une case révélée contenant des ruines et collecter le trésor,
**afin de** récupérer des ressources aléatoires et des perles.

**Critères d'acceptation :**
- Un bottom sheet s'ouvre avec l'icône de ruines, les coordonnées, et un texte indiquant la nature de la récompense.
- Un bouton "Collecter le trésor" est affiché.
- La collecte est **gratuite** et **immédiate**.
- Les ruines donnent : **20-80 ressources aléatoires** (type aléatoire) + **1-5 perles**.
- Les montants sont générés aléatoirement au moment de la collecte (ou de la génération de la carte).
- Les ressources et perles sont ajoutées au stock du joueur.
- Après collecte, la case reste visible mais son icône est **grisée**.
- Si on reclique sur la case, le message "Vous êtes déjà venu par ici" s'affiche.

### US-3 : Cliquer sur un monstre

**En tant que** joueur,
**je veux** voir les informations du monstre quand je clique sur sa case,
**afin de** connaître sa difficulté avant qu'un futur système de combat soit disponible.

**Critères d'acceptation :**
- Un bottom sheet s'ouvre avec l'icône du monstre, les coordonnées, et la **difficulté** (Facile / Moyen / Difficile).
- Le message "Combat non disponible" est affiché clairement.
- Aucun bouton d'action n'est disponible (pas de collecte, pas de combat).

### US-4 : Cliquer sur une plaine vide révélée

**En tant que** joueur,
**je veux** voir un message informatif quand je clique sur une case vide déjà révélée,
**afin de** savoir qu'il n'y a rien d'intéressant.

**Critères d'acceptation :**
- Un bottom sheet s'ouvre avec les coordonnées et le message "Il n'y a rien à voir ici".
- Aucun bouton d'action n'est disponible.

### US-5 : Cliquer sur la base du joueur

**En tant que** joueur,
**je veux** voir des informations sur ma base quand je clique dessus,
**afin d'**avoir un rappel visuel de l'emplacement de mon QG.

**Critères d'acceptation :**
- Un bottom sheet s'ouvre avec l'icône de la base, les coordonnées, et un texte "Votre base".
- Aucun bouton d'action n'est disponible.

### US-6 : Explorer une case non révélée

**En tant que** joueur,
**je veux** pouvoir envoyer des éclaireurs sur les cases non révélées éligibles,
**afin de** découvrir la carte.

**Critères d'acceptation :**
- Comportement **identique** à l'existant (ExplorationSheet actuel).
- Les cases non révélées adjacentes à une case révélée affichent le panneau d'exploration avec coût, éclaireurs disponibles, zone révélée.
- Les cases non révélées non adjacentes ne sont pas éligibles.

### US-7 : Case déjà collectée

**En tant que** joueur,
**je veux** voir qu'une case a déjà été visitée quand je reclique dessus,
**afin de** ne pas confondre avec une case non collectée.

**Critères d'acceptation :**
- L'icône de la case (resourceBonus ou ruins) reste affichée sur la carte mais avec un **effet grisé** (opacité réduite ou désaturation).
- Cliquer sur la case ouvre un bottom sheet avec le message "Vous êtes déjà venu par ici".
- Aucun bouton d'action n'est disponible.

## 3. Testing and Validation

### Tests unitaires (domain)
- Collecte d'un resourceBonus : vérifie que les ressources sont ajoutées au stock du joueur.
- Collecte de ruines : vérifie que les ressources aléatoires (20-80) et les perles (1-5) sont ajoutées.
- Collecte d'une case déjà collectée : vérifie que l'action échoue ou est refusée.
- Le flag "collecté" persiste correctement après sauvegarde/chargement.

### Tests unitaires (présentation)
- Le bon type de bottom sheet s'affiche selon le contenu et l'état de la case :
  - resourceBonus révélé non collecté → bouton "Collecter le trésor"
  - ruins révélé non collecté → bouton "Collecter le trésor"
  - monsterLair révélé → difficulté + "Combat non disponible"
  - empty révélé → "Il n'y a rien à voir ici"
  - base du joueur → "Votre base"
  - case non révélée éligible → panneau d'exploration existant
  - case déjà collectée → "Vous êtes déjà venu par ici"

### Tests d'intégration
- Scénario complet : générer une carte, révéler des cases, collecter un trésor, vérifier le stock de ressources, vérifier l'état grisé de la case.
- Vérifier que les ruines donnent bien des perles en plus des ressources.

### Critères de réussite
- `flutter analyze` passe sans erreur.
- `flutter test` passe à 100%.
- Chaque fichier reste sous 150 lignes.
