# SVG Terrain — Feature Specification

## 1. Feature Overview

Création de 12 fichiers SVG illustratifs pour le rendu visuel de la carte 20×20 du jeu ABYSSES. Ces assets constituent la couche graphique de l'onglet "Carte" (Étape 3 du roadmap).

Les SVG suivent un style **détaillé illustratif** : dégradés riches, textures complexes, effets de lumière bioluminescente via filtres SVG (`feGaussianBlur`, `feColorMatrix`). La palette de base est celle de `abyss_colors.dart`, enrichie de teintes dérivées (plus claires/sombres) pour les dégradés et textures.

**Paramètres techniques** :
- ViewBox : `0 0 48 48` (correspondance 1:1 avec la taille de case Flutter)
- Format : SVG 1.1 valide
- Pas de texte embarqué (tout en paths/shapes)
- Pas de dépendances externes (images, fonts)
- Les variantes visuelles (rotation, mirror) seront gérées côté Flutter, pas par des fichiers SVG distincts

---

## 2. User Stories

### US-1 : En tant que joueur, je vois des tuiles de terrain distinctes et reconnaissables

**Acceptance Criteria** :
- Chaque type de terrain (récif, plaine, roche, faille) est visuellement unique et identifiable d'un coup d'œil
- Les tuiles fonctionnent en juxtaposition sans bordure visible (rendu seamless sur grille 20×20)
- Le fond `abyssBlack (#0A0E1A)` transparaît à travers les terrains semi-transparents (récif, plaine)
- Les terrains opaques (roche, faille) se distinguent clairement comme obstacles/zones spéciales

### US-2 : En tant que joueur, je distingue les contenus de case (ressources, ruines, monstres)

**Acceptance Criteria** :
- Les 5 marqueurs de contenu sont superposables sur n'importe quelle tuile de terrain sans conflit visuel
- La difficulté des monstres est identifiable par un double codage : couleur (vert/orange/rouge) ET étoiles (1/2/3)
- Les icônes de contenu sont lisibles à la taille par défaut (48×48) et restent reconnaissables au zoom minimum

### US-3 : En tant que joueur, je repère instantanément ma base et les factions

**Acceptance Criteria** :
- La base du joueur est l'élément visuellement le plus dominant de la grille (bioluminescence cyan intense)
- Les factions neutres et hostiles sont visuellement distinctes entre elles et de la base joueur
- Les factions hostiles communiquent un sentiment de menace par leur design

---

## 3. Assets à créer

### 3.1 Tuiles de terrain — `assets/icons/terrain/`

#### `reef.svg` — Récif corallien

**Description visuelle détaillée** :

Fond semi-transparent laissant transparaître le noir abyssal. Au premier plan, un ensemble de formations coralliennes stylisées occupant environ 60-70% de la surface de la tuile.

- **Couche de fond** : Rectangle plein utilisant `reefPink (#FF6E91)` à 40% d'opacité (valeur hex `#66FF6E91`). Ce fond rosé translucide crée l'identité chromatique du récif tout en laissant percevoir les profondeurs sombres.

- **Formations coralliennes principales** : Deux à trois branches de corail montant depuis le bord inférieur de la tuile. Chaque branche est constituée de formes organiques arrondies et ramifiées, rappelant du corail cerveau (Diploria) ou du corail digité (Acropora). Les branches utilisent un dégradé radial allant de `coralPink (#FF6E91)` au centre vers un rose plus sombre `#CC5577` aux extrémités. Les silhouettes sont irrégulières, avec des bords ondulés et des ramifications asymétriques.

- **Corail secondaire** : Petites excroissances coralliennes au sol (bord inférieur), plus basses et arrondies, utilisant un rose plus profond `#D45A7A`. Elles remplissent l'espace entre les grandes branches pour enrichir la texture.

- **Particules en suspension** : 4 à 6 petits cercles de 1-1.5px de rayon, dispersés dans la partie supérieure de la tuile. Couleur `biolumPink (#FF80AB)` à 30-50% d'opacité. Ils simulent du plancton ou des particules organiques flottant autour du récif.

