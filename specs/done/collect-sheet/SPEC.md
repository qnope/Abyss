# Collect Sheet - Feature Specification

## 1. Feature Overview

Cette feature ajoute un **retour visuel explicite** lors de la collecte d'un trésor (resourceBonus) ou de ruines (ruins) sur la carte. Aujourd'hui, l'action `CollectTreasureAction` ajoute silencieusement les ressources au stock du joueur, sans informer le joueur du détail de ce qui a été collecté.

Cette feature comporte deux changements :

1. **Affichage du résultat de collecte** : après une collecte, le bottom sheet d'interaction se ferme automatiquement et une **dialog modale** s'ouvre pour présenter les ressources gagnées (icône + montant).
2. **Rééquilibrage des ruines** : les ressources non-perles données par les ruines passent à des intervalles plus larges et plus utiles au joueur :
   - Algues : 0-100
   - Corail : 0-25
   - Minerai océanique : 0-25
   - Perles : 0-2 (inchangé par rapport à l'implémentation actuelle)

Les valeurs des trésors (resourceBonus) restent inchangées.

## 2. User Stories

### US-1 : Voir le détail des ressources collectées (trésor)

**En tant que** joueur,
**je veux** voir précisément combien de chaque ressource j'ai gagné après avoir collecté un trésor,
**afin de** comprendre l'impact de mon action sur mon économie.

**Critères d'acceptation :**
- Quand je clique sur "Collecter le trésor" sur une case `resourceBonus`, l'action est exécutée comme actuellement.
- Le bottom sheet d'interaction de la case se **ferme automatiquement** dès que la collecte est validée.
- Une **dialog modale** s'ouvre par-dessus la carte avec :
  - Un titre clair (ex : "Trésor collecté !").
  - Une liste des ressources gagnées, chaque ligne contenant :
    - L'icône de la ressource.
    - Le montant gagné préfixé par `+` (ex : `+75`).
  - Seules les ressources avec un montant **strictement supérieur à 0** sont affichées.
  - Un bouton de fermeture (ex : "OK") qui ferme la dialog.
- Les montants affichés correspondent **exactement** aux montants effectivement ajoutés au stock (en tenant compte d'un éventuel `clamp` au `maxStorage`).

### US-2 : Voir le détail des ressources collectées (ruines)

**En tant que** joueur,
**je veux** voir précisément combien de chaque ressource (et de perles) j'ai gagné après avoir collecté des ruines,
**afin de** savoir si mon exploration a été rentable.

**Critères d'acceptation :**
- Quand je clique sur "Collecter le trésor" sur une case `ruins`, l'action est exécutée.
- Le bottom sheet se ferme automatiquement et la dialog modale s'ouvre (même comportement que US-1).
- La dialog affiche les ressources gagnées avec icône + `+montant`.
- Si aucune ressource n'est gagnée (cas extrême : tous les tirages aléatoires donnent 0), la dialog affiche un message indiquant que les ruines étaient vides (ex : "Les ruines étaient vides...").

### US-3 : Rééquilibrage des récompenses des ruines

**En tant que** joueur,
**je veux** que les ruines donnent des récompenses significatives en ressources standards,
**afin de** ressentir un vrai bénéfice à explorer et collecter des ruines.

**Critères d'acceptation :**
- Lors de la collecte d'une case `ruins`, les ressources ajoutées sont tirées dans les intervalles suivants (uniformes) :
  - **Algues** : entre 0 et 100 inclus.
  - **Corail** : entre 0 et 25 inclus.
  - **Minerai océanique** : entre 0 et 25 inclus.
  - **Perles** : entre 0 et 2 inclus (inchangé).
- Les bornes sont toutes inclusives.
- Chaque ressource est tirée indépendamment des autres.
- Les valeurs des trésors (resourceBonus) ne sont **pas** modifiées et restent :
  - Algues : 50-100
  - Corail : 30-50
  - Minerai : 30-50

### US-4 : Cohérence avec le clamp au stockage maximum

**En tant que** joueur,
**je veux** que le détail affiché reflète ce qui a vraiment été ajouté à mon stock,
**afin de** ne pas être induit en erreur si mes stocks sont déjà au maximum.

**Critères d'acceptation :**
- Si une ressource est déjà au `maxStorage` et que la collecte tente d'en ajouter, le montant affiché dans la dialog doit être le **delta réellement appliqué** (potentiellement 0).
- Une ressource avec un delta de 0 n'est pas affichée dans la dialog.
- Si toutes les ressources ont un delta de 0, la dialog affiche le message "vide" (cas extrême du US-2).

## 3. Testing and Validation

### Tests unitaires (domain)

- `CollectTreasureAction` retourne désormais (via son `ActionResult` ou un champ équivalent) le **détail des ressources réellement ajoutées** (delta par type de ressource), pour permettre l'affichage par la couche présentation.
- Vérifier que la collecte d'une case `ruins` produit des montants dans les intervalles `[0, 100]` pour les algues, `[0, 25]` pour le corail et le minerai, `[0, 2]` pour les perles.
- Vérifier (via un `Random` injecté ou des bornes) que les montants minimums et maximums sont atteignables.
- Vérifier que la collecte d'un `resourceBonus` reste inchangée dans ses intervalles.
- Vérifier que le delta retourné est **clampé** quand le stock est déjà au `maxStorage`.

### Tests unitaires (présentation)

- Quand la collecte renvoie un détail non vide, la dialog modale s'ouvre avec une ligne par ressource non nulle (icône + `+montant`).
- Quand toutes les ressources sont à 0, la dialog affiche le message "ruines vides".
- Le bottom sheet d'interaction se ferme bien automatiquement avant l'ouverture de la dialog.
- Le bouton de fermeture de la dialog la ferme et ne déclenche aucune autre action.

### Tests d'intégration

- Scénario complet : générer une carte avec une case `ruins`, déclencher la collecte, vérifier que les ressources sont bien ajoutées au stock du joueur **et** que la dialog affiche les bons montants.
- Scénario stock plein : amener une ressource au maxStorage, collecter un trésor, vérifier que cette ressource n'apparaît pas dans la dialog.

### Critères de réussite

- `flutter analyze` passe sans erreur.
- `flutter test` passe à 100%.
- Chaque fichier reste sous 150 lignes.
- Aucun composant UI dupliqué : la dialog réutilise les composants/icônes du thème existant (`lib/presentation/theme/`) et les extensions d'icônes/labels de ressources déjà disponibles.
