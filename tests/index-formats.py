"""Render the actual index in isolation: web badges, document citation links.

Run after R/Quarto/TinyTeX setup: python tests/index-formats.py
No Atlas project hooks, publication steps, or network badge conversion in PDF.
"""
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ZENODO = "https://zenodo.org/badge/latestdoi/452585667"
OSF = "https://osf.io/6w5k8/"
LICENSE = "https://github.com/patolojiatlasi/patolojiatlasi.github.io/blob/main/LICENSE"
BADGES = (
    "https://zenodo.org/badge/452585667.svg",
    "https://img.shields.io/github/issues/patolojiatlasi/patolojiatlasi.github.io",
    "https://img.shields.io/github/license/patolojiatlasi/patolojiatlasi.github.io",
)


def render_index(language, output_format, source, trace=False):
    with tempfile.TemporaryDirectory(prefix="atlas-index-") as directory:
        work = Path(directory)
        (work / "R").mkdir()
        (work / "R/language.R").write_text(f'language <- "{language}"\n')
        (work / "index.qmd").write_text(source)
        # An isolated project prevents the Atlas render/publish hooks from running.
        (work / "_quarto.yml").write_text(
            'project:\n  type: default\nbook:\n  title: "Atlas citation check"\n'
            'execute:\n  freeze: false\nformat:\n  html: {}\n  pdf:\n    keep-tex: true\n'
        )
        result = subprocess.run(
            ["quarto", "render", "index.qmd", "--to", output_format],
            cwd=work, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        )
        if trace:
            tex = work / "index.tex"
            if tex.exists():
                lines = tex.read_text().splitlines()
                for i, line in enumerate(lines):
                    if "includesvg" in line or "mediabag/badge" in line:
                        print("Legacy TeX media trace:\n" + "\n".join(lines[max(0, i-3):i+4]), flush=True)
            print(f"Legacy PDF exit status: {result.returncode}", flush=True)
            return
        if result.returncode:
            raise AssertionError(f"{language}/{output_format}:\n{result.stdout}")
        target = work / ("index.html" if output_format == "html" else "index.tex")
        text = target.read_text()
        for link in (ZENODO, OSF, LICENSE):
            assert link in text, (language, output_format, "Missing citation link", link)
        if output_format == "html":
            for badge in BADGES:
                assert badge in text, (language, "Missing web badge", badge)
            assert "twitter.com/intent/tweet" in text
            assert "randomIframe" in text
        else:
            assert (work / "index.pdf").stat().st_size > 0
            assert "10.17605/OSF.IO/6W5K8" in text
            assert "Zenodo DOI" in text
            assert "includesvg" not in text
            assert "img.shields.io" not in text
            assert "452585667.svg" not in text
            assert "randomIframe" not in text
        print(f"index {language}/{output_format}: PASS", flush=True)


if __name__ == "__main__":
    source = (ROOT / "index.qmd").read_text()
    # Reconstruct the former citation guard once to identify the failing media's
    # enclosing hyperlink in generated TeX. This diagnostic is not a pass gate:
    # external badge endpoints can change; current renders must always pass.
    opening = '::: {.content-visible when-format="html"}'
    closing = '::: {.content-hidden when-format="html"}'
    before, table = source.split(opening, 1)
    table, after = table.split(closing, 1)
    table = table.rstrip().removesuffix(':::').rstrip()
    _, after = after.split(':::', 1)
    legacy = before + '```{asis, echo = (output_type=="html")}\n' + table + '\n```' + after
    render_index("TR", "pdf", legacy, trace=True)
    for language in ("TR", "EN"):
        for output_format in ("html", "pdf"):
            render_index(language, output_format, source)
