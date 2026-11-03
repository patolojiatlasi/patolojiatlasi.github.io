"""Read-only validation of local/Atlas-hosted catalog screenshots; no HTTP."""
import argparse
from pathlib import Path
import sys
import re
from urllib.parse import unquote, urlsplit

import yaml

ATLAS_HOSTS = {"patolojiatlasi.com", "www.patolojiatlasi.com",
               "histopathologyatlas.com", "www.histopathologyatlas.com"}


def local_target(value):
    if not isinstance(value, str) or not value.strip():
        return None
    url = urlsplit(value)
    if url.netloc and url.hostname not in ATLAS_HOSTS:
        return None
    path = unquote(url.path).removeprefix("./").lstrip("/")
    return path if path.startswith("screenshots/") else None


def audit(root, qmd_files=()):
    root = Path(root).resolve()
    findings, summaries = [], []
    for name in ("list.yaml", "yaml_preparation_file.yaml"):
        entries = yaml.safe_load((root / "lists" / name).read_text(encoding="utf-8"))
        if not isinstance(entries, list):
            raise ValueError(f"{name}: expected a list")
        missing = checked = 0
        for entry in entries:
            target = local_target(entry.get("screenshot"))
            if target is None:
                continue
            checked += 1
            resolved = (root / target).resolve()
            if not resolved.is_relative_to(root / "screenshots") or not resolved.is_file():
                missing += 1
                findings.append({"source": f"lists/{name}", "entry": entry.get("stainname", "<unknown>"),
                                 "target": target,
                                 "blocking": name == "list.yaml" and entry.get("type") == "published"})
        summaries.append(f"lists/{name}: {len(entries)} entries, {checked} local references, {missing} missing")
    for file in qmd_files:
        text = (root / file).read_text(encoding="utf-8")
        # Check literal screenshot paths in Markdown, HTML and R chunks.
        targets = set(re.findall(r"screenshots/[^\s\)\]<>\"'`{}]+\.(?:png|jpe?g|webp)", text))
        for target in sorted(targets):
            target = local_target(target)
            resolved = (root / target).resolve()
            if not resolved.is_relative_to(root / "screenshots") or not resolved.is_file():
                findings.append({"source": str(file), "entry": "QMD", "target": target, "blocking": True})
    return summaries, findings


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--all", action="store_true", help="Also fail on staging/unpublished targets")
    parser.add_argument("--qmd", action="append", default=[], help="Check literal source screenshot targets; repeatable")
    args = parser.parse_args(argv)
    summaries, findings = audit(args.root, args.qmd)
    for line in summaries:
        print(line)
    for finding in findings:
        level = "ERROR" if finding["blocking"] or args.all else "WARN"
        print(f'{level} {finding["source"]}: {finding["entry"]}: {finding["target"]}')
    return int(any(f["blocking"] or args.all for f in findings))


if __name__ == "__main__":
    sys.exit(main())
