# Task 01 — Créer scout.svg (Éclaireur)

## Résumé

Créer le fichier SVG de l'Éclaireur : silhouette fine et agile en combinaison de plongée, avec visière bleue luminescente, propulseur dorsal et pose dynamique.

## Couleur dominante

Bleu luminescent — palette : `#0D47A1` (bleu foncé) → `#42A5F5` (bleu moyen) → `#80D8FF` (bleu clair lumineux).

## Étapes d'implémentation

1. Créer le répertoire `assets/icons/units/` s'il n'existe pas.
2. Créer le fichier `assets/icons/units/scout.svg`.
3. Structure SVG :
   - `viewBox="0 0 64 64"`
   - `<defs>` : gradients préfixés `scout*` + filtre glow `scoutGlow`
   - `<g filter="url(#scoutGlow)">` englobant tous les éléments

## Éléments visuels à inclure

- **Corps** : silhouette fine, pose inclinée vers l'avant (mouvement rapide)
- **Combinaison** : noir mat (`#1A1A2E` → `#16213E`) avec liserés bleus
- **Masque intégral** : forme profilée avec visière bleue luminescente (`#80D8FF`, opacity glow)
- **Propulseur dorsal** : forme compacte sur le dos, avec jet lumineux bleu
- **Balises à la ceinture** : 2-3 petits cercles lumineux bleus le long de la taille
- **Bras/jambes** : position dynamique, jambes fléchies, bras le long du corps
- **Effet de vitesse** : lignes ou traits horizontaux derrière la silhouette

## Fichier cible

`assets/icons/units/scout.svg`

## Référence de style

Suivre le pattern de `assets/icons/buildings/ore_extractor.svg` : defs (gradients + filter glow), puis g avec éléments détaillés, commentaires par section.

## Validation

- XML valide, viewBox 0 0 64 64
- Pas de CSS, `<use>`, `<symbol>`
- IDs préfixés `scout*`
- Silhouette reconnaissable : personnage agile avec visière bleue
