# Abyss Tech Tree Icons Library

## Quick Reference

All 20 tech tree icons are ready for integration into your Abyss game project.

### File Organization

#### Architecture Branch
- `tech_corail_renforce.svg` - Hardened coral fragment (metallic sheen, durability)
- `tech_bio_ciment.svg` - Organic cement block (green bio-veins, structural strength)
- `tech_corail_vivant.svg` - Living coral (glowing, active regeneration)

#### Armement Branch
- `tech_alliages_avances.svg` - Layered armor plates (protection, metallurgy)
- `tech_torpilles_guidees.svg` - Guided torpedo (precision, weaponry)
- `tech_armes_impulsion.svg` - EMP energy orb (energy weapons, disruption)

#### Sciences de la Vie Branch
- `tech_recycleurs_air.svg` - Air recycler filter (life support, sustainability)
- `tech_population_resiliente.svg` - Resilient population (human figures, society)
- `tech_medecine_abyssale.svg` - Abyssal medicine (healing, biotech with purple tentacle)

#### Énergie Branch
- `tech_condensateurs.svg` - Crystalline battery (power storage, energy)
- `tech_boucliers_energetiques.svg` - Energy shields (force hexagon, protection)
- `tech_leurres_photoniques.svg` - Photonic decoys (holograms, cloaking)

#### Centrale Branch (Hub Technologies)
- `tech_cartographie_avancee.svg` - Advanced cartography (map, exploration)
- `tech_diplomatie_avancee.svg` - Advanced diplomacy (sealed scroll, peace)
- `tech_navigation_profonde.svg` - Deep navigation (compass, guidance)

#### Branch Icons (Category Markers)
- `tech_branche_architecture.svg` - Coral pillar (structural symbol)
- `tech_branche_armement.svg` - Crossed weapons (crossed torpedo & sword)
- `tech_branche_sciences_vie.svg` - DNA helix (biological sciences)
- `tech_branche_energie.svg` - Lightning in circle (energy/power)
- `tech_branche_centrale.svg` - North star (central hub/core)

## Technical Specifications

- **Dimensions**: 128x128 pixels
- **Format**: SVG 1.1 (scalable vector graphics)
- **Color Space**: RGB
- **Aspect Ratio**: 1:1 (square)

## Color Palette

```
Dark Background:     #0a0e27 (void black)
Primary Teal:        #00ffcc (bright cyan-green)
Primary Blue:        #0099ff (ocean blue)
Light Teal:          #33ffdd (lighter cyan)
Light Blue:          #33bbff (lighter ocean blue)
Purple Accent:       #9900ff (special effects)
Bio Green:           #00dd88 (organic/life)
```

## Features

- **Gradients**: Linear and radial for depth
- **Animations**: Glow and pulse effects (CSS keyframes)
- **Filters**: Gaussian blur for glow effects
- **Opacity Layers**: Creates visual depth
- **Professional SVG**: Valid XML with proper namespaces

## Usage Examples

### HTML
```html
<img src="tech_corail_renforce.svg" alt="Hardened Coral" width="64" height="64">
```

### CSS Background
```css
.tech-icon {
  background-image: url('tech_corail_renforce.svg');
  background-size: contain;
  width: 128px;
  height: 128px;
}
```

### Game Engine (e.g., Godot)
```gdscript
var tech_icon = preload("res://assets/tech_corail_renforce.svg")
```

## Design Notes

Each icon follows consistent design principles:

1. **Dark Theme**: Deep ocean background suggests the abyss
2. **Luminescence**: Teal and blue glows suggest bioluminescence or technology
3. **Organic + Tech**: Mix of coral/biology with geometric precision
4. **Visual Hierarchy**: Important elements are larger and brighter
5. **Symbolic**: Each icon visually represents its technology

## Animation Properties

All icons include CSS animations that activate in supporting browsers:

- **Glow Animation**: 3-second cycle, opacity pulse (0.7 to 1.0)
- **Pulse Animation**: 2-second cycle, radius variation (1 to 1.5)

These are applied selectively to elements using `.glow` and `.pulse` classes.

## File Generation

All icons were generated programmatically using Python 3.
See: `generate_tech_icons.py` in parent directory for regeneration.

The script is fully parametric - modify color values to generate theme variations.

## Integration Checklist

- [ ] Copy all 20 SVG files to your project assets folder
- [ ] Verify icon display in your game engine
- [ ] Test responsive scaling (128px down to 32px)
- [ ] Confirm animation playback in target platform
- [ ] Implement in tech tree UI component
- [ ] Create hover/selection states if needed

## Quality Assurance

- All files are valid SVG 1.1
- All coordinates are precise and centered
- Gradient IDs are unique within each file
- Filter definitions are complete
- Animation syntax is standard CSS
- Files are 2.4-2.8 KB each (efficient)

---
Generated for the Abyss Project
Last Updated: 2026-02-11
