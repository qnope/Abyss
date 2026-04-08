# Begin Fight - Feature Specification

## 1. Feature Overview

Cette feature introduit le **système de combat tour par tour** d'ABYSSES. Jusqu'à présent, cliquer sur une tanière de monstre n'affichait qu'un message "Combat non disponible" (cf. `specs/done/map-treasure`). Désormais, le joueur peut sélectionner des unités de sa base, les envoyer attaquer un monstre, et récupérer un butin (ressources et perles) en cas de victoire.

Principes clés :
- **Tour par tour** : chaque tour de combat, toutes les unités vivantes (joueur et monstres) attaquent dans un ordre **aléatoire global**.
- **Ciblage aléatoire** : chaque unité d'un camp choisit aléatoirement une unité vivante du camp adverse.
- **Coups critiques** : 5% de chance par attaque, infligeant **3× les dégâts** (200% de dégâts en plus).
- **Formule de dégâts** : `ATK × (100 / (100 + DEF))`, arrondi à l'entier supérieur, minimum 1. Sur critique, on multiplie le résultat final par 3.
- **Résolution instantanée** : le combat est calculé immédiatement lorsque le joueur le lance, sans coût en tours de jeu.
- **Combat à mort** : aucune fuite possible une fois le combat lancé.
- **Bilan adaptatif** : les unités tombées du joueur sont soit blessées (de retour disponibles à la base) soit mortes définitivement, selon l'équilibre du combat.
- **Butin** : ressources et perles dépendant du niveau (difficulté) du monstre.

Cette feature étend `MonsterLairSheet` (déjà en place) en remplaçant le message "Combat non disponible" par un flux complet de sélection d'armée + combat + résumé.

## 2. User Stories

### US-1 : Sélectionner les unités à envoyer au combat

**En tant que** joueur,
**je veux** pouvoir cliquer sur une tanière de monstre révélée et choisir précisément quelles unités de ma base envoyer au combat,
**afin de** doser ma force selon la difficulté du monstre.

**Critères d'acceptation :**
- Le `MonsterLairSheet` actuel affiche désormais un bouton **"Préparer le combat"** (à la place de "Combat non disponible").
- Cliquer sur ce bouton ouvre un nouvel écran de **sélection d'armée**.
- L'écran liste tous les types d'unités militaires du joueur disponibles à la base, avec leur stock actuel.
- Pour chaque type, le joueur peut choisir combien d'unités envoyer (entre 0 et le stock disponible).
- L'écran affiche également la composition prévue du monstre (nombre d'unités monstres, niveau).
- Un bouton **"Lancer le combat"** est présent ; il est désactivé si aucune unité n'est sélectionnée.
- Un bouton **"Annuler"** ferme l'écran sans engager le combat (aucune unité perdue, aucun changement d'état).

### US-2 : Résoudre un combat tour par tour avec ciblage aléatoire

**En tant que** joueur,
**je veux** que le combat se résolve automatiquement selon des règles claires et justes,
**afin de** vivre des combats équilibrés et compréhensibles.

**Critères d'acceptation :**
- Le combat est composé de **tours**. Chaque tour :
  1. La liste de toutes les unités vivantes (joueur + monstres) est mélangée aléatoirement.
  2. Dans l'ordre obtenu, chaque unité encore vivante effectue **une attaque** sur une unité encore vivante choisie aléatoirement dans le camp adverse.
- Le combat se termine quand un camp n'a plus d'unités vivantes.
- **Formule de dégâts** : `dégâts = ceil(ATK_attaquant × (100 / (100 + DEF_cible)))`, minimum 1.
- **Coup critique** : à chaque attaque, 5% de chance que les dégâts soient multipliés par **3** (200% de dégâts en plus).
- Les PV de chaque unité sont suivis individuellement durant le combat (pas seulement par type).
- Lorsque les PV d'une unité tombent à 0 ou moins, elle est retirée du combat (ne peut plus attaquer ni être ciblée).
- Aucune fuite n'est possible : une fois lancé, le combat se résout entièrement.

### US-3 : Voir le résumé du combat

