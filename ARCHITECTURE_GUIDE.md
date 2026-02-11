# Guide d'Architecture Complet — ABYSSES

> Ce document est un guide ultra-détaillé destiné à quelqu'un qui n'a **jamais fait de Dart/Flutter**. Il explique chaque concept, chaque couche de l'architecture, et comment tout s'articule dans le projet ABYSSES.

---

## Table des matières

1. [Les bases de Dart (le langage)](#1-les-bases-de-dart)
2. [Flutter (le framework UI)](#2-flutter)
3. [Les Widgets : la brique de base](#3-les-widgets)
4. [La gestion d'état avec Riverpod (les Providers)](#4-riverpod-et-les-providers)
5. [Drift : la base de données locale](#5-drift-la-base-de-données)
6. [L'architecture en couches du projet](#6-architecture-en-couches)
7. [Couche Core — Fondations](#7-couche-core)
8. [Couche Domain — Les modèles de données](#8-couche-domain)
9. [Couche Engine — Le cerveau du jeu](#9-couche-engine)
10. [Couche Application — Les Providers (le pont)](#10-couche-application)
11. [Couche Presentation — L'interface utilisateur](#11-couche-presentation)
12. [Couche Infrastructure — Services système](#12-couche-infrastructure)
13. [Le Game Loop (boucle de jeu)](#13-le-game-loop)
14. [Le système d'IA](#14-le-systeme-dia)
15. [Le flux de données complet](#15-le-flux-de-données-complet)
16. [Glossaire](#16-glossaire)

---

## 1. Les bases de Dart

### Qu'est-ce que Dart ?

Dart est le langage de programmation créé par Google, utilisé par Flutter. Si tu connais JavaScript, Java ou C#, Dart te semblera familier. C'est un langage **typé** (chaque variable a un type), **orienté objet** (tout est un objet), et **compilé** (transformé en code machine natif sur mobile).

### Syntaxe de base

```dart
// ---------- Variables ----------
int age = 25;               // entier
double prix = 19.99;        // nombre à virgule
String nom = "Abysses";     // texte
bool estActif = true;       // booléen (vrai/faux)
List<int> scores = [10, 20, 30];  // liste d'entiers
Map<String, int> inventaire = {'bois': 5, 'fer': 3}; // dictionnaire clé→valeur

// Le type peut être inféré automatiquement :
var message = "Bonjour";    // Dart sait que c'est un String
final pi = 3.14159;         // 'final' = ne peut plus être modifié après assignation
const gravity = 9.81;       // 'const' = valeur fixée à la compilation (jamais modifiable)
```

### Différences clés `final` vs `const` vs `var`

| Mot-clé | Modifiable ? | Quand la valeur est fixée ? | Exemple |
|---------|-------------|---------------------------|---------|
| `var`   | Oui         | Jamais fixée              | `var x = 5; x = 10;` (OK) |
| `final` | Non         | Au moment de l'exécution  | `final now = DateTime.now();` (calculé au lancement) |
| `const` | Non         | A la compilation          | `const pi = 3.14;` (connu avant même de lancer l'app) |

### Fonctions

```dart
// Fonction classique
int additionner(int a, int b) {
  return a + b;
}

// Fonction fléchée (raccourci pour une seule expression)
int additionner(int a, int b) => a + b;

// Paramètres nommés (très courant en Flutter)
void creerColonie({required String nom, int population = 100}) {
  print('Colonie $nom créée avec $population habitants');
}

// Appel :
creerColonie(nom: "Alpha", population: 250);
creerColonie(nom: "Beta"); // population = 100 par défaut
```

**Les paramètres nommés** (`{required String nom}`) sont partout en Flutter. Ils rendent le code plus lisible car on voit le nom de chaque argument à l'appel.

### Classes et objets

```dart
class Colony {
  // Propriétés (= attributs en d'autres langages)
  final String name;
  int population;
  double credits;

  // Constructeur
  Colony({
    required this.name,      // 'this.name' assigne directement la propriété
    this.population = 100,   // valeur par défaut
    this.credits = 1000.0,
  });

  // Méthode
  void produceResources() {
    credits += 60.0;
  }
}

// Utilisation :
final maColonie = Colony(name: "Neptune", population: 500);
maColonie.produceResources(); // credits passe à 1060.0
```

### Enums (énumérations)

Un enum est une liste fermée de valeurs possibles. Exemple concret du projet :

```dart
// Fichier : lib/engine/ai/utility_engine.dart (ligne 5)
enum StrategicAction {
  attack,        // Attaquer
  defend,        // Défendre
  buildResource, // Construire un bâtiment de ressources
  buildMilitary, // Construire un bâtiment militaire
  trade,         // Commercer
  explore,       // Explorer
  spy,           // Espionner
  diplomacy,     // Diplomatie
  research,      // Rechercher
  retreat,       // Battre en retraite
}
```

L'intérêt : tu ne peux pas écrire `StrategicAction.attck` (faute de frappe) — le compilateur le refuse. C'est une sécurité.

### Null Safety

Dart est "null-safe" : par défaut, une variable **ne peut pas** être `null` (vide/absente).

```dart
String nom = "Alpha";     // OK — toujours une valeur
String nom = null;         // ERREUR de compilation !

String? nom = null;        // OK — le '?' dit "cette variable peut être null"
String? nom;               // Pareil, null par défaut

// Pour utiliser une variable nullable, tu dois vérifier :
if (nom != null) {
  print(nom.length);       // OK, Dart sait que ce n'est plus null ici
}

// Ou utiliser l'opérateur '??' (valeur par défaut si null)
print(nom ?? "Inconnu");   // Affiche "Inconnu" si nom est null
```

### Async/Await (code asynchrone)

Certaines opérations prennent du temps (lire un fichier, accéder à la BDD). Dart utilise `async`/`await` pour ne pas bloquer l'interface pendant l'attente.

```dart
// Future<T> = "une promesse de recevoir un T plus tard"
Future<String> chargerDonnees() async {
  // await = "attends que ça finisse avant de continuer"
  final resultat = await baseDeDonnees.lire('colonies');
  return resultat;
}
```

C'est exactement comme les `Promise` en JavaScript ou les `Task` en C#.

---

## 2. Flutter

### Qu'est-ce que Flutter ?

Flutter est un framework (kit d'outils) de Google qui permet de créer des **applications mobiles** (iOS + Android), web, et desktop à partir d'un **seul code source** en Dart. L'interface est dessinée pixel par pixel par le moteur de rendu de Flutter (pas par les composants natifs du téléphone).

### Comment fonctionne une app Flutter ?

Tout part de `main.dart` :

```dart
// Fichier : lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Initialise le moteur Flutter
  runApp(
    const ProviderScope(       // Active Riverpod (gestion d'état) — voir section 4
      child: AbyssesApp(),     // Lance l'application
    ),
  );
}
```

**Ligne par ligne :**
1. `import` — importe des bibliothèques (comme `#include` en C ou `import` en Python/JS)
2. `WidgetsFlutterBinding.ensureInitialized()` — nécessaire quand on utilise des plugins (BDD, fichiers) avant `runApp`
3. `ProviderScope` — enveloppe l'app pour que Riverpod fonctionne (expliqué section 4)
4. `AbyssesApp()` — le widget racine de l'application

---

## 3. Les Widgets : la brique de base

### Tout est un Widget

En Flutter, **absolument tout** est un Widget : un bouton, un texte, un espacement, une couleur de fond, une mise en page... L'interface est un **arbre de widgets** imbriqués :

```
MaterialApp                    ← L'application entière
  └── Scaffold                 ← Structure d'une page (barre de nav, corps, FAB)
        ├── AppBar             ← Barre du haut
        ├── Body               ← Contenu principal
        │     └── Column       ← Disposition verticale
        │           ├── Text   ← Du texte
        │           └── Button ← Un bouton
        └── BottomNavigationBar ← Barre de navigation du bas
```

### StatelessWidget vs StatefulWidget

C'est LA distinction fondamentale :

#### StatelessWidget — "Sans état" (immutable)

Un widget qui **ne change jamais** après sa création. Par exemple, un titre fixe :

```dart
// Fichier : lib/presentation/app.dart
class AbyssesApp extends StatelessWidget {
  const AbyssesApp({super.key}); // Constructeur

  @override
  Widget build(BuildContext context) {   // Construit l'interface
    return MaterialApp(
      title: 'ABYSSES',
      theme: ThemeData(brightness: Brightness.dark),
      home: const MainNavigation(),
    );
  }
}
```

La méthode `build()` est appelée une seule fois. Le widget produit toujours le même résultat.

#### StatefulWidget — "Avec état" (mutable)

Un widget qui **peut changer** au cours du temps (l'utilisateur clique, des données arrivent, un timer se déclenche...).

```dart
// Fichier : lib/presentation/navigation/main_navigation.dart
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;   // <-- L'ÉTAT : quel onglet est actif

  final List<Widget> _screens = const [
    BaseScreen(),           // Onglet 0 : Base
    MessagesScreen(),       // Onglet 1 : Messages
    FleetScreen(),          // Onglet 2 : Flotte
    MapScreen(),            // Onglet 3 : Carte
    ResearchScreen(),       // Onglet 4 : Recherche
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(         // Affiche l'écran correspondant à l'index
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        //      ^^^^^^^^    ^^^^^^^^
        //      callback     reconstruit le widget avec le nouvel index
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.domain), label: 'Base'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.sailing), label: 'Flotte'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Recherche'),
        ],
      ),
    );
  }
}
```

**Le cycle :**
1. L'utilisateur tape sur l'onglet "Carte" (index 3)
2. `onTap` est appelé avec `index = 3`
3. `setState()` met `_currentIndex = 3` ET dit à Flutter de reconstruire le widget
4. `build()` est rappelé, `IndexedStack` affiche maintenant `MapScreen()`

**`setState()` est le mécanisme de base** pour dire "quelque chose a changé, redessine-moi". Mais pour des états complexes (partagés entre plusieurs widgets), on utilise **Riverpod**.

### ConsumerWidget — Un widget qui "écoute" Riverpod

```dart
// Fichier : lib/presentation/widgets/resource_bar.dart
class ResourceBar extends ConsumerWidget {    // <-- ConsumerWidget, pas StatelessWidget
  const ResourceBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // <-- 'ref' donne accès aux providers
    // ref.watch(unProvider) — écoute les changements
    // ref.read(unProvider) — lit une seule fois
    return Container(/* ... */);
  }
}
```

`ConsumerWidget` est la version Riverpod de `StatelessWidget`. Le paramètre `ref` permet de lire les données depuis les Providers.

---

## 4. Riverpod et les Providers

### Le problème que Riverpod résout

Imagine cette situation :
- Le `GameLoop` (dans engine/) produit des ressources toutes les 5 secondes
- Le `ResourceBar` (dans presentation/) doit afficher ces ressources en temps réel
- Le `BaseScreen` doit aussi afficher les bâtiments de la colonie
- Le `FleetScreen` doit connaître les troupes disponibles

**Sans** gestion d'état, il faudrait passer les données de widget en widget, à travers tout l'arbre, manuellement. C'est ingérable.

### La solution : les Providers

Un **Provider** est un "conteneur de données" accessible depuis n'importe quel widget de l'application. C'est un intermédiaire entre la logique (engine) et l'interface (presentation).

```
┌─────────────────────────────────────────────────┐
│                    UI (Widgets)                  │
│  ResourceBar    BaseScreen    FleetScreen        │
│      │              │             │              │
│      └──────────────┼─────────────┘              │
│                     │ ref.watch(...)             │
│              ┌──────▼──────┐                     │
│              │  PROVIDERS   │   ← Couche Application │
│              │ (Riverpod)  │                     │
│              └──────┬──────┘                     │
│                     │ appelle                    │
│              ┌──────▼──────┐                     │
│              │   ENGINE    │   ← Logique de jeu  │
│              │ (AI, Combat │                     │
│              │  Simulation)│                     │
│              └──────┬──────┘                     │
│                     │ lit/écrit                   │
│              ┌──────▼──────┐                     │
│              │  DATABASE   │   ← Drift/SQLite    │
│              └─────────────┘                     │
└─────────────────────────────────────────────────┘
```

### Types de Providers

Voici les principaux types, du plus simple au plus avancé :

#### 1. `Provider` — Valeur en lecture seule

```dart
// Fournit une instance unique du moteur de base de données
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();  // Créé une seule fois, partagé partout
});
```

#### 2. `StateProvider` — Valeur simple modifiable

```dart
// L'onglet actuellement sélectionné
final currentTabProvider = StateProvider<int>((ref) => 0);

// Dans un widget :
final tab = ref.watch(currentTabProvider);         // Lire
ref.read(currentTabProvider.notifier).state = 2;   // Modifier
```

#### 3. `StateNotifierProvider` — État complexe avec logique

```dart
// Modèle de données
class PlayerResources {
  final int credits;
  final int biomass;
  final int minerals;
  final int energy;

  PlayerResources({
    this.credits = 5000,
    this.biomass = 3000,
    this.minerals = 2000,
    this.energy = 1500,
  });

  PlayerResources copyWith({int? credits, int? biomass, int? minerals, int? energy}) {
    return PlayerResources(
      credits: credits ?? this.credits,
      biomass: biomass ?? this.biomass,
      minerals: minerals ?? this.minerals,
      energy: energy ?? this.energy,
    );
  }
}

// Le "Notifier" contient la logique de modification
class PlayerResourcesNotifier extends StateNotifier<PlayerResources> {
  PlayerResourcesNotifier() : super(PlayerResources()); // état initial

  void addCredits(int amount) {
    state = state.copyWith(credits: state.credits + amount);
    // 'state = ...' déclenche automatiquement la reconstruction des widgets qui écoutent
  }

  void spendMinerals(int amount) {
    if (state.minerals >= amount) {
      state = state.copyWith(minerals: state.minerals - amount);
    }
  }
}

// Déclaration du provider
final playerResourcesProvider =
    StateNotifierProvider<PlayerResourcesNotifier, PlayerResources>((ref) {
  return PlayerResourcesNotifier();
});
```

#### 4. `FutureProvider` — Données asynchrones

```dart
// Charge les colonies depuis la BDD (opération asynchrone)
final coloniesProvider = FutureProvider<List<Colony>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.coloniesDao.getAllColonies();
});

// Dans un widget :
Widget build(BuildContext context, WidgetRef ref) {
  final coloniesAsync = ref.watch(coloniesProvider);

  return coloniesAsync.when(
    loading: () => CircularProgressIndicator(),   // Pendant le chargement
    error: (err, stack) => Text('Erreur: $err'),  // En cas d'erreur
    data: (colonies) => ListView(                 // Quand les données arrivent
      children: colonies.map((c) => ColonyCard(colony: c)).toList(),
    ),
  );
}
```

#### 5. `StreamProvider` — Flux continu de données

```dart
// Écoute les changements en temps réel dans la BDD
final playerResourcesStreamProvider = StreamProvider<PlayerResources>((ref) {
  final db = ref.watch(databaseProvider);
  return db.playerDao.watchResources(); // Émet une valeur à chaque changement
});
```

### Comment un widget utilise un Provider

```dart
class ResourceBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() — écoute les changements et reconstruit le widget automatiquement
    final resources = ref.watch(playerResourcesProvider);

    return Row(children: [
      Text('Crédits: ${resources.credits}'),
      Text('Biomasse: ${resources.biomass}'),
    ]);
  }
}
```

**Le flux :**
1. `ref.watch(playerResourcesProvider)` dit "je veux les ressources et préviens-moi quand elles changent"
2. Quand le GameLoop appelle `addCredits(60)`, le `state` change
3. Riverpod détecte le changement et reconstruit **uniquement** les widgets qui font `ref.watch` de ce provider
4. Le `ResourceBar` se redessine avec les nouvelles valeurs

### `ref.watch()` vs `ref.read()`

| Méthode | Quand l'utiliser | Reconstruit le widget ? |
|---------|-----------------|------------------------|
| `ref.watch(provider)` | Dans `build()` pour afficher des données | Oui, à chaque changement |
| `ref.read(provider)` | Dans les callbacks (onTap, onPressed) pour une action ponctuelle | Non |

```dart
// DANS build() → watch
Widget build(BuildContext context, WidgetRef ref) {
  final score = ref.watch(scoreProvider); // Se reconstruit quand le score change
  return Text('Score: $score');
}

// DANS un callback → read
onPressed: () {
  ref.read(scoreProvider.notifier).state += 1; // Modifie une seule fois, pas besoin d'écouter
}
```

---

## 5. Drift : la base de données

### Qu'est-ce que Drift ?

Drift est un **ORM** (Object-Relational Mapping) pour SQLite en Dart. Au lieu d'écrire du SQL brut, tu définis tes tables en Dart et Drift génère le code SQL automatiquement. C'est **type-safe** : si tu fais une erreur de nom de colonne, le compilateur te le dit.

### Comment les tables sont définies

```dart
// Fichier : lib/core/database/tables.dart

class ColoniesTable extends Table {        // Étend la classe Table de Drift
  @override
  String get tableName => 'colonies';      // Nom de la table en SQL

  // Chaque ligne = une colonne SQL
  IntColumn get id => integer().autoIncrement()();     // INTEGER PRIMARY KEY AUTOINCREMENT
  TextColumn get ownerType => text()();                // TEXT NOT NULL
  TextColumn get name => text()();                     // TEXT NOT NULL
  IntColumn get population =>
      integer().withDefault(const Constant(100))();    // INTEGER DEFAULT 100
  IntColumn get credits =>
      integer().withDefault(const Constant(1000))();   // INTEGER DEFAULT 1000
  BoolColumn get discoveredByPlayer =>
      boolean().withDefault(const Constant(false))();  // BOOLEAN DEFAULT FALSE

  // Clé unique composite (pas 2 colonies au même endroit)
  @override
  List<Set<Column>>? get uniqueKeys => [
    {positionX, positionY}
  ];
}
```

**Correspondance Dart → SQL :**

| Dart (Drift)          | SQL résultant                    |
|-----------------------|----------------------------------|
| `IntColumn`           | `INTEGER`                        |
| `TextColumn`          | `TEXT`                           |
| `RealColumn`          | `REAL` (nombre à virgule)        |
| `BoolColumn`          | `INTEGER` (0/1 en SQLite)        |
| `DateTimeColumn`      | `INTEGER` (timestamp)            |
| `.autoIncrement()`    | `PRIMARY KEY AUTOINCREMENT`      |
| `.withDefault(...)`   | `DEFAULT value`                  |
| `.nullable()`         | Permet `NULL`                    |
| `.references(T, #id)` | `FOREIGN KEY REFERENCES T(id)` |

### Les 10 tables du projet

Le projet définit **10 tables** dans `tables.dart` qui couvrent toutes les données du jeu :

| Table | Rôle | Enregistrements estimés |
|-------|------|------------------------|
| `player` | Profil du joueur, ressources, niveau, XP | 1 |
| `colonies` | Les 100 colonies (joueur + IA) — position, ressources, personnalité | ~100 |
| `buildings` | Bâtiments de chaque colonie — type, niveau, production | ~900 (10 × colonie) |
| `troops` | Unités militaires — type, nombre, statut, destination | ~600 |
| `world_map` | Terrain du monde — type, profondeur, ressources spéciales | ~20 000 |
| `combat_log` | Historique des combats — attaquant, défenseur, résultat | ~36 000/6 mois |
| `messages` | Messages entre colonies — template, variables, lu/non-lu | ~90 000/6 mois |
| `diplomacy` | Relations entre colonies — disposition, confiance, pactes | ~4 950 |
| `research` | Technologies recherchées — progression, prérequis | ~50 |
| `quests` | Quêtes — type, progression, récompenses | ~100 |

### Les DAOs (Data Access Objects)

Un DAO est une classe qui regroupe toutes les requêtes liées à une table :

```dart
// Exemple conceptuel d'un DAO pour les colonies
@DriftAccessor(tables: [ColoniesTable])
class ColonyDao extends DatabaseAccessor<AppDatabase> {
  ColonyDao(AppDatabase db) : super(db);

  // Récupérer toutes les colonies
  Future<List<Colony>> getAllColonies() => select(coloniesTable).get();

  // Récupérer les colonies IA uniquement
  Future<List<Colony>> getAIColonies() =>
      (select(coloniesTable)..where((c) => c.ownerType.equals('ai'))).get();

  // Observer les changements en temps réel (Stream)
  Stream<List<Colony>> watchAllColonies() => select(coloniesTable).watch();

  // Insérer une nouvelle colonie
  Future<int> insertColony(ColoniesTableCompanion colony) =>
      into(coloniesTable).insert(colony);
}
```

### La génération de code

Drift utilise la **génération de code** (`build_runner`). Tu écris les tables en Dart, puis tu lances :

```bash
dart run build_runner build
```

Cela génère des fichiers `.g.dart` (comme `database.g.dart`) qui contiennent :
- Les classes de données typées (ex: `Colony` avec des champs `.id`, `.name`, etc.)
- Les classes "Companion" pour les insertions/mises à jour
- Le code SQL réel

Tu ne modifies **jamais** les fichiers `.g.dart` — ils sont régénérés automatiquement.

---

## 6. Architecture en couches

Le projet suit une **architecture en couches** (layered architecture). Chaque couche a une responsabilité claire et ne communique qu'avec ses voisines directes.

```
┌──────────────────────────────────────────────────────────────┐
│                     PRESENTATION                              │
│   Widgets, Screens, Navigation                                │
│   (Ce que l'utilisateur voit et touche)                       │
├──────────────────────────────────────────────────────────────┤
│                     APPLICATION                               │
│   Riverpod Providers                                          │
│   (Le pont entre l'UI et la logique)                          │
├──────────────────────────────────────────────────────────────┤
│                       ENGINE                                  │
│   AI (Utility + Behavior Trees)                               │
│   Combat (résolution instantanée)                             │
│   Simulation (game loop + catch-up)                           │
│   (Toute la logique de jeu)                                   │
├──────────────────────────────────────────────────────────────┤
│                       DOMAIN                                  │
│   Models: Colony, Fleet, Personality, Building, Resource      │
│   (Les structures de données pures)                           │
├──────────────────────────────────────────────────────────────┤
│                        CORE                                   │
│   Database (Drift), Constants, Utilities                      │
│   (Les fondations techniques)                                 │
├──────────────────────────────────────────────────────────────┤
│                   INFRASTRUCTURE                              │
│   Save Manager, Settings, Notifications                       │
│   (Les services système)                                      │
└──────────────────────────────────────────────────────────────┘
```

### Règle d'or des dépendances

Les couches ne dépendent que vers le **bas** :
- Presentation → Application → Engine → Domain → Core
- **Jamais** Engine → Presentation (le moteur de jeu ne connaît pas l'interface)
- **Jamais** Core → Engine (les fondations ne connaissent pas la logique)

Cette règle garantit que tu peux modifier l'interface sans toucher au moteur de jeu, et vice versa.

---

## 7. Couche Core

**Dossier :** `lib/core/`

C'est la fondation du projet. Elle contient 3 sous-systèmes :

### 7.1 Database (`core/database/`)

Fichiers :
- `database.dart` — Déclare la base Drift, configure SQLite (WAL mode, foreign keys)
- `database.g.dart` — Code généré automatiquement
- `tables.dart` — Définition des 10 tables (décrit section 5)
- `daos/` — Les classes d'accès aux données

### 7.2 Constants (`core/constants/`)

Fichier principal : `game_constants.dart`

```dart
class GameConstants {
  GameConstants._();  // Constructeur privé — on ne crée jamais d'instance

  // Ressources max
  static const int maxCredits = 500000;
  static const int maxBiomass = 300000;

  // Taux de production (par heure)
  static const double biomassFarmBaseRate = 100.0;     // 100 biomasse/h
  static const double mineralMineBaseRate = 80.0;      // 80 minerais/h

  // Multiplicateur par niveau : production * (1 + (level-1) * 0.15)
  static const double levelMultiplier = 0.15;

  // Intervalles du game loop
  static const Duration activeTickInterval = Duration(seconds: 5);
  static const Duration semiActiveTickInterval = Duration(seconds: 30);
  static const Duration dormantTickInterval = Duration(minutes: 5);

  // Combat
  static const double triangleDamageBonus = 1.40;  // +40% contre type faible
  static const double triangleArmorMalus = 0.80;   // -20% contre type fort
  static const int maxCombatRounds = 15;

  // Diplomatie
  static const int allianceDisposition = 75;        // Disposition min pour alliance
  // ...
}
```

`GameConstants._()` : le `._()` crée un constructeur **privé**. On ne peut pas écrire `GameConstants()` — c'est intentionnel car cette classe ne contient que des `static const`, pas besoin d'en créer une instance.

Autres fichiers de constantes :
- `unit_stats.dart` — Statistiques des 9 types d'unités (PV, ATK, DEF, vitesse, coût)
- `tech_tree.dart` — Les 15 technologies (5 branches × 3 niveaux)
- `personality_archetypes.dart` — Les 8 archétypes de personnalité IA

### 7.3 Utils (`core/utils/`)

- `id_generator.dart` — Génère des UUID (identifiants uniques universels) pour chaque entité

---

## 8. Couche Domain

**Dossier :** `lib/domain/models/`

Cette couche contient les **modèles de données purs** — des classes simples qui représentent les concepts du jeu sans aucune logique métier.

### Exemple : Personality

```dart
// Fichier : lib/domain/models/personality.dart

enum Archetype {
  warrior, diplomat, economist, explorer,
  manipulator, balanced, conqueror, defender,
}

class Personality {
  double aggressivity;   // 0.0 à 1.0
  double diplomacy;      // 0.0 à 1.0
  double expansion;      // 0.0 à 1.0
  double economy;        // 0.0 à 1.0
  double cunning;        // 0.0 à 1.0

  Personality({
    required this.aggressivity,
    required this.diplomacy,
    required this.expansion,
    required this.economy,
    required this.cunning,
  });

  // copyWith : crée une copie avec certaines valeurs modifiées
  Personality copyWith({double? aggressivity, ...}) =>
      Personality(
        aggressivity: aggressivity ?? this.aggressivity,
        // ...
      );

  // Clampe toutes les valeurs entre 0 et 1
  void clamp() {
    aggressivity = aggressivity.clamp(0.0, 1.0);
    diplomacy = diplomacy.clamp(0.0, 1.0);
    // ...
  }
}
```

**Le pattern `copyWith`** est omniprésent en Flutter/Dart. Plutôt que de modifier un objet directement, on crée une **copie** avec les changements désirés. Cela facilite la détection des changements par Riverpod.

---

## 9. Couche Engine

**Dossier :** `lib/engine/`

C'est le **cerveau du jeu**. Trois sous-systèmes :

### 9.1 AI (`engine/ai/`)

Le systeme d'IA est décrit en détail dans la [section 14](#14-le-systeme-dia).

Fichiers :
- `utility_engine.dart` — Moteur de scoring Utility AI
- `behavior_tree.dart` — Arbres de comportement
- `personality.dart` — Évolution de la personnalité
- `memory.dart` — Mémoire des colonies IA (~31 KB/colonie)
- `message_generator.dart` — Génération de messages par templates

### 9.2 Combat (`engine/combat/`)

- `combat_resolver.dart` — Algorithme de résolution des batailles
- `unit_catalog.dart` — Catalogue des unités et modificateurs du triangle
- `defense_system.dart` — Défenses statiques (mines, tourelles)

Le combat utilise un système **pierre-feuille-ciseaux** :

```
    Torpilleurs
      ↗     ↘
 +40%         -20%
    ↑           ↓
Léviathans ← Essaims
      -20%    +40%
```

### 9.3 Simulation (`engine/simulation/`)

- `game_loop.dart` — La boucle de jeu (ticks à intervalles réguliers)
- `catch_up_engine.dart` — Simule le temps passé hors-ligne
- `activity_tiers.dart` — Gère les niveaux d'activité (actif/semi-actif/dormant)

---

## 10. Couche Application

**Dossier :** `lib/application/`

C'est la couche **pont** entre Engine et Presentation. Elle contient les **Providers Riverpod** qui exposent les données de la logique de jeu aux widgets.

Cette couche est actuellement vide et sera remplie au fur et à mesure. Voici à quoi elle ressemblera :

```dart
// Exemple conceptuel : application/providers/game_providers.dart

// Provider pour la base de données
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Provider pour le game loop
final gameLoopProvider = Provider<GameLoop>((ref) {
  final db = ref.watch(databaseProvider);
  return GameLoop(
    onActiveTick: () { /* mettre à jour colonies actives */ },
    onSemiActiveTick: () { /* mettre à jour colonies semi-actives */ },
    onDormantTick: () { /* mettre à jour colonies dormantes */ },
    onDbSync: () { /* sauvegarder en BDD */ },
  );
});

// Provider pour les ressources du joueur (réactif)
final playerResourcesProvider =
    StateNotifierProvider<PlayerResourcesNotifier, PlayerResources>((ref) {
  return PlayerResourcesNotifier(ref.watch(databaseProvider));
});

// Provider pour la liste des colonies
final coloniesProvider = StreamProvider<List<Colony>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.coloniesDao.watchAllColonies();
});

// Provider pour l'IA
final aiEngineProvider = Provider<UtilityScoringEngine>((ref) {
  return UtilityScoringEngine();
});
```

### Pourquoi cette couche est séparée ?

- L'Engine ne sait **rien** de Flutter ni de Riverpod (il pourrait tourner dans un test unitaire)
- La Presentation ne sait **rien** de la BDD ni du game loop
- Les Providers font la **traduction** entre les deux mondes

---

## 11. Couche Presentation

**Dossier :** `lib/presentation/`

C'est tout ce que l'utilisateur **voit et touche**.

### Structure

```
presentation/
├── app.dart                 ← Configuration de l'app (thème, MaterialApp)
├── navigation/
│   └── main_navigation.dart ← Barre de navigation (5 onglets)
├── screens/                 ← Les 5 écrans principaux
│   ├── base_screen.dart     ← Gestion de la colonie (bâtiments)
│   ├── messages_screen.dart ← Boîte de réception (messages IA)
│   ├── fleet_screen.dart    ← Composition et envoi de flottes
│   ├── map_screen.dart      ← Carte du monde + liste des colonies
│   └── research_screen.dart ← Arbre technologique
└── widgets/                 ← Composants réutilisables
    ├── resource_bar.dart    ← Barre de ressources (haut de l'écran)
    ├── colony_card.dart     ← Carte d'information d'une colonie
    └── combat_report_widget.dart ← Rapport de combat
```

### Le thème (app.dart)

```dart
theme: ThemeData(
  brightness: Brightness.dark,                        // Mode sombre
  scaffoldBackgroundColor: const Color(0xFF0A1628),   // Bleu océan profond
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D1F3C),               // Bleu un peu plus clair
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF132240),                          // Bleu pour les cartes
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF1E88E5),    // Bleu principal
    secondary: Color(0xFF26C6DA),  // Cyan secondaire
  ),
),
```

Toutes les couleurs suivent une palette **bleu océan profond** cohérente avec le thème sous-marin.

### Le ResourceBar (widget réutilisable)

```dart
class ResourceBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFF0D1F3C),
      child: Row(                          // Disposition horizontale
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResource(Icons.monetization_on, 'Crédits', 5000, 60, Color(0xFFFFD54F)),
          _buildResource(Icons.grass, 'Bio', 3000, 100, Color(0xFF81C784)),
          _buildResource(Icons.diamond, 'Min', 2000, 80, Color(0xFF90CAF9)),
          _buildResource(Icons.bolt, 'Énergie', 1500, 120, Color(0xFFFFAB40)),
        ],
      ),
    );
  }
}
```

`Row` = disposition horizontale, `Column` = disposition verticale. Ce sont les deux widgets de layout les plus utilisés en Flutter.

---

## 12. Couche Infrastructure

**Dossier :** `lib/infrastructure/`

Services bas niveau qui interagissent avec le système d'exploitation :

- `save_manager.dart` — Sauvegarde/chargement/export des parties
- `settings.dart` — Paramètres du jeu (vitesse, notifications, langue)
- *(Prévu)* Notifications locales via `flutter_local_notifications`

---

## 13. Le Game Loop

Le **game loop** (boucle de jeu) est le coeur battant du jeu. Il fait avancer le temps et met à jour toutes les colonies à intervalles réguliers.

```dart
// Fichier : lib/engine/simulation/game_loop.dart

class GameLoop {
  Timer? _gameTimer;
  bool _isRunning = false;

  // 4 callbacks — chacun sera connecté à un système différent
  final void Function() onActiveTick;       // Toutes les 5 secondes
  final void Function() onSemiActiveTick;   // Toutes les 30 secondes
  final void Function() onDormantTick;      // Toutes les 5 minutes
  final void Function() onDbSync;           // Sauvegarde BDD toutes les 30s

  void start() {
    _gameTimer = Timer.periodic(
      GameConstants.activeTickInterval,  // 5 secondes
      (_) => _tick(),
    );
  }

  void _tick() {
    onActiveTick();   // TOUJOURS exécuté (colonies proches)

    // Vérifie si assez de temps s'est écoulé pour les tiers inférieurs
    if (tempsDepuisDernierSemiTick >= 30s) onSemiActiveTick();
    if (tempsDepuisDernierDormantTick >= 5min) onDormantTick();
    if (tempsDepuisDernierSync >= 30s) onDbSync();
  }
}
```

### Les 3 tiers d'activité

Pour faire tourner 100 colonies sans surcharger le téléphone, le jeu utilise un système de **tiers** basé sur la distance :

```
┌─────────────────────────────────────────────────┐
│                                                   │
│          DORMANT (>500 unités)                    │
│          ~50 colonies                             │
│          Tick toutes les 5 minutes                │
│          Simulation simplifiée                    │
│                                                   │
│     ┌───────────────────────────────────┐        │
│     │     SEMI-ACTIF (200-500 unités)   │        │
│     │     ~30 colonies                  │        │
│     │     Tick toutes les 30 secondes   │        │
│     │     IA partielle                  │        │
│     │                                   │        │
│     │   ┌───────────────────────┐      │        │
│     │   │   ACTIF (<200 unités) │      │        │
│     │   │   ~20 colonies        │      │        │
│     │   │   Tick toutes les 5s  │      │        │
│     │   │   IA complète         │      │        │
│     │   │       [JOUEUR]        │      │        │
│     │   └───────────────────────┘      │        │
│     └───────────────────────────────────┘        │
│                                                   │
└─────────────────────────────────────────────────┘
```

**Résultat :** ~22 ms de CPU par cycle, soit ~1.8% du processeur. Le jeu reste fluide.

### Le Catch-Up Engine

Quand le joueur revient après une absence (ex : 8 heures de sommeil), le **catch-up engine** simule tout le temps écoulé :

1. Calcule le temps écoulé depuis la dernière session
2. Simule la production de ressources (formules simplifiées)
3. Résout les constructions terminées
4. Exécute les décisions IA accumulées
5. Génère les événements (combats, diplomatie, messages)
6. Affiche un résumé au joueur

---

## 14. Le système d'IA

Le système d'IA est composé de **deux couches** qui travaillent ensemble :

### Couche 1 : Utility AI (décision stratégique)

"Que faire ?" — Évalue toutes les actions possibles et choisit la meilleure.

```dart
// Fichier : lib/engine/ai/utility_engine.dart

double calculateUtility({
  required StrategicAction action,
  required Personality personality,
  Map<String, dynamic> context = const {},
}) {
  final baseScore = _baseScores[action];          // Score de base (ex: attack = 0.6)
  final contextMultiplier = ...;                   // Multiplieur selon la situation
  final personalityMultiplier = ...;               // Multiplieur selon la personnalité
  final randomVariation = 1.0 ± 10%;              // Variation aléatoire

  return baseScore * contextMultiplier * personalityMultiplier * randomVariation;
}
```

**Exemple concret :**

Une colonie de type **Kraken** (guerrier, aggressivité=0.95) détecte un voisin faible (powerRatio=2.0) :

| Action | Base | Contexte | Personnalité | Aléa | Score final |
|--------|------|----------|-------------|------|-------------|
| ATTACK | 0.6 | ×1.8 (ratio>1.8) | ×1.43 (agg 0.95) | ×1.05 | **1.0** (clampé) |
| DEFEND | 0.75 | ×1.0 | ×0.77 | ×0.95 | 0.55 |
| TRADE | 0.5 | ×1.0 | ×0.54 (dip faible) | ×1.02 | 0.28 |

→ Le Kraken choisit **ATTACK** (score le plus élevé).

Une **Medusa** (diplomate, diplomacy=0.95) dans la même situation :

| Action | Base | Contexte | Personnalité | Aléa | Score final |
|--------|------|----------|-------------|------|-------------|
| ATTACK | 0.6 | ×1.8 | ×0.72 (dip haute réduit) | ×0.97 | 0.75 |
| TRADE | 0.5 | ×1.0 | ×1.26 (dip 0.95) | ×1.03 | 0.65 |
| DIPLOMACY | 0.55 | ×1.0 | ×1.45 | ×0.98 | 0.78 |

→ La Medusa choisit **DIPLOMACY**.

### Couche 2 : Behavior Trees (exécution tactique)

"Comment faire ?" — Une fois l'action choisie, l'arbre de comportement exécute les étapes.

```
Arbre pour ATTACK :
├── Séquence (toutes les étapes doivent réussir)
│   ├── Condition : ai-je assez de troupes ?
│   │   ├── OUI → continuer
│   │   └── NON → ÉCHEC (passer à BuildMilitary)
│   ├── Action : choisir la cible la plus faible à portée
│   ├── Action : composer la flotte optimale
│   └── Action : lancer l'attaque
```

Les noeuds d'un Behavior Tree :
- **Séquence** : exécute les enfants dans l'ordre, s'arrête au premier échec
- **Sélecteur** : essaie les enfants dans l'ordre, s'arrête au premier succès
- **Condition** : teste un état (renvoie SUCCESS ou FAIL)
- **Action** : effectue une opération concrète

### Personnalité et évolution

Chaque colonie IA a 5 traits entre 0.0 et 1.0 :

```
Aggressivité ████████░░ 0.80    (tendance à attaquer)
Diplomatie   ██░░░░░░░░ 0.20    (tendance à négocier)
Expansion    ██████░░░░ 0.60    (tendance à s'étendre)
Économie     ████░░░░░░ 0.40    (tendance à accumuler)
Ruse         █████░░░░░ 0.50    (tendance à espionner/manipuler)
```

Ces traits **évoluent** au fil du jeu :

```dart
// Fichier : lib/engine/ai/personality.dart

void updateFromEvent(Personality personality, StrategicEventType eventType) {
  switch (eventType) {
    case StrategicEventType.betrayed:       // Trahi par un allié !
      personality.diplomacy -= 0.05;        // Perd confiance en la diplomatie
      personality.aggressivity += 0.05;     // Devient plus agressive
      personality.cunning += 0.03;          // Devient plus méfiante
      break;
    case StrategicEventType.tradeSuccess:   // Échange commercial réussi
      personality.diplomacy += 0.03;        // Renforce la diplomatie
      personality.aggressivity -= 0.02;     // Moins besoin d'attaquer
      break;
    // ...
  }
  personality.clamp();  // Garde toutes les valeurs entre 0 et 1
}
```

Cela signifie qu'une colonie initialement pacifique peut devenir agressive si elle est attaquée régulièrement. Le jeu crée des **histoires émergentes**.

### Les 8 archétypes

| Archétype | Nom | Style | Traits dominants |
|-----------|-----|-------|-----------------|
| Kraken | Guerrier | Attaques précoces, raids | Agg: 0.95, Dip: 0.10 |
| Medusa | Diplomate | Réseaux d'alliances, commerce | Dip: 0.95, Agg: 0.20 |
| Leviathan | Économe | Accumulation massive | Eco: 0.95, Agg: 0.30 |
| Nautilus | Explorateur | Déploiement rapide | Exp: 0.90, Agg: 0.40 |
| Sirene | Manipulateur | Espionnage, fausses alliances | Cun: 0.95, Agg: 0.50 |
| Triton | Équilibré | Adaptatif, pas de spécialité | Tous à 0.50 |
| Titan | Conquérant | Expansion massive et rapide | Exp: 0.95, Agg: 0.75 |
| Golem | Défenseur | Fortifications massives | Eco: 0.80, Agg: 0.10 |

### La mémoire IA

Chaque colonie IA maintient une **mémoire** (~31 KB) :
- **Colonies connues** : qui elle a rencontré, à quelle distance
- **Relations** : disposition (-1.0 à +1.0), confiance, historique commercial
- **Événements récents** : les 50 derniers événements (300 octets chacun)
- **Objectifs** : objectif stratégique courant, cible
- **Cooldowns** : temps d'attente avant de pouvoir refaire certaines actions

---

## 15. Le flux de données complet

Voici comment une action typique traverse toutes les couches. Exemple : **le joueur construit une Ferme de Biomasse**.

```
1. L'UTILISATEUR tape "Construire" sur le BaseScreen
         │
         ▼
2. PRESENTATION : Le widget appelle ref.read(buildingProvider.notifier).build('biomass_farm')
         │
         ▼
3. APPLICATION (Provider) : Le BuildingNotifier vérifie les ressources,
   calcule le temps de construction, crée l'entrée en BDD
         │
         ▼
4. ENGINE : Le GameLoop, au prochain tick, voit un bâtiment en construction.
   Quand le timer expire, il passe l'état à "terminé" et ajoute
   la production de biomasse (+100/h)
         │
         ▼
5. CORE (Database) : Drift écrit le nouveau bâtiment dans la table 'buildings'
   et met à jour les ressources dans 'player'
         │
         ▼
6. APPLICATION (Provider) : Le Stream détecte le changement en BDD
         │
         ▼
7. PRESENTATION : Le ResourceBar se reconstruit avec le nouveau taux
   de production (+100/h en biomasse). Le BaseScreen affiche le
   nouveau bâtiment dans la liste.
```

### Flux pour une décision IA

```
1. GAME LOOP : Tick actif (toutes les 5s)
         │
         ▼
2. ACTIVITY TIERS : La colonie "Kraken-07" est dans le tier Actif
         │
         ▼
3. UTILITY ENGINE : Calcule les scores pour les 10 actions possibles
   → ATTACK score le plus haut (0.92)
         │
         ▼
4. BEHAVIOR TREE : Exécute l'arbre "ATTACK"
   → Vérifie les troupes ✓ → Choisit la cible → Compose la flotte
         │
         ▼
5. COMBAT RESOLVER : Résout le combat instantanément
   → Kraken-07 gagne, pille 20% des ressources
         │
         ▼
6. DATABASE : Enregistre le combat_log, met à jour les troupes,
   les ressources des deux camps
         │
         ▼
7. MESSAGE GENERATOR : Crée un message de victoire/menace basé
   sur la personnalité Kraken (template agressif)
         │
         ▼
8. PERSONALITY EVOLUTION : La victoire renforce l'agressivité (+0.04)
   et l'expansion (+0.05)
         │
         ▼
9. APPLICATION : Les Providers détectent les changements
         │
         ▼
10. PRESENTATION : Le joueur reçoit un message dans l'onglet Messages,
    voit ses ressources diminuées dans le ResourceBar
```

---

## 16. Glossaire

| Terme | Définition |
|-------|-----------|
| **Widget** | Brique de base de l'interface Flutter. Tout est un widget : texte, bouton, espacement, layout... |
| **StatelessWidget** | Widget qui ne change jamais (immutable). Reconstruit toujours la même interface. |
| **StatefulWidget** | Widget qui peut changer au fil du temps. Utilise `setState()` pour se reconstruire. |
| **ConsumerWidget** | Version Riverpod d'un StatelessWidget, avec accès aux Providers via `ref`. |
| **Provider** | Conteneur de données/logique Riverpod, accessible depuis n'importe quel widget. |
| **ref.watch()** | "Écoute" un Provider. Le widget se reconstruit quand la valeur change. |
| **ref.read()** | "Lit" un Provider une seule fois, sans s'abonner aux changements. |
| **StateNotifier** | Classe qui encapsule un état et sa logique de modification. |
| **ProviderScope** | Widget racine qui active Riverpod dans toute l'application. |
| **build()** | Méthode qui retourne l'arbre de widgets à afficher. Appelée à chaque reconstruction. |
| **setState()** | Déclenche la reconstruction d'un StatefulWidget. |
| **Drift** | ORM (Object-Relational Mapping) pour SQLite en Dart. Génère du SQL type-safe. |
| **DAO** | Data Access Object — classe qui regroupe les requêtes BDD pour une table. |
| **build_runner** | Outil de génération de code Dart. Génère les fichiers `.g.dart` pour Drift. |
| **Isolate** | Thread séparé en Dart. Permet d'exécuter du code sans bloquer l'interface. |
| **Stream** | Flux de données continu (comme un robinet). Émet des valeurs au fil du temps. |
| **Future** | Promesse de recevoir une valeur plus tard (opération asynchrone). |
| **async/await** | Syntaxe pour écrire du code asynchrone de manière lisible. |
| **enum** | Type avec un nombre fini de valeurs possibles (ex: `StrategicAction.attack`). |
| **copyWith** | Pattern qui crée une copie d'un objet avec certains champs modifiés. |
| **Tick** | Un "battement" du game loop. Chaque tick met à jour une partie du monde. |
| **Utility AI** | Système qui évalue et score toutes les actions possibles pour choisir la meilleure. |
| **Behavior Tree** | Arbre de décision qui exécute une stratégie étape par étape. |
| **Catch-up Engine** | Système qui simule le temps écoulé quand le joueur était absent. |
| **Triangle (combat)** | Pierre-feuille-ciseaux entre Torpilleurs, Essaims et Léviathans. |
| **Disposition** | Score de -100 à +100 représentant la relation entre deux colonies. |
| **Archétype** | Profil de personnalité prédéfini (Kraken, Medusa, etc.) avec des traits de base. |
| **pubspec.yaml** | Fichier de configuration du projet Dart/Flutter (nom, version, dépendances). |
| **WAL mode** | Write-Ahead Logging — mode SQLite qui améliore les performances d'écriture. |
