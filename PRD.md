# ABYSSES - Product Requirements Document (PRD)

> Version 2.0
> Statut : Draft

---

## 1. Vision

Jeu de strategie tour par tour en single player. Le joueur developpe une base, explore un monde, interagit avec des entites rivales et progresse vers un objectif final.

---

## 2. Etapes de developpement (haut niveau)

Le developpement est decoupe en etapes incrementales. Chaque etape produit une version jouable du jeu et s'appuie sur les etapes precedentes.

### Etape 1 — Noyau minimal

Mettre en place le squelette jouable : un ecran principal, un systeme de ressources de base, quelques batiments constructibles, un bouton de fin de tour et une sauvegarde automatique.

### Etape 2 — Contraintes et progression de base

Introduire des ressources supplementaires et un mecanisme de contrainte centrale qui limite et oriente le developpement de la base.

### Etape 3 — Monde et exploration

Faire sortir le joueur de sa base : introduire une carte decouvrable, un brouillard de guerre, des unites d'exploration et du contenu a decouvrir sur le monde.

### Etape 4 — Configuration de partie

Permettre au joueur de personnaliser son style de depart via plusieurs profils predefinis, et gerer le cycle nouvelle partie / reprise.

### Etape 5 — Dimension militaire

Introduire les unites de combat, les adversaires neutres et le systeme de combat de base.

### Etape 6 — Progression technologique

Ajouter un systeme de recherche permettant au joueur de specialiser sa base et de debloquer de nouvelles capacites.

### Etape 7 — Entites rivales

Peupler le monde avec des entites autonomes qui evoluent en parallele et peuvent interagir avec le joueur.

### Etape 8 — Cooperation

Permettre au joueur de cooperer avec certaines entites et de leur donner des directives.

### Etape 9 — Evenements dynamiques

Introduire des evenements aleatoires pour varier le gameplay d'une partie a l'autre.

### Etape 10 — Unites avancees

Debloquer un tier superieur d'unites accessible via la progression technologique.

### Etape 11 — Progression verticale

Etendre le monde en plusieurs zones successives, avec des points de transition gardes et des conditions pour y acceder.

### Etape 12 — Fin de partie

Conclure l'experience avec un ecran de fin et des statistiques de partie.

### Etape 13 — Equilibrage et montee en charge

Scaler le jeu a sa taille cible et equilibrer l'experience complete.

### Etape 14 — Finition

Polish visuel, sonore et ergonomique, tutoriel et adaptation multi-plateformes.

---

## 3. Principes transverses

- **Jouable a chaque etape** : chaque increment produit un jeu fonctionnel.
- **Choix significatifs** : chaque decision du joueur a un impact visible.
- **Progression visible** : le joueur voit en permanence l'evolution de son monde.
- **Tests obligatoires** : chaque etape est validee par des tests automatises.

---

> Ce PRD est un document vivant. Chaque etape sera detaillee dans un document dedie au moment de son implementation.
