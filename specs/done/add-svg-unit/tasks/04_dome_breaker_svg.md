# Task 04 — Créer dome_breaker.svg (Briseur de Dôme)

## Résumé

Créer le fichier SVG du Briseur de Dôme : technicien trapu avec générateur dorsal orange pulsant, gants amplificateurs et casque à antennes.

## Couleur dominante

Orange pulsant — palette : `#E65100` (orange profond) → `#FF9100` (orange vif) → `#FFAB40` (orange clair) + accents `#FFD180` (lueur pulsante).

## Étapes d'implémentation

1. Créer le fichier `assets/icons/units/dome_breaker.svg`.
2. Structure SVG :
   - `viewBox="0 0 64 64"`
   - `<defs>` : gradients préfixés `domeBreaker*` + filtre glow `domeBreakerGlow`
   - `<g filter="url(#domeBreakerGlow)">` englobant tous les éléments

## Éléments visuels à inclure

- **Corps** : silhouette trapue et compacte, posture de technicien
- **Combinaison utilitaire** : tons sombres (`#37474F` → `#455A64`) avec poches et modules visibles (petits rectangles)
- **Générateur dorsal** : cylindre massif sur le dos avec lueur orange pulsante (radialGradient orange + glow)
- **Gants amplificateurs** : mains visibles avec électrodes aux doigts (petits traits lumineux orange)
- **Câbles** : lignes reliant les gants au générateur dorsal le long des bras
- **Casque à antennes** : casque avec 2-3 antennes/tiges dépassant vers le haut + petits analyseurs
- **Arcs d'énergie** : petits éclairs/arcs orange entre les doigts ou autour des gants

## Fichier cible

`assets/icons/units/dome_breaker.svg`

## Référence de style

Suivre le pattern de `assets/icons/buildings/ore_extractor.svg`. Ambiance "électricien de l'extrême".

## Validation

- XML valide, viewBox 0 0 64 64
- Pas de CSS, `<use>`, `<symbol>`
- IDs préfixés `domeBreaker*`
- Silhouette reconnaissable : technicien trapu avec générateur orange et antennes
