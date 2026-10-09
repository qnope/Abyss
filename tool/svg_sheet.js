// Renders every SVG under a directory on one contact sheet, to review the
// game art the way a player sees it. Needs Playwright with Chromium.
//
//   node tool/svg_sheet.js assets/icons out.png [cellPx=112] [columns=7]
//
// Optional env: PLAYWRIGHT_MODULE (path to the playwright package) and
// CHROMIUM_PATH (browser executable) when they are not resolvable.
const fs = require('fs');
const path = require('path');

const [root, out, cellArg, columnsArg] = process.argv.slice(2);
if (!root || !out) {
  console.error('usage: node tool/svg_sheet.js <svgDirOrFiles> <out.png>');
  process.exit(1);
}
const cell = parseInt(cellArg || '112', 10);
const columns = parseInt(columnsArg || '7', 10);
const playwright = require(process.env.PLAYWRIGHT_MODULE || 'playwright');

function listSvgs(dir) {
  const files = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) files.push(...listSvgs(full));
    else if (full.endsWith('.svg')) files.push(full);
  }
  return files.sort();
}

const isDir = fs.existsSync(root) && fs.statSync(root).isDirectory();
const files = isDir ? listSvgs(root) : root.split(',');
const base = isDir ? root : path.dirname(files[0]);

const tiles = files.map((file) => {
  const svg = fs
    .readFileSync(file, 'utf8')
    .replace('<svg ', `<svg width="${cell}" height="${cell}" `);
  const name = path.relative(base, file).replace(/\.svg$/, '');
  return `<div class="tile"><div class="art">${svg}</div><div>${name}</div></div>`;
});

const html = `<html><head><style>
  body { margin: 0; background: #0b1526; color: #9fb3c8;
         font: 11px sans-serif; }
  .grid { display: grid; gap: 8px; padding: 8px;
          grid-template-columns: repeat(${columns}, ${cell + 16}px); }
  .tile { background: #13213a; border-radius: 8px; padding: 8px;
          text-align: center; word-break: break-all; }
  .art { width: ${cell}px; height: ${cell}px; margin: 0 auto 4px; }
</style></head><body><div class="grid">${tiles.join('')}</div></body></html>`;

(async () => {
  const browser = await playwright.chromium.launch({
    executablePath: process.env.CHROMIUM_PATH,
  });
  const page = await browser.newPage({
    viewport: { width: columns * (cell + 24) + 16, height: 400 },
  });
  await page.setContent(html);
  await page.screenshot({ path: out, fullPage: true });
  await browser.close();
  console.log(`${out}: ${files.length} SVG`);
})();
