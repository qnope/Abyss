# ABYSSES - Roadmap de Requirements Progressif

> Principe : à chaque étape, le joueur a un jeu jouable et amusant.
> Chaque étape enrichit l'expérience sans casser ce qui existe.

---

## Étape 1 — Le Noyau Minimal (le joueur peut "jouer")

**Objectif** : Un écran de jeu avec des ressources, des bâtiments, et un bouton "Tour suivant".

### Requirements :
1. **Écran principal** avec affichage du numéro de tour
2. **3 ressources de base** : Algues, Corail, Minerai océanique
   - Affichées en permanence dans une barre de ressources
   - Production automatique à chaque tour
3. **Le QG** (niveau 1) — toujours présent
4. **3 bâtiments constructibles** : Ferme d'algues, Mine de corail, Extracteur de minerai
   - Construction coûte des ressources
   - Construction prend 1 tour
   - Amélioration possible (niveaux 1-3)
   - L'amélioration augmente la production
5. **Bouton "Tour suivant"**
   - Production des ressources
   - Avancement des constructions en cours
   - Résumé du tour affiché au joueur
6. **Sauvegarde automatique** via Hive

**Le joueur peut** : construire, améliorer, gérer ses ressources, voir sa base grandir tour après tour.

---

## Étape 2 — Énergie & Contraintes

**Objectif** : Introduire l'Énergie comme 4ème ressource et le concept de contrainte du QG.

### Requirements :
1. **Ressource Énergie** + Panneau solaire (bâtiment)
2. **Niveau du QG améliorable** (1-5)
   - Le niveau du QG limite le nombre max de bâtiments
   - Le niveau du QG limite le niveau max des autres bâtiments
