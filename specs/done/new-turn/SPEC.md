# New Turn - Feature Specification

## 1. Feature Overview

Lorsque le joueur appuie sur le bouton "Tour suivant", une popup de confirmation s'affiche avec un apercu de la production qui sera ajoutee a chaque ressource. Si le joueur confirme, le tour est resolu : les ressources sont mises a jour en respectant le plafond de stockage, la partie est sauvegardee automatiquement, et un resume post-tour est affiche dans une popup.

Cette feature transforme le bouton "Tour suivant" (actuellement un simple incrementeur de compteur) en un veritable systeme de resolution de tour.

## 2. User Stories

### US-01 : Confirmation avant passage de tour

En tant que joueur, je veux voir une popup de confirmation avec l'apercu de ma production avant de passer au tour suivant, afin de valider que je suis pret.

Criteres d'acceptation :
- Quand le joueur appuie sur "Tour suivant", une popup (AlertDialog) s'affiche
- La popup affiche le titre "Passer au tour suivant ?"
- La popup affiche la liste des ressources avec la production prevue (ex: Algues +5, Corail +4)
- Seules les ressources avec une production > 0 sont affichees
- Deux boutons sont disponibles : "Annuler" et "Confirmer"
- "Annuler" ferme la popup sans rien changer
- "Confirmer" lance la resolution du tour

### US-02 : Mise a jour des ressources

En tant que joueur, je veux que mes ressources soient mises a jour selon la production de mes batiments quand je confirme le passage de tour.

Criteres d'acceptation :
- La production est calculee a partir du niveau des batiments (via ProductionCalculator)
- Chaque ressource recoit sa production correspondante
- Les ressources ne peuvent pas depasser leur plafond de stockage (maxStorage)
- Si une ressource atteindrait le plafond, elle est plafonnee a maxStorage
- Le compteur de tour est incremente de 1
- Les perles ne sont pas concernees (pas de production par batiments)

### US-03 : Sauvegarde automatique

En tant que joueur, je veux que ma partie soit sauvegardee automatiquement apres chaque tour, afin de ne pas perdre ma progression.

Criteres d'acceptation :
- Apres la resolution du tour (mise a jour des ressources + increment du tour), la partie est sauvegardee via GameRepository
- La sauvegarde est transparente pour le joueur (pas de popup supplementaire)

### US-04 : Resume post-tour

En tant que joueur, je veux voir un resume de ce qui s'est passe pendant le tour, afin de comprendre les changements.

Criteres d'acceptation :
- Apres la resolution du tour, une popup (AlertDialog) s'affiche avec le resume
- Le resume affiche les ressources gagnees par type (ex: Algues +5)
- Si une ressource a ete plafonnee, un indicateur le signale (ex: "Algues +5 (max atteint)")
- Un bouton "OK" ferme la popup
- L'UI (barre de ressources) est mise a jour avec les nouvelles valeurs

## 3. Testing and Validation

### Tests unitaires
- ProductionCalculator : verifier que la production est correctement calculee selon les niveaux de batiments (deja teste)
- Application de la production aux ressources : verifier que les montants sont correctement mis a jour
- Plafonnement : verifier qu'une ressource ne depasse jamais maxStorage
- Cas limite : production a 0 (pas de batiments), toutes les ressources au plafond

### Tests de widgets
- Popup de confirmation : verifier qu'elle affiche l'apercu de production correct
- Popup de confirmation : verifier que "Annuler" ferme sans changement
- Popup de confirmation : verifier que "Confirmer" declenche la resolution
- Popup de resume : verifier qu'elle affiche les bonnes valeurs et l'indicateur de plafond
- Integration : verifier que la barre de ressources est mise a jour apres le tour

### Criteres de succes
- Le joueur ne peut plus passer au tour suivant par erreur (confirmation obligatoire)
- Les ressources augmentent correctement a chaque tour
- La sauvegarde est fiable et automatique
- Le resume donne une vision claire des changements