- **Lueur bioluminescente** : Un filtre SVG `feGaussianBlur` (stdDeviation=2) appliqué sur un cercle centré au milieu de la plus grande formation corallienne. Couleur `biolumPink (#FF80AB)` à 20% d'opacité. Cet effet crée un léger halo rosé autour du corail, suggérant une activité biologique.

- **Texture de sol** : Quelques lignes ondulées très fines (stroke-width 0.3-0.5) au bas de la tuile, en `#CC5577` à 20% d'opacité, simulant des rides dans le sable sous le corail.

---

#### `plain.svg` — Plaine sous-marine

**Description visuelle détaillée** :

La tuile la plus ouverte et aérée de la palette. Elle représente le fond océanique dégagé, avec une sensation d'espace et de passage libre.

- **Couche de fond** : Rectangle utilisant `plainBlue (#42A5F5)` à 40% d'opacité (valeur hex `#6642A5F5`). Ce bleu translucide crée un contraste clair avec les zones de récif rosées, communiquant visuellement "zone de passage".

- **Sable fin** : La moitié inférieure de la tuile est occupée par un sol sableux. Celui-ci utilise un dégradé linéaire vertical allant de `#42A5F5` à 15% d'opacité (haut du sol) vers `#2E7BC8` à 25% d'opacité (bas de la tuile). Des points très fins (rayon 0.3-0.5px) dispersés aléatoirement simulent les grains de sable, en `#5BB8FF` à 20% d'opacité.

- **Rides de courant** : 2 à 3 lignes ondulées très subtiles traversant horizontalement la partie inférieure de la tuile (zone de sable). Stroke-width 0.4, couleur `#5BB8FF` à 15% d'opacité. Elles suggèrent le mouvement lent de l'eau sur le fond.

- **Algues flottantes** : 2 à 3 filaments d'algue verts montant du sol vers le haut. Chaque algue est un path courbe en S, de 8-15px de haut, avec un stroke de 0.8-1px. Couleur : dégradé le long du path allant de `algaeGreen (#69F0AE)` à 60% d'opacité à la base vers `#69F0AE` à 20% d'opacité en pointe. Les algues ondulent légèrement, donnant une impression de courant.

