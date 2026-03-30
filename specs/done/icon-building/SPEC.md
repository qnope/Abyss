# icon-building - Feature Specification

## 1. Feature Overview

Creation de 5 icones SVG pour les batiments du jeu ABYSSES :
- **QG (Quartier General)** : centre de commande de la base
- **Ferme d'algues** : produit des Algues
- **Mine de corail** : produit du Corail
- **Extracteur de minerai** : produit du Minerai oceanique
- **Panneau solaire** : produit de l'Energie

Les icones doivent etre tres detaillees, immediatement comprehensibles (on doit comprendre le lien batiment-ressource sans connaitre le jeu), et coherentes avec les icones de ressources existantes dans `assets/icons/resources/`.

## 2. User Stories

### US-01 : Voir l'icone du QG

En tant que joueur, je vois une icone violette luminescente representant le Quartier General, qui evoque clairement un centre de commande sous-marin.

**Design** :
- Couleur principale : violet biolumPurple `#B388FF` avec gradient vers `#7C4DFF`
- Forme : dome ou structure centrale high-tech sous-marine avec antennes/tourelles
- Elements : hublots lumineux, structure metallique futuriste, rayonnement violet
- L'icone doit evoquer le pouvoir, le commandement, le coeur de la base

**Criteres d'acceptation** :
- Format SVG, viewBox 64x64
- Utilise des gradients lineaires et un filtre glow (feGaussianBlur + feMerge) comme les icones de ressources existantes
- Stockee dans `assets/icons/buildings/headquarters.svg`
- Reconnaissable comme un batiment de commandement meme sans contexte

### US-02 : Voir l'icone de la Ferme d'algues

En tant que joueur, je vois une icone verte representant la Ferme d'algues, qui montre clairement le lien avec la production d'algues.

**Design** :
- Couleur principale : vert algae `#69F0AE` avec gradient vers `#2E7D32`
- Forme : structure high-tech sous-marine (dome en verre / serre sous-marine)
- Elements integres de la ressource : feuilles/tiges d'algues visibles a l'interieur ou autour de la structure
- Details : tuyaux, lumieres de croissance, structure metallique

**Criteres d'acceptation** :
- Format SVG, viewBox 64x64
- Gradients et glow coherents avec le style existant
- Stockee dans `assets/icons/buildings/algae_farm.svg`
- On comprend immediatement que ce batiment produit des algues

### US-03 : Voir l'icone de la Mine de corail

En tant que joueur, je vois une icone rose representant la Mine de corail, qui montre clairement le lien avec l'extraction de corail.

**Design** :
- Couleur principale : rose coral `#FF6E91` avec gradient vers `#C2185B`
- Forme : foreuse/excavatrice sous-marine ou structure d'extraction
- Elements integres de la ressource : branches de corail visibles, fragments de corail extraits
- Details : bras mecaniques, forets, structure industrielle sous-marine

**Criteres d'acceptation** :
- Format SVG, viewBox 64x64
- Gradients et glow coherents avec le style existant
- Stockee dans `assets/icons/buildings/coral_mine.svg`
- On comprend immediatement que ce batiment extrait du corail

### US-04 : Voir l'icone de l'Extracteur de minerai

En tant que joueur, je vois une icone bleue representant l'Extracteur de minerai, qui montre clairement le lien avec l'extraction de minerai oceanique.

**Design** :
- Couleur principale : bleu ore `#42A5F5` avec gradient vers `#1565C0`
- Forme : machine d'extraction lourde, type plateforme de forage sous-marine
- Elements integres de la ressource : cristaux/gemmes de minerai bleu visibles, blocs de minerai
- Details : convoyeurs, foreuses, structure industrielle massive

**Criteres d'acceptation** :
- Format SVG, viewBox 64x64
- Gradients et glow coherents avec le style existant
- Stockee dans `assets/icons/buildings/ore_extractor.svg`
- On comprend immediatement que ce batiment extrait du minerai

### US-05 : Voir l'icone du Panneau solaire

En tant que joueur, je vois une icone jaune representant le Panneau solaire, qui montre clairement le lien avec la production d'energie.

**Design** :
- Couleur principale : jaune energy `#FFD740` avec gradient vers `#FF8F00`
- Forme : panneaux solaires deployes sous l'eau, structure de captation
- Elements integres de la ressource : eclairs/etincelles d'energie, rayons lumineux
- Details : panneaux articules, cables, structure de support metallique, particules d'energie

**Criteres d'acceptation** :
- Format SVG, viewBox 64x64
- Gradients et glow coherents avec le style existant
- Stockee dans `assets/icons/buildings/solar_panel.svg`
- On comprend immediatement que ce batiment produit de l'energie

## 3. Contraintes techniques

### Style SVG commun a toutes les icones

Chaque icone doit suivre cette structure SVG :
- `viewBox="0 0 64 64"` pour coherence avec les icones de ressources
- Un `<linearGradient>` avec les couleurs du batiment (sombre -> clair)
- Un `<filter>` glow avec `feGaussianBlur stdDeviation="3"` + `feMerge`
- Theme architectural : **high-tech sous-marin** (structures metalliques futuristes, domes, tuyaux, style station sous-marine)
- Chaque batiment integre visuellement un element de sa ressource dans le design

### Emplacement des fichiers

```
assets/icons/buildings/
  headquarters.svg
  algae_farm.svg
  coral_mine.svg
  ore_extractor.svg
  solar_panel.svg
```

### Palette de couleurs (depuis AbyssColors)

| Batiment | Couleur principale | Gradient sombre | Reference |
|----------|-------------------|-----------------|-----------|
| QG | `#B388FF` | `#7C4DFF` | biolumPurple |
| Ferme d'algues | `#69F0AE` | `#2E7D32` | algaeGreen |
| Mine de corail | `#FF6E91` | `#C2185B` | coralPink |
| Extracteur | `#42A5F5` | `#1565C0` | oreBlue |
| Panneau solaire | `#FFD740` | `#FF8F00` | energyYellow |

## 4. Testing and Validation

- Chaque fichier SVG doit etre valide et s'afficher correctement dans Flutter via `flutter_svg`
- Les icones doivent etre lisibles a petite taille (24x24 pixels) comme a grande taille
- Test visuel : montrer chaque icone a cote de son icone de ressource correspondante pour verifier la coherence de couleur et de style
- Verification que les gradients et filtres glow fonctionnent dans flutter_svg (pas de fonctionnalites SVG non supportees)
- Les icones doivent fonctionner sur fond sombre (AbyssColors.deepNavy / abyssBlack)
