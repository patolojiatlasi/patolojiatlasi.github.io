# Screenshot reconciliation — 2026-11-01

Inspected Atlas tree: `474002900ed906beac91f01c2951a10407a29582`.
Inspected pipeline tree: `dcb719fda464953620af3b2b7d3039ec5539b4d0`.

## Authority and scope

`lists/list.yaml` is the curated, authoritative publication catalog: `lists/index.qmd`,
`lists/published.qmd`, and `lists/stains.qmd` use it as their listing contents;
the pipeline reads it for vocabulary and syncs README metadata into it.
`lists/yaml_preparation_file.yaml` is staging material, with blank titles and
unpublished defaults. Do not replace the curated catalog with staging data.

The measurement below compares literal screenshot references in these two YAML
files against the complete, non-truncated Git tree's root `screenshots/` paths.
It measures path existence, not image integrity, Git LFS hydration or HTTP availability.
No complete catalog, QMD chapter, screenshots or website output was regenerated.
The older pipeline TODO count is historical and is not used here.

| Source | Entries | Local screenshot references | Missing before | Missing after |
| --- | ---: | ---: | ---: | ---: |
| Curated list.yaml | 378 | 377 | 158 | 154 |
| Staging yaml_preparation_file.yaml | 257 | 257 | 133 | 129 |

One additional curated entry (`mucin`, unpublished) has no screenshot field; it is
not a nonexistent filename reference. Before correction, 2 missing curated targets
were published and 156 were unpublished. After correction, 1 published and 153
unpublished targets remain missing. All staging entries are unpublished.
Counts are per catalog entry; references shared across catalogs are not unique assets.
The CSV alongside this report lists every remaining missing target after correction.

## Focused correction

HE, CD3, CD8 and CD20 lymphocytic-gastritis entries in both catalogs now reference
`thumbnail_lymphocytic-gastritis{stain}.png`, matching existing assets and gastrit.qmd.
All other metadata, diagnostic content, existing QMD references and assets are preserved.

The remaining published target is:
`screenshots/thumbnail_duodenum-tubular-adenoma-HE.png`.
No corresponding asset exists in the inspected inventory. Supply a verified screenshot
or make a separate editorial decision about publication status; do not substitute an
unrelated duodenal case image. The new publication gate is expected to fail until this
is resolved or the build genuinely creates the correct image.

## Validation and publication gate

`python -m unittest discover -s validation -p test_screenshots.py` — 3 tests pass.
`python validation/check_screenshots.py .` checks both catalogs offline, fails on missing
published curated targets, and reports staging/unpublished targets as warnings.
`--all` also fails on unpublished and staging targets, for readiness review.
`--qmd gastrit.qmd` additionally checks literal screenshot targets in that source.
The bilingual workflow runs the default check after rendering and before publication.

Using a temporary filesystem inventory populated from the inspected Git tree (not
fabricated image data), gastrit.qmd has zero missing literal screenshot targets.
The checker detects a removed target, encoded paths, traversal outside screenshots,
and missing published targets; tests cover warning versus failure exit behavior.
External-host screenshots are not queried. Dynamic QMD expressions require rendered
output checks; this tool checks literal filenames only.

The companion pipeline change aligns legacy QMD templates, section QMDs, README
catalog blocks and discovery skeletons. New stain screenshots use the undashed QMD
convention. When the Atlas screenshot directory is supplied, existing undashed,
dashed and legacy `*_screenshot.png` stain assets are reused in that order. It never
falls back to a different stain or a case-level image. Comparison-viewer filenames
and existing QR conventions are preserved. Single- and four-stain synthetic fixtures
pass without production regeneration.

No merge, deployment or publication is requested by these changes.
