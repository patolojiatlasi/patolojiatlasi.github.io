# Lessons

## 2026-10-22 — Squash merge silently skipped the deploy build

- **Failure:** PR #13 was squash-merged with GitHub's default body, which concatenates every branch commit message. Several contained `[skip ci]`, so the push to `main` did not run the bilingual render/deploy workflow.
- **Detection:** `gh run list` after the merge showed only `pages-build-deployment`, with no "Quarto Render Bilingual Book" run.
- **Prevention:** When squash-merging a branch whose commits carry `[skip ci]`, pass an explicit `--body` without it (or use a merge commit). After merging, check `gh run list`.
