# icon-army - Feature Specification

## 1. Feature Overview

Creer les icones SVG pour deux nouveaux batiments du jeu ABYSSES :
- **Caserne** : batiment de recrutement des unites humaines (eclaireur, plongeur soldat, ingenieur sous-marin)
- **Laboratoire** : batiment de recherche technologique (3 arbres : militaire, economie, exploration)

Les icones doivent etre coherentes avec les 5 icones existantes (QG, ferme d'algues, mine de corail, extracteur de minerai, panneau solaire) et suivre le meme style graphique.

Scope : fichiers SVG uniquement, pas d'integration dans le code.

## 2. User Stories

**US-01 : Icone de la Caserne**
En tant que joueur, je vois une icone reconnaissable pour la caserne dans la liste des batiments.

Design :
- **Ambiance** : bunker militaire sous-marin, structure fortifiee avec blindage
- **Couleur dominante** : orange/ambre (gradient lineaire, du sombre au clair)
- **Elements visuels attendus** :
  - Structure fortifiee type bunker avec murs epais
  - Creneaux ou meurtieres evoquant la defense
  - Hublots lumineux (coherent avec le style des autres icones)
  - Plateforme de base (comme les autres batiments)
- **Style graphique** : gradients lineaires, filtre glow, traits fins (stroke), meme technique SVG que les icones existantes

Criteres d'acceptation :
- Fichier SVG au format 64x64 (viewBox="0 0 64 64")
- Place dans `assets/icons/buildings/barracks.svg`
- Utilise des gradients lineaires et un filtre glow comme les icones existantes
- La palette orange/ambre est distincte des couleurs existantes (violet, vert, rose, bleu, jaune)
- L'icone est lisible a petite taille (20-24px) comme a grande taille (64px)

**US-02 : Icone du Laboratoire**
En tant que joueur, je vois une icone reconnaissable pour le laboratoire dans la liste des batiments.

Design :
- **Ambiance** : laboratoire high-tech sous-marin, dome vitre avec equipements scientifiques
- **Couleur dominante** : vert (gradient lineaire, du sombre au clair)
- **Elements visuels attendus** :
  - Dome vitre ou structure transparente
  - Fioles, ecrans holographiques ou instruments scientifiques
  - Lumiere cyan/verte evoquant la science
  - Plateforme de base (comme les autres batiments)
- **Style graphique** : gradients lineaires, filtre glow, traits fins (stroke), meme technique SVG que les icones existantes

Criteres d'acceptation :
- Fichier SVG au format 64x64 (viewBox="0 0 64 64")
- Place dans `assets/icons/buildings/laboratory.svg`
- Utilise des gradients lineaires et un filtre glow comme les icones existantes
- La palette verte est distincte des couleurs existantes (violet, vert algue, rose, bleu, jaune)
- L'icone est lisible a petite taille (20-24px) comme a grande taille (64px)

## 3. Testing and Validation

- **Verification visuelle** : les icones sont coherentes avec le style existant quand affichees cote a cote
- **Verification technique** : les SVG sont valides et s'affichent correctement via flutter_svg
- **Lisibilite** : les icones restent reconnaissables aux tailles 16px, 24px, 40px et 64px (tailles utilisees dans l'app)
- **Palette** : les couleurs orange/ambre (caserne) et vert (laboratoire) sont distinctes des 5 couleurs existantes
- **Structure SVG** : memes conventions que les fichiers existants (defs pour gradients/filtres, groupe avec filtre glow, commentaires pour les sections)
