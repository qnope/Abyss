# Action System - Feature Specification

## 1. Feature Overview

Le systeme d'action introduit un pattern unifie pour representer et executer toute action de gameplay dans ABYSSES. Chaque action utilisateur (construire, recruter, deplacer, attaquer...) est encapsulee dans un objet Action, valide par les calculateurs existants, et execute via un ActionExecutor central.

L'objectif principal est de creer une abstraction commune que le joueur et les factions IA utiliseront de maniere identique. Cela simplifie considerablement la gestion de l'IA : une faction IA genere des objets Action identiques a ceux du joueur, valides et executes par le meme pipeline.

**Perimetre v1** : seule l'action de construction/amelioration de batiment est implementee. Le systeme est concu pour etre extensible aux futures actions (recrutement, recherche, deplacement, etc.).

## 2. API Design

### 2.1 Action (classe abstraite)

Represente une intention d'action sur le jeu. Une Action peut etre creee sans etre executee immediatement.

```dart
abstract class Action {
  /// Type identifiant l'action (ex: ActionType.upgradeBuilding)
  ActionType get type;

  /// Description lisible de l'action pour l'UI et le logging
  String get description;

  /// Valide l'action contre l'etat courant du jeu.
  /// Retourne un ActionResult en succes si l'action est valide,
  /// ou en echec avec la raison sinon.
  ActionResult validate(Game game);

  /// Execute l'action sur le jeu : valide puis applique les effets.
  /// Retourne un ActionResult en succes ou en echec.
  ActionResult execute(Game game);
}
```

### 2.2 ActionType (enum)

Enumere les types d'actions disponibles.

```dart
enum ActionType {
  upgradeBuilding,
  // futures actions : recruitUnit, research, moveUnit, attack, ...
}
```

### 2.3 UpgradeBuildingAction

Premiere implementation concrete. Represente l'action d'ameliorer un batiment.

```dart
class UpgradeBuildingAction extends Action {
  final BuildingType buildingType;

  ActionType get type => ActionType.upgradeBuilding;

  String get description => 'Ameliorer $buildingType';

  ActionResult validate(Game game) {
    // Delegue au BuildingCostCalculator.checkUpgrade
  }

  ActionResult execute(Game game) {
    // 1. Valide via validate(game)
    // 2. Si echec, retourne le resultat
    // 3. Si succes, applique les effets (deduction ressources, incrementation niveau)
    // 4. Retourne ActionResult en succes
  }
}
```

### 2.4 ActionResult

Resultat de l'execution d'une action.

```dart
class ActionResult {
  final bool isSuccess;
  final String? reason; // message explicatif en cas d'echec
}
```

### 2.5 ActionExecutor

Point d'entree unique pour valider et executer les actions. Utilise les calculateurs existants (BuildingCostCalculator) pour la validation.

```dart
class ActionExecutor {
  ActionResult execute(Action action, Game game);
}
```

Comportement de `execute` :
1. Delegue a `action.validate(game)` pour la validation
2. Si la validation echoue, retourne le `ActionResult` en echec
3. Si la validation reussit, delegue a `action.execute(game)` pour appliquer les effets
4. Retourne le `ActionResult`

> Note : la logique de validation et d'execution est portee par chaque Action concrete. L'ActionExecutor sert de point d'entree unifie et peut ajouter des comportements transversaux (logging, historique, etc.).

### 2.6 Usage depuis la presentation

```dart
// Widget cree l'action
final action = UpgradeBuildingAction(buildingType: BuildingType.headquarters);

// Widget execute via l'executor
final result = actionExecutor.execute(action, game);

if (result.isSuccess) {
  // fermer le sheet, rafraichir l'UI
} else {
  // afficher result.reason a l'utilisateur
}
```

### 2.7 Usage par l'IA (futur)

```dart
// L'IA genere ses actions
final aiActions = aiBrain.decideActions(factionGame);

// Executees par le meme executor
for (final action in aiActions) {
  actionExecutor.execute(action, factionGame);
}
```

## 3. Testing and Validation

### Tests unitaires

- **ActionExecutor** :
  - Executer une UpgradeBuildingAction valide : ressources deduites, niveau incremente, retourne succes
  - Executer une UpgradeBuildingAction sans ressources suffisantes : retourne echec avec raison, game inchange
  - Executer une UpgradeBuildingAction a niveau max : retourne echec avec raison, game inchange
  - Executer une UpgradeBuildingAction avec prerequis manquants : retourne echec avec raison

- **UpgradeBuildingAction** :
  - Le type retourne `ActionType.upgradeBuilding`
  - Le buildingType est correctement stocke
  - `description` retourne une chaine lisible contenant le type de batiment
  - `validate` retourne succes quand les ressources et prerequis sont suffisants
  - `validate` retourne echec avec raison quand les ressources sont insuffisantes
  - `validate` retourne echec avec raison quand le batiment est au niveau max
  - `execute` deduit les ressources et incremente le niveau quand l'action est valide
  - `execute` retourne echec sans modifier le game quand la validation echoue

- **ActionResult** :
  - `isSuccess` et `reason` correctement initialises

### Tests d'integration

- Flux complet : creer une action → executer → verifier l'etat du game apres execution
- Verifier que le meme ActionExecutor fonctionne pour un "joueur" et une "IA" (meme Action, meme Game, meme resultat)

### Criteres de reussite

- Le code existant de construction (dans GameScreen) est remplace par le passage via ActionExecutor
- Aucune regression sur les tests existants
- `flutter analyze` et `flutter test` passent sans erreur
- Chaque fichier reste sous 150 lignes
