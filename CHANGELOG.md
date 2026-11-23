# Lessons

## 2026-11-23: Edited case files did not reach the site because of the freeze cache

- **Failure:** Title fixes in `_subchapters/*.qmd` were published, but ten chapters (the BS collection, glioma, colon and others) still showed the old titles. `freeze: auto` reuses a chapter's cached output when the md5 of the chapter `.qmd` equals the hash stored in `_freeze_{TR,EN}/<chapter>/execute-results/html.json`. Text pulled in by `{{< include >}}` is not part of that hash, and CI never commits a refreshed cache, so a chapter whose own file is unchanged keeps rendering the case text from the day its cache was committed.
- **Detection:** After publishing, the live headings of `bs.html` and `gliom.html` did not match the sources while `pankreas.html` did. Comparing `md5(chapter.qmd)` with the stored hash showed 41 chapters reusing cached output.
- **Prevention:** After editing a case file, delete the cache folder of every chapter that includes it (`git rm -r _freeze_TR/<tr-name> _freeze_EN/<en-name>`), or the edit will not appear. Verify on the live page, not only by a green build.

## 2026-11-23: A case was added to a chapter that the book does not build

- **Failure:** `_PDAC-adrenal-invasion.qmd` was included in `pankreas.qmd` and reported as placed "under pancreas". `pankreas.qmd` existed, had a mapping in `chapter-mappings.yml` and already held seven cases, but was not in `_quarto_chapters_TR.yml` or `_quarto_chapters_EN.yml`, so no pancreas page was rendered. A second trap: a push only builds and checks; publishing needs a manual run with `publish=true`.
- **Detection:** After publishing, `grep` for the case on the live pancreas page found nothing, and `docs/pankreas.html` did not exist.
- **Prevention:** Before adding a case to a chapter, confirm the chapter file is listed in both `_quarto_chapters_{TR,EN}.yml`. When a chapter is added or removed, update the route counts in `validation/check_atlas_html.py` (83 TR / 80 EN after adding pancreas). Call a case published only after finding it on the live page.

## 2026-11-14: The Lua filter missed iframes produced by shortcodes

- **Failure:** `filters/wsi-iframes.lua` was first registered as a plain filter, which runs before Quarto's own processing. The 42 YouTube iframes from `{{< video >}}` on `hacettepecom.html` came out without `loading="lazy"`.
- **Detection:** Counting `loading="lazy"` against `<iframe` in a rendered page gave 26/68 lazy.
- **Prevention:** A filter that rewrites final HTML (including shortcode output) needs `at: post-quarto`. Check it against a real rendered page, not just a pandoc fixture.

## 2026-10-22 — Squash merge silently skipped the deploy build

- **Failure:** PR #13 was squash-merged with GitHub's default body, which concatenates every branch commit message. Several contained `[skip ci]`, so the push to `main` did not run the bilingual render/deploy workflow.
- **Detection:** `gh run list` after the merge showed only `pages-build-deployment`, with no "Quarto Render Bilingual Book" run.
- **Prevention:** When squash-merging a branch whose commits carry `[skip ci]`, pass an explicit `--body` without it (or use a merge commit). After merging, check `gh run list`.
