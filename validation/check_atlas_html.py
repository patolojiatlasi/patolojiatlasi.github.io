"""Check both freshly rendered Atlas HTML editions (PR #13 regression checks).

Requires Python 3, PyYAML and lxml. From the source checkout run:
    python validation/check_atlas_html.py . /path/to/TR/output /path/to/EN/output

The outputs must be complete builds, not focused single-page renders.
This inspects local HTML/metadata; it does not fetch remote viewers or certify WCAG.
"""

import json, re, sys, yaml, posixpath
from pathlib import Path
from lxml import html, etree
from urllib.parse import urlsplit, unquote, urljoin

if len(sys.argv) != 4:
    raise SystemExit(__doc__)
repo = Path(sys.argv[1])
roots = {"TR": Path(sys.argv[2]), "EN": Path(sys.argv[3])}
errors = []
notes = []


def check(ok, msg):
    if not ok:
        errors.append(msg)


def paths(obj):
    if isinstance(obj, str):
        return [obj] if obj.endswith(".qmd") else []
    if isinstance(obj, dict):
        return sum([paths(v) for v in obj.values()], [])
    if isinstance(obj, list):
        return sum([paths(v) for v in obj], [])
    return []


seo = yaml.safe_load((repo / "config/seo.yml").read_text())
mappings = yaml.safe_load((repo / "chapter-mappings.yml").read_text())["chapters"]
allpaths = {}
for lang, expected in [("TR", 82), ("EN", 79)]:
    book = yaml.safe_load((repo / f"_quarto_chapters_{lang}.yml").read_text())["book"]
    ps = paths([book["chapters"], book["appendices"]])
    allpaths[lang] = [p[:-4] + ".html" for p in ps]
    check(
        len(ps) == len(set(ps)) == expected,
        f"{lang}: expected {expected} unique routes, got {len(ps)}",
    )
    root = roots[lang]
    cfg = yaml.safe_load((repo / f"_quarto_{lang}.yml").read_text())
    host = cfg["book"]["site-url"]
    docs = {}
    for p in allpaths[lang]:
        check((root / p).is_file(), f"{lang}: missing {p}")
        if not (root / p).exists():
            continue
        raw = (root / p).read_text()
        doc = html.fromstring(raw)
        docs[p] = doc
        check(
            not re.search("oncocytoma|onkositom", raw, re.I),
            f"{lang}/{p}: unavailable oncocytoma reference",
        )
        check(
            len(doc.xpath('//link[@rel="canonical"]')) == 1,
            f"{lang}/{p}: canonical count",
        )
        # All book chapters must be reachable from every rendered chapter sidebar.
        hrefs = {
            urlsplit(urljoin(host + p, x)).path.lstrip("/")
            for x in doc.xpath('//*[@id="quarto-sidebar"]//a/@href')
        }
        check(
            set(allpaths[lang]) <= hrefs,
            f"{lang}/{p}: missing chapter navigation {set(allpaths[lang])-hrefs}",
        )
    for p, desc in seo["descriptions"][lang].items():
        if p not in docs:
            continue
        doc = docs[p]
        for attr, key in [
            ("name", "description"),
            ("property", "og:description"),
            ("name", "twitter:description"),
        ]:
            check(
                doc.xpath(f'//meta[@{attr}="{key}"]/@content') == [desc],
                f"{lang}/{p}: incorrect {key}",
            )
    kidney = "bobrek.html" if lang == "TR" else "kidney.html"
    d = docs.get(kidney)
    if d is not None:
        main = d.xpath("//main")[0]
        txt = " ".join(main.itertext())
        notice = (
            "Bu bölüm için vaka hazırlanıyor."
            if lang == "TR"
            else "A case is being prepared for this chapter."
        )
        check(notice in txt, f"{lang}: kidney preparation notice missing")
        check(len(main.xpath(".//h1")) == 1, f"{lang}: kidney H1 count")
        check(not main.xpath(".//iframe"), f"{lang}: kidney iframe remains")
    search = root / "search.json"
    check(search.exists(), f"{lang}: search.json missing")
    if search.exists():
        raw = search.read_text()
        check(
            not re.search("oncocytoma|onkositom", raw, re.I),
            f"{lang}: oncocytoma in search",
        )
        data = json.loads(raw)
        hs = {urlsplit(x["href"]).path for x in data}
        check(kidney in hs, f"{lang}: kidney missing in search")
    # Check changed/new navigation and GI internal links including local fragment targets.
    broken = []
    for p, doc in docs.items():
        nodes = doc.xpath(
            '//*[@id="quarto-sidebar"]//a[@href] | //nav[contains(@class,"page-navigation")]//a[@href]'
        )
        if p == "gastro.html":
            nodes += doc.xpath("//main//a[@href]")
        for node in nodes:
            href = node.get("href")
            u = urlsplit(href)
            if u.netloc and not href.startswith(host):
                continue
            if u.scheme and u.scheme not in ("http", "https"):
                continue
            path = unquote(u.path)
            if href.startswith(host):
                path = path.lstrip("/") or "index.html"
            elif path.startswith("/"):
                path = path[1:]
            elif not path:
                path = p
            else:
                path = posixpath.normpath(str(Path(p).parent / path))
            dest = root / path
            if dest.is_dir():
                dest = dest / "index.html"
            if not dest.is_file():
                broken.append((p, href, "missing file"))
                continue
            if u.fragment and dest.suffix == ".html":
                target = docs.get(path)
                if target is None:
                    target = html.parse(str(dest))
                if not target.xpath(
                    "//*[@id=$id or @name=$id]", id=unquote(u.fragment)
                ):
                    broken.append((p, href, "missing fragment"))
    check(not broken, f"{lang}: broken reviewed internal links {broken[:15]}")
    sitemap = etree.parse(str(root / "sitemap.xml"))
    urls = sitemap.xpath('//*[local-name()="url"]/*[local-name()="loc"]/text()')
    check(len(urls) == expected, f"{lang}: sitemap count {len(urls)}")
    notes.append(
        f'{lang}: {len(docs)} pages, {len(seo["descriptions"][lang])} description triplets, kidney notice/H1, sidebar coverage, search, reviewed internal links, {len(urls)} sitemap URLs checked'
    )