- **Particules de plancton** : 3 à 5 points minuscules (rayon 0.5-0.8px) dans la moitié supérieure (zone d'eau libre), en `biolumTeal (#1DE9B6)` à 20-30% d'opacité. Ils renforcent la sensation d'un milieu aquatique vivant.

- **Absence de lueur filtrée** : Pas de filtre SVG glow sur cette tuile. La plaine est calme, sans activité bioluminescente marquée. C'est le "négatif visuel" qui met en valeur les autres terrains.

---

#### `rock.svg` — Bloc rocheux

**Description visuelle détaillée** :

Tuile entièrement opaque représentant un mur de roche impassable. L'atmosphère est sombre, dense et minérale.

- **Couche de fond** : Rectangle plein en `rockGray (#4A5568)` à 100% d'opacité. Aucune transparence — la roche bloque complètement la vue des profondeurs.

- **Masse rocheuse principale** : Un polygone irrégulier occupant 80-90% de la tuile, centré. Ses contours sont anguleux et brisés, avec 8 à 12 sommets formant une silhouette de bloc massif. La roche utilise un dégradé linéaire diagonal (du coin haut-gauche au coin bas-droit) allant de `#5A6678` (face éclairée par l'ambiance) à `#3A4558` (face dans l'ombre). Cela donne du volume au bloc.

- **Fissures et veines** : 3 à 5 lignes brisées traversant la surface de la roche. Chaque fissure est un path de 2 à 4 segments droits formant une ligne en zigzag. Stroke-width 0.5-0.8, couleur `#2D3748` (plus sombre que la roche). Une fissure principale part du quart supérieur gauche et descend vers le tiers inférieur droit. Les fissures secondaires sont plus courtes et partent de la fissure principale ou des bords de la roche.

- **Reflets minéraux** : 2 à 3 petites zones de brillance (ellipses de 2-3px) sur les faces supérieures du bloc. Couleur `#6B7C8F` à 60% d'opacité. Elles simulent des inclusions minérales reflétant la faible lumière ambiante.

- **Sédiments au pied** : Au bord inférieur de la tuile, une bande de 4-6px de haut composée de petits débris anguleux (triangles de 1-2px) en `#3A4558`. Ils simulent les éboulis au pied du bloc rocheux.

- **Micro-organismes** : 1 à 2 petites taches rondes (rayon 1-1.5px) de couleur `#5A6678` à 50% d'opacité sur la surface de la roche, simulant des lichens ou des dépôts biologiques marins.

- **Ombrage périmétrique** : Une bordure intérieure très subtile de 1-2px utilisant `#2D3748` à 40% d'opacité, créant un effet d'encaissement et de profondeur. Le bloc semble encastré dans la grille.

---

#### `fault.svg` — Faille abyssale

**Description visuelle détaillée** :

Tuile opaque spectaculaire représentant une fissure dans le plancher océanique, avec de la lave ou de l'énergie volcanique visible à l'intérieur. C'est la tuile la plus dramatique visuellement.

- **Couche de fond** : Rectangle plein en `faultBlack (#1A1A2E)` à 100% d'opacité. Noir profond violacé, encore plus sombre que l'abyssBlack standard, communiquant un danger immédiat.

- **Fissure centrale** : Un path irrégulier en zigzag traversant la tuile approximativement du tiers supérieur au tiers inférieur (ou d'un bord à l'autre en diagonale). La fissure fait 3-6px de large, avec des bords dentelés et asymétriques. L'intérieur de la fissure utilise un dégradé linéaire le long de son axe : au centre le plus profond, un rouge-orange vif `#FF4500` transitionnant vers `error (#FF5252)` puis vers `#FF8A65` aux bords. Cela simule la roche en fusion visible dans les profondeurs de la faille.

- **Lueur volcanique** : Un filtre SVG combinant `feGaussianBlur` (stdDeviation=3) et `feColorMatrix` appliqué sur un path épousant la fissure. Couleur source `#FF5252` à 40% d'opacité. Le halo rouge-orangé déborde de 4-6px de chaque côté de la fissure, illuminant la roche environnante et créant un contraste dramatique avec le fond noir.

- **Roche craquelée environnante** : Le fond `#1A1A2E` est parcouru de fissures secondaires plus fines (stroke-width 0.3-0.5) rayonnant depuis la fissure principale. 4 à 6 craquelures en `#2A1A3E` (noir violacé légèrement plus clair), s'étendant sur 5-10px depuis la faille centrale. Elles montrent la fracturation progressive de la croûte océanique.

- **Particules en suspension** : 5 à 8 petits cercles de tailles variées (rayon 0.5-1.5px) flottant au-dessus de la fissure, dans la moitié supérieure de la tuile. Ils utilisent un dégradé d'opacité : les plus proches de la fissure en `#FF8A65` à 50% d'opacité, les plus éloignés en `#FF5252` à 15% d'opacité. Ils simulent des débris et cendres volcaniques en suspension dans l'eau chaude.

- **Points de chaleur** : 2 à 3 cercles très petits (rayon 0.8-1px) de couleur `energyYellow (#FFD740)` à 70% d'opacité, positionnés à l'intérieur de la fissure aux points les plus larges. Ils représentent les zones les plus chaudes, là où la lave est directement exposée.

- **Texture de bord** : Les bords gauche et droit de la tuile présentent une texture de roche basaltique : des formes hexagonales/pentagonales très subtiles (stroke 0.3, fill `#1F1F35` à 30%) évoquant les colonnes de basalte typiques des failles océaniques.

---

### 3.2 Contenus de case — `assets/icons/map_content/`

#### `resource_bonus.svg` — Dépôt de ressources

**Description visuelle détaillée** :

Marqueur superposé au terrain représentant un coffre ou une caisse sous-marine entrouverte, source de ressources récupérables.

- **Coffre** : Forme rectangulaire aux coins arrondis (type coffre au trésor), centré dans la tuile, d'environ 24×18px. Le corps du coffre utilise un dégradé vertical allant de `#3A5070` (haut, couvercle) à `#2A3A50` (bas, caisse). Le couvercle est légèrement entrouvert (angle de 15-20°), créant une ouverture d'où s'échappe la lumière.

- **Éclat intérieur** : Depuis l'ouverture du coffre, un faisceau de lumière dorée s'élève. Implémenté comme un path triangulaire évasé vers le haut, avec un dégradé vertical de `energyYellow (#FFD740)` à 60% d'opacité (base, à l'ouverture) vers `#FFD740` à 0% d'opacité (pointe, 10-12px au-dessus). Un filtre `feGaussianBlur` (stdDeviation=1.5) appliqué sur ce faisceau crée un effet de lueur chaude sortant du coffre.

