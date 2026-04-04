# Task 06 — Créer saboteur.svg (Saboteur des Courants)

## Résumé

Créer le fichier SVG du Saboteur des Courants : silhouette petite et furtive avec lunettes thermiques vertes, posture basse et sacoche d'outils.

## Couleur dominante

Vert — palette : `#1B5E20` (vert profond) → `#4CAF50` (vert moyen) → `#69F0AE` (vert lumineux) + accents `#B9F6CA` (lunettes thermiques).

## Étapes d'implémentation

1. Créer le fichier `assets/icons/units/saboteur.svg`.
2. Structure SVG :
   - `viewBox="0 0 64 64"`
   - `<defs>` : gradients préfixés `saboteur*` + filtre glow `saboteurGlow`
   - `<g filter="url(#saboteurGlow)">` englobant tous les éléments

## Éléments visuels à inclure

- **Corps** : silhouette petite et ramassée, posture basse et furtive (accroupi ou penché)
- **Combinaison adaptative** : tons changeants — base sombre (`#263238`) avec zones de couleur variable (gris roche, bleu profond, vert algue) suggérant le camouflage
- **Lunettes thermiques** : larges lunettes vertes couvrant la moitié du visage (`#69F0AE` glow), l'élément le plus lumineux et reconnaissable
- **Sacoche ventrale** : forme rectangulaire/arrondie sur le ventre avec micro-charges EMP visibles (petits cercles/rectangles)
- **Pas d'arme** : uniquement des outils de sabotage à la ceinture (petites formes utilitaires)
- **Posture rasante** : le personnage est proche du sol, mains potentiellement au sol
- **Crustacés robotiques** : 1-2 petites formes de crabes mécaniques près de la sacoche ou au sol (optionnel mais distinctif)

## Fichier cible

`assets/icons/units/saboteur.svg`

## Référence de style

Suivre le pattern de `assets/icons/buildings/ore_extractor.svg`. Ambiance "rat des profondeurs furtif".

## Validation

- XML valide, viewBox 0 0 64 64
- Pas de CSS, `<use>`, `<symbol>`
- IDs préfixés `saboteur*`
- Silhouette reconnaissable : figure accroupie avec lunettes vertes lumineuses
