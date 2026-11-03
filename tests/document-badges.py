"""Render the actual workflow-status section as a one-chapter Quarto book.

Run after the existing R/Quarto/TinyTeX setup: python tests/document-badges.py
The historical image-only section is also rendered to trace its media filenames.
"""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OPEN = '::: {.content-visible when-format="html"}'
FALLBACK = '::: {.content-hidden when-format="html"}'


def render(section, language, output_format, links, legacy=False):
    with tempfile.TemporaryDirectory(prefix="atlas-status-") as directory:
        work = Path(directory)
        (work / "index.qmd").write_text('# Workflow status {.unnumbered}\n\n' + section)
        (work / "_quarto.yml").write_text(
            'project:\n  type: book\nbook:\n  title: "Atlas status check"\n'
            '  chapters: [index.qmd]\n'
            f'lang: {language.lower()}\n'
            'execute:\n  freeze: false\nformat:\n  html: {}\n  pdf:\n    keep-tex: true\n'
        )
        result = subprocess.run(
            ["quarto", "render", "--to", output_format], cwd=work, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=180,
        )
        # Book output is in _book; TeX can remain in the project root.
        if legacy:
            files = list(work.rglob("*.tex"))
            assert files, result.stdout
            tex = files[0].read_text()
            assert "includesvg" in tex, tex
            assert links[0][1] in tex, tex
            lines = tex.splitlines()
            for i, line in enumerate(lines):
                if "includesvg" in line:
                    print("Original status-section TeX trace:\n" +
                          "\n".join(lines[max(0, i-4):i+4]), flush=True)
                    break
            print(f"Original image section PDF exit status: {result.returncode}", flush=True)
            return
        assert result.returncode == 0, result.stdout
        if output_format == "html":
            text = (work / "_book/index.html").read_text()
            for name, url in links:
                assert url + '/badge.svg' in text, name
                assert f'href="{url}"' in text, name
        else:
            pdfs = list(work.rglob("*.pdf"))
            assert any(p.stat().st_size > 0 for p in pdfs), result.stdout
            tex = next(work.rglob("*.tex")).read_text()
            for name, url in links:
                assert url in tex, name
                assert name in re.sub(r"\s+", " ", tex), name
            assert "includesvg" not in tex
            assert "badge.svg" not in tex
        print(f"workflow status {language}/{output_format}: PASS", flush=True)


if __name__ == "__main__":
    source = (ROOT / "yonetim-gelistirme.qmd").read_text()
    section = source.split(OPEN, 1)[1].split('\n---', 1)[0]
    section = OPEN + section
    badges = section.split(OPEN, 1)[1].split(':::', 1)[0]
    links = re.findall(r'\[!\[([^\]]+)\]\([^\n]+?\)\]\(([^)]+)\)', badges)
    assert len(links) == 7, links
    # This is the exact original, unguarded image section from the source.
    render(badges, "TR", "pdf", links, legacy=True)
    for language in ("TR", "EN"):
        for output_format in ("html", "pdf"):
            render(section, language, output_format, links)