- **Particules dorées** : 4 à 6 petits losanges ou cercles de 1-1.5px, dispersés autour de l'éclat, en `energyYellow (#FFD740)` à 40-70% d'opacité. Ils simulent des éclats de matière précieuse s'échappant du coffre.

- **Cerclages métalliques** : 2 bandes horizontales sur le corps du coffre (haut et bas), en `#5A7090` (bleu-gris plus clair), stroke-width 0.8. Elles ajoutent un détail de construction au coffre.

- **Ombre portée** : Ellipse sous le coffre, en `#0A0E1A` à 30% d'opacité, légèrement plus large que le coffre. Elle ancre visuellement l'objet sur le terrain.

---

#### `ruins.svg` — Ruines anciennes

**Description visuelle détaillée** :

Vestiges d'une architecture sous-marine oubliée, évoquant une civilisation disparue. Ambiance mystérieuse et nacrée.

- **Arc brisé central** : Structure architecturale principale occupant le centre de la tuile. Un arc en plein cintre dont la moitié droite est effondrée. La partie intacte (gauche) monte du bas de la tuile jusqu'aux 2/3 de la hauteur, formant une courbe élégante. Pierre en dégradé de `#5A6678` (base) vers `#7B8C9F` (sommet). La partie brisée (droite) est réduite à un moignon irrégulier avec des bords dentelés.

- **Colonne renversée** : Au pied de l'arc, une colonne cylindrique couchée en diagonale. Environ 16px de long, 3px de diamètre. Dégradé le long de l'axe de `#6B7C8F` à `#4A5568`. Des sections brisées visibles aux extrémités (cercles partiels montrant la section).

- **Lueur nacrée/violette** : Un filtre SVG `feGaussianBlur` (stdDeviation=2.5) sur une ellipse centrée derrière l'arc. Couleur `biolumPurple (#B388FF)` à 25% d'opacité. Ce halo violet nacré émane des ruines, suggérant une énergie ancienne encore active (et la possibilité de trouver des Perles).

- **Inscriptions** : 2 à 3 lignes très fines (stroke-width 0.3) sur la surface de l'arc intact, formant des motifs géométriques abstraits (lignes parallèles, spirales). Couleur `biolumPurple (#B388FF)` à 30% d'opacité. Elles brillent faiblement.

- **Débris au sol** : 3 à 5 petits fragments anguleux (polygones de 1-3px) dispersés à la base de l'arc, en `#4A5568` à 70% d'opacité. Pierre et gravats de l'effondrement.

- **Particules nacrées** : 3 à 4 cercles minuscules (rayon 0.5-1px) de couleur `pearlWhite (#E0F7FA)` à 30-50% d'opacité, flottant autour des ruines. Ils évoquent la présence potentielle de perles.

---

#### `monster_easy.svg` — Repaire de monstre (Facile)

**Description visuelle détaillée** :

Petite caverne avec une créature à peine visible, aura verte rassurante (mais prudence). Badge 1 étoile.

- **Caverne** : Ouverture en demi-cercle au centre-bas de la tuile, d'environ 20×14px. Le contour est formé de rochers irréguliers en `rockGray (#4A5568)` avec un dégradé vers `#3A4558` à l'intérieur. L'intérieur de la caverne est un dégradé radial de `#0A0E1A` (profondeur, noir) vers `#1A2D47` (bord de l'ouverture).

