# Task 02 — Créer harpoonist.svg (Harponneur)

## Résumé

Créer le fichier SVG du Harponneur : combattant imposant avec lance-harpon hydraulique, viseur optique rouge et carrure massive.

## Couleur dominante

Rouge/orange — palette : `#BF360C` (rouge foncé) → `#E65100` (orange brûlé) → `#FF6E40` (orange vif) + accents `#FF1744` (viseur rouge).

## Étapes d'implémentation

1. Créer le fichier `assets/icons/units/harpoonist.svg`.
2. Structure SVG :
   - `viewBox="0 0 64 64"`
   - `<defs>` : gradients préfixés `harpoonist*` + filtre glow `harpoonistGlow`
   - `<g filter="url(#harpoonistGlow)">` englobant tous les éléments

## Éléments visuels à inclure

- **Corps** : silhouette imposante, épaules larges, carrure trapue du haut
- **Combinaison** : tons sombres (`#263238` → `#37474F`) avec renforts orange aux épaules/avant-bras
- **Lance-harpon** : arme massive dans un bras mécanisé, tenu en avant ou à l'épaule
- **Réservoir dorsal** : cylindre sur le dos avec tuyaux reliant au lance-harpon
- **Viseur optique** : cercle rouge lumineux sur un œil (`#FF1744` glow)
- **Harpons de rechange** : 2-3 formes allongées fixées le long de la cuisse
- **Casque ouvert** : partie du visage visible sous le casque

## Fichier cible

`assets/icons/units/harpoonist.svg`

## Référence de style

Suivre le pattern de `assets/icons/buildings/ore_extractor.svg` pour la structure et le niveau de détail.

## Validation

- XML valide, viewBox 0 0 64 64
- Pas de CSS, `<use>`, `<symbol>`
- IDs préfixés `harpoonist*`
- Silhouette reconnaissable : combattant massif avec harpon et viseur rouge
