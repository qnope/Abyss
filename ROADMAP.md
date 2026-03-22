# ABYSSES - Roadmap de développement progressif

Principe : **à chaque étape, le joueur peut jouer et s'amuser**. Chaque étape enrichit l'expérience sans casser ce qui existe.

---

## Étape 1 — Le squelette jouable (MVP minimal)

**Objectif** : Le joueur peut produire des ressources et passer des tours.

### Requirements
- **R1.1** : Écran principal avec affichage des 4 ressources de base (Algues, Corail, Minerai, Énergie) et du compteur de tours
- **R1.2** : Le QG est présent par défaut (niveau 1)
- **R1.3** : Construction de bâtiments de production (Ferme d'algues, Mine de corail, Extracteur, Panneau solaire) avec coûts en ressources
- **R1.4** : Production automatique des ressources à chaque tour selon les bâtiments possédés
- **R1.5** : Bouton "Tour suivant" qui déclenche la production et avance le compteur
- **R1.6** : Amélioration des bâtiments (niveaux) pour augmenter la production
- **R1.7** : Le niveau du QG limite le nombre et le niveau max des bâtiments
- **R1.8** : Résumé de fin de tour (ressources gagnées, constructions terminées)
- **R1.9** : Sauvegarde/chargement de la partie (Hive)

**Le joueur peut** : Construire sa base, optimiser sa production, monter ses bâtiments.

---

## Étape 2 — La carte et l'exploration

**Objectif** : Le joueur découvre le monde autour de sa base.

### Requirements
- **R2.1** : Grille 20×20 avec fog of war — seules les cases proches de la base sont visibles
- **R2.2** : Types de terrain sous-marin (récif, plaine, roche, faille) générés aléatoirement
- **R2.3** : Recrutement d'Éclaireurs à la Caserne (nouveau bâtiment)
- **R2.4** : Déplacement des éclaireurs case par case sur la carte
- **R2.5** : L'exploration révèle les cases et leur contenu (vide, ressources, ruines)
- **R2.6** : Découverte de Perles (5ème ressource) via l'exploration de ruines/épaves
- **R2.7** : La base du joueur est positionnée sur la carte

**Le joueur peut** : Explorer la carte, découvrir des trésors, collecter des Perles.

---

## Étape 3 — Création de compte et kit de départ

**Objectif** : Le joueur personnalise son début de partie.

### Requirements
- **R3.1** : Écran d'accueil avec "Nouvelle partie" / "Continuer"
- **R3.2** : Saisie du nom du joueur / nom de la base
- **R3.3** : Choix entre 3 kits de départ avec description détaillée :
  - **Militaire** : QG + Caserne + unités de combat supplémentaires + stock réduit
  - **Économique** : QG + bâtiments de production supplémentaires + stock augmenté
  - **Explorateur** : QG + éclaireurs supplémentaires + vision étendue
- **R3.4** : Le kit choisi initialise correctement la base, les unités et les ressources
- **R3.5** : Possibilité de relancer une nouvelle partie (reset)

**Le joueur peut** : Choisir son style de jeu, recommencer avec une approche différente.

---

## Étape 4 — Le combat

**Objectif** : Le joueur peut se battre et utiliser son armée.

### Requirements
- **R4.1** : Recrutement de Plongeurs soldats et Ingénieurs sous-marins à la Caserne
- **R4.2** : Chaque unité a des stats : PV, attaque, défense, déplacement
- **R4.3** : Des bases de monstres (créatures sous-marines hostiles) sont placées sur la carte
- **R4.4** : Système de combat automatique quand une unité entre sur une case ennemie
- **R4.5** : Résolution de combat basée sur les stats (attaque vs défense, PV)
- **R4.6** : Butin en ressources/Perles après un combat victorieux
- **R4.7** : Rapport de combat détaillé dans le résumé de tour

**Le joueur peut** : Former une armée, combattre des monstres, gagner du butin.

---

## Étape 5 — La technologie

**Objectif** : Le joueur peut progresser et débloquer de nouvelles capacités.

### Requirements
- **R5.1** : Construction du Laboratoire
- **R5.2** : Arbre technologique Militaire (amélioration stats unités, débloque Atelier mécanique)
- **R5.3** : Arbre technologique Économie (amélioration production, réduction coûts)
- **R5.4** : Arbre technologique Exploration (augmentation vision, amélioration éclaireurs)
- **R5.5** : Recherche d'une technologie consomme des ressources + des tours
- **R5.6** : Les technologies avancées coûtent des Perles
- **R5.7** : Prérequis entre technologies dans un même arbre
- **R5.8** : Atelier mécanique débloqué par la tech → recrute Drones, Mini sous-marins, Torpilles

**Le joueur peut** : Choisir une stratégie de progression, débloquer des unités avancées.

---

## Étape 6 — Les factions IA

**Objectif** : Le joueur n'est plus seul — le monde vit autour de lui.

### Requirements
- **R6.1** : 99 factions IA présentes dès le tour 1, cachées par le fog of war
- **R6.2** : Chaque faction a sa propre base, ses ressources et son armée
- **R6.3** : Les factions IA progressent à chaque tour (construction, recrutement, exploration)
- **R6.4** : Découverte des factions en explorant la carte
- **R6.5** : Les factions IA peuvent attaquer le joueur ou entre elles
- **R6.6** : Factions de difficulté variable (faibles en périphérie, fortes au centre/profondeur)
- **R6.7** : Indicateur de relation (hostile, neutre) avec les factions découvertes

**Le joueur peut** : Découvrir des rivaux, être attaqué, planifier ses batailles.

---

## Étape 7 — La diplomatie et les alliances

**Objectif** : Le joueur peut former des alliances et diriger des alliés.

### Requirements
- **R7.1** : Le joueur est automatiquement meneur de son alliance
- **R7.2** : Invitation de factions IA à rejoindre l'alliance (max 10 membres)
- **R7.3** : Système d'humeur/disposition de chaque allié (influencé par les actions du joueur)
- **R7.4** : Ordres aux alliés : attaquer, défendre, envoyer des ressources, explorer
- **R7.5** : Les alliés acceptent ou refusent selon leur humeur
- **R7.6** : Les factions IA non alliées forment aussi des alliances entre elles
- **R7.7** : Vue diplomatie avec la liste des factions connues et leur statut

**Le joueur peut** : Tisser des alliances, donner des ordres, construire une force collective.

---

## Étape 8 — Les événements aléatoires

**Objectif** : Chaque partie est unique grâce à l'imprévisible.

### Requirements
- **R8.1** : Probabilité d'événement à chaque tour (pas systématique)
- **R8.2** : Événements environnementaux négatifs (courant marin, éruption, marée toxique, tempête de pression)
- **R8.3** : Événements de découverte positifs (épave, ruines, créature rare, gisement)
- **R8.4** : Notification visuelle claire de l'événement et de ses conséquences
- **R8.5** : Choix interactifs sur certains événements (ex: combattre ou apprivoiser une créature rare)
- **R8.6** : Équilibrage positif/négatif des événements

**Le joueur peut** : Être surpris, adapter sa stratégie, profiter d'opportunités.

---

## Étape 9 — Les niveaux de profondeur

**Objectif** : Le jeu s'étend verticalement — objectif de fin de partie visible.

### Requirements
- **R9.1** : Trois niveaux : Surface, Profondeur, Noyau (chacun une grille 20×20)
- **R9.2** : Construction de l'Ascenseur abyssal (QG haut niveau + ressources rares) pour accéder au niveau 2
- **R9.3** : Construction du Tunnel de pression pour accéder au niveau 3
- **R9.4** : Boss de monstres gardant le passage entre les niveaux
- **R9.5** : Le nouveau niveau démarre entièrement en fog of war
- **R9.6** : Le joueur conserve sa base du niveau précédent
- **R9.7** : L'énergie solaire ne fonctionne plus en profondeur → géothermie nécessaire
- **R9.8** : Nouvelles ressources et monstres spécifiques à chaque profondeur

**Le joueur peut** : Plonger plus profond, affronter des défis croissants, viser la victoire.

---

## Étape 10 — Condition de victoire et polish

**Objectif** : Le jeu a une fin, et l'expérience est complète.

### Requirements
- **R10.1** : Objectif final au niveau 3 (boss final / bâtiment ultime)
- **R10.2** : Écran de victoire avec statistiques de la partie (tours, unités perdues, ressources collectées, factions vaincues)
- **R10.3** : Condition de défaite (QG détruit → game over)
- **R10.4** : Équilibrage global : partie gagnable en 50-100 tours avec chaque kit
- **R10.5** : Tutoriel / conseils intégrés pour les premières parties
- **R10.6** : Écran de game over avec possibilité de recommencer

**Le joueur peut** : Terminer une partie complète, voir ses stats, recommencer.

---

## Résumé visuel de la progression

| Étape | Le joueur peut... | Nouvelles mécaniques |
|-------|------------------|---------------------|
| 1 | Construire et produire | Ressources, bâtiments, tours |
| 2 | Explorer le monde | Carte, fog of war, éclaireurs |
| 3 | Personnaliser son départ | Kits, nouvelle partie |
| 4 | Se battre | Unités, combat, monstres |
| 5 | Progresser technologiquement | Recherche, arbres tech |
| 6 | Rencontrer des rivaux | Factions IA |
| 7 | Former des alliances | Diplomatie, ordres |
| 8 | Vivre des surprises | Événements aléatoires |
| 9 | Plonger plus profond | Niveaux de profondeur |
| 10 | Gagner la partie | Victoire, stats, polish |