- **Silhouette de créature** : À l'intérieur de la caverne, une forme sombre et petite suggère un animal. Silhouette simple en `#050810` à 70% d'opacité : un corps arrondi (rayon 3-4px) avec 2 petites extensions latérales (nageoires ou pattes). Deux points pour les yeux en `algaeGreen (#69F0AE)` à 80% d'opacité, rayon 0.8px, luisant dans l'obscurité.

- **Aura verte** : Un filtre `feGaussianBlur` (stdDeviation=3) sur une ellipse englobant la caverne. Couleur `algaeGreen (#69F0AE)` à 20% d'opacité. Le halo vert entoure la caverne et signifie "danger faible". Il s'étend 4-5px au-delà des rochers.

- **Badge 1 étoile** : En haut à droite de la tuile (position ~36,4), un cercle de fond de rayon 5px en `algaeGreen (#69F0AE)` à 80% d'opacité. À l'intérieur, une étoile à 5 branches de 3px en `abyssBlack (#0A0E1A)`. Le badge est net, sans filtre de flou.

- **Végétation** : 1 à 2 petites touffes d'algue sur les rochers de la caverne, en `algaeGreen (#69F0AE)` à 40% d'opacité. Elles renforcent le thème vert.

---

#### `monster_medium.svg` — Repaire de monstre (Moyen)

**Description visuelle détaillée** :

Caverne plus imposante, créature de taille moyenne, aura orange d'avertissement. Badge 2 étoiles.

- **Caverne** : Ouverture plus large que le monstre facile, environ 26×18px, toujours en demi-cercle mais plus haute et plus large. Rochers de contour plus massifs et anguleux, en `rockGray (#4A5568)` avec un dégradé vers `#2D3748`. Des stalactites (2-3 petits triangles inversés) pendent du sommet de l'ouverture, en `#3A4558`.

- **Silhouette de créature** : Plus grande et plus imposante que le monstre facile. Forme en `#050810` à 80% d'opacité : corps ovale allongé (6×4px) avec 4 extensions (tentacules ou pattes), partiellement visible depuis l'ouverture — la créature ne tient pas entièrement dans l'ombre. Yeux en `energyYellow (#FFD740)` à 90% d'opacité, rayon 1px, regard perçant.

- **Aura orange** : Filtre `feGaussianBlur` (stdDeviation=3.5) sur une ellipse autour de la caverne. Couleur `energyYellow (#FFD740)` à 25% d'opacité. Le halo orangé est plus intense et étendu que le vert du monstre facile (5-6px au-delà des rochers), signifiant "danger modéré".

- **Badge 2 étoiles** : En haut à droite (position ~34,3), un cercle de fond de rayon 6px en `energyYellow (#FFD740)` à 85% d'opacité. À l'intérieur, 2 étoiles à 5 branches côte à côte, chacune de 2.5px, en `abyssBlack (#0A0E1A)`.

- **Os/débris** : 1 à 2 petites formes blanches (os stylisés) au sol devant la caverne, en `#7B9CC0` à 30% d'opacité. Elles suggèrent que la créature a déjà chassé.

---

#### `monster_hard.svg` — Repaire de monstre (Difficile)

**Description visuelle détaillée** :

Caverne massive et menaçante, créature terrifiante avec tentacules visibles, aura rouge de danger. Badge 3 étoiles.

