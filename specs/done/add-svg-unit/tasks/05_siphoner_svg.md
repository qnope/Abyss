# Task 05 — Créer siphoner.svg (Siphonneur)

## Résumé

Créer le fichier SVG du Siphonneur : silhouette élancée et fantomatique en combinaison noire avec circuits bioluminescents violets et masque miroir.

## Couleur dominante

Violet — palette : `#4A148C` (violet profond) → `#7C4DFF` (violet vif) → `#B388FF` (violet clair) + accents `#E040FB` (circuits lumineux).

## Étapes d'implémentation

1. Créer le fichier `assets/icons/units/siphoner.svg`.
2. Structure SVG :
   - `viewBox="0 0 64 64"`
   - `<defs>` : gradients préfixés `siphoner*` + filtre glow `siphonerGlow`
   - `<g filter="url(#siphonerGlow)">` englobant tous les éléments

## Éléments visuels à inclure

- **Corps** : silhouette élancée et androgyne, posture flottante (pieds ne touchant pas le sol)
- **Combinaison moulante** : noire (`#1A1A2E` → `#0D0D1A`) ajustée au corps
- **Circuits bioluminescents** : lignes/traits violets (`#E040FB`) parcourant les bras et le torse, formant un réseau visible
- **Masque miroir** : ovale lisse sans traits, rempli d'un gradient réfléchissant sombre (`#1A1A2E` → `#37474F`)
- **Bracelets holographiques** : anneaux lumineux violets aux poignets projetant des données (petits traits/points)
- **Posture flottante** : espace visible entre les pieds et le bas du viewBox
- **Absence d'arme** : mains ouvertes ou le long du corps, aucun objet offensif

## Fichier cible

`assets/icons/units/siphoner.svg`

## Référence de style

Suivre le pattern de `assets/icons/buildings/ore_extractor.svg`. Ambiance "fantôme numérique".

## Validation

- XML valide, viewBox 0 0 64 64
- Pas de CSS, `<use>`, `<symbol>`
- IDs préfixés `siphoner*`
- Silhouette reconnaissable : figure flottante avec circuits violets et masque miroir
