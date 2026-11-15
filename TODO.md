# Frontend modernization (Modern Web Guidance), 2026-11-14

Plan: removing unused render-blocking libraries, lazy-loading and titling iframes, and fixing script.js.

- [x] Delete unused jQuery 1.11.3 / jQuery UI 1.11.4 and double-loaded OpenSeadragon/Annotorious from `headerTR.html` and `headerEN.html`
- [x] `defer` on `script.js` and `webpages.js` (`_quarto_html_base.yml`)
- [x] `script.js`: no TypeError on pages without `#randomIframe`; remove countapi.xyz call (service unreachable, no `#visitorCount` element)
- [x] `filters/wsi-iframes.lua` (`at: post-quarto`): `loading="lazy"` on every iframe; TR/EN title on WSI iframes; `title="Video"` for blank `{{< video >}}` titles
- [x] Leanpub iframes: `title`, `style="border:0"` instead of `frameborder`/`allowtransparency`; `#randomIframe` title
- [x] Verify (see Results)

## Results
- `sh filters/test-wsi-iframes.sh` → PASS
- `legacy-scan headerTR.html` / `headerEN.html` → 0 findings (was 1 each)
- Rendered `index`, `BOS`, `hacettepecom` in a throwaway worktree:
  - hacettepecom: 68/68 iframes lazy and titled (was 0/68 and 26 WSI + 42 YouTube with `title=""`)
  - no jQuery or OpenSeadragon script tags in any rendered page
- Headless Chrome:
  - BOS: no console errors
  - index: random viewer gets a `src`
  - tab viewers stay unloaded until their tab is opened, the same as the published baseline
- Not run: full `R/bilingual-quarto-book.R`; CI runs it on push

## Follow-ups
- `webpages.js` has malformed URLs (`brain-invasive-meningioma}/HE.html`): a typo in a qmd iframe URL
- Load `webpages.js` (16 KB) only on the home page
- `lists/`, `deneme/`: probably dead code
