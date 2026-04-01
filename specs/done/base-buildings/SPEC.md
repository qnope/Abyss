# Base Buildings - Feature Specification

## 1. Feature Overview

L'onglet **Base** affiche la liste des batiments du joueur. Chaque batiment est represente par une carte cliquable montrant son icone, son niveau et un resume de ses stats. Un tap ouvre un BottomSheet de detail avec les informations completes et la possibilite d'ameliorer le batiment.

Pour cette premiere version, seul le **Quartier General (QG)** est implemente. L'architecture est concue pour accueillir facilement les autres batiments (Ferme d'algues, Mine de corail, etc.) dans de futurs projets.

### Decisions cles

- **Upgrade instantane** : payer les ressources = upgrade applique immediatement. Pas de file de construction. La file de construction sera ajouté plus tard, il faut garder ça en compte pendant le design.
- **QG niveau 0 a 10** : le QG demarre au niveau 0 et peut monter jusqu'au niveau 10.
- **Pas d'effet mecanique** : pour l'instant le niveau du QG n'a pas d'impact sur le gameplay. C'est un squelette UI pour valider le flux.
- **Couts progressifs** : formule simple et facilement modifiable pour l'equilibrage futur.
- **BottomSheet** : coherent avec le ResourceDetailSheet existant.
- **Verrouillage grise** : les upgrades impossibles (ressources insuffisantes, niveau max atteint) sont grises avec une explication.
- **Carte grise**: Si le bâtiment n'est pas encore construit, il sera légérement grisé.

## 2. User Stories

### US-01 : Voir la liste des batiments

En tant que joueur, quand je suis sur l'onglet Base, je vois une ListView de mes batiments.

Chaque element de la liste affiche :
- L'icone du batiment (SVG, ex: `headquarters.svg`)
- Le nom du batiment (ex: "Quartier General")
- Le niveau actuel (ex: "Niveau 3")
- Un resume compact des stats (ex: pour un batiment de production, le nombre de ressources produites par tour)

Criteres d'acceptation :
- La liste affiche tous les batiments du joueur
- Pour le QG, le resume indique le niveau uniquement (pas de production)
- La liste est scrollable si le nombre de batiments depasse l'ecran
- Le design utilise le theme existant (couleurs, typographie, cartes)
- Element de la liste gris si bâtiment non construit. Le SVG devra être rendu de maniere grise aussi.

### US-02 : Voir le detail d'un batiment

En tant que joueur, je tape sur un batiment dans la liste pour ouvrir un BottomSheet de detail.

Le BottomSheet affiche :
- L'icone du batiment en grand (64px)
- Le nom du batiment
- Le niveau actuel
- Une description du batiment
- Les stats actuelles (si applicable)
- La section d'upgrade (voir US-03)

Criteres d'acceptation :
- Le BottomSheet est dismissible (swipe down ou tap en dehors)
- Le design est coherent avec le ResourceDetailSheet existant
- Les informations sont lisibles et bien organisees

### US-03 : Ameliorer un batiment

En tant que joueur, je vois dans le BottomSheet les couts d'upgrade et un bouton pour ameliorer.

La section upgrade affiche :
- Le niveau actuel → niveau suivant (ex: "Niveau 2 → 3")
- Le cout en ressources pour le niveau suivant
- Chaque ressource du cout est affichee avec son icone et sa quantite
- Les ressources insuffisantes sont affichees en rouge
- Un bouton "Ameliorer" pour lancer l'upgrade

Criteres d'acceptation :
- Le bouton "Ameliorer" est actif uniquement si le joueur a assez de ressources
- Si les ressources sont insuffisantes, le bouton est grise
- Si les conditions de niveau des autres batiments est insuffisant, le bouton est grise
- Au clic sur "Ameliorer", les ressources sont deduites et le niveau augmente de 1
- Le BottomSheet se met a jour pour refleter le nouveau niveau
- La ResourceBar en haut de l'ecran se met a jour (les montants diminuent)
- Si le batiment est au niveau max (10), la section upgrade affiche "Niveau maximum atteint" et pas de bouton

### US-04 : Batiment non-ameliorable (grise)

En tant que joueur, quand je ne peux pas ameliorer un batiment, je comprends pourquoi.

Cas ou l'upgrade est impossible :
- **Ressources insuffisantes** : le bouton est grise, les ressources manquantes en rouge
- **Condition insuffisantes**: Par exemple si le QG ou un autre bâtiment n'est pas à un niveau suffisamment élevé pour upgrade un batiment, le nom du batiment fautif apparaît en rouge.
- **Niveau max atteint** : message "Niveau maximum atteint", pas de bouton

Criteres d'acceptation :
- Le joueur voit clairement pourquoi l'upgrade est impossible
- Le texte explicatif utilise la couleur `disabled` ou `error` du theme

## 3. Donnees du QG

### Formule de cout

Le cout d'upgrade du QG au niveau N+1 est :

```
corail:   baseCoral   * (N^2 + 1)
minerai:  baseOre     * (N^2 + 1)
```

Valeurs de base (facilement modifiables) :
- `baseCoral = 30`
- `baseOre = 20`

La formule est isolee dans une fonction pour etre facilement modifiable (lineaire, exponentielle, table fixe...).

### Description du QG

- **Nom** : Quartier General
- **Icone** : `assets/icons/buildings/headquarters.svg`
- **Description** : "Centre de commandement de votre base sous-marine. Son niveau determine les capacites de votre colonie."
- **Niveau initial** : 0
- **Niveau max** : 10
- **Production** : aucune
- **Effet mecanique** : aucun pour l'instant (prevu : debloquer le nombre et le niveau max des autres batiments)

## 4. Testing and Validation

### Tests unitaires
- Le modele Building contient les bonnes valeurs par defaut (niveau 0, etc.)
- La formule de cout retourne les bons montants pour chaque niveau
- L'upgrade incremente le niveau et deduit les ressources
- L'upgrade est refuse si les ressources sont insuffisantes
- L'upgrade est refuse si le niveau max est atteint
- Le BuildingType enum contient headquarters avec les bonnes metadonnees

### Tests widgets
- La liste de batiments affiche le QG avec son niveau
- Le tap sur un batiment ouvre le BottomSheet
- Le BottomSheet affiche les infos correctes (nom, niveau, cout)
- Le bouton Ameliorer est grise quand les ressources sont insuffisantes
- Le bouton Ameliorer est absent quand le niveau max est atteint
- Apres un upgrade, le niveau et les ressources sont mis a jour dans l'UI