- **Caverne** : La plus grande des trois, environ 30×22px, occupant presque les deux tiers inférieurs de la tuile. Ouverture irrégulière et menaçante — pas un simple demi-cercle mais une forme déchiquetée avec des pointes rocheuses. Rochers en `rockGray (#4A5568)` avec un dégradé vers `#1A1A2E` (noir profond à l'intérieur). Des stalactites et stalagmites proéminents (triangles de 3-5px) encadrent l'entrée comme des mâchoires.

- **Silhouette de créature avec tentacules** : La créature dépasse partiellement de la caverne. Corps massif en `#050810` à 90% d'opacité, occupant la majeure partie de l'ouverture. 3 à 4 tentacules s'étendent hors de la caverne, ondulant vers les bords de la tuile. Chaque tentacule est un path courbe de 8-12px de long, en `#1A1A2E` à 80% d'opacité avec un dégradé vers la pointe plus fine. Yeux : 2 grands yeux en `error (#FF5252)` à 90% d'opacité, rayon 1.5px, avec un point central plus sombre simulant la pupille.

- **Aura rouge** : Filtre `feGaussianBlur` (stdDeviation=4) sur une ellipse large autour de la caverne. Couleur `error (#FF5252)` à 30% d'opacité. Le halo rouge est intense et s'étend largement (6-8px), remplissant la périphérie de la tuile d'une lueur menaçante.

- **Badge 3 étoiles** : En haut à droite (position ~32,2), un cercle de fond de rayon 7px en `error (#FF5252)` à 90% d'opacité. À l'intérieur, 3 étoiles à 5 branches disposées en arc, chacune de 2px, en `abyssBlack (#0A0E1A)`.

- **Particules de danger** : 3 à 5 petits éclats anguleux (triangles de 0.5-1px) flottant autour de l'entrée, en `error (#FF5252)` à 20-40% d'opacité, simulant des fragments de roche ou des bulles sombres.

- **Marques de griffes** : 2 à 3 entailles parallèles sur les rochers de l'entrée (paths diagonaux, stroke-width 0.5, couleur `#2D3748`), traces de la créature.

---

### 3.3 Base du joueur — `assets/icons/map_content/`

#### `player_base.svg` — Base du joueur

**Description visuelle détaillée** :

L'élément visuel le plus dominant et lumineux de toute la grille. Un dôme bioluminescent cyan rayonnant d'énergie.

- **Dôme principal** : Demi-sphère occupant le centre de la tuile (environ 28×20px, base au centre vertical, sommet aux 2/3 supérieurs). Le dôme utilise un dégradé radial complexe : centre `biolumCyan (#00E5FF)` à 80% d'opacité → mi-distance `biolumBlue (#448AFF)` à 60% → bord `#0D1B2A` à 40%. Cela crée un effet de verre translucide lumineux.

- **Structure du dôme** : 4 à 5 arcs méridiens (lignes courbes du bas vers le sommet) en `biolumCyan (#00E5FF)` à 50% d'opacité, stroke-width 0.5. Ils figurent l'armature du dôme. 2 arcs parallèles horizontaux complètent la grille structurelle.

- **Halo bioluminescent principal** : Filtre `feGaussianBlur` (stdDeviation=4) sur un cercle de rayon 18px centré sur le dôme. Couleur `biolumCyan (#00E5FF)` à 25% d'opacité. Ce halo massif déborde largement de la tuile (ce qui est voulu — il sera clippé par la tuile mais crée un effet de rayonnement).

- **Halo secondaire** : Un second filtre flou (stdDeviation=2) sur un cercle plus petit (rayon 12px), en `biolumTeal (#1DE9B6)` à 15% d'opacité. Il crée un second anneau de lumière plus verdâtre, simulant la diffusion dans l'eau.

- **Base du dôme** : Rectangulaire avec coins arrondis, 30×6px, en `deepNavy (#0D1B2A)` avec une bordure supérieure de 0.5px en `biolumCyan (#00E5FF)` à 60%. C'est le socle ancré au fond marin.

- **Points lumineux** : 3 à 4 points de lumière intense (rayon 0.8px) disposés sur le dôme — au sommet et sur les faces. Couleur `pearlWhite (#E0F7FA)` à 90% d'opacité. Ils simulent des reflets spéculaires du verre.

- **Particules bioluminescentes** : 5 à 7 cercles de tailles variées (rayon 0.3-1px) dans un rayon de 20px autour du dôme. Couleur alternant entre `biolumCyan (#00E5FF)` et `biolumTeal (#1DE9B6)` à 20-50% d'opacité. Ils simulent le plancton attiré par la lumière de la base.

---

### 3.4 Factions IA — `assets/icons/map_content/`

#### `faction_neutral.svg` — Faction neutre

**Description visuelle détaillée** :

Version atténuée de la base joueur, en bleu terne. Présence non menaçante mais clairement "autre".

- **Dôme** : Même forme de demi-sphère que la base joueur, mais plus petit (22×16px). Dégradé radial de `oreBlue (#42A5F5)` à 50% d'opacité (centre) vers `#2A3A50` à 40% (bord). Nettement moins lumineux que la base joueur.

- **Structure** : 3 arcs méridiens seulement, en `oreBlue (#42A5F5)` à 30% d'opacité, stroke-width 0.4. Structure simplifiée — faction moins avancée technologiquement.

- **Halo** : Filtre `feGaussianBlur` (stdDeviation=2) sur un cercle de rayon 12px. Couleur `oreBlue (#42A5F5)` à 12% d'opacité. Lueur bleutée discrète, visible mais non dominante.

- **Base/socle** : Rectangle arrondi 24×5px en `#1A2D47` avec bordure en `oreBlue (#42A5F5)` à 30% d'opacité.

- **Indicateur de neutralité** : Un petit symbole de balance ou de poignée de main stylisé au sommet du dôme (3×3px), en `oreBlue (#42A5F5)` à 60% d'opacité. Il distingue cette faction de la faction hostile.

---

#### `faction_hostile.svg` — Faction hostile

**Description visuelle détaillée** :

Dôme menaçant en rouge sombre avec un design agressif et défensif.

- **Dôme** : Demi-sphère de 22×16px, identique en taille à la faction neutre. Dégradé radial de `error (#FF5252)` à 50% d'opacité (centre) vers `#2A1015` à 60% (bord). La teinte rouge sombre communique immédiatement le danger.

- **Pointes défensives** : 4 à 6 éléments pointus (triangles de 3-4px de haut) partant de la base du dôme vers l'extérieur, comme des piquants. Couleur `#4A2020` avec reflets en `error (#FF5252)` à 30%. Ils donnent un aspect fortifié et agressif absent des autres bases.

- **Structure** : 3 arcs méridiens en `error (#FF5252)` à 35% d'opacité, stroke-width 0.5. Même nombre que la faction neutre mais couleur rouge.

- **Halo menaçant** : Filtre `feGaussianBlur` (stdDeviation=2.5) sur un cercle de rayon 13px. Couleur `error (#FF5252)` à 15% d'opacité. Lueur rougeâtre, plus intense que la faction neutre.

- **Lumières rouges** : 2 à 3 points de lumière (rayon 1px) sur le dôme en `error (#FF5252)` à 80% d'opacité, positionnés pour évoquer des "yeux" ou des sentinelles. Pas de points blancs spéculaires comme la base joueur — uniquement du rouge.

- **Base/socle** : Rectangle arrondi 24×5px en `#1A1015` avec bordure en `error (#FF5252)` à 40% d'opacité. Plus sombre que les autres socles.

- **Indicateur d'hostilité** : Un petit symbole d'épée croisée ou de crâne stylisé au sommet du dôme (3×3px), en `error (#FF5252)` à 70% d'opacité.

---

## 4. Testing and Validation

### 4.1 Validation technique

- Chaque SVG est valide selon la spécification SVG 1.1
- Chaque SVG utilise le viewBox `0 0 48 48`
- Aucun texte, font externe ou image bitmap embarqué
- Taille fichier < 5 Ko par SVG (cible de performance pour 400 cases)

### 4.2 Validation visuelle

- Chaque SVG est rendu correctement dans Flutter via `flutter_svg` ou équivalent
- Les tuiles de terrain sont visuellement seamless quand juxtaposées sur une grille 4×4 minimum
- Les contenus de case sont lisibles quand superposés sur chacun des 4 types de terrain
- La base joueur est visuellement dominante par rapport à toutes les autres icônes
- Les 3 niveaux de monstres sont distinguables par couleur ET par nombre d'étoiles
- Les factions neutre et hostile sont visuellement distinctes entre elles et de la base joueur

### 4.3 Test d'accessibilité

- Le codage couleur (vert/orange/rouge) des monstres est doublé par le nombre d'étoiles (1/2/3) pour les joueurs daltoniens
- Les icônes restent reconnaissables en niveaux de gris (test de contraste)

### 4.4 Test de performance

- Le rendu de 400 tuiles de terrain + contenus ne provoque pas de lag perceptible sur un appareil mobile milieu de gamme
- Les filtres SVG (glow/blur) ne dégradent pas les performances de scroll/zoom de la carte