**En tant que** joueur,
**je veux** voir un résumé clair du résultat du combat,
**afin de** comprendre ce qui s'est passé et planifier mes prochaines actions.

**Critères d'acceptation :**
- Après la résolution, un écran de résumé s'affiche avec :
  - Le **résultat** : Victoire ou Défaite.
  - Le nombre de tours de combat.
  - Pour chaque type d'unité du joueur engagée : nombre envoyé / nombre survivant intact / nombre blessé / nombre mort définitivement.
  - Pour le monstre : nombre d'unités monstres tuées (devrait être total en cas de victoire).
  - Le **butin** récupéré (ressources et perles) en cas de victoire.
- Un bouton **"Retour à la carte"** ferme le résumé.
- À la fermeture, l'état du jeu est mis à jour (stocks de ressources, perles, unités).

### US-4 : Récupérer le butin en cas de victoire

**En tant que** joueur,
**je veux** récupérer un butin proportionnel à la difficulté du monstre vaincu,
**afin de** progresser dans le jeu.

**Critères d'acceptation :**
- Le butin dépend de la difficulté du monstre :

| Niveau | Difficulté carte | Algues   | Corail   | Minerai  | Perles |
|--------|------------------|----------|----------|----------|--------|
| 1      | `easy`           | 300-500  | 300-500  | 300-500  | 0      |
| 2      | `medium`         | 500-1000 | 500-1000 | 500-1000 | 2      |
| 3      | `hard`           | 1000-2000| 1000-2000| 1000-2000| 10     |

- Les montants de ressources sont tirés aléatoirement dans la plage indiquée au moment de la victoire (un tirage indépendant par ressource).
- Les perles sont un nombre fixe par niveau.
- Les ressources et perles sont ajoutées immédiatement au stock du joueur après fermeture du résumé.
- En cas de défaite, **aucun butin** n'est attribué.

### US-5 : Gérer les pertes et les blessés

**En tant que** joueur,
**je veux** que les unités tuées au combat aient une chance de revenir blessées plutôt que mortes,
**afin de** ne pas être systématiquement puni à chaque combat équilibré.

**Critères d'acceptation :**
- À la fin du combat, pour chaque unité du joueur ayant été engagée et tuée pendant le combat, on détermine si elle est :
  - **Blessée** : elle revient à la base immédiatement disponible (compte à nouveau dans le stock du joueur, sans coût de soin).
  - **Morte définitivement** : retirée du stock du joueur de manière permanente.
- Le ratio blessés/morts dépend du **pourcentage de PV total perdu par le joueur** durant le combat (`pct_lost = pv_perdus / pv_total_engagé`) :
  - `pct_lost ≤ 50%` (combat équilibré) : **80% blessés / 20% morts**.
  - `pct_lost ≥ 80%` (carnage) : **20% blessés / 80% morts**.
  - Entre les deux : interpolation linéaire continue entre 80/20 et 20/80.
- L'application du ratio se fait par tirage aléatoire individuel pour chaque unité tombée (pas un compte global).
- Les unités survivantes intactes sont 100% disponibles immédiatement.

### US-6 : Marquer la tanière comme vaincue

**En tant que** joueur,
**je veux** que la tanière vaincue reste visible mais grisée sur la carte,
**afin de** voir mon historique de combats et ne pas la confondre avec une tanière active.

**Critères d'acceptation :**
- Après une **victoire**, la case de la tanière passe à l'état **"collectée"** (même mécanique que `resourceBonus`/`ruins` du projet `map-treasure`).
- L'icône du monstre reste visible mais grisée (opacité réduite).
- Recliquer sur la case affiche le message "Vous êtes déjà venu par ici" sans bouton d'action.
- Après une **défaite**, la case reste **inchangée** : le monstre garde sa composition initiale et le joueur peut retenter avec une autre armée.

### US-7 : Composition et stats des armées de monstres

**En tant que** joueur,
**je veux** que les tanières soient peuplées de monstres dont la difficulté est cohérente avec le niveau,
**afin d'**avoir une progression claire.

**Critères d'acceptation :**
- Chaque tanière contient un nombre variable de **unités monstres génériques** d'un même niveau :

