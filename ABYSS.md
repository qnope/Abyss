# ABYSSES - Game Design Specification

## 1. Feature Overview

ABYSSES est un jeu de strategie tour par tour en single player, dans un univers sous-marin. Le joueur developpe une base sous-marine, explore les profondeurs de l'ocean, forme des alliances et combat des factions IA rivales. L'objectif final est d'atteindre le noyau volcanique au 3eme niveau de profondeur.

Le jeu s'inspire de Travian, OGame et Clash of Clans, mais en solo et tour par tour. Au lieu d'attendre des heures, le joueur effectue ses actions puis appuie sur "Tour suivant".

Parties courtes : 50 a 100 tours.

## 2. User Stories

### 2.1 Demarrage de partie

**US-01 : Choix du kit de depart**
En tant que joueur, je choisis un kit de depart parmi 3 options pour orienter ma strategie initiale.

Kits disponibles :
- **Militaire** : QG + Caserne + unites de combat supplementaires + stock de ressources reduit
- **Economique** : QG + batiments de production supplementaires + stock de ressources augmente
- **Explorateur** : QG + unites d'exploration supplementaires + vision etendue sur la carte

Criteres d'acceptation :
- Le joueur voit les 3 kits avec leur contenu detaille
- Le joueur selectionne un kit avant que la partie commence
- Les ressources et batiments du kit sont places automatiquement

### 2.2 Carte et exploration

**US-02 : Carte en grille avec fog of war**
En tant que joueur, je vois une grille 20x20 dont seules les cases proches de ma base sont visibles.

Criteres d'acceptation :
- La grille est 20x20 cases
- Seules les cases dans le rayon de vision de la base sont visibles au depart
- Les cases non explorees sont cachees (fog of war)
- Chaque case a un type de terrain sous-marin (recif, plaine, roche, faille...)

**US-03 : Exploration par unites**
En tant que joueur, j'envoie des unites d'exploration (eclaireurs, sondes) pour reveler la carte.

Criteres d'acceptation :
- Les unites d'exploration peuvent etre envoyees sur des cases adjacentes non explorees
- L'exploration revele la case et son contenu (ressources, ruines, monstres...)
- L'exploration consomme 1 tour de deplacement par case

### 2.3 Ressources

**US-04 : Systeme de 5 ressources**
En tant que joueur, je collecte et gere 5 ressources pour developper ma base.

Ressources :
| Ressource | Role | Batiment de production |
|-----------|------|----------------------|
| Algues | Nourriture, entretien des unites | Ferme d'algues |
| Corail | Materiau de construction | Mine de corail |
| Minerai oceanique | Metal, unites avancees | Extracteur de minerai |
| Energie | Alimentation des batiments | Panneau solaire (niveau 1) |
| Perles | Ressource rare, technologies avancees | Non produite, trouvee par exploration/combat |

Criteres d'acceptation :
- Les 4 premieres ressources sont produites chaque tour par les batiments correspondants
- Les Perles sont obtenues uniquement via l'exploration, les evenements ou le combat
- Le joueur voit son stock de ressources en permanence
- Les Perles servent exclusivement a debloquer les technologies avancees

### 2.4 Base et batiments

**US-05 : Base unique evolutive**
En tant que joueur, je developpe une base unique qui s'agrandit et se specialise au fil du jeu.

Batiments de base disponibles :
| Batiment | Fonction | Cout principal |
|----------|----------|---------------|
| QG (Quartier General) | Centre de la base, ameliorable | - |
| Ferme d'algues | Produit des Algues | Corail |
| Mine de corail | Produit du Corail | Minerai |
| Extracteur de minerai | Produit du Minerai oceanique | Corail, Energie |
| Panneau solaire | Produit de l'Energie | Corail, Minerai |
| Laboratoire | Permet la recherche de technologies | Corail, Minerai, Energie |
| Caserne | Recrute des unites humaines | Corail, Minerai |

