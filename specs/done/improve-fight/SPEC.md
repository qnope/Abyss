# improve-fight Feature Specification

## 1. Feature Overview

Cette spécification regroupe quatre améliorations du système de combat existant
(`FightMonsterAction` + `ArmySelectionScreen` + `FightEngine`) afin de rendre
la préparation des combats plus ergonomique, le retour des forces plus juste,
et la progression militaire significative.

Les quatre axes :

1. **Sélection des unités via slider + boutons +/-** dans `ArmySelectionScreen`.
2. **Retour des survivants intacts à la base** (en plus des blessés qui
   reviennent déjà aujourd'hui).
3. **Amélioration de la gestion des morts** : limitée au point 2 (les
   survivants intacts rentrent désormais), le calcul existant
   (`CasualtyCalculator` 20-80 % de blessés selon `pctLost`) est conservé tel
   quel.
4. **La technologie militaire affecte les unités** : un bonus d'attaque
   de **+20 % par niveau de recherche militaire** s'applique à toutes les
   unités du joueur en combat.

## 2. User Stories

### US-01 — Sélection des unités avec slider et boutons +/-

**En tant que joueur**, depuis l'écran de préparation du combat
(`ArmySelectionScreen`), je veux pouvoir choisir rapidement combien d'unités
de chaque type envoyer en combat, grâce à un slider, tout en conservant des
boutons + / - pour affiner le choix unité par unité.

Critères d'acceptation :
- Pour chaque type d'unité disponible (stock > 0), une ligne dédiée affiche :
  - L'icône, le nom et le stock disponible.
  - Un slider horizontal allant de `0` à `stock` (pas de 1).
  - Un bouton `-` (décrémente de 1, désactivé à 0).
  - Un bouton `+` (incrémente de 1, désactivé à `stock`).
  - La valeur courante sélectionnée, mise à jour en temps réel.
- Le slider démarre à `0` à l'ouverture de l'écran.
- Le slider et les boutons +/- sont synchronisés (modifier l'un met l'autre
  à jour).
- Si le stock disponible est `1`, le slider est masqué ou désactivé (les
  boutons +/- suffisent).
- Le bouton "Lancer le combat" reste désactivé tant qu'aucune unité n'est
  sélectionnée (comportement actuel).
- L'écran continue d'afficher en haut le `MonsterPreview` de la tanière
  ciblée.

### US-02 — Affichage du total ATK / DEF de la sélection

**En tant que joueur**, dans l'écran de préparation du combat, je veux voir
en temps réel le total d'attaque et de défense de ma sélection, pour pouvoir
le comparer à la difficulté du monstre avant de lancer.

Critères d'acceptation :
- Un encart visible (ex: au-dessus du bouton "Lancer le combat") affiche :
  - **ATK totale** : somme des `atk` de toutes les unités sélectionnées,
    bonus de tech militaire **inclus**.
  - **DEF totale** : somme des `def` de toutes les unités sélectionnées.
- Les valeurs sont mises à jour à chaque changement de la sélection.
- Si aucune unité n'est sélectionnée, les totaux affichent `0`.

### US-03 — Affichage du bonus tech militaire actif

**En tant que joueur**, je veux voir, dans l'écran de préparation du combat,
le bonus d'attaque actif issu de ma recherche militaire, pour comprendre
pourquoi mes unités frappent plus fort.

Critères d'acceptation :
- Un libellé visible affiche par exemple :
  `Bonus militaire : +X% ATK (niveau Y)` où :
  - `X` = `niveau militaire * 20`
  - `Y` = `TechBranchState.researchLevel` de la branche `military`
- Si la branche militaire n'est pas débloquée ou si `researchLevel == 0`,
  le libellé indique `Bonus militaire : aucun` (ou est masqué).
- Le bonus affiché est cohérent avec celui réellement appliqué dans le moteur
  de combat (US-05).

### US-04 — Retour des survivants intacts à la base

**En tant que joueur**, après un combat, je veux que mes unités survivantes
(intactes ET blessées) rejoignent immédiatement le stock de ma base, et que
seules les unités définitivement mortes soient retirées.

Critères d'acceptation :
- À la fin de `FightMonsterAction.execute`, pour chaque unité envoyée en
  combat :
  - **Survivants intacts** (HP > 0 à la fin du combat) : réintégrés
    immédiatement dans `player.units[type].count`.
  - **Blessés** (issus de `CasualtySplit.wounded`) : réintégrés immédiatement
    (déjà géré par `FightMonsterHelpers.restoreWounded`).
  - **Morts** (issus de `CasualtySplit.dead`) : NON réintégrés, perdus
    définitivement.
- L'invariant suivant doit être vrai après un combat :
  `stock_final_par_type == stock_initial_par_type - dead_par_type`
- Le `FightMonsterResult` renvoyé continue d'exposer séparément `sent`,
  `survivorsIntact`, `wounded` et `dead` (déjà le cas).
- Le retour est immédiat (pas de tours de voyage retour) — pas de changement
  de timing par rapport au comportement actuel pour les blessés.

### US-05 — La technologie militaire augmente l'attaque des unités

**En tant que joueur**, plus j'investis dans la branche militaire de
recherche, plus mes unités frappent fort en combat.

Règle :
- Pour chaque niveau de `TechBranchState.researchLevel` de la branche
  `TechBranch.military` du joueur, **chaque unité du joueur** envoyée au
  combat reçoit un bonus d'attaque de **+20 %**, **multiplicatif sur la
  stat de base**.
- Formule : `atk_finale = round(atk_base * (1 + 0.20 * researchLevel))`
- Le bonus s'applique à **toutes** les unités du joueur (humaines et
  machines), quel que soit leur rôle (combat, exploration, ingénierie).
