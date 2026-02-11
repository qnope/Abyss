# ABYSSES — Les Profondeurs Océaniques
## Game Design Document (GDD) — Version 4.0
### Architecture 100% Locale — MVP Offline-First

---

> **Changement fondamental v4.0** : ABYSSES passe d'une architecture serveur + Claude API (v3.0) à une application **100% locale, offline, sans serveur**. L'IA est exécutée directement sur l'appareil via Utility AI + Behavior Trees. Le stockage est assuré par SQLite via Drift. Le coût serveur tombe à **0€**.

---

# SECTION 1 — VISION & PHILOSOPHIE

## 1.1 Pitch

L'humanité a épuisé les ressources terrestres. Les nations se tournent vers les fonds marins. Dans ABYSSES, le joueur dirige une cité sous-marine pressurisée, exploitant les richesses abyssales tout en affrontant la pression, les créatures des profondeurs et **50 à 100 colonies rivales dirigées par des intelligences artificielles locales**.

Chaque colonie IA possède une personnalité unique définie par 5 axes, une mémoire persistante et des comportements émergents — le tout calculé localement sur l'appareil du joueur, sans connexion internet.

## 1.2 Genre et plateforme

- **Genre** : Stratégie / Gestion solo avec monde persistant simulé localement
- **Plateforme** : Mobile uniquement (iOS 16+, Android 12+)
- **Modèle économique** : À définir
- **Public cible** : Joueurs de 16+ ans, fans de Travian, OGame, Clash of Clans
- **Session type** : Sessions courtes (3-10 min). Le monde évolue entre les sessions via catch-up.
- **Connexion requise** : Aucune (100% offline)

## 1.3 Piliers de design

1. **100% Offline** — Aucune dépendance serveur, aucune latence, aucun coût API. Le jeu fonctionne en avion, en métro, partout.
2. **IA locale crédible** — Utility AI + Behavior Trees créent des adversaires avec personnalités distinctes et mémorables, sans LLM.
3. **Stratégie asynchrone** — Le joueur donne des ordres, les résultats arrivent dans le temps. Combats auto-résolus à l'impact.
4. **Mobile-first** — Interface pensée pour le pouce, sessions de 5 minutes, gestion par listes et presets.
5. **Coût de développement minimal** — MVP réalisable par 2 développeurs en 3-4 mois pour ~5K€.

## 1.4 Pourquoi l'approche 100% locale ?

### Avantages vs architecture serveur (v3.0)

| Critère | v3.0 (Serveur + Claude) | v4.0 (100% Local) |
|---------|------------------------|-------------------|
| **Coût serveur** | 8-11€/joueur/mois | **0€** |
| **Coût API IA** | 5-6€/joueur/mois | **0€** |
| **Latence** | 500-2000ms par décision IA | **<50ms** |
| **Offline** | Impossible | **100%** |
| **Batterie** | Drain HTTP constant | **Minimal** |
| **Privacy** | Données sur serveur | **Tout local** |
| **Scalabilité** | Coûts linéaires par joueur | **Coût fixe (0€)** |
| **MVP Budget** | ~450K€ (10 personnes, 10 mois) | **~5K€ (2 personnes, 4 mois)** |
| **Qualité IA** | Texte riche mais coûteux | **90% de la qualité pour 0€** |

### Ce qu'on perd (et comment compenser)

| Perte | Compensation |
|-------|-------------|
| Messages IA générés par LLM | Templates [Situation × Personnalité × Variante] (~60-150 messages) |
| Mémoire narrative riche | Mémoire structurée locale (50 événements/colonie, relations, dispositions) |
| Arcs narratifs dynamiques | Événements scriptés + personnalités évolutives |
| Couche sociale serveur | Progression locale + Prestige system |
| 1000 colonies | 50-100 colonies (largement suffisant pour MVP) |

## 1.5 Concept central : Un monde d'IA locales vivantes

Le joueur coexiste avec 50-100 colonies IA, chacune dotée de :

- **5 axes de personnalité** (Agressivité, Diplomatie, Expansion, Économie, Ruse)
- **8 archétypes** (Guerrier, Diplomate, Économe, Explorateur, Manipulateur, Équilibré, Conquérant, Défenseur)
- **Mémoire locale** (~31 KB/colonie) : relations, événements récents, objectifs
- **Évolution dynamique** : personnalités qui changent selon les événements vécus
- **Communication par templates** : messages contextuels selon situation et personnalité

### Tiers d'activité (gestion CPU)

| Tier | Colonies | Fréquence tick | Simulation |
|------|----------|---------------|------------|
| **Active** | ~20 (proches du joueur) | 1×/5s | Complète (Utility AI + BT) |
| **Semi-Active** | ~30 (distance moyenne) | 1×/30s | Réduite (construction, diplo) |
| **Dormant** | ~50 (lointaines) | 1×/5min | Catch-up (production linéaire) |

**Overhead CPU moyen** : ~22ms/cycle = ~1.8% CPU.

---

# SECTION 2 — ARCHITECTURE TECHNIQUE

## 2.1 Stack technologique

| Composant | Technologie | Rôle |
|-----------|------------|------|
| **Framework** | Flutter 3.x + Dart | Cross-platform iOS/Android |
| **Moteur 2D** | Flame Engine | Carte, colonies, animations |
| **State Management** | Riverpod | Réactivité UI, providers |
| **Base de données** | Drift (ex-Moor) + SQLite | Persistance locale type-safe |
| **IA** | Utility AI + Behavior Trees | Décisions stratégiques locales |
| **Threading** | Dart Isolates | Calcul IA hors main thread |
| **Notifications** | flutter_local_notifications | Rappels et alertes locales |

## 2.2 Architecture logicielle

```
lib/
├── core/
│   ├── database/           ← Drift (SQLite) — tables, DAOs, migrations
│   ├── constants/          ← Constantes de jeu, balancing
│   └── utils/              ← Helpers, extensions
├── domain/
│   └── models/             ← Colony, Fleet, Building, Resource, Personality
├── engine/
│   ├── ai/                 ← Utility AI scoring + Behavior Trees
│   │   ├── utility_engine.dart
│   │   ├── behavior_tree.dart
│   │   ├── personality.dart
│   │   ├── memory.dart
│   │   └── message_generator.dart
│   ├── combat/             ← Résolution instantanée (triangle tactique)
│   │   ├── combat_resolver.dart
│   │   ├── unit_catalog.dart
│   │   └── defense_system.dart
│   └── simulation/         ← Tick system + catch-up offline
│       ├── game_loop.dart
│       ├── catch_up_engine.dart
│       └── activity_tiers.dart
├── application/            ← Riverpod providers
│   ├── game_state_provider.dart
│   ├── colony_provider.dart
│   └── combat_provider.dart
├── presentation/
│   ├── screens/            ← 5-7 écrans
│   │   ├── base_screen.dart
│   │   ├── messages_screen.dart
│   │   ├── fleet_screen.dart
│   │   ├── map_screen.dart
│   │   └── research_screen.dart
│   └── widgets/
│       ├── resource_bar.dart
│       ├── colony_card.dart
│       └── combat_report.dart
└── infrastructure/
    ├── local_notifications.dart
    ├── save_manager.dart
    └── settings.dart
```

## 2.3 Flux de données

```
┌─────────────────────────────────────────────────────────┐
│                     APPAREIL MOBILE                       │
│                                                           │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │  Flutter  │◄──►│  Riverpod    │◄──►│  Game Loop   │   │
│  │  UI/Flame │    │  Providers   │    │  (Tick Sys)  │   │
│  └──────────┘    └──────────────┘    └──────┬───────┘   │
│                                              │           │
│                    ┌─────────────────────────┤           │
│                    │                         │           │
│              ┌─────▼─────┐          ┌───────▼───────┐   │
│              │  Utility   │          │  Catch-Up     │   │
│              │  AI + BT   │          │  Engine       │   │
│              │ (Isolate)  │          │ (Offline Δ)   │   │
│              └─────┬──────┘          └───────┬───────┘   │
│                    │                         │           │
│              ┌─────▼─────────────────────────▼───────┐   │
│              │         Drift (SQLite ORM)             │   │
│              │    ~4-6 MB (100 colonies, 6 mois)     │   │
│              └───────────────────────────────────────┘   │
│                                                           │
│  ┌──────────────────────────────────────────────────┐    │
│  │  Notifications Locales (flutter_local_notifs)     │    │
│  └──────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## 2.4 Game Loop et système de ticks

```dart
class GameLoop {
  static const TICK_INTERVAL = Duration(seconds: 5);

  Timer? _gameTimer;
  final AIActivityManager _activityManager;
  final CatchUpEngine _catchUpEngine;
  final GameDatabase _db;

