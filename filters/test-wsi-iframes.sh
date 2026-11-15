#!/bin/sh
# Self-check for wsi-iframes.lua: run from the repo root with `sh filters/test-wsi-iframes.sh`.
set -eu
cd "$(dirname "$0")"

md='<iframe src="https://images.patolojiatlasi.com/colon-adenocarcinoma/HE.html" style="height:600px;width:100%;" data-external="1"></iframe>

<iframe title="Custom" src="https://images.patolojiatlasi.com/a/b/viewer_z0.html"></iframe>

<iframe loading="eager" src="https://leanpub.com/x/embed"></iframe>

```{=html}
<iframe src="https://www.youtube.com/embed/x" title=""></iframe>
```

```html
<iframe src="https://images.patolojiatlasi.com/code/HE.html"></iframe>
```'

render() { printf '%s' "$md" | pandoc -f markdown -t html -M lang="$1" --lua-filter wsi-iframes.lua; }

tr=$(render tr)
en=$(render en)

fail() { echo "FAIL: $1"; echo "$tr"; exit 1; }
echo "$tr" | grep -q 'title="Sanal mikroskop — colon-adenocarcinoma / HE" loading="lazy" src=' || fail "TR WSI iframe"
echo "$en" | grep -q 'title="Whole-slide viewer — colon-adenocarcinoma / HE"' || fail "EN title"
echo "$tr" | grep -q '<iframe loading="lazy" title="Custom"' || fail "existing title kept"
# 4 raw iframes get/keep exactly one loading attr; the code-block example gets none.
[ "$(echo "$tr" | grep -c 'loading=')" -eq 4 ] || fail "one loading attr per raw iframe, none in code"
echo "$tr" | grep -q 'loading="eager" src="https://leanpub' || fail "existing loading kept"
echo "$tr" | grep -q 'title="Video"' || fail "empty video title filled"
echo "PASS"
