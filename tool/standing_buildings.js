// Cuts each building illustration out of its square card, so that it can
// stand on the isometric ground of the base: keeps the defs and the
// building, drops the water, its light, the sand floor and the frame.
//
//   node tool/standing_buildings.js
//
// Reads the cards of assets/icons/buildings (and the volcanic kernel of
// assets/icons/terrain) and writes assets/icons/buildings/standing/.
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..', 'assets', 'icons');
const outDir = path.join(root, 'buildings', 'standing');

// Sections of a card that are scenery, by their comment, without accents.
const DROPPED = new Set([
  'eau', 'rayons de lumiere', 'rayons captes', 'lueur', 'lueur au sol',
  'lueur sur le sol', 'lueur rose au sol', 'lueur cyan au sol',
  'particules en suspension', 'particules proches', 'plancher de sable',
  'galets', 'coquillages', 'petites algues et anemones',
  'galets, coquillages, algues', 'galets, coquillages, algues, gorgones',
  'bulles', 'cadre', 'faisceaux des projecteurs', 'halo de la citadelle',
  'halo ambiant teal', 'banc de petits poissons', 'suspended particles',
  'basalt gravel',
]);

const plain = (text) =>
  text.normalize('NFKD').replace(/[̀-ͯ]/g, '').trim().toLowerCase();

function cards() {
  const dir = path.join(root, 'buildings');
  return fs
    .readdirSync(dir)
    .filter((name) => name.endsWith('.svg'))
    .map((name) => path.join(dir, name))
    .concat(path.join(root, 'terrain', 'volcanic_kernel.svg'));
}

// The card [svg] reduced to its defs and the sections kept. Anything drawn
// before the first named section is an unnamed background and goes too.
function standing(svg) {
  const cut = svg.indexOf('</defs>') + '</defs>'.length;
  const body = svg.slice(cut).replace(/<\/svg>\s*$/, '');
  const parts = body.split(/(<!--[\s\S]*?-->)/);
  const kept = [];
  for (let i = 1; i < parts.length; i += 2) {
    if (!DROPPED.has(plain(parts[i].slice(4, -3)))) {
      kept.push(parts[i] + parts[i + 1]);
    }
  }
  return `${svg.slice(0, cut)}\n${kept.join('').trim()}\n</svg>\n`;
}

fs.mkdirSync(outDir, { recursive: true });
for (const card of cards()) {
  const out = path.join(outDir, path.basename(card));
  fs.writeFileSync(out, standing(fs.readFileSync(card, 'utf8')));
  console.log(path.relative(process.cwd(), out));
}