  void start() {
    // Au lancement : catch-up du temps offline
    _catchUpEngine.processOfflineTime();

    // Démarrer le tick loop
    _gameTimer = Timer.periodic(TICK_INTERVAL, (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();

    // 1. Mettre à jour les tiers d'activité (toutes les 30s)
    _activityManager.updateActivityTiers(playerColony, allAIColonies);

    // 2. Tick les colonies ACTIVE (chaque tick = 5s)
    for (final colony in _activityManager.activeColonies) {
      colony.tick(gameState);
    }

    // 3. Tick les colonies SEMI_ACTIVE (toutes les 30s)
    if (_shouldTickSemiActive(now)) {
      for (final colony in _activityManager.semiActiveColonies) {
        colony.semiActiveTick(gameState);
      }
    }

    // 4. Tick les colonies DORMANT (toutes les 5min)
    if (_shouldTickDormant(now)) {
      for (final colony in _activityManager.dormantColonies) {
        colony.catchUpTick(gameState);
      }
    }

    // 5. Sync SQLite périodique (toutes les 30-60s)
    if (_shouldSyncDB(now)) {
      _db.syncGameState(gameState);
    }
  }
}
```

## 2.5 Catch-Up Engine (gestion offline)

Quand le joueur réouvre l'application, le moteur calcule le delta temporel et simule la progression :

```dart
class CatchUpEngine {
  Future<CatchUpReport> processOfflineTime() async {
    final lastSaved = await _db.getLastSaveTimestamp();
    final now = DateTime.now();
    final deltaSeconds = now.difference(lastSaved).inSeconds;

    if (deltaSeconds < 60) return CatchUpReport.empty(); // Moins d'1 min

    final report = CatchUpReport();

    // 1. Production de ressources (linéaire)
    for (final colony in allColonies) {
      final production = colony.calculateProductionPerSecond();
      final gained = production * deltaSeconds;
      colony.addResources(gained, capToMaxStorage: true);
      report.addResourceGain(colony.id, gained);
    }

    // 2. Construction terminée
    for (final building in pendingBuildings) {
      if (building.completionTime.isBefore(now)) {
        building.complete();
        report.addBuildingCompleted(building);
      }
    }

    // 3. Recherche terminée
    for (final tech in pendingResearch) {
      if (tech.completionTime.isBefore(now)) {
        tech.complete();
        report.addResearchCompleted(tech);
      }
    }

    // 4. Événements IA offline (simplifiés)
    // Pas de simulation complète — seulement production + probabilité d'événement
    final eventChance = (deltaSeconds / 3600).clamp(0, 1.0); // Max 1 event/h
    if (Random().nextDouble() < eventChance * 0.3) {
      report.addOfflineEvent(_generateRandomEvent());
    }

    // 5. Sauvegarder état mis à jour
    await _db.saveGameState(gameState);

    return report;
  }
}
```

## 2.6 Utilisation des Dart Isolates

Les calculs IA lourds sont exécutés dans un Isolate séparé pour ne pas bloquer l'UI :

```dart
class AIComputeService {
  late Isolate _aiIsolate;
  late SendPort _sendPort;

  Future<void> initialize() async {
    final receivePort = ReceivePort();
    _aiIsolate = await Isolate.spawn(_aiWorker, receivePort.sendPort);
    _sendPort = await receivePort.first;
  }

  /// Envoie les données de colonies à l'Isolate pour calcul IA
  Future<List<AIDecision>> computeAIDecisions(
    List<AIColonyData> colonies,
    GameStateSnapshot snapshot,
  ) async {
    final responsePort = ReceivePort();
    _sendPort.send(AIRequest(
      colonies: colonies,
      gameState: snapshot,
      responsePort: responsePort.sendPort,
    ));
    return await responsePort.first as List<AIDecision>;
  }

  /// Worker function exécutée dans l'Isolate
  static void _aiWorker(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    port.listen((message) {
      if (message is AIRequest) {
        final engine = UtilityScoringEngine();
        final decisions = <AIDecision>[];

        for (final colony in message.colonies) {
          final decision = engine.makeBestDecision(colony, message.gameState);
          decisions.add(decision);
        }

        message.responsePort.send(decisions);
      }
    });
  }
}
```

---

# SECTION 3 — MOTEUR D'IA LOCALE

## 3.1 Philosophie : Pourquoi l'IA locale suffit

Pour un jeu de stratégie mobile 100% offline comme ABYSSES, une IA locale n'est pas un compromis technique — c'est un avantage stratégique.

**Arguments pour l'IA locale :**

1. **Déterminisme contrôlé** : Contrairement à un LLM qui produit des réponses probabilistes, une IA locale basée sur des règles peut être debuggée, testée et équilibrée. Les bugs sont reproductibles. Le balancing est prédictible.

2. **Pas de latence réseau** : Chaque décision IA s'exécute en <50ms (vs 500-2000ms avec API). Pour 100 colonies simultanées, c'est 0.5s vs 100s de surcharge.

3. **Économie d'énergie** : Pas de requêtes HTTP = batterie préservée. Un LLM via API signifie data usage constant. Sur 8h de jeu (casual mobile), cela triple la consommation.

4. **Privacy absolue** : Les colonies IA ne "communiquent" avec rien. Aucune trace, aucune télémétrie cachée. Le joueur contrôle totalement le comportement IA.

5. **Pertinence stratégique** : Un LLM est entraîné sur du texte général. Une IA de Travian/OGame basée sur Utility AI comprend *réellement* les tradeoffs (expansion vs défense, commerce vs militarisation). Elle joue mieux aux échecs qu'un texte.

6. **Personnalités stables et mémorables** : Avec 100 colonies, un LLM les rendrait toutes indistinguables. L'IA locale crée des nemesis reconnaissables : "Kraken le Guerrier" vs "Medusa l'Économe".

## 3.2 Architecture IA : Hybrid Utility AI + Behavior Trees

L'IA des colonies fonctionne sur deux couches :
1. **Utility AI** (couche décision) : Quoi faire ?
2. **Behavior Trees** (couche exécution) : Comment le faire ?

### 3.2.1 Utility AI — Couche Décision

L'Utility AI score chaque action possible via une fonction d'utilité :

```
Utilité(action) = Score_Base(action) × Multiplicateur_Contexte(état) × Multiplicateur_Personnalité
```

Le système évalue à chaque tick (toutes les 30-60 secondes) parmi ~10-15 catégories d'actions :

| Action | Description | Facteurs de score |
|--------|-------------|-------------------|
| **ATTAQUER** | Lancer raid sur colonie ennemie | Armée dispo, richesse cible, distance, risque perte, vengeance historique |
| **DÉFENDRE** | Renforcer troupes contre menace | Menace détectée, ressources murailles, moral |
| **CONSTRUIRE_RESSOURCES** | Farm, mine, collecteur | Taux consommation, stock, besoin ressource spécifique |
| **CONSTRUIRE_MILITAIRE** | Soldat, croiseur, tank | Menace, objectif expansion, richesse |
| **COMMERCER** | Proposer échange à colonie proche | Surplus, besoin, alliance, reputation |
| **EXPLORER** | Envoyer scout vers zone inconnue | Curiosité (personnalité ruse), ressources à découvrir |
| **ESPIONNER** | Envoyer espion sur rivale | Menace détectée, personnalité ruse |
| **DIPLOMATIQUE** | Proposer paix, alliance, reddition | Résilience, historique avec ennemi |
| **RECHERCHE** | Investir en technologie | Objectif long terme, économie, militarisation |
| **RETRAITE** | Évacuer troupes, réallouer resources | Défaite imminente, changement objectif |

### 3.2.2 Formule de Scoring — Pseudo-code Dart

```dart
class UtilityScoringEngine {
  /// Calcule le score d'utilité pour une action donnée
  /// Renvoie : double [0.0 à 1.0] où 1.0 = action optimale
  double calculateUtility(
    AIColony colony,
    StrategicAction action,
    GameState gameState,
  ) {
    // 1. Score de base (hardcodé pour l'action)
    double baseScore = _getBaseScore(action);

    // 2. Contexte du jeu (état objectif)
    double contextMultiplier = _calculateContextMultiplier(
      action: action,
      colony: colony,
      gameState: gameState,
    );

    // 3. Filtre personnalité (traits IA)
    double personalityMultiplier = _calculatePersonalityFilter(
      action: action,
      personality: colony.personality,
    );

    // 4. Composante aléatoire contrôlée (±10%)
    double randomVariation = 1.0 + (_random.nextDouble() - 0.5) * 0.2;

    double finalScore = baseScore
      * contextMultiplier
      * personalityMultiplier
      * randomVariation;

    return (finalScore).clamp(0.0, 1.0);
  }

  double _getBaseScore(StrategicAction action) {
    const baseScores = {
      'ATTACK': 0.6,
      'DEFEND': 0.75,
      'BUILD_RESOURCE': 0.7,
      'BUILD_MILITARY': 0.65,
      'TRADE': 0.5,
      'EXPLORE': 0.4,
      'SPY': 0.45,
      'DIPLOMACY': 0.55,
      'RESEARCH': 0.6,
      'RETREAT': 0.3,
    };
    return baseScores[action.type] ?? 0.5;
  }

  double _calculateContextMultiplier({
    required StrategicAction action,
    required AIColony colony,
    required GameState gameState,
  }) {
    double multiplier = 1.0;

    switch (action.type) {
      case 'ATTACK':
        AIColony? target = gameState.findColony(action.targetId);
        if (target != null) {
          double powerRatio = colony.militaryPower / (target.militaryPower + 1);
          double wealthRatio = target.totalResources / (colony.totalResources + 1);
          double distancePenalty = 1.0 - (action.distance / 100.0).clamp(0, 1);
          if (powerRatio > 1.8 && wealthRatio > 1.5) multiplier *= 1.8;
          else if (powerRatio < 1.1) multiplier *= 0.3;
          multiplier *= distancePenalty;
        }
        break;

      case 'DEFEND':
        if (colony.hasDetectedThreat) multiplier *= 2.0;
        if (colony.militaryPower < colony.averageEnemyPower) multiplier *= 1.5;
        break;

      case 'BUILD_RESOURCE':
        if (colony.foodPerTurn < 50) multiplier *= 1.6;
        if (colony.stonePerTurn < 30) multiplier *= 1.3;
        break;

      case 'TRADE':
        int tradeHistory = colony.memory.successfulTradesWith(action.targetId);
        multiplier *= 1.0 + (tradeHistory * 0.15).clamp(0, 0.6);
        break;

      case 'DIPLOMACY':
        if (colony.isDeadlyEnemy(action.targetId)) multiplier *= 0.1;
        if (colony.militaryPower < 1000) multiplier *= 1.4;
        break;
    }

    return multiplier;
  }

  double _calculatePersonalityFilter({
    required StrategicAction action,
    required Personality personality,
  }) {
    double multiplier = 1.0;

    switch (action.type) {
      case 'ATTACK':
        multiplier *= (0.5 + personality.agressivity);
        multiplier *= (1.5 - personality.diplomacy * 0.5);
        break;
      case 'BUILD_RESOURCE':
        multiplier *= (0.5 + personality.economy);
        break;
      case 'BUILD_MILITARY':
        multiplier *= (0.5 + personality.agressivity * 0.6 + personality.expansion * 0.4);
        break;
      case 'EXPLORE':
        multiplier *= (0.5 + personality.cunning);
        multiplier *= (0.5 + personality.expansion * 0.5);
        break;
      case 'SPY':
        multiplier *= (0.5 + personality.cunning * 1.2);
        break;
      case 'TRADE':
        multiplier *= (0.5 + personality.diplomacy * 0.8);
        break;
      case 'DIPLOMACY':
        multiplier *= (0.5 + personality.diplomacy);
        break;
    }

    return multiplier;
  }
}
```

### 3.2.3 Behavior Trees — Couche Exécution

Une fois l'action décidée par Utility AI, les Behavior Trees exécutent les détails tactiques.

```dart
class BehaviorTree {
  Future<BehaviorResult> executeAction(
    AIColony colony,
    StrategicAction action,
  ) async {
    final root = _buildActionTree(action);
    return root.tick(colony);
  }

  Node _buildActionTree(StrategicAction action) {
    switch (action.type) {
      case 'ATTACK':
        return Selector([
          Sequence([
            Condition(() => colony.militaryPower > 500),
            Condition(() => colony.foodPerTurn > 100),
            Condition(() => !colony.isUnderSiege),
          ]),
          Sequence([
            Action_GatherTroops(action.targetId, fractionToSend: 0.6),
            Action_CalculateRoute(action.targetId),
            Action_SendArmy(action.targetId),
            Action_WaitForResolution(),
            Action_MemorizeOutcome(),
          ]),
        ]);

      case 'BUILD_RESOURCE':
        return Sequence([
          Action_FindAvailableSlot(action.resourceType),
          Action_PayResources(action.cost),
          Action_QueueBuild(action),
          Action_UpdateProductionQueue(),
        ]);

      case 'TRADE':
        return Sequence([
          Condition(() => colony.canInitiateTrade(action.targetId)),
          Action_PrepareOffer(action.offer),
          Action_SendTradeProposal(action.targetId),
          Action_WaitForResponse(timeoutSeconds: 120),
          Action_MemorizeTradeResult(),
        ]);

      default:
        return Leaf.Fail();
    }
  }
}

abstract class Node {
  NodeResult tick(AIColony colony);
}

class Sequence extends Node {
  List<Node> children;
  Sequence(this.children);

  @override
  NodeResult tick(AIColony colony) {
    for (var child in children) {
      final result = child.tick(colony);
      if (result == NodeResult.FAIL) return NodeResult.FAIL;
      if (result == NodeResult.RUNNING) return NodeResult.RUNNING;
    }
    return NodeResult.SUCCESS;
  }
}

class Selector extends Node {
  List<Node> children;
  Selector(this.children);

  @override
  NodeResult tick(AIColony colony) {
    for (var child in children) {
      final result = child.tick(colony);
      if (result == NodeResult.SUCCESS) return NodeResult.SUCCESS;
      if (result == NodeResult.RUNNING) return NodeResult.RUNNING;
    }
    return NodeResult.FAIL;
  }
}

enum NodeResult { SUCCESS, FAIL, RUNNING }
```

### 3.2.4 Exemple concret complet : Décision d'attaque

```dart
void aiDecisionTick(AIColony kraken) {
  // Phase 1 : Utility AI évalue TOUTES les actions
  Map<String, double> utilities = {};

  for (var action in kraken.possibleActions) {
    utilities[action.id] = scoringEngine.calculateUtility(
      kraken, action, gameState,
    );
  }

  // Résultats possibles (exemple) :
  // ATTACK_Medusa: 0.78
  // BUILD_RESOURCE_Food: 0.65
  // DEFEND: 0.42
  // TRADE_Leviathan: 0.38

  // Phase 2 : Sélectionner meilleur score
  final bestAction = utilities.entries
    .where((e) => e.value > 0.5)
    .reduce((a, b) => a.value > b.value ? a : b)
    .key;

  // Phase 3 : Behavior Tree exécute l'action
  behaviorTree.executeAction(kraken, gameState.getAction(bestAction))
    .then((result) {
      // Phase 4 : Mémoriser résultat
      kraken.memory.recordOutcome(
        action: bestAction,
        success: result.success,
        details: result.details,
      );
    });
}
```

## 3.3 Profils de personnalité (5 axes)

Chaque colonie IA possède une personnalité définie par 5 axes (floats de 0.0 à 1.0) :

1. **Agressivité** (0.0 = pacifiste, 1.0 = belliciste) — Affecte : bonus ATTACK, malus TRADE
2. **Diplomatie** (0.0 = solitaire, 1.0 = diplomate) — Affecte : bonus TRADE, bonus DIPLOMACY
3. **Expansion** (0.0 = défenseur, 1.0 = conquérant) — Affecte : bonus EXPLORE, bonus ATTACK
4. **Économie** (0.0 = militariste, 1.0 = économe) — Affecte : bonus BUILD_RESOURCE, bonus RESEARCH
5. **Ruse** (0.0 = transparent, 1.0 = manipulateur) — Affecte : bonus SPY, bonus DECEPTION

### 3.3.1 Archétypes nommés (8)

| Archétype | Nom | Agr. | Dip. | Exp. | Éco. | Ruse | Playstyle |
|-----------|-----|------|------|------|------|------|-----------|
| **Guerrier** | Kraken | 0.95 | 0.1 | 0.8 | 0.2 | 0.3 | Attaque précoce, raids constants |
| **Diplomate** | Medusa | 0.2 | 0.95 | 0.5 | 0.7 | 0.4 | Réseau d'alliances, commerce actif |
| **Économe** | Leviathan | 0.3 | 0.6 | 0.2 | 0.95 | 0.3 | Fermes massives, dominance tardive |
| **Explorateur** | Nautilus | 0.4 | 0.5 | 0.9 | 0.4 | 0.8 | Déploiement rapide, opportunisme |
| **Manipulateur** | Sirène | 0.5 | 0.4 | 0.6 | 0.5 | 0.95 | Espionnage, fausses alliances |
| **Équilibré** | Triton | 0.5 | 0.5 | 0.5 | 0.5 | 0.5 | Adaptatif, pas de spécialité |
| **Conquérant** | Titan | 0.75 | 0.25 | 0.95 | 0.3 | 0.4 | Expansion massive et rapide |
| **Défenseur** | Golem | 0.1 | 0.4 | 0.1 | 0.8 | 0.3 | Fortifications massives, stable |

### 3.3.2 Instanciation avec variance

```dart
class AIColonyFactory {
  AIColony createColonyFromArchetype(
    String archetypeId,
    {double variance = 0.1}
  ) {
    final basePersonality = _getArchetypePersonality(archetypeId);

    // Variance aléatoire (±variance*100%)
    final personalityWithNoise = Personality(
      agressivity: _addVariance(basePersonality.agressivity, variance),
      diplomacy: _addVariance(basePersonality.diplomacy, variance),
      expansion: _addVariance(basePersonality.expansion, variance),
      economy: _addVariance(basePersonality.economy, variance),
      cunning: _addVariance(basePersonality.cunning, variance),
    );

    return AIColony(
      id: generateId(),
      name: _generateName(archetypeId),
      personality: personalityWithNoise,
      position: Vector2(...),
    );
  }

  double _addVariance(double baseValue, double variance) {
    final factor = 1.0 + (Random().nextDouble() - 0.5) * 2 * variance;
    return (baseValue * factor).clamp(0.0, 1.0);
  }
}
```

## 3.4 Système de mémoire locale

Chaque colonie IA stocke une mémoire limitée et structurée (~31 KB/colonie).

```dart
class AIMemory {
  // Colonies connues (position, ressources estimées, armée)
  Map<String, ColonyDisposition> knownColonies = {};

  // Historique limité à 50 entrées
  List<StrategicEvent> recentEvents = [];

  // Objectifs courants
  String? currentObjective; // 'EXPAND', 'DEFEND', 'ECONOMIZE', 'CONQUEST'
  double objectiveProgress; // 0.0 - 1.0

  // Relations
  Map<String, RelationshipScore> relationships = {};
  // id -> diplomacy_level (-1.0 à +1.0), trust_level, last_interaction

  // Cooldowns
  Map<String, DateTime> actionCooldowns = {};
}

class RelationshipScore {
  double diplomacyLevel; // -1.0 (ennemi) à +1.0 (allié)
  double trustLevel;     // -1.0 (traître) à +1.0 (fiable)
  int tradeCompletions = 0;
  int attacksExchanged = 0;

  bool isDeadlyEnemy() => diplomacyLevel < -0.7;
  bool isAlly() => diplomacyLevel > 0.6;
}
```

### Taille mémoire estimée

```
Par colonie IA :
  - knownColonies (50 × 200 bytes)    = 10 KB
  - relationships (50 × 100 bytes)     = 5 KB
  - recentEvents (50 × 300 bytes)      = 15 KB
  - cooldowns + techs                  = 1.5 KB
  TOTAL PAR COLONIE : ~31 KB

Pour 100 colonies : 3.1 MB
+ Données gameplay : ~50 KB/colonie × 100 = 5 MB
TOTAL MÉMOIRE IA : ~8.1 MB (acceptable pour mobile moderne)
```

## 3.5 Évolution des personnalités

Les personnalités NE sont PAS figées. Elles évoluent lentement selon les événements (max ±0.05 par événement) :

```dart
class PersonalityEvolution {
  void updateFromEvent(Personality personality, StrategicEvent event) {
    switch (event.type) {
      case 'ATTACK_RECEIVED':
        if (event.details['wasAllied'] == true) {
          // Trahison → moins diplomate, plus agressif
          personality.diplomacy -= 0.05;
          personality.agressivity += 0.05;
          personality.cunning += 0.03;
        }
        break;
      case 'TRADE_SUCCESS':
        personality.diplomacy += 0.03;
        personality.agressivity -= 0.02;
        break;
      case 'CONQUEST_VICTORY':
        personality.agressivity += 0.04;
        personality.expansion += 0.05;
        break;
    }
    _clampPersonality(personality);
  }
}
```

## 3.6 Système de messages templates

Les colonies IA communiquent via des messages générés par templates. Pas de LLM, mais assez de variantes pour sembler naturel.

### Architecture : [Situation] × [Personnalité] × [Variante]

```
Message = Template_{Situation}_{Personnalité}_{Variante}
```

### Table des situations

| Situation | Description | Trigger |
|-----------|-------------|---------|
| **TRADE_OFFER** | Proposition de commerce | Surplus détecté + besoin chez autre |
| **THREAT** | Menace militaire | Menace détectée, attaque imminente |
| **PEACE** | Proposition de paix | Guerre épuisante, faiblesse |
| **BETRAYAL** | Dénonciation/trahison | Alliance brisée |
| **HELP_REQUEST** | Appel à l'aide | Menace grave |
| **INFO** | Partage d'information | Allié, intel sur ennemi commun |
| **VICTORY_GLOAT** | Fanfaronnade | Victoire majeure |
| **APOLOGY** | Excuses | Attaque amicale accidentelle |

### Exemples de templates

```dart
// Guerrier menace
"${TARGET}, tes défenses pathétiques ne résisteront pas à mes ${ARMY_COUNT} troupes.
Rends-toi ou sois anéanti. ${TIME_LIMIT}h pour décider."

// Diplomate propose commerce
"Salutations, ${TARGET} ! J'ai remarqué que tu pourrais bénéficier de nos ressources.
J'offre ${RESOURCE_OFFER} en échange de ton surplus. Commerce équitable ?"

// Manipulateur trahit
"${TARGET}, tu es tombé dans mon piège. Bien joué de ma part.
Voilà ce qui arrive quand on sous-estime la ruse."
```

### Nombre de templates pour MVP

```
6 situations × 4 archétypes × 3 variantes = ~72 templates

Distribution recommandée :
  TRADE_OFFER:    12 templates
  THREAT:         10 templates
  PEACE:           8 templates
  BETRAYAL:        6 templates
  HELP_REQUEST:    9 templates
  INFO:            6 templates
  VICTORY_GLOAT:   6 templates
  APOLOGY:         2 templates
  TOTAL MVP: ~59 templates
```

## 3.7 Tiers d'activité IA (gestion CPU)

Avec 100 colonies IA, impossible de faire tick() à chacune à fréquence égale. Solution : tiers d'activité basés sur la proximité au joueur.

| Tier | Fréquence | Simulation | Complexité | Coût CPU |
|------|-----------|-----------|-----------|----------|
| **ACTIVE** | 1×/5s | Complète (toutes actions) | Full Utility AI + BT | ~5-10ms/tick |
| **SEMI_ACTIVE** | 1×/30s | Réduite (construction, diplo) | Utility AI simplifiée | ~2-3ms/tick |
| **DORMANT** | 1×/5min | Catch-up (production seule) | Production linéaire | ~1ms/tick |

### Estimations CPU/Batterie

```
Scénario : 100 colonies IA, joueur centré carte, 10h jeu

ACTIVE (20 colonies) : 20 × 5ms = 100ms par tick (5s) → ~20ms overhead moyen
SEMI_ACTIVE (30 colonies) : 30 × 2ms = 60ms par tick (30s) → ~2ms overhead moyen
DORMANT (50 colonies) : 50 × 1ms = 50ms par tick (5min) → ~0.16ms overhead moyen

TOTAL OVERHEAD MOYEN : ~22ms / cycle = ~1.8% CPU (bon marché)
```

### Hysteresis (éviter le flicker entre tiers)

```dart
class ActivityTransitionManager {
  static const ACTIVE_RADIUS = 200.0;
  static const ACTIVE_BUFFER = 50.0;    // Zone tampon
  static const SEMI_ACTIVE_RADIUS = 500.0;
  static const SEMI_ACTIVE_BUFFER = 100.0;

  ActivityTier calculateTier(
    Vector2 playerPos, Vector2 colonyPos, ActivityTier currentTier,
  ) {
    final distance = playerPos.distanceTo(colonyPos);

    switch (currentTier) {
      case ActivityTier.ACTIVE:
        if (distance > ACTIVE_RADIUS + ACTIVE_BUFFER) {
          return ActivityTier.SEMI_ACTIVE;
        }
        return ActivityTier.ACTIVE;
      case ActivityTier.SEMI_ACTIVE:
        if (distance < ACTIVE_RADIUS - ACTIVE_BUFFER) return ActivityTier.ACTIVE;
        if (distance > SEMI_ACTIVE_RADIUS + SEMI_ACTIVE_BUFFER) return ActivityTier.DORMANT;
        return ActivityTier.SEMI_ACTIVE;
      case ActivityTier.DORMANT:
        if (distance < SEMI_ACTIVE_RADIUS - SEMI_ACTIVE_BUFFER) return ActivityTier.SEMI_ACTIVE;
        return ActivityTier.DORMANT;
    }
  }
}
```

---

# SECTION 4 — BASE DE DONNÉES ET PERSISTANCE

## 4.1 Choix de Drift (SQLite)

**Drift** est un ORM généré au compile-time pour Dart qui encapsule SQLite natif. Avantages :

- **Type-safe au compile-time** : requêtes vérifiées à la compilation
- **Zéro dépendance externe** : SQLite intégré au système iOS/Android
- **Offline-first natif** : données locales, aucune latence réseau
- **Performances** : <100ms même pour 100 colonies × 180 jours d'historique
- **Migration simplifiée** : MigrationStrategy automatique
- **Intégration Flutter** : pas de sérialisation JSON excessive

## 4.2 Schéma de Base de Données (10 tables)

### 4.2.1 Table `player`

```sql
CREATE TABLE player (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    level INTEGER NOT NULL DEFAULT 1,
    experience INTEGER NOT NULL DEFAULT 0,
    credits INTEGER NOT NULL DEFAULT 5000,
    biomass INTEGER NOT NULL DEFAULT 3000,
    minerals INTEGER NOT NULL DEFAULT 2000,
    energy INTEGER NOT NULL DEFAULT 1500,
    created_at INTEGER NOT NULL,
    last_played_at INTEGER NOT NULL,
    game_speed_multiplier REAL DEFAULT 1.0,
    tutorial_completed BOOLEAN DEFAULT 0,
    talents_unlocked TEXT NOT NULL DEFAULT '[]',
    playstyle_preference TEXT DEFAULT 'balanced'
);
```

### 4.2.2 Table `colonies`

```sql
CREATE TABLE colonies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_type TEXT NOT NULL CHECK(owner_type IN ('player', 'ai')),
    name TEXT NOT NULL,
    type_personnalite TEXT NOT NULL,
    position_x INTEGER NOT NULL,
    position_y INTEGER NOT NULL,
    faction TEXT DEFAULT 'independent',
    population INTEGER NOT NULL DEFAULT 100,
    niveau_dome INTEGER NOT NULL DEFAULT 1,
    health_dome INTEGER NOT NULL DEFAULT 100,
    credits INTEGER NOT NULL DEFAULT 1000,
    biomass INTEGER NOT NULL DEFAULT 800,
    minerals INTEGER NOT NULL DEFAULT 500,
    energy INTEGER NOT NULL DEFAULT 300,
    loyalty INTEGER NOT NULL DEFAULT 50,
    ai_personality_traits TEXT NOT NULL DEFAULT '{}',
    ai_behavior_state TEXT DEFAULT 'expansion',
    ai_threat_level INTEGER DEFAULT 0,
    discovered_by_player BOOLEAN DEFAULT 0,
    last_activity_at INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    UNIQUE(position_x, position_y)
);
```

### 4.2.3 Table `buildings`

```sql
CREATE TABLE buildings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    colony_id INTEGER NOT NULL,
    building_type TEXT NOT NULL,
    level INTEGER NOT NULL DEFAULT 1,
    construction_end_time INTEGER,
    damage_level INTEGER DEFAULT 0,
    production_rate REAL DEFAULT 1.0,
    is_active BOOLEAN DEFAULT 1,
    built_at INTEGER NOT NULL,
    FOREIGN KEY(colony_id) REFERENCES colonies(id) ON DELETE CASCADE
);
```

### 4.2.4 Table `troops`

```sql
CREATE TABLE troops (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    colony_id INTEGER NOT NULL,
    troop_type TEXT NOT NULL,
    count INTEGER NOT NULL DEFAULT 1,
    health_per_unit INTEGER NOT NULL DEFAULT 100,
    status TEXT DEFAULT 'idle',
    target_x INTEGER,
    target_y INTEGER,
    eta_arrival INTEGER,
    morale INTEGER DEFAULT 75,
    trained_at INTEGER NOT NULL,
    FOREIGN KEY(colony_id) REFERENCES colonies(id) ON DELETE CASCADE
);
```

### 4.2.5 Table `world_map`

```sql
CREATE TABLE world_map (
    zone_id INTEGER PRIMARY KEY AUTOINCREMENT,
    chunk_x INTEGER NOT NULL,
    chunk_y INTEGER NOT NULL,
    terrain_type TEXT DEFAULT 'plaine_abyssale',
    depth_level INTEGER NOT NULL,
    special_resource TEXT,
    resource_abundance REAL DEFAULT 1.0,
    exploration_level INTEGER DEFAULT 0,
    discovered_at INTEGER,
    UNIQUE(chunk_x, chunk_y)
);
```

### 4.2.6 Table `combat_log`

```sql
CREATE TABLE combat_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    attacker_id INTEGER NOT NULL,
    defender_id INTEGER NOT NULL,
    timestamp INTEGER NOT NULL,
    combat_type TEXT DEFAULT 'raid',
    result TEXT NOT NULL,
    attacker_losses_json TEXT NOT NULL,
    defender_losses_json TEXT NOT NULL,
    spoils_json TEXT,
    battle_log_json TEXT,
    FOREIGN KEY(attacker_id) REFERENCES colonies(id),
    FOREIGN KEY(defender_id) REFERENCES colonies(id)
);
```

### 4.2.7 Table `messages`

```sql
CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_colony_id INTEGER NOT NULL,
    to_colony_id INTEGER NOT NULL,
    message_type TEXT NOT NULL,
    content_template_id TEXT NOT NULL,
    variables_json TEXT DEFAULT '{}',
    timestamp INTEGER NOT NULL,
    is_read BOOLEAN DEFAULT 0,
    response_type TEXT,
    is_archived BOOLEAN DEFAULT 0,
    FOREIGN KEY(from_colony_id) REFERENCES colonies(id),
    FOREIGN KEY(to_colony_id) REFERENCES colonies(id)
);
```

### 4.2.8 Table `diplomacy`

```sql
CREATE TABLE diplomacy (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    colony1_id INTEGER NOT NULL,
    colony2_id INTEGER NOT NULL,
    relation_type TEXT DEFAULT 'neutral',
    disposition INTEGER NOT NULL DEFAULT 0,
    trust_level INTEGER DEFAULT 0,
    last_interaction INTEGER,
    pact_type TEXT,
    pact_expiry_time INTEGER,
    treaty_violated BOOLEAN DEFAULT 0,
    UNIQUE(colony1_id, colony2_id),
    FOREIGN KEY(colony1_id) REFERENCES colonies(id),
    FOREIGN KEY(colony2_id) REFERENCES colonies(id)
);
```

### 4.2.9 Table `research`

```sql
CREATE TABLE research (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tech_id TEXT NOT NULL UNIQUE,
    tech_name TEXT NOT NULL,
    tech_tier INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT 0,
    completion_percentage INTEGER DEFAULT 0,
    start_time INTEGER,
    end_time INTEGER,
    points_required INTEGER NOT NULL,
    points_invested INTEGER DEFAULT 0,
    prerequisites_json TEXT DEFAULT '[]'
);
```

### 4.2.10 Table `quests`

```sql
CREATE TABLE quests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    quest_id TEXT NOT NULL UNIQUE,
    quest_name TEXT NOT NULL,
    quest_type TEXT NOT NULL,
    description TEXT,
    progress_json TEXT DEFAULT '{}',
    progress_percentage INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT 0,
    started_at INTEGER,
    completed_at INTEGER,
    reward_xp INTEGER DEFAULT 0,
    reward_credits INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT 1
);
```

## 4.3 Estimation de taille

| Table | Lignes | Taille/ligne | Total |
|-------|--------|-------------|-------|
| player | 1 | 0.2 KB | ~0 MB |
| colonies | 100 | 0.8 KB | 0.08 MB |
| buildings | 900 | 0.5 KB | 0.45 MB |
| troops | 600 | 0.4 KB | 0.24 MB |
| world_map | 20 000 | 0.3 KB | 6 MB |
| combat_log | 36 000 (6 mois) | 2.0 KB | 72 MB |
| messages | 90 000 (6 mois) | 0.6 KB | 54 MB |
| diplomacy | 4 950 | 0.4 KB | 2 MB |
| research | 50 | 0.3 KB | 0.015 MB |
| quests | 100 | 0.5 KB | 0.05 MB |

**Total estimé : ~135 MB** (avec overhead SQLite ~150 MB réel pour 6 mois).

**Pour le MVP (1 mois)** : ~25-30 MB (très acceptable).

## 4.4 Stratégie de migration Drift

```dart
@DriftDatabase(
  tables: [Player, Colonies, Buildings, Troops, WorldMap,
           CombatLog, Messages, Diplomacy, Research, Quests],
)
class GameDatabase extends _$GameDatabase {
  GameDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode=WAL');
    },
    onUpgrade: (m, from, to) async {
      // Migrations incrémentielles
    },
  );
}
```

## 4.5 Sauvegarde et récupération

- **WAL (Write-Ahead Logging)** : Activé pour atomicité
- **Backup automatique quotidien** : Export JSON compressé
- **Import/Export** : Fonctionnalité de savegame (JSON)
- **Checksum SHA256** : Vérification intégrité

---

# SECTION 5 — SYSTÈME DE RESSOURCES

## 5.1 Les quatre ressources principales

| Ressource | Source | Usage | Stockage initial | Stockage max |
|-----------|--------|-------|-----------------|-------------|
| **Crédits** | Modules économiques, commerce | Construction, upgrade | 5 000 | 500 000 |
| **Biomasse** | Fermes, récifs | Nourriture, population | 3 000 | 300 000 |
| **Minéraux** | Mines, gisements | Technologie, unités | 2 000 | 200 000 |
| **Énergie** | Centrales, collecteurs | Alimentation modules, boucliers | 1 500 | 150 000 |

### Mécanique de pénurie

- **Énergie à 0** → Alerte Rouge : production arrêtée, population -1%/min, défenses -50%
- **Biomasse à 0** → Famine : moral troupes -25%, recrutement impossible
- **Minéraux à 0** → Construction et recherche impossibles

## 5.2 Formule de production

```
production_par_tick = base_production × (1 + (niveau_module - 1) × 0.15) × multiplicateur_terrain
```

| Module | Production de base | Par niveau (+15%) | Max (niveau 10) |
|--------|-------------------|-------------------|-----------------|
| Ferme biomasse | 100/h | +15/h | 235/h |
| Mine minéraux | 80/h | +12/h | 188/h |
| Centrale énergie | 120/h | +18/h | 282/h |
| Collecteur crédits | 60/h | +9/h | 141/h |

## 5.3 Économie et commerce

- **Commerce entre colonies** : Propositions IA basées sur surplus/besoins
- **Prix régulés** : ±20% du prix de base (invisible pour le joueur)
- **Cooldown commerce** : 6h minimum entre deux échanges avec la même colonie
- **Caravanes** : Temps de transport réel basé sur distance (30min-4h)

---

# SECTION 6 — CONSTRUCTION ET PROGRESSION

## 6.1 Le Dôme Central

15 niveaux pour le MVP. Ne peut pas être détruit (endommagé à 80% max).

| Niveau | Débloque | Emplacements | Population max |
|--------|---------|--------------|---------------|
| 1-3 | Modules de base | 4 → 6 | 50 → 150 |
| 4-6 | Modules intermédiaires | 7 → 9 | 200 → 400 |
| 7-9 | Modules avancés | 10 → 12 | 500 → 800 |
| 10-12 | Modules d'élite | 13 → 15 | 1 000 → 1 500 |
| 13-15 | Avant-poste | 16 → 18 | 2 000 → 3 000 |

## 6.2 Les 10 Modules MVP

### Modules de production (4)

| Module | Fonction | Niveaux | Production base |
|--------|----------|---------|-----------------|
| **Ferme biomasse** | Biomasse | 1-10 | 100/h |
| **Mine minéraux** | Minéraux | 1-10 | 80/h |
| **Centrale énergie** | Énergie | 1-10 | 120/h |
| **Comptoir commercial** | Crédits | 1-10 | 60/h |

### Modules militaires (3)

| Module | Fonction | Niveaux |
|--------|----------|---------|
| **Chantier naval** | Construction unités | 1-10 |
| **Baie de lancement** | Stockage troupes | 1-8 |
| **Tourelle sonique** | Défense auto | 1-8 |

### Modules utilitaires (3)

| Module | Fonction | Niveaux |
|--------|----------|---------|
| **Habitat** | Population | 1-10 |
| **Laboratoire** | Recherche | 1-8 |
| **Entrepôt** | Capacité stockage | 1-10 |

## 6.3 Early Game Accelerator

Pendant les **72 premières heures** :
- Temps de construction réduits de **50%**
- Production de base **+25%**
- Le joueur atteint un "point de saveur" (armée, alliances, premier combat) en ~2h au lieu de 8h

## 6.4 Temps de construction (formule)

```
temps_construction = temps_base × (1.3 ^ (niveau - 1))
```

| Module | Temps niv.1 | Temps niv.5 | Temps niv.10 |
|--------|------------|------------|-------------|
| Production | 30s | 2min | 15min |
| Militaire | 1min | 4min | 30min |
| Utilitaire | 45s | 3min | 20min |

---

# SECTION 7 — SYSTÈME DE COMBAT

## 7.1 Philosophie du combat

Le système de combat d'ABYSSES repose sur une **auto-résolution instantanée côté client** inspirée des mécaniques de Travian et OGame. La victoire est déterminée par :

1. **Composition tactique** : le rapport Torpilleurs/Essaims/Léviathans
2. **Timing stratégique** : moment de l'attaque, prise en compte des défenses
3. **Renseignement** : reconnaissance avant engagement

**Principe fondamental** : Un joueur avec une petite armée bien composée bat un joueur avec une grosse armée mal équilibrée.

## 7.2 Triangle Tactique

| Attaquant | vs. Défenseur | Bonus | Malus |
|-----------|---------------|-------|-------|
| **Torpilleurs** | Essaims | +40% dégâts | Essaims −20% armure |
| **Essaims** | Léviathans | +40% dégâts | Léviathans −20% armure |
| **Léviathans** | Torpilleurs | +40% dégâts | Torpilleurs −20% armure |

**Bonus de diversité** :
- Flotte mono-type : -10% dégâts
- Flotte 2 types : 0%
- Flotte 3 types : **+5% dégâts**

## 7.3 Les 9 Unités MVP

### Torpilleurs (Rapides, anti-Essaims)

| Unité | PV | ATK | DEF | VIT | Coût | Temps |
|-------|-----|-----|-----|-----|------|-------|
| **Raie** (T1) | 35 | 18 | 8 | 2.5 | 100 Métal, 50 Cristal | 15s |
| **Espadon** (T2) | 55 | 28 | 14 | 2.0 | 250 Métal, 150 Cristal | 45s |
| **Fantôme** (T3) | 90 | 42 | 22 | 1.5 | 500 Métal, 350 Cristal, 100 Deuterium | 120s |

### Essaims (Nombreux, anti-Léviathans)

| Unité | PV | ATK | DEF | VIT | Coût | Temps |
|-------|-----|-----|-----|-----|------|-------|
| **Alevin** (T1) | 12 | 6 | 3 | 1.8 | 40 Métal, 20 Cristal | 10s |
| **Piranha** (T2) | 24 | 12 | 6 | 1.5 | 120 Métal, 80 Cristal | 35s |
| **Méduse** (T3) | 50 | 20 | 10 | 1.2 | 300 Métal, 200 Cristal, 50 Deuterium | 100s |

### Léviathans (Puissants, anti-Torpilleurs)

| Unité | PV | ATK | DEF | VIT | Coût | Temps |
|-------|-----|-----|-----|-----|------|-------|
| **Nautile** (T1) | 180 | 35 | 30 | 0.8 | 400 Métal, 250 Cristal, 150 Deuterium | 150s |
| **Kraken** (T2) | 300 | 55 | 50 | 0.6 | 800 Métal, 500 Cristal, 300 Deuterium | 300s |
| **Béhémoth** (T3) | 500 | 85 | 80 | 0.4 | 1500 Métal, 1000 Cristal, 600 Deuterium | 600s |

## 7.4 Algorithme de résolution (5 étapes)

### Étape 1 : Bonus terrain défenseur

```
profondeur < 100m  → bonus armure +5%
100m-500m          → bonus armure +10%
profondeur ≥ 500m  → bonus armure +15%
```

### Étape 2 : Défenses statiques

- **Mines sous-marines** : 150 dégâts × nombre_mines (max 3), cooldown 8h
- **Tourelles** : 80 dégâts/round, 200 PV, max 2

### Étape 3 : Triangle tactique appliqué

```
POUR chaque unité u ∈ armée_attaquant :
    SI type(u) > type(cible) : modificateur = 1.40
    SI type(u) < type(cible) : modificateur = 0.80
    SINON : modificateur = 1.00