Criteres d'acceptation :
- Le QG est present des le debut et ne peut pas etre detruit
- Chaque batiment peut etre ameliore pour augmenter sa production
- Le niveau du QG limite le nombre et le niveau max des autres batiments
- La construction d'un batiment prend 1 ou plusieurs tours selon son niveau

### 2.5 Unites militaires

**US-06 : Recrutement d'unites (humains + machines)**
En tant que joueur, je recrute des unites pour explorer, attaquer et defendre.

Unites de depart (humains) :
| Unite | Role | Recrutee a |
|-------|------|-----------|
| Eclaireur | Exploration rapide, faible en combat | Caserne |
| Plongeur soldat | Combat basique, polyvalent | Caserne |
| Ingenieur sous-marin | Reparation, construction avancee | Caserne |

Unites avancees (machines, debloquees par la tech) :
| Unite | Role | Recrutee a |
|-------|------|-----------|
| Drone de reconnaissance | Exploration longue distance | Atelier mecanique |
| Mini sous-marin | Combat moyen, mobilite elevee | Atelier mecanique |
| Torpille automatique | Degats eleves, usage unique | Atelier mecanique |

Criteres d'acceptation :
- Les unites humaines sont disponibles des le debut via la Caserne
- Les unites machines necessitent un Atelier mecanique (debloque par technologie)
- Chaque unite a des stats : PV, attaque, defense, deplacement
- Le recrutement coute des ressources et prend 1+ tours

### 2.6 Technologies

**US-07 : Arbres de technologies paralleles**
En tant que joueur, je recherche des technologies dans 3 arbres independants pour progresser.

Arbres technologiques :
- **Militaire** : ameliore les unites, debloque les vehicules, ameliore les defenses
- **Economie** : ameliore la production, debloque de nouveaux batiments, reduit les couts
- **Exploration** : augmente la vision, ameliore les eclaireurs, debloque les sondes

Criteres d'acceptation :
- Le Laboratoire est necessaire pour rechercher
- Chaque technologie coute des ressources + du temps (tours)
- Les technologies avancees coutent des Perles
- Les 3 arbres sont independants, le joueur choisit ses priorites
- Certaines technologies sont des prerequis pour d'autres dans le meme arbre

### 2.7 Factions IA et alliances

**US-08 : 100 factions sur la carte**
En tant que joueur, je partage la carte avec 99 factions IA qui evoluent en parallele.

Criteres d'acceptation :
- Les 99 factions IA sont presentes des le tour 1
- Chaque faction IA a sa propre base, ses ressources et son armee
- Les factions IA progressent a chaque tour (construction, recrutement, exploration)
- Les factions sont cachees par le fog of war jusqu'a ce qu'on les decouvre

**US-09 : Systeme d'alliances**
En tant que joueur et meneur d'alliance, je gere une alliance pouvant contenir jusqu'a 10 factions.

Criteres d'acceptation :
- Le joueur est automatiquement meneur de son alliance
- Une alliance peut contenir jusqu'a 10 factions (joueur inclus)
- Le joueur peut inviter des factions IA a rejoindre son alliance
- Les factions IA d'autres alliances existent aussi sur la carte

**US-10 : Gestion des allies**
En tant que meneur d'alliance, je donne des ordres a mes allies et ils peuvent accepter ou refuser.

Types d'ordres :
- Attaquer une cible
- Defendre une position
- Envoyer des ressources
- Explorer une zone

Criteres d'acceptation :
- Le joueur peut envoyer des ordres a chaque allie individuellement
- Chaque allie a une "humeur/disposition" qui influence sa probabilite d'accepter
- L'humeur depend des actions passees du joueur (ordres raisonnables, aide mutuelle...)
- Le joueur voit la disposition de chaque allie

### 2.8 Niveaux de profondeur

**US-11 : Transition vers un niveau de profondeur inferieur**
En tant que joueur, je debloque l'acces au niveau suivant en construisant un batiment special et en vainquant un boss de monstres.

3 niveaux de profondeur :
| Niveau | Nom | Theme | Taille |
|--------|-----|-------|--------|
| 1 | Surface | Eaux claires, proches de la surface, panneaux solaires | 20x20 |
| 2 | Profondeur | Eaux sombres, pression accrue, nouvelles ressources | 20x20 |
| 3 | Noyau | Zone volcanique/geothermique, environnement extreme | 20x20 |