| Niveau | Difficulté carte | Nb d'unités monstres |
|--------|------------------|----------------------|
| 1      | `easy`           | 20 à 50                |
| 2      | `medium`         | 60 à 100               |
| 3      | `hard`           | 120 à 200              |

- Chaque unité monstre a les stats suivantes (PV / ATK / DEF) :

| Niveau | PV | ATK | DEF |
|--------|----|-----|-----|
| 1      | 10 | 2   | 1   |
| 2      | 20 | 4   | 2   |
| 3      | 35 | 7   | 4   |

- La composition exacte (nombre d'unités) d'une tanière donnée est tirée **à la génération de la carte** et reste stable entre les sauvegardes.
- Les unités monstres ne sont pas un nouveau `UnitType` du joueur ; elles existent uniquement comme combattants ennemis durant un combat.

## 3. Testing and Validation

### Tests unitaires (domain)

- **Formule de dégâts** : vérifier `ceil(ATK × (100 / (100 + DEF)))`, minimum 1, sur plusieurs combinaisons (ATK > DEF, ATK < DEF, DEF = 0).
- **Coups critiques** : avec un random injectable / mocké, vérifier que le multiplicateur ×3 s'applique correctement et qu'à 5% le résultat statistique est cohérent sur N attaques.
- **Ciblage aléatoire** : vérifier qu'une unité ne peut cibler que des unités vivantes du camp adverse, et que le tirage est uniforme.
- **Ordre aléatoire global** : vérifier que toutes les unités vivantes (des deux camps) sont incluses dans l'ordre du tour, et que l'ordre change entre tours.
- **Fin de combat** : vérifier qu'un camp à 0 unités vivantes met fin au combat avec le bon résultat (victoire/défaite).
- **Calcul du butin** : pour chaque niveau de monstre, vérifier que les ressources sont dans la plage attendue et que le nombre de perles est exact.
- **Ratio blessés/morts** : vérifier l'interpolation linéaire entre `(50%, 80/20)` et `(80%, 20/80)`, et les bornes.
- **Unités blessées** : vérifier qu'elles sont restaurées dans le stock du joueur après le combat.
- **Défaite** : vérifier qu'aucune ressource n'est attribuée et que la tanière reste intacte.
- **Victoire** : vérifier que la case de la tanière passe à l'état "collectée".
- **Génération de tanières** : vérifier que la composition (nombre d'unités) est dans les plages attendues par niveau et stable après sauvegarde.

### Tests unitaires (présentation)

- `MonsterLairSheet` : affiche désormais le bouton "Préparer le combat" pour une tanière non vaincue.
- `MonsterLairSheet` : affiche "Vous êtes déjà venu par ici" pour une tanière vaincue (collectée).
- Écran de sélection d'armée : liste correctement les types d'unités disponibles, le bouton "Lancer le combat" est désactivé si aucune unité sélectionnée.
- Écran de résumé : affiche correctement le résultat, les pertes, le butin.
- L'icône de monstre est grisée sur la carte après une victoire.

### Tests d'intégration

- **Scénario victoire** : générer une carte avec une tanière niv 1, recruter une armée suffisante, lancer le combat, vérifier la victoire, le butin attribué, l'état grisé de la case et la persistance après sauvegarde/chargement.
- **Scénario défaite** : envoyer une armée trop faible, vérifier la défaite, l'absence de butin, et que la tanière est intacte (peut être réattaquée).
- **Scénario blessés** : combat équilibré, vérifier qu'une partie des unités tombées sont restaurées dans le stock après le combat.
- **Persistance** : la case collectée et les nouveaux stocks de ressources/perles survivent à un cycle de sauvegarde/chargement.

### Critères de réussite

- `flutter analyze` passe sans erreur.
- `flutter test` passe à 100%.
- Chaque fichier reste sous **150 lignes**.
- Pas d'objet avec une fonction `initialize()` (règle projet).
- Composants de combat conçus pour être réutilisables (le moteur de combat ne dépend pas spécifiquement des monstres : il peut traiter n'importe quels deux camps d'unités).
- L'UI utilise le thème du projet (`lib/presentation/theme/`).
