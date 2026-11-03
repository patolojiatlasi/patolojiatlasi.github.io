from contextlib import redirect_stdout
import importlib.util
import io
from pathlib import Path
import tempfile
import unittest

import yaml

spec = importlib.util.spec_from_file_location("check", Path(__file__).with_name("check_screenshots.py"))
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)


class ScreenshotCheck(unittest.TestCase):
    def test_publication_gate(self):
        with tempfile.TemporaryDirectory() as directory, redirect_stdout(io.StringIO()):
            root = Path(directory)
            (root / "lists").mkdir()
            (root / "screenshots").mkdir()
            (root / "screenshots/existing.png").touch()
            entries = [dict(stainname="HE", type="published", screenshot="./screenshots/existing.png"),
                       dict(stainname="CD3", type="unpublished", screenshot="https://www.patolojiatlasi.com/screenshots/missing.png?x=1")]
            for name in ("list.yaml", "yaml_preparation_file.yaml"):
                (root / "lists" / name).write_text(yaml.safe_dump(entries))
            _, findings = check.audit(root)
            self.assertEqual(len(findings), 2)
            self.assertFalse(any(f["blocking"] for f in findings))
            self.assertEqual(check.main([directory]), 0)
            self.assertEqual(check.main([directory, "--all"]), 1)
            entries[0]["screenshot"] = "/screenshots/missing%20HE.png"
            (root / "lists/list.yaml").write_text(yaml.safe_dump(entries))
            self.assertEqual(check.main([directory]), 1)

    def test_url_boundaries_and_traversal(self):
        self.assertIsNone(check.local_target("https://elsewhere.org/screenshots/a.png"))
        self.assertEqual(check.local_target("screenshots/a%20b.png#x"), "screenshots/a b.png")
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "lists").mkdir()
            (root / "outside.png").touch()
            for name in ("list.yaml", "yaml_preparation_file.yaml"):
                (root / "lists" / name).write_text(yaml.safe_dump([dict(type="published", screenshot="screenshots/../outside.png")]))
            _, findings = check.audit(root)
            self.assertEqual(len(findings), 2)

    def test_qmd_literals_are_checked_once(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "lists").mkdir()
            for name in ("list.yaml", "yaml_preparation_file.yaml"):
                (root / "lists" / name).write_text("[]")
            (root / "case.qmd").write_text('![HE](./screenshots/HE.png)\nfile="./screenshots/HE.png"')
            _, findings = check.audit(root, ["case.qmd"])
            self.assertEqual(len(findings), 1)
            self.assertTrue(findings[0]["blocking"])
