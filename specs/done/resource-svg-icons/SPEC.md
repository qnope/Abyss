# Resource SVG Icons — Feature Specification

## 1. Feature Overview

Créer les 5 icônes SVG des ressources du jeu Abysses, codées à la main, dans un style bioluminescent détaillé avec halos prononcés et dégradés internes. Ces icônes seront utilisées dans la barre de ressources et dans les différents écrans de l'UI (bâtiments, inventaire, etc.).

Les 5 ressources sont :

| Ressource | Couleur principale | Code couleur |
|---|---|---|
| Algues (nourriture) | Vert bioluminescent | `#69F0AE` |
| Corail (construction) | Rose bioluminescent | `#FF6E91` |
| Minerai océanique (métal) | Bleu bioluminescent | `#42A5F5` |
| Énergie | Jaune vif | `#FFD740` |
| Perles (rare) | Cyan pâle / blanc | `#E0F7FA` |

## 2. User Stories

### US-1 : Icônes visibles dans la barre de ressources
**En tant que** joueur,
**je veux** voir une icône distincte pour chaque ressource dans la barre en haut de l'écran,
**afin de** identifier rapidement mes ressources sans lire le texte.

**Critères d'acceptation :**
- Chaque icône est visuellement distincte même à 24px.
- Les couleurs correspondent à la palette définie dans `abyss_colors.dart`.
- Les icônes sont lisibles sur fond sombre (`#0A0E1A` à `#1A2D47`).

### US-2 : Icônes utilisables à différentes tailles
**En tant que** développeur,
**je veux** des icônes SVG vectorielles,
**afin de** les utiliser à différentes tailles (24-32px pour la barre, 48-64px pour les écrans de bâtiments/inventaire) sans perte de qualité.

**Critères d'acceptation :**
- Les SVG ont un viewBox de `0 0 64 64`.
- Les icônes restent lisibles et esthétiques de 24px à 64px.
- Pas de détails trop fins qui disparaissent aux petites tailles.

### US-3 : Style bioluminescent cohérent
**En tant que** joueur,
**je veux** que les icônes aient un style bioluminescent avec des effets de glow et dégradés,
**afin de** renforcer l'immersion dans l'univers sous-marin profond.

**Critères d'acceptation :**
- Chaque icône possède un halo lumineux (glow) dans sa couleur principale.
- Des dégradés internes donnent un aspect lumineux riche.
- Le style est cohérent entre les 5 icônes (même famille visuelle).

## 3. Design détaillé par ressource

### Algues (`algae.svg`)
- **Forme** : Brin d'algue stylisé avec 2-3 feuilles ondulées.
- **Couleur** : Dégradé du vert foncé (`#2E7D32`) vers le vert bioluminescent (`#69F0AE`).
- **Glow** : Halo vert doux autour des feuilles.

### Corail (`coral.svg`)
- **Forme** : Branche de corail ramifiée.
- **Couleur** : Dégradé du rose profond (`#C2185B`) vers le rose bioluminescent (`#FF6E91`).
- **Glow** : Halo rose aux extrémités des branches.

### Minerai océanique (`ore.svg`)
- **Forme** : Cristal géométrique facetté (type gemme hexagonale).
- **Couleur** : Dégradé du bleu profond (`#1565C0`) vers le bleu bioluminescent (`#42A5F5`).
- **Glow** : Halo bleu autour du cristal, reflets lumineux sur les facettes.

### Énergie (`energy.svg`)
- **Forme** : Éclair ou orbe d'énergie.
- **Couleur** : Dégradé du jaune orangé (`#FF8F00`) vers le jaune vif (`#FFD740`).
- **Glow** : Halo jaune rayonnant.

### Perles (`pearl.svg`)
- **Forme** : Perle sphérique avec reflet.
- **Couleur** : Dégradé du cyan pâle (`#B2EBF2`) vers le blanc nacré (`#E0F7FA`).
- **Glow** : Halo blanc/cyan subtil, éclat nacré.

## 4. Spécifications techniques

- **Format** : SVG codé à la main (pas d'outil externe).
- **ViewBox** : `0 0 64 64` pour toutes les icônes.
- **Emplacement** : `assets/icons/resources/`.
- **Effets de glow** : Réalisés via des filtres SVG (`<filter>`, `<feGaussianBlur>`, `<feMerge>`).
- **Dégradés** : Via `<linearGradient>` ou `<radialGradient>` définis dans `<defs>`.
- **Pas de dépendance externe** : SVG pur, pas de polices ou images embarquées.

## 5. Testing and Validation

- **Vérification visuelle** : Chaque icône doit être inspectée à 24px, 48px et 64px sur fond sombre.
- **Validation SVG** : Les fichiers SVG doivent être bien formés (XML valide).
- **Test d'intégration Flutter** : Un widget test vérifie que chaque SVG se charge sans erreur via `flutter_svg` (ou équivalent).
- **Contraste** : Les icônes doivent être clairement distinguables les unes des autres, même pour un utilisateur daltonien (formes distinctes, pas seulement la couleur).
- **Critère de succès** : Les 5 SVG sont présents dans `assets/icons/resources/`, se chargent dans Flutter, et sont visuellement cohérents avec le thème Abyss.
