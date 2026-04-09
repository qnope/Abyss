# Task 06 — Coral Citadel SVG asset

## Summary

Author `assets/icons/buildings/coral_citadel.svg`, a fully detailed 64×64 SVG of the Citadelle corallienne. The file is the visual centerpiece of the feature and must satisfy the SPEC's strict content and palette requirements.

## Content requirements (from SPEC §2 / US-4)

Mandatory palette:
- **Corail rose**: `#F48FB1`, `#EC407A`, `#AD1457`
- **Bleu profond**: `#1A237E`, `#283593`, `#3949AB`
- **Accents** blanc / ivoire for hublots & cristaux (e.g. `#FFFFFF`, `#E0F7FA`, `#B3E5FC`)

Mandatory decorative elements (all seven, unified composition — not a grid of icons):
1. **Massive central fortress** — trapezoidal / wide pentagon base, stylized stone-block stroke lines, coral-pink gradient fill.
2. **Crenellated corner towers** — at least 2 (ideally 4), rising above the main body, topped with square merlons.
3. **Coral defensive spikes** — 3 to 5 pointy outgrowths emerging from the sides or top.
4. **Central engraved emblem** — stylized shield or starfish crest in deep blue over pink, on the main façade.
5. **Lit portholes** — 3 to 5 small round / square openings with dark navy background and bright cyan / white halo.
6. **Glowing defensive crystals** — 2 to 4 small crystals embedded in the walls, blue-cyan gradient with partial opacity for magic glow.
7. **Algae banners** — 2 vertical stylized algae hanging beside the towers, dark-green to blue gradient, banner-like motion curves.

Other constraints:
- `viewBox="0 0 64 64"`.
- Target file size ≈ 5 KB (within ±1 KB is fine). If you exceed 6 KB, simplify gradients / remove redundant nodes.
- A subtle `<filter id="citadelGlow">` with `feGaussianBlur` wrapping the main group — matches the style of the HQ SVG.
- Legible at small sizes (≈ 24–32 px). Avoid strokes thinner than `0.4`.
- Silhouette must be recognizable in half a second: massive pink fortress with crenellations on deep-blue / navy background, clearly distinct from the purple-dome HQ.

## Implementation steps

1. **Create** `assets/icons/buildings/coral_citadel.svg`. Use the HQ SVG (`assets/icons/buildings/headquarters.svg`) as a structural template: same `<defs>` → `<linearGradient>` + `<filter feGaussianBlur>` → wrapped `<g filter=...>` layout.

2. **Compose from back to front**:
   - Back wall / main fortress body (coral pink gradient)
   - Engraved stone-block strokes
   - Corner towers + merlons
   - Engraved emblem (deep blue)
   - Portholes (navy circle + cyan halo)
   - Crystals (cyan gradient, partial opacity)
   - Defensive spikes (coral pink, pointy polygons)
   - Algae banners (dark green → deep blue linear gradients, flanking the fortress)

3. **Gradients** — define at most 4 linear gradients to stay within budget:
   - `citadelPink` (`#F48FB1` → `#AD1457`)
   - `citadelNavy` (`#3949AB` → `#1A237E`) for emblem / shadows
   - `citadelCrystal` (`#B3E5FC` → `#1A237E`) for the crystals
   - `citadelAlgae` (`#2E7D32` → `#1A237E`) for the banners

4. **Filter** — a single `citadelGlow` filter with `stdDeviation` around 2–3, wrapping the top-level `<g>`. Match the HQ style (`feMerge` of blurred copy + source graphic).

5. **Validation checklist (to run during authoring)**:
   - `wc -c assets/icons/buildings/coral_citadel.svg` → ≤ 6000.
   - Open the file in the Flutter DevTools or a browser and check silhouette at 24 px, 48 px, and 128 px.
   - Count elements with an SVG inspector to confirm all seven decorative pieces are present.

6. **Do NOT** add the asset to `pubspec.yaml` — the `assets:` section already uses the `assets/icons/buildings/` directory wildcard (`pubspec.yaml:29-31`), so any new file in that folder is auto-included.

## Files touched

- `assets/icons/buildings/coral_citadel.svg` (new)

## Dependencies

- **Internal**: task 05 for the matching `iconPath`. Either order is fine; both must land for the UI to render without exceptions.
- **External**: none.

## Test plan

1. **Automated sanity** — add a lightweight test `test/assets/coral_citadel_svg_test.dart`:
   - Load the asset bundle via `rootBundle.loadString('assets/icons/buildings/coral_citadel.svg')` in a widget test (`testWidgets` with `tester.runAsync`).
   - Assert the raw content contains the mandatory palette strings `#F48FB1`, `#1A237E`, and at least one of the mandatory gradient ids.
   - Assert the file size is below 7000 bytes (soft upper bound).

2. **Manual visual check** — run the app (`flutter run`), navigate to the Building tab after granting HQ level 3 resources (or use a hot-seeded save), and confirm the Citadel card displays the SVG correctly. Compare the silhouette side-by-side with the HQ card.

## Notes

- Budget is tight but achievable — the `coral_mine.svg` at 5 KB shows this level of detail is possible. Prefer reusing gradients across multiple shapes to save bytes.
- Do not use `<image>` embeds, external references, or `<style>` blocks — keep it pure SVG elements with inline attributes to match the other assets.
- Coordinates: keep the fortress centered around `(32, 38)`, the algae banners near x≈6 and x≈58, and the towers roughly at y=14.
- This is the most author-intensive task of the feature; schedule more than 5 minutes for it. That is a conscious exception to the "5 minutes per task" guideline: splitting further would fragment the composition.