3. **Coûts de construction diversifiés** (certains bâtiments coûtent de l'énergie)
4. **Amélioration du QG** : coût élevé, prend plusieurs tours

**Le joueur peut** : planifier sa progression, choisir quel bâtiment prioriser, gérer la contrainte d'énergie.

---

## Étape 3 — Carte & Exploration

**Objectif** : Le joueur sort de sa base et découvre le monde.

### Requirements :
1. **Carte en grille 20×20** avec fog of war
2. **Types de terrain** : récif, plaine, roche, faille
3. **Base du joueur placée** sur la carte
4. **Unité Éclaireur** (recrutée à la Caserne)
   - La Caserne comme nouveau bâtiment constructible
   - Déplacement de 1 case par tour
   - Révèle les cases adjacentes
5. **Cases avec contenu** : vide, ressources bonus, ruines (donnent des ressources)
6. **Navigation sur la carte** : zoom, déplacement de la caméra

**Le joueur peut** : explorer la carte, découvrir des trésors, envoyer ses éclaireurs en expédition.

---

## Étape 4 — Kit de Départ & Nouvelle Partie

**Objectif** : Personnaliser le début de partie et permettre le rejeu.

### Requirements :
1. **Écran de choix du kit de départ** (Militaire, Économique, Explorateur)
   - Chaque kit donne des bâtiments/unités/ressources différents
   - Description claire de chaque kit
2. **Écran "Nouvelle partie"** depuis le menu principal
3. **Gestion de la sauvegarde** : sauvegarder / charger / nouvelle partie
4. **Ressource Perles** : trouvée uniquement par exploration (cases spéciales sur la carte)

**Le joueur peut** : recommencer avec des stratégies différentes, choisir son style de jeu.

---

## Étape 5 — Unités de Combat & Monstres

**Objectif** : Introduire le combat.

### Requirements :
1. **Unités de combat** : Plongeur soldat (via Caserne)
   - Stats : PV, attaque, défense, déplacement
   - Recrutement coûte ressources + tours
2. **Bases de monstres** sur la carte (cases spéciales)
   - Gardent des trésors (ressources, Perles)
   - Différents niveaux de difficulté
3. **Système de combat simple**
   - Résolution automatique au tour suivant
   - Basé sur attaque vs défense + PV
   - Résultat affiché dans le résumé du tour
4. **Butin** après victoire

**Le joueur peut** : former une armée, attaquer des monstres, gagner du butin.

---

## Étape 6 — Technologies

**Objectif** : Donner de la profondeur stratégique via l'arbre de recherche.

### Requirements :
1. **Laboratoire** comme nouveau bâtiment
2. **Arbre technologique Économie** (5-6 techs)
   - Améliore la production, réduit les coûts
3. **Arbre technologique Militaire** (5-6 techs)
   - Améliore les stats des unités, débloque l'Ingénieur sous-marin
4. **Arbre technologique Exploration** (5-6 techs)
   - Augmente la vision, améliore la vitesse des éclaireurs
5. **Recherche coûte ressources + tours**
6. **Certaines techs avancées coûtent des Perles**

**Le joueur peut** : orienter sa stratégie, spécialiser sa base, débloquer de nouvelles capacités.

---

## Étape 7 — Factions IA

**Objectif** : Le joueur n'est plus seul — le monde vit.

### Requirements :
1. **Factions IA** présentes sur la carte (commencer par 10-20, pas 99 immédiatement)
   - Chaque faction a une base visible une fois découverte
   - Les factions progressent chaque tour (simplifiée au départ)
2. **Diplomatie basique** : Neutre / Hostile
   - Les factions hostiles peuvent attaquer le joueur
3. **Combat PvE contre factions** (même système que les monstres)
4. **Défense de la base** : les unités restées à la base défendent

**Le joueur peut** : découvrir des factions, être attaqué, devoir défendre sa base, planifier offensivement.

---

## Étape 8 — Alliances

**Objectif** : Le joueur peut s'allier pour être plus fort.

### Requirements :
1. **Système d'alliance** : le joueur est meneur
   - Inviter des factions IA (max 10 dans l'alliance)
   - Les factions peuvent accepter ou refuser
2. **Humeur/disposition des alliés** (visible)
   - Dépend des actions passées du joueur
3. **Ordres aux alliés** : attaquer, défendre, envoyer ressources, explorer
   - L'allié peut accepter ou refuser selon son humeur
4. **Diplomatie étendue** : Neutre / Allié / Hostile

**Le joueur peut** : construire des alliances, coordonner des attaques, gérer la diplomatie.

---

## Étape 9 — Événements Aléatoires

**Objectif** : Chaque partie est unique.

### Requirements :
1. **Événements négatifs** : courant marin, éruption, marée toxique, tempête de pression
2. **Événements positifs** : épave ancienne, ruines mystérieuses, créature rare, gisement caché
3. **Probabilité d'événement** à chaque tour (pas systématique)
4. **Notification claire** de l'événement et de ses conséquences
5. **Créatures rares apprivoisables** (unité spéciale bonus)

**Le joueur peut** : réagir aux aléas, profiter des opportunités, adapter sa stratégie.

---

## Étape 10 — Unités Avancées (Machines)

**Objectif** : Débloquer le tier supérieur d'unités.

### Requirements :
1. **Atelier mécanique** (bâtiment débloqué par technologie militaire avancée)
2. **Drone de reconnaissance** : exploration longue distance
3. **Mini sous-marin** : combat moyen, mobilité élevée
4. **Torpille automatique** : dégâts élevés, usage unique
5. **Coûts en Minerai + Énergie** pour les machines

**Le joueur peut** : constituer une armée avancée, explorer plus efficacement, préparer l'assaut final.

---

## Étape 11 — Niveaux de Profondeur

**Objectif** : Le monde s'agrandit — la victoire est en vue.

### Requirements :
1. **Niveau 2 — Profondeur** : nouvelle grille 20×20
   - Ascenseur abyssal (bâtiment spécial) requis pour y accéder
   - Boss de monstres à vaincre pour ouvrir le passage
   - Énergie solaire ne fonctionne plus → Géothermie comme nouvelle source d'énergie
   - Nouvelles ressources ou variantes
2. **Niveau 3 — Noyau** : grille 20×20 finale
   - Tunnel de pression requis
   - Boss final
   - Environnement extrême
3. **Navigation entre niveaux** (la base du niveau précédent est conservée)
4. **Condition de victoire** : conquérir l'objectif au niveau 3

**Le joueur peut** : descendre dans les profondeurs, affronter des défis croissants, terminer le jeu.

---

## Étape 12 — Écran de Victoire & Statistiques

**Objectif** : Conclure l'expérience.

### Requirements :
1. **Écran de victoire** avec animation
2. **Statistiques de fin de partie** :
   - Nombre de tours
   - Ressources collectées
   - Unités recrutées / perdues
   - Bâtiments construits
   - Technologies recherchées
   - Factions vaincues / alliées
3. **Score final** calculé
4. **Option "Rejouer"** renvoyant au choix du kit

**Le joueur peut** : voir son accomplissement, comparer ses parties, rejouer pour améliorer son score.

---

## Étape 13 — Équilibrage & Scaling à 99 Factions

**Objectif** : L'expérience complète telle que décrite dans ABYSS.md.

### Requirements :
1. **99 factions IA** sur la carte
2. **IA améliorée** : construction, recrutement, exploration, diplomatie, alliances entre IA
3. **Équilibrage** : chaque kit permet de gagner en 50-100 tours
4. **Événements spécifiques par niveau de profondeur**
5. **Difficulté progressive naturelle**

---

## Étape 14 — Polish & Assets

**Objectif** : Le jeu est beau et agréable à utiliser.

### Requirements :
1. **Assets graphiques** sous-marins (sprites, tiles, UI)
2. **Animations** de construction, combat, exploration
3. **Sons et musique** d'ambiance
4. **Tutoriel intégré** pour les premiers tours
5. **Responsive** : iOS, Android, Web

---

## Résumé de la Progression Joueur

| Étape | Le joueur peut... |
|-------|-------------------|
| 1 | Construire, produire, gérer des ressources |
| 2 | Planifier avec des contraintes (QG, énergie) |
| 3 | Explorer une carte, découvrir des trésors |
| 4 | Choisir son style, recommencer différemment |
| 5 | Combattre des monstres, gagner du butin |
| 6 | Rechercher des technologies, se spécialiser |
| 7 | Interagir avec des factions IA |
| 8 | Former des alliances, coordonner |
| 9 | Réagir à des événements aléatoires |
| 10 | Utiliser des machines avancées |
| 11 | Descendre dans les profondeurs, gagner |
| 12 | Voir ses stats, rejouer |
| 13 | Jouer l'expérience complète équilibrée |
| 14 | Profiter d'un jeu poli et beau |
