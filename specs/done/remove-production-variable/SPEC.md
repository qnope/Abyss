# remove-production-variable - Feature Specification

## 1. Feature Overview

Supprimer la variable `productionPerTurn` stockee dans le modele `Resource` et la remplacer par un calcul dynamique base sur l'etat du jeu (batiments, et plus tard technologies et armees).

Actuellement, `productionPerTurn` est un champ Hive persiste sur `Resource`, mute manuellement a chaque upgrade de batiment. Cette approche pose des problemes de synchronisation quand plusieurs systemes affectent la production (batiments, technologies, armees). En calculant la production a la volee depuis l'etat du jeu, on elimine ces risques et on simplifie l'ajout de futurs modificateurs.

## 2. User Stories

**US-01 : Production calculee depuis les batiments**
En tant que joueur, ma production de ressources reflete automatiquement le niveau de mes batiments sans variable intermediaire.

Criteres d'acceptation :
- La production par tour est calculee dynamiquement a partir du niveau des batiments de production
- La formule reste identique : `niveau * bonus_par_niveau` (ex: Ferme d'algues niv.3 = 3 * 5 = 15 algues/tour)
- Un batiment a niveau 0 ne produit rien
- Au debut de la partie, tous les batiments sont a niveau 0 donc la production est 0 pour toutes les ressources
- Les montants de ressources de depart restent inchanges (Algues=100, Corail=80, Minerai=50, Energie=60, Perles=5)

**US-02 : Suppression de la variable stockee**
En tant que developpeur, la variable `productionPerTurn` n'existe plus dans le modele `Resource`.

Criteres d'acceptation :
- Le champ `productionPerTurn` est supprime du modele `Resource`
- Le champ Hive correspondant (HiveField 2) est retire
- L'action `UpgradeBuildingAction` ne mute plus `productionPerTurn` apres un upgrade
- `Game.defaultResources()` ne specifie plus de valeur de production initiale
- Tous les endroits lisant `resource.productionPerTurn` utilisent le calcul dynamique a la place

**US-03 : API extensible pour les modificateurs de production**
En tant que developpeur, l'API de calcul de production est concue pour accepter plusieurs sources de modificateurs.

Criteres d'acceptation :
- Le calcul de production prend en entree l'etat du jeu (batiments, et dans le futur : technologies, armees)
- L'API est extensible : on peut ajouter de nouvelles sources de production ou de consommation sans modifier le code existant
- Pour cette iteration, seuls les batiments sont implementes comme source
- Les technologies (bonus %) et les armees (consommation) pourront etre branches plus tard sans refactoring

**US-04 : Coherence de l'affichage**
En tant que joueur, l'affichage de la production dans la barre de ressources reste identique.

Criteres d'acceptation :
- La barre de ressources affiche toujours `+X/t` a cote de chaque ressource
- La valeur affichee correspond au resultat du calcul dynamique
- Si la production est 0, le `+X/t` ne s'affiche pas (comportement actuel)

## 3. Testing and Validation

### Tests unitaires
- Le calcul de production renvoie 0 pour tous les types de ressource quand tous les batiments sont a niveau 0
- Le calcul de production renvoie le bon montant pour un batiment a un niveau donne
- Le calcul de production cumule correctement les contributions de plusieurs batiments
- L'upgrade d'un batiment ne mute plus aucune variable de production
- Les Perles ne sont jamais produites (aucun batiment ne les produit)

### Tests widgets
- La barre de ressources affiche la production calculee dynamiquement
- La barre de ressources n'affiche pas `+0/t`

### Criteres de reussite
- `productionPerTurn` n'existe plus dans le modele `Resource`
- `flutter analyze` passe sans erreur
- `flutter test` passe sans erreur
- Le comportement en jeu est identique (meme production pour les memes niveaux de batiments)
