// Renders the app icon SVGs of assets/app_icon/ to the PNGs that
// flutter_launcher_icons.yaml consumes, with Chromium through Playwright.
//
//   node tool/app_icon_png.js
//
// Outputs (next to the sources):
//   app_icon.png            1024 px, opaque  (iOS, web, Android legacy)
//   app_icon_adaptive.png   1024 px, opaque  (Android adaptive background:
//                           the whole scene shrunk into the safe zone)
//   app_icon_foreground.png 1024 px, transparent (Android adaptive
//                           foreground: empty, the background carries the art)
//   favicon.png             64 px, opaque (tight crop of favicon.svg)
//
// Optional env: PLAYWRIGHT_MODULE (path to the playwright package) and
// CHROMIUM_PATH (browser executable) when they are not resolvable.
// Chromium screenshots always carry an alpha channel: ImageMagick's
// `convert` (when present) strips it from the opaque ones so they stay RGB.
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const dir = path.join(__dirname, '..', 'assets', 'app_icon');
const playwright = require(process.env.PLAYWRIGHT_MODULE || 'playwright');

const jobs = [
  { svg: 'app_icon.svg', png: 'app_icon.png', size: 1024, opaque: true },
  { svg: 'app_icon_adaptive.svg', png: 'app_icon_adaptive.png', size: 1024, opaque: true },
  { svg: null, png: 'app_icon_foreground.png', size: 1024, opaque: false },
  { svg: 'favicon.svg', png: 'favicon.png', size: 64, opaque: true },
];

function pageHtml(svg, size) {
  const art = svg
    ? fs.readFileSync(path.join(dir, svg), 'utf8')
        .replace('<svg ', `<svg width="${size}" height="${size}" `)
    : '';
  return `<html><body style="margin:0;background:transparent">${art}</body></html>`;
}

function stripAlpha(file) {
  try {
    execFileSync('convert', [file, '-alpha', 'off', `PNG24:${file}`]);
  } catch (e) {
    console.warn(`${file}: alpha channel kept (ImageMagick convert not usable)`);
  }
}

(async () => {
  const browser = await playwright.chromium.launch({
    executablePath: process.env.CHROMIUM_PATH,
  });
  for (const job of jobs) {
    const page = await browser.newPage({
      viewport: { width: job.size, height: job.size },
      deviceScaleFactor: 1,
    });
    await page.setContent(pageHtml(job.svg, job.size));
    const out = path.join(dir, job.png);
    await page.screenshot({ path: out, omitBackground: !job.opaque });
    await page.close();
    if (job.opaque) stripAlpha(out);
    console.log(`${out}: ${job.size} px`);
  }
  await browser.close();
})();
