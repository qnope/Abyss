# Task 03 — Créer guardian.svg (Gardien des Abysses)

## Résumé

Créer le fichier SVG du Gardien des Abysses : silhouette massive en exosquelette de corail avec large bouclier convexe et dôme blindé.

## Couleur dominante

Gris-blanc — palette : `#ECEFF1` (blanc corail) → `#B0BEC5` (gris moyen) → `#607D8B` (gris foncé) + accents `#FAFAFA` (reflets corail).

## Étapes d'implémentation

1. Créer le fichier `assets/icons/units/guardian.svg`.
2. Structure SVG :
   - `viewBox="0 0 64 64"`
   - `<defs>` : gradients préfixés `guardian*` + filtre glow `guardianGlow`
   - `<g filter="url(#guardianGlow)">` englobant tous les éléments

## Éléments visuels à inclure

- **Corps** : silhouette très large (presque 2x la carrure normale), occupant une grande partie du viewBox
- **Exosquelette** : plaques épaisses gris-blanc avec texture de corail fossilisé (lignes/rainures)
- **Casque dôme blindé** : forme arrondie sans visière, avec capteurs latéraux (petits cercles ou rectangles sur les côtés)
- **Bouclier convexe** : large forme bombée tenue devant, couvrant une bonne partie du corps, rayures d'impacts
- **Bottes magnétiques** : pieds larges et lourds, ancrés au sol
- **Plaques de corail** : détails de texture sur l'armure (lignes, stries, formes organiques)
- **Marques d'impact** : petites lignes/rayures sur le bouclier

## Fichier cible

`assets/icons/units/guardian.svg`

## Référence de style

Suivre le pattern de `assets/icons/buildings/ore_extractor.svg`. Le Gardien doit paraître massif et immuable.

## Validation

- XML valide, viewBox 0 0 64 64
- Pas de CSS, `<use>`, `<symbol>`
- IDs préfixés `guardian*`
- Silhouette reconnaissable : colosse blindé avec bouclier et armure de corail
