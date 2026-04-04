# add-svg-unit — Feature Specification

## 1. Feature Overview

Création de 6 fichiers SVG représentant les unités militaires du jeu ABYSSES, décrites dans `Unite.md`. Chaque unité possède une apparence unique et une couleur dominante distinctive. Les SVGs seront placés dans `assets/icons/units/` et devront être compatibles avec `flutter_svg`.

Les 6 unités à illustrer :

| Unité | Couleur dominante | Fichier |
|-------|-------------------|---------|
| Éclaireur | Bleu luminescent | `scout.svg` |
| Harponneur | Rouge/orange | `harpoonist.svg` |
| Gardien des Abysses | Gris-blanc | `guardian.svg` |
| Briseur de Dôme | Orange pulsant | `dome_breaker.svg` |
| Siphonneur | Violet | `siphoner.svg` |
| Saboteur des Courants | Vert | `saboteur.svg` |

## 2. User Stories

### US-1 : Cohérence visuelle avec les assets existants

**En tant que** joueur,
**je veux** que les icônes d'unités s'intègrent visuellement au style du jeu,
**afin de** garder une identité graphique cohérente.

**Critères d'acceptation :**
- Chaque SVG utilise le `viewBox="0 0 64 64"`.
- Les SVGs utilisent des `linearGradient` et/ou `radialGradient` pour les dégradés.
- Les SVGs utilisent un `filter` avec `feGaussianBlur` + `feMerge` pour l'effet de glow bioluminescent (identique au pattern des bâtiments existants).
- Les IDs de gradients/filters sont préfixés par le nom de l'unité pour éviter les collisions (ex: `scoutGrad`, `harpoonistGlow`).

### US-2 : Silhouettes détaillées et reconnaissables

**En tant que** joueur,
**je veux** reconnaître chaque unité d'un coup d'œil grâce à sa silhouette et sa couleur,
**afin de** distinguer rapidement les rôles sur le champ de bataille.

**Critères d'acceptation :**
- Chaque unité est représentée en tant que **silhouette de personnage la plus détaillée possible** dans le format 64x64.
- L'attribut-clé de chaque unité est visible et mis en avant (voir section détails ci-dessous).
- Chaque unité a une **couleur dominante unique** qui la distingue des autres.

### US-3 : Compatibilité flutter_svg

**En tant que** développeur,
**je veux** que les SVGs soient directement utilisables avec `flutter_svg`,
**afin de** les intégrer sans modification.

**Critères d'acceptation :**
- Aucune utilisation de CSS (pas de `<style>`, pas d'attribut `class`).
- Aucune utilisation de `<use>` ou `<symbol>`.
- Uniquement des éléments SVG basiques : `<rect>`, `<circle>`, `<ellipse>`, `<polygon>`, `<polyline>`, `<path>`, `<line>`, `<g>`, `<defs>`, `<linearGradient>`, `<radialGradient>`, `<stop>`, `<filter>`, `<feGaussianBlur>`, `<feMerge>`, `<feMergeNode>`.
- Tous les styles sont en attributs inline (`fill`, `stroke`, `opacity`, etc.).

## 3. Détails visuels par unité

Chaque description est tirée de `Unite.md` et doit guider la création du SVG.

### Éclaireur (`scout.svg`) — Bleu luminescent

Silhouette fine et agile en combinaison de plongée légère noir mat. Masque intégral avec visière luminescente bleue (sonar). Balises lumineuses miniatures à la ceinture. Propulseur dorsal compact. Pose dynamique suggérant le mouvement rapide.

**Éléments-clés :** visière bleue luminescente, propulseur dorsal, silhouette élancée.

### Harponneur (`harpoonist.svg`) — Rouge/orange

Combattant imposant du haut du corps. Bras mécanisé portant un lance-harpon à compression hydraulique relié par des tuyaux à un réservoir dorsal. Combinaison renforcée aux épaules et avant-bras. Viseur optique rouge sur un œil. Harpons de rechange sur la cuisse.

**Éléments-clés :** lance-harpon massif, viseur rouge, carrure imposante.

### Gardien des Abysses (`guardian.svg`) — Gris-blanc

Silhouette massive (presque deux fois la carrure normale). Exosquelette épais recouvert de plaques de corail fossilisé gris-blanc. Casque intégral en dôme blindé avec capteurs latéraux. Large bouclier convexe en alliage de corail. Bottes magnétiques lourdes.

**Éléments-clés :** bouclier large, armure de corail, stature imposante.

### Briseur de Dôme (`dome_breaker.svg`) — Orange pulsant

Technicien trapu en combinaison utilitaire avec poches et modules électroniques. Générateur cylindrique massif sur le dos émettant une lueur orange pulsante (disrupteur de fréquence). Gants amplificateurs avec électrodes. Casque hérissé d'antennes et d'analyseurs.

**Éléments-clés :** générateur dorsal orange, gants avec électrodes, antennes sur le casque.

### Siphonneur (`siphoner.svg`) — Violet

Silhouette élancée et androgyne en combinaison moulante noire avec circuits bioluminescents violets sur bras et torse. Masque lisse miroir noir sans traits. Bracelets-interfaces holographiques aux poignets. Flotte sans mouvement apparent (propulsion silencieuse).

**Éléments-clés :** circuits violets bioluminescents, masque miroir, posture flottante.

### Saboteur des Courants (`saboteur.svg`) — Vert

Petit et ramassé. Combinaison adaptative changeant de teinte. Sacoche ventrale de micro-charges EMP. Lunettes thermiques vertes couvrant la moitié du visage. Mouvements bas et rasants. Pas d'arme visible — outils de sabotage uniquement.

**Éléments-clés :** lunettes thermiques vertes, posture basse/furtive, sacoche d'outils.

## 4. Contraintes techniques

- **Format :** SVG pur, un fichier par unité.
- **ViewBox :** `0 0 64 64` (identique aux assets existants).
- **Emplacement :** `assets/icons/units/`.
- **Nommage :** snake_case en anglais (voir tableau section 1).
- **Compatibilité :** flutter_svg ^2.0.17 (pas de CSS, pas de `<use>`, pas de `<symbol>`).
- **IDs uniques :** tous les IDs de gradients et filtres sont préfixés par le nom de l'unité.

## 5. Testing and Validation

- Chaque fichier SVG est valide et bien formé (XML valide).
- Chaque SVG respecte le viewBox `0 0 64 64`.
- Aucun élément SVG interdit (CSS, `<use>`, `<symbol>`) n'est présent.
- Les SVGs se chargent correctement via `SvgPicture.asset()` dans flutter_svg.
- Vérification visuelle : chaque unité est reconnaissable par sa silhouette et sa couleur dominante.
- Les IDs de gradients/filters ne collisionnent pas entre les fichiers.