- Le bonus s'applique uniquement au joueur, pas aux monstres.
- Le bonus n'affecte que la stat `atk` ; `def` et `hp` restent inchangés.
- Si `researchLevel == 0` ou si la branche militaire n'est pas débloquée,
  le bonus est `0` (stats brutes).

Critères d'acceptation :
- Les `Combatant` créés par `CombatantBuilder.playerCombatantsFrom` reçoivent
  une `atk` correctement majorée par le niveau militaire du joueur.
- Le calcul de l'arrondi est cohérent (`round`) et déterministe.
- Le bonus est visible :
  - Indirectement, via les dégâts plus élevés en combat.
  - Directement, via l'affichage de US-02 (ATK totale incluant bonus) et
    US-03 (libellé du bonus).
- Aucune autre branche de recherche (`resources`, `explorer`) ne doit
  modifier les stats de combat dans le cadre de cette spec.

## 3. Testing and Validation

### Tests unitaires

- **Sélecteur d'unités (UI)** : tests de widget pour `ArmySelectionScreen`
  vérifiant que :
  - Slider et boutons +/- sont synchronisés.
  - Le bouton + se désactive à `stock`, le bouton - à `0`.
  - Le slider démarre à `0`.
  - Le bouton "Lancer le combat" est désactivé tant que `total == 0`.

- **Total ATK/DEF de la sélection (UI)** : tests de widget vérifiant que la
  somme affichée se met à jour à chaque changement, et inclut le bonus
  militaire.

- **Retour des survivants** : tests unitaires sur `FightMonsterAction`
  (avec un `Random` déterministe et un combat scénarisé) vérifiant que :
  - Les survivants intacts retournent au stock.
  - Les blessés retournent au stock (régression).
  - Les morts NE retournent PAS au stock.
  - L'invariant `stock_final == stock_initial - dead` est respecté pour
    chaque type d'unité.

- **Bonus tech militaire** : tests unitaires sur `CombatantBuilder` (ou
  équivalent) vérifiant que :
  - À `researchLevel = 0`, l'`atk` du combattant est égale à `UnitStats.atk`.
  - À `researchLevel = 3`, l'`atk` est `round(UnitStats.atk * 1.6)`.
  - À `researchLevel = 5`, l'`atk` est `round(UnitStats.atk * 2.0)`.
  - Aucun bonus n'est appliqué aux `monsterCombatantsFrom`.
  - Aucun bonus n'est appliqué si la branche militaire n'est pas débloquée.

### Tests d'intégration

- **Combat complet avec tech militaire** : créer un `Game` avec un joueur
  ayant un `researchLevel` militaire de 3, lancer un `FightMonsterAction`
  contre une tanière de difficulté connue, et vérifier que les dégâts
  infligés sont supérieurs à ceux d'un joueur sans tech militaire (avec un
  `Random` déterministe).

- **Régression** : les tests d'intégration existants
  (`fight_monster_action_test`, `fight_summary_*_test`, persistance) doivent
  continuer de passer.

### Critères de succès

- `flutter analyze` ne renvoie aucune erreur ni avertissement nouveau.
- `flutter test` passe à 100 %.
- Aucun fichier ne dépasse 150 lignes (règle CLAUDE.md).
- L'architecture en 5 couches est respectée : la logique de bonus tech
  militaire vit dans la couche `domain/`, l'affichage du bonus dans
  `presentation/`.
- Les composants UI (slider+/-, encart ATK/DEF, libellé bonus) sont
  réutilisables (extraits en widgets dédiés si besoin).