SI 3+ types distincts : dégâts × 1.05
```

### Étape 4 : Boucle de combat (max 15 rounds)

```
TANT QUE round ≤ 15 ET armées non vides :
    Phase 1 : Attaquants tirent (dégâts × modificateur × variance ±15%)
    Phase 2 : Défenseurs tirent
    Phase 3 : Tourelles tirent (si présentes)
    round += 1
```

### Étape 5 : Pillage (si victoire attaquant)

```
cap_pillage = 20% des ressources défenseur
efficacité = 60% + 15% (si Essaims) + 10% (si Torpilleurs)
ressources_pillées = ressources × cap × efficacité
Répartition : 50% Métal, 30% Cristal, 20% Deuterium
```

## 7.5 Types d'actions militaires

| Action | Objectif | Unités autorisées | Cap pillage |
|--------|---------|-------------------|-------------|
| **Attaque** | Détruire + piller | Toutes | 20% |
| **Raid** | Pillage léger | Essaims uniquement | 10% |
| **Reconnaissance** | Intel | Torpilleurs uniquement | 0% |
| **Soutien** | Renforcer allié | Toutes | 0% |
| **Interception** | Bloquer flotte en route | Auto-détection | 0% |

## 7.6 Défenses statiques

| Défense | Dégâts | Coût | Cooldown |
|---------|--------|------|----------|
| **Mine sous-marine** (×3 max) | 150 par mine | 500M, 300C, 50D | 8h |
| **Tourelle** (×2 max) | 80/round, 200 PV | 800M, 400C, 150D | - |
| **Bouclier magnétique** | Absorbe 100% | Auto | Variable |

## 7.7 Boucliers de protection

| Type | Durée | Déclenchement | Pénalité |
|------|-------|--------------|----------|
| **Post-attaque** | 8h | Auto après attaque subie | -20% production |
| **Inactivité** | 24h | Hors ligne ≥ 24h | Levé au retour |
| **Acheté en jeu** | 12h | Achat (150 Cristaux) | Cooldown 1h |

## 7.8 Performance combat

| Scénario | Taille armée | Rounds | Temps calcul |
|----------|-------------|--------|-------------|
| Petit raid | 10 vs 5 | 3 | 2.1 ms |
| Combat moyen | 50 vs 40 | 8 | 8.7 ms |
| Bataille majeure | 150 vs 120 | 12 | 24.3 ms |
| Maximum | 500 vs 450 | 15 | 68.9 ms |

---

# SECTION 8 — INTERACTIONS ET DIPLOMATIE

## 8.1 Messagerie (Feed d'événements)

### Catégories de messages

| Catégorie | Badge | Contenu |
|-----------|-------|---------|
| **Critique** | Rouge | Attaques imminentes, défenses |
| **Alliés** | Bleu | Messages alliés |
| **Ennemis** | Orange | Menaces, provocations |
| **Commerce** | Vert | Propositions d'échange |
| **Diplomatie** | Violet | Pactes, alliances |
| **Monde** | Gris | Événements globaux |

### Volume contrôlé

- **Messages reçus/jour** : 8-15 maximum
- **Cooldown par paire** : 6h entre deux messages mêmes colonies
- **Rotation des variantes** : pas de répétition immédiate

## 8.2 Système de diplomatie

### Jauge de disposition (-100 à +100)

| Action | Effet disposition |
|--------|------------------|
| Accepter échange | +5 à +15 |
| Refuser échange | -2 à -5 |
| Don de ressources | +10 à +25 |
| Attaquer la colonie | -30 à -80 |
| Défendre l'IA | +20 à +50 |
| Rompre un pacte | -40 à -60 |
| Respecter pacte longtemps | +1/jour |
| Ignorer messages (3+ jours) | -5 à -15 |

### Types de pactes

| Pacte | Effet | Durée | Condition |
|-------|-------|-------|-----------|
| **Non-agression** | Pas d'attaque mutuelle | 7 jours renouvelable | Disposition ≥ 0 |
| **Commerce** | -10% taxe, priorité échanges | 14 jours | Disposition ≥ 20 |
| **Défense mutuelle** | Soutien automatique si attaqué | 30 jours | Disposition ≥ 50 |
| **Alliance** | Tous bonus combinés | Permanent | Disposition ≥ 75 |

## 8.3 Réponses du joueur

- **Choix multiples** (3-4 options contextuelles) — mode principal
- **Accepter/Refuser** (pour propositions concrètes)
- **Ignorer** (avec conséquence sur disposition)

---

# SECTION 9 — CONSORTIUMS OCÉANIQUES

## 9.1 Consortiums pré-existants (MVP)

| Consortium | Chef | Membres | Caractère |
|-----------|------|---------|-----------|
| **L'Alliance Profonde** | Commandant Osei | ~15 IA | Défensif, accueillant |
| **Les Crocs de l'Abysse** | Barracuda | ~12 IA | Agressif, pillard |
| **Le Cercle Silencieux** | La Recluse | ~8 IA | Isolationniste, riche |
| **Pax Oceana** | Dr. Nakamura | ~10 IA | Pacifique, scientifique |
| **Indépendants** | — | ~55 IA | Variés, non-alignés |

## 9.2 Dynamique

- Le joueur peut **rejoindre** un consortium (bonus commerce intra-consortium)
- Ou **rester indépendant** (liberté totale mais pas de protection)
- Les rivalités entre consortiums génèrent des événements (guerres, embargos)
- Les chefs peuvent être **renversés** par vote interne

---

# SECTION 10 — INTERFACE MOBILE

## 10.1 Principes

- **Pouce-first** : Bottom tab bar fixe, tout accessible au pouce
- **Gestion par listes** : Pas de vue isométrique comme écran principal
- **5 écrans maximum** pour le MVP
- **Presets et raccourcis** : Compositions de flotte sauvegardées

## 10.2 Navigation — Bottom Tab Bar

| Onglet | Icône | Contenu |
|--------|-------|---------|
| **Base** | Dôme | Liste bâtiments + ressources + alertes |
| **Messages** | Bulle | Inbox catégorisée (6 onglets) |
| **Flotte** | Sous-marin | Presets composition + envoi |
| **Carte** | Globe | Liste colonies + mini-map |
| **Recherche** | Labo | Arbre tech + progression |

**FAB** (Floating Action Button) : "Actions rapides" → Envoyer flotte, Commercer, Construire

## 10.3 Écran Base

```
┌─────────────────────────────────┐
│ [Crédits] [Bio] [Min] [Énergie] │  ← Barre ressources fixe
│   5.2K     3.1K  2.0K   1.5K   │
│   +60/h   +100/h +80/h +120/h  │
├─────────────────────────────────┤
│ BÂTIMENTS          [+ Construire]│
│ ─────────────────────────────── │
│ Ferme biomasse    Niv.3  100/h  │
│ Mine minéraux     Niv.2   80/h  │
│ Centrale énergie  Niv.4  120/h  │
│ Chantier naval    Niv.2         │
│ Habitat           Niv.3  Pop:150│
│ Laboratoire       Niv.1         │
│                                 │
│ [Upgrade recommandé: Mine → Niv.3]│
├─────────────────────────────────┤
│ [Base] [Msg] [Flotte] [Carte] [Tech]│
└─────────────────────────────────┘
```

## 10.4 Écran Messages

```
┌─────────────────────────────────┐
│ [Crit(2)] [Alliés] [Ennemis]    │
│ [Commerce] [Diplo] [Monde]      │
├─────────────────────────────────┤
│ 🔴 Kraken         -45 hostile   │
│ "Tes défenses ne résisteront..."│
│ Il y a 12min                    │
│ ─────────────────────────────── │
│ 🔵 Medusa          +67 allié    │
│ "Proposition commerciale..."    │
│ Il y a 1h                       │
│ ─────────────────────────────── │
│ 🟢 Leviathan       +23 neutre   │
│ "Surplus de minéraux..."        │
│ Il y a 3h                       │
├─────────────────────────────────┤
│ [Base] [Msg] [Flotte] [Carte] [Tech]│
└─────────────────────────────────┘
```

---

# SECTION 11 — FTUE (First Time User Experience)

## 11.1 Les 90 premières minutes

| Étape | Durée | Objectif | Action |
|-------|-------|----------|--------|
| **Intro** | 1-2 min | Établir l'univers | Texte narratif : "Année 2147..." |
| **Nom colonie** | 30s | Propriété personnelle | Champ texte + default |
| **1er bâtiment** | 2-3 min | Comprendre la construction | Tuto : "Construisez un Électrolyseur" (timer 30s) |
| **1er message IA** | 1-2 min | Révéler le monde vivant | Medusa : "Bienvenue ! Commerce ?" |
| **1er commerce** | 2-3 min | Valider la diplomatie | Accepter/Refuser proposition |
| **1ère unité** | 3-5 min | Préparer le combat | "Construisez une Raie" |
| **1er combat** | 3-5 min | Goûter la victoire | Cible facile (100% win) |
| **Survol carte** | 1-2 min | Montrer le monde | Carte avec colonies visibles |

## 11.2 Paired Onboarding (J0-J7)

Deux IA accueillantes pré-configurées :
- **Medusa (Diplomate)** : Propose échanges commerciaux à J0, J2, J4
- **Golem (Défenseur)** : Propose alliance défensive à J1, J3

## 11.3 Mini-Milestones (J0-J30)

| Jour | Milestone | Récompense |
|------|-----------|-----------|
| J0 | 1ère colonie + 1ère unité | 1er message IA |
| J1 | 1er échange commercial | +500 Crédits bonus |
| J2 | 1ère attaque réussie | Titre "Explorateur" |
| J3 | Rejoindre consortium | Double production 24h |
| J7 | 5 combats réussis | Coffre de ressources |
| J14 | Recherche T2 | Nouvelle unité débloquée |
| J30 | Dôme niv.10 | Déblocage avant-poste |

---

# SECTION 12 — ARBRE DE RECHERCHE TECHNOLOGIQUE

## 12.1 Philosophie : Spécialisation

Le joueur choisit **2 branches principales sur 5** à développer (T1-T3 pour le MVP). Les 3 autres sont accessibles T1 uniquement.

## 12.2 Les 15 technologies MVP (3 par branche)

### Branche Architecture

| Tier | Tech | Effet | Temps |
|------|------|-------|-------|
| T1 | Corail renforcé | +20% durabilité bâtiments | 1h |
| T2 | Bio-ciment | -10% coût construction | 4h |
| T3 | Corail vivant | Auto-réparation 1%/h | 12h |

### Branche Armement

| Tier | Tech | Effet | Temps |
|------|------|-------|-------|
| T1 | Alliages avancés | +10% PV unités | 1h |
| T2 | Torpilles guidées | +20% puissance torpilleurs | 4h |
| T3 | Armes à impulsion | Dégât EMP (nouveau type) | 12h |

### Branche Sciences de la Vie

| Tier | Tech | Effet | Temps |
|------|------|-------|-------|
| T1 | Recycleurs d'air | -15% conso énergie bâtiments | 1h |
| T2 | Population résiliente | Alerte Rouge 2× plus lente | 4h |
| T3 | Médecine abyssale | Régénération troupes +50% | 12h |

### Branche Énergie

| Tier | Tech | Effet | Temps |
|------|------|-------|-------|
| T1 | Condensateurs | +20% stockage énergie | 1h |
| T2 | Boucliers énergétiques | Bouclier sur unités | 4h |
| T3 | Leurres photoniques | Fantômes trompeurs (défense) | 12h |

### Branche Centrale

| Tier | Tech | Effet | Temps |
|------|------|-------|-------|
| T1 | Cartographie avancée | +30% carte révélée | 1h |
| T2 | Diplomatie avancée | Débloque pactes de non-agression | 4h |
| T3 | Navigation profonde | Unités +20% vitesse | 12h |

## 12.3 Interface recherche

- **Slider horizontal** : 5 branches en haut
- **Timeline verticale** : T1 → T2 → T3 par branche
- **Mode Playstyle** : Suggestions selon profil (Bâtisseur / Guerrier / Commerçant)

---

# SECTION 13 — PROGRESSION ET PRESTIGE

## 13.1 Double progression

- **Niveau de base** (Dôme 1-15) : Bâtiments, modules, unités
- **Niveau de commandant** (1-50) : XP par toutes les actions, talents passifs

## 13.2 Boucle quotidienne

| Moment | Activité | Durée | Récompense |
|--------|---------|-------|-----------|
| **Matin** | Collecter ressources, lancer constructions | 3-5 min | Production accumulée |
| **Midi** | Lire messages, répondre diplomatie | 2-3 min | XP social |
| **Soir** | Lancer attaques/commerce, planifier | 5-10 min | XP combat/commerce |
| **Nuit** | Offline (catch-up au retour) | Auto | Production + événements |

## 13.3 Système de Prestige

Au **Dôme 15** (max MVP), option "Transcender" :
- Réinitialise le Dôme à 1
- Conserve **20% des ressources** et **toutes les relations IA**
- Débloque **1 bonus permanent** (+5% production, +10% XP, etc.)
- Le monde IA est **régénéré** avec plus de difficulté
- Boucle infinie anti-stagnation

## 13.4 Quêtes

### Quêtes quotidiennes (3/jour)

- "Construire 1 bâtiment" → +100 XP
- "Faire 1 échange commercial" → +150 XP
- "Gagner 1 combat" → +200 XP

### Quêtes de découverte (uniques)

- "Explorer 10 zones" → Débloquer nouveau terrain
- "Allier 3 colonies" → Titre "Diplomate"
- "Conquérir 5 colonies" → Titre "Conquérant"

---

# SECTION 14 — ÉVÉNEMENTS PvE

## 14.1 Créatures des profondeurs

Des créatures apparaissent périodiquement comme menaces PvE :

| Créature | PV | ATK | Fréquence | Récompense |
|----------|-----|-----|-----------|-----------|
| **Essaim de méduses** | 500 | 30 | 1×/jour | 200 Crédits |
| **Serpent abyssal** | 2 000 | 80 | 1×/3 jours | 500 Minéraux + Titre |
| **Léviathan ancien** | 10 000 | 200 | 1×/semaine | 2000 Ressources mixtes |

## 14.2 Événements mondiaux

| Événement | Fréquence | Effet | Durée |
|-----------|-----------|-------|-------|
| **Éruption thermique** | 1×/semaine | +50% production zone | 24h |
| **Migration de créatures** | 1×/2 semaines | Menace PvE accrue | 48h |
| **Marée sismique** | 1×/mois | Révèle zones cachées | 12h |
| **Tempête magnétique** | 1×/mois | Communications coupées (pas de messages IA) | 6h |

---

# SECTION 15 — PLAN DE PRODUCTION MVP

## 15.1 Équipe et durée

| Rôle | Personnes | Profil |
|------|----------|--------|
| **Dev Flutter/Dart** | 1 | Full-stack mobile, Flame, Drift |
| **Dev Game Design/IA** | 1 | Utility AI, balancing, contenu |
| **Total** | **2 développeurs** | **16 semaines (4 mois)** |

## 15.2 Planning détaillé (16 semaines)

### Phase 1 — Fondations (Semaines 1-4)

| Semaine | Dev 1 (Flutter) | Dev 2 (Game Design) |
|---------|----------------|---------------------|
| S1 | Setup projet Flutter, Drift, structure | Définition complète des données (tables, constantes) |
| S2 | Écran Base + barre ressources | Système de production (formules, ticks) |
| S3 | Navigation bottom tab bar (5 onglets) | Moteur de construction (queue, timers) |
| S4 | Écran Carte (mini-map + liste) | Génération monde (carte, placement colonies) |

**Livrable S4** : App navigable avec 5 écrans, production de ressources fonctionnelle, carte avec colonies placées.

### Phase 2 — Moteur IA (Semaines 5-8)

| Semaine | Dev 1 (Flutter) | Dev 2 (Game Design) |
|---------|----------------|---------------------|
| S5 | Écran Messages (inbox catégorisée) | Utility AI scoring engine |
| S6 | Écran Flotte (presets + envoi) | Behavior Trees (exécution) |
| S7 | Rapports de combat (UI) | Système de combat (résolution) |
| S8 | Notifications locales | Personnalités IA (8 archétypes × variance) |

**Livrable S8** : IA fonctionnelle (décisions, messages), combats auto-résolus, notifications.

### Phase 3 — Contenu (Semaines 9-12)

| Semaine | Dev 1 (Flutter) | Dev 2 (Game Design) |
|---------|----------------|---------------------|
| S9 | Écran Recherche (arbre tech) | 59 templates de messages IA |
| S10 | Diplomatie UI (dispositions, pactes) | Balancing (ressources, unités, timers) |
| S11 | FTUE (tutoriel guidé) | Quêtes (daily + découverte) |
| S12 | Système de sauvegarde/export | Événements PvE (créatures, événements monde) |

**Livrable S12** : Jeu complet jouable, 100 colonies IA, contenu MVP.

### Phase 4 — Polish (Semaines 13-16)

| Semaine | Dev 1 (Flutter) | Dev 2 (Game Design) |
|---------|----------------|---------------------|
| S13 | Animations, transitions, feedback haptique | Catch-up engine (offline) |
| S14 | Optimisation performance (Isolates) | Prestige system |
| S15 | Tests sur devices (iOS + Android) | Balancing final (10 playthroughs) |
| S16 | Bug fixes, submission stores | Documentation, assets finaux |

**Livrable S16** : MVP prêt pour publication sur App Store et Google Play.

## 15.3 Budget estimé

### Scénario Bootstrap (développeurs bénévoles)

| Poste | Coût |
|-------|------|
| Compte Apple Developer | 99€/an |
| Compte Google Play | 25€ (one-time) |
| Assets graphiques (Kenney, OpenGameArt) | 0-200€ |
| Musique/SFX (royalty-free) | 0-100€ |
| Hébergement (aucun serveur) | 0€ |
| Outils (Flutter = gratuit, Dart = gratuit) | 0€ |
| **Total bootstrap** | **~200-500€** |

### Scénario Freelance (développeurs payés)

| Poste | Coût |
|-------|------|
| Dev Flutter senior (4 mois × 3K€/mois) | 12 000€ |
| Dev Game Design (4 mois × 2.5K€/mois) | 10 000€ |
| Assets + divers | 500€ |
| **Total freelance** | **~22 500€** |

### Scénario Intermédiaire (2 associés)

| Poste | Coût |
|-------|------|
| Développement (temps propre) | 0€ |
| Assets graphiques professionnels | 500-1 000€ |
| Sound design | 200-500€ |
| Marketing soft-launch | 1 000-2 000€ |
| Comptes développeur | 124€ |
| **Total intermédiaire** | **~2 000-4 000€** |

---

# SECTION 16 — RISQUES ET MITIGATIONS

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|-----------|
| **IA trop prévisible** | Ennui rapide | Moyenne | Variance ±10%, évolution personnalité, rotation templates |
| **Rétention offline faible** | Churn J7-J30 | Haute | Prestige, quêtes daily, événements PvE, catch-up gratifiant |
| **Monotonie combat** | Lassitude | Moyenne | 9 unités × triangle tactique × défenses = centaines de compositions |
| **SQLite trop lourd (6 mois)** | Performance | Basse | Purge automatique combat_log > 30 jours, archivage |
| **Messages IA répétitifs** | Immersion brisée | Moyenne | 59 templates min, cooldown 6h, rotation variants |
| **Scope creep** | Retard MVP | Haute | Strict : 100 colonies, 10 modules, 9 unités, 15 techs — pas plus |
| **Batterie** | Désinstallation | Basse | 1.8% CPU, pas de GPS, pas de réseau, Isolates |
| **Concurrence** | Noyé dans les stores | Haute | Niche (stratégie offline IA), soft-launch, itération rapide |

---

# SECTION 17 — ROADMAP POST-MVP

| Période | Contenu | Objectif |
|---------|---------|----------|
| **MVP (M0)** | 100 colonies, 10 modules, 9 unités, 15 techs | Publication stores |
| **Patch 1.1 (M+1)** | +2 modules, balancing, bug fixes | Stabilisation |
| **Patch 1.2 (M+2)** | +6 unités T4, avant-postes | Rétention M30 |
| **v1.5 (M+4)** | 200 colonies, Mythos (arc narratif), mutations | Profondeur |
| **v2.0 (M+8)** | Mode Expédition (roguelike), créatures capturables | Nouveau contenu |
| **v3.0 (M+12)** | Multijoueur optionnel (P2P local), classements | Social |

---

# SECTION 18 — MÉTRIQUES ET KPIs CIBLES

| Métrique | Objectif MVP | Objectif v1.5 |
|----------|-------------|--------------|
| **Rétention J1** | > 45% | > 55% |
| **Rétention J7** | > 22% | > 30% |
| **Rétention J30** | > 10% | > 18% |
| **Session moyenne** | 5-10 min | 8-15 min |
| **Sessions/jour** | 3-6 | 4-8 |
| **Messages IA lus** | > 70% | > 85% |
| **Taille app** | < 50 MB | < 80 MB |
| **Taille DB (1 mois)** | < 30 MB | < 50 MB |
| **CPU usage** | < 3% | < 5% |
| **Crash rate** | < 0.5% | < 0.3% |

---

# RÉSUMÉ EXÉCUTIF

## ABYSSES v4.0 en un coup d'œil

| Aspect | Valeur |
|--------|--------|
| **Architecture** | 100% locale, offline, 0€ serveur |
| **Stack** | Flutter + Dart + Flame + Drift + Riverpod |
| **IA** | Utility AI + Behavior Trees (locale, <50ms) |
| **Stockage** | SQLite via Drift (~4-6 MB initial, ~30 MB/mois) |
| **Colonies IA** | 50-100 avec 5 axes personnalité × 8 archétypes |
| **Modules** | 10 (4 production + 3 militaire + 3 utilitaire) |
| **Unités** | 9 (3 Torpilleurs + 3 Essaims + 3 Léviathans) |
| **Technologies** | 15 (3 par branche × 5 branches) |
| **Combat** | Auto-résolu, triangle tactique (+40%/-20%), max 15 rounds |
| **Messages IA** | ~59 templates [Situation × Personnalité × Variante] |
| **Écrans** | 5 (Base, Messages, Flotte, Carte, Recherche) |
| **Équipe** | 2 développeurs |
| **Durée** | 16 semaines (4 mois) |
| **Budget** | ~2K-5K€ (bootstrap) ou ~22K€ (freelance) |

---

*Document confidentiel — ABYSSES Game Design Document v4.0*
*Architecture 100% locale — MVP Offline-First — 2 développeurs, 4 mois*
*Utility AI + Behavior Trees — SQLite via Drift — Flutter + Flame*
*Tous droits réservés.*