Conditions pour passer au niveau suivant :
1. Construire le batiment special (ex: "Ascenseur abyssal" pour le niveau 2, "Tunnel de pression" pour le niveau 3)
2. Vaincre la base de monstres qui garde le passage vers la profondeur

Criteres d'acceptation :
- Le batiment special necessite un QG de niveau eleve + ressources rares
- La base de monstres est un combat difficile necessite une armee preparee
- Le nouveau niveau est une nouvelle grille 20x20 entierement en fog of war
- Le joueur conserve sa base du niveau precedent
- L'energie solaire ne fonctionne plus aux niveaux inferieurs (necessite une source alternative : geothermie)

### 2.9 Systeme de tours

**US-12 : Deroulement d'un tour**
En tant que joueur, j'effectue mes actions puis j'appuie sur "Tour suivant" pour avancer.

Phase d'action (le joueur joue) :
- Construire/ameliorer des batiments
- Recruter des unites
- Deplacer des unites
- Lancer des attaques
- Lancer des recherches
- Donner des ordres aux allies
- Gerer la diplomatie

Resolution du tour (automatique) :
- Production des ressources
- Avancement des constructions en cours
- Avancement des recherches en cours
- Resolution des combats
- Mouvements des unites
- Actions des factions IA
- Evenement aleatoire (possible)

Criteres d'acceptation :
- Le joueur peut faire autant d'actions qu'il veut avant d'appuyer sur "Tour suivant"
- Toutes les resolutions sont affichees au joueur (resume du tour)
- Les factions IA jouent leur tour en meme temps

### 2.10 Evenements aleatoires

**US-13 : Evenements entre les tours**
En tant que joueur, des evenements aleatoires surviennent pour varier le gameplay.

Evenements environnementaux (negatifs) :
- Courant marin violent : deplace des unites aleatoirement
- Eruption volcanique sous-marine : endommage les batiments proches
- Maree toxique : reduit la production d'algues pendant X tours
- Tempete de pression : empeche l'exploration pendant 1 tour

Evenements de decouverte (positifs) :
- Epave ancienne : donne des ressources bonus
- Ruines mysterieuses : donne des Perles ou un bonus de technologie
- Creature rare : peut etre apprivoisee (unite speciale) ou combattue (butin)
- Gisement cache : revele une case riche en ressources

Criteres d'acceptation :
- Un evenement a une probabilite de survenir a chaque tour (pas systematique)
- L'evenement est affiche au joueur avec ses consequences
- Les evenements positifs et negatifs sont equilibres
- Certains evenements sont specifiques a un niveau de profondeur

### 2.11 Condition de victoire

**US-14 : Atteindre le noyau**
En tant que joueur, je gagne la partie en atteignant et conquerant le 3eme niveau de profondeur.

Criteres d'acceptation :
- Le joueur doit atteindre le niveau 3 (Noyau)
- Un objectif final est present au niveau 3 (a definir : batiment ultime, boss final...)
- La victoire affiche un ecran de fin avec les statistiques de la partie

## 3. Testing and Validation

### Tests unitaires
- Systeme de ressources : production, consommation, limites de stockage
- Systeme de construction : couts, duree, prerequis
- Systeme de combat : resolution des combats, stats des unites
- Arbre technologique : prerequis, couts, effets
- IA des factions : decisions, progression, diplomatie
- Evenements aleatoires : declenchement, effets

### Tests d'integration
- Enchainement de tours complet : actions → resolution → production → evenements
- Transition entre niveaux de profondeur
- Systeme d'alliance complet : ordres, humeur, reponses

### Tests de gameplay
- Equilibrage : une partie peut etre gagnee en 50-100 tours avec chaque kit
- Les 3 kits de depart menent a des experiences de jeu differentes
- La difficulte progresse naturellement avec les niveaux de profondeur
- Les factions IA sont un defi sans etre injustes