# Reciprocal bilingual alternates match configured mappings only.
pairs = []
for m in mappings:
    tr = m["tr"] + ".html"
    en = ("index" if m["tr"] == "index" else m["en"]) + ".html"
    if (
        tr in allpaths["TR"]
        and en in allpaths["EN"]
        and not {tr, en} & set(seo["hreflang-exclude"])
    ):
        pairs.append((tr, en))
for tr, en in pairs:
    for lang, p in [("TR", tr), ("EN", en)]:
        d = html.parse(str(roots[lang] / p))
        links = {
            n.get("hreflang"): n.get("href")
            for n in d.xpath('//link[@rel="alternate"][@hreflang]')
        }
        for code, path in [("tr", tr), ("en", en)]:
            host = yaml.safe_load((repo / f"_quarto_{code.upper()}.yml").read_text())[
                "book"
            ]["site-url"]
            check(
                links.get(code) == host + ("" if path == "index.html" else path),
                f"{lang}/{p}: {code} alternate mismatch",
            )
notes.append(f"{len(pairs)} reciprocal bilingual page pairs checked")
# October 22 accessibility additions.
doc = html.parse(str(roots["TR"] / "yonetim-gelistirme.html"))
frames = doc.xpath("//main//iframe")
check(
    len(frames) == 4 and all(n.get("title", "").strip() for n in frames),
    "TR development: direct iframe titles",
)
for token in [
    "patoloji-atlasi-openseadragon-example.png",
    "patoloji-atlasi-quarto-example.png",
    "626x0w.webp",
]:
    ns = doc.xpath("//main//img[contains(@src,$t)]", t=token)
    check(
        len(ns) == 1 and ns[0].get("alt", "").strip(),
        f"TR development: alt text for {token}",
    )
    if ns and not urlsplit(ns[0].get("src")).scheme:
        check(
            (roots["TR"] / ns[0].get("src")).exists(),
            f"TR development: missing image {token}",
        )
archive = repo / "_subchapters_cases_to_find/_kidney-oncocytoma.qmd"
check(
    archive.exists() and "kidneyoncocytoma/HE.html" in archive.read_text(),
    "Archived source missing",
)
check(
    (roots["TR"] / "lists/index.html").is_file(),
    "TR: published case list is missing at lists/index.html",
)
for lang, root in roots.items():
    check(
        not list(root.rglob("*kidney-oncocytoma*")),
        f"{lang}: archived source copied into site",
    )
# Resolve all main-content links to either Atlas host against the fresh editions.
host_roots = {}
for lang, root in roots.items():
    host = urlsplit(
        yaml.safe_load((repo / f"_quarto_{lang}.yml").read_text())["book"]["site-url"]
    ).netloc.removeprefix("www.")
    host_roots[host] = root
link_count = 0
for lang, root in roots.items():
    host = yaml.safe_load((repo / f"_quarto_{lang}.yml").read_text())["book"][
        "site-url"
    ]
    for p in allpaths[lang]:
        doc = html.parse(str(root / p))
        for href in doc.xpath("//main//a/@href"):
            u = urlsplit(urljoin(host + p, href))
            target_root = host_roots.get(u.netloc.removeprefix("www."))
            if target_root is None:
                continue
            dest = target_root / unquote(u.path).lstrip("/")
            if dest.is_dir():
                dest = dest / "index.html"
            check(dest.is_file(), f"{lang}/{p}: missing internal content target {href}")
            link_count += 1
notes.append(
    f"{link_count} main-content links to either Atlas host resolve to local files"
)
print(json.dumps({"checks": notes, "errors": errors}, ensure_ascii=False, indent=2))
sys.exit(bool(errors))
