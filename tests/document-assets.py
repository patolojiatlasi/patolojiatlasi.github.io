"""Focused document regressions; decode the SVG pixels, not URL metadata.

Run: python -m pip install -r tests/document-assets-requirements.txt
     python tests/document-assets.py
"""
import io
import re
import unittest
from pathlib import Path

import cairosvg
from PIL import Image
import yaml
import zxingcpp

ROOT = Path(__file__).resolve().parents[1]
BASE = "https://images.patolojiatlasi.com/"
CASES = {
    "tukuruk.qmd": {
        "mammary-analogue-secretory-carcinoma-HE1_qrcode.svg": BASE + "mammary-analogue-secretory-carcinoma/HE1.html",
        "mammary-analogue-secretory-carcinoma-HE2_qrcode.svg": BASE + "mammary-analogue-secretory-carcinoma/HE2.html",
    },
    "hucre-ici-birikimler.qmd": {
        # Historical HE1 asset name intentionally identifies the HE.html viewer.
        "anthracosis-HE1_qrcode.svg": BASE + "anthracosis/HE.html",
        "anthracosis-HE2_qrcode.svg": BASE + "anthracosis/HE2.html",
    },
}


def decode_asset(path):
    assert path.is_file(), f"Missing QR asset: {path}"
    png = cairosvg.svg2png(url=str(path), output_width=1000, output_height=1000)
    results = zxingcpp.read_barcodes(Image.open(io.BytesIO(png)))
    assert len(results) == 1, f"Expected one readable QR in {path}"
    return results[0].text


def check_links(text, destinations):
    # QR-bearing asis chunks can wrap the thumbnail/link across several lines.
    chunks = re.findall(r"```\{asis[^\n]*\}\s*\n(.*?)```", text, re.S)
    for asset, destination in destinations.items():
        matched = [s for s in chunks if f"./qrcodes/{asset}" in s]
        assert len(matched) == 2, f"Expected TR and EN QR sections for {asset}"
        for chunk in matched:
            urls = re.findall(r"\]\((https://images\.patolojiatlasi\.com/[^)]+)\)", chunk)
            assert urls and set(urls) == {destination}, (asset, urls, destination)
        # Keep the fallback R generator aligned with the committed QR and link.
        generators = re.findall(r"```\{r[^\n]*\}\s*\n(.*?)```", text, re.S)
        generator = [s for s in generators if f'filename = "./qrcodes/{asset}"' in s]
        assert len(generator) == 1
        assert f'qrcode::qr_code("{destination}")' in generator[0]


def check_formats(config):
    formats = config["format"]
    for name in ("epub", "docx"):
        assert isinstance(formats[name], dict), f"format.{name} must be a mapping"


class DocumentAssets(unittest.TestCase):
    def test_qr_assets_and_decoded_destinations(self):
        for destinations in CASES.values():
            for asset, destination in destinations.items():
                with self.subTest(asset=asset):
                    self.assertEqual(decode_asset(ROOT / "qrcodes" / asset), destination)

    def test_bilingual_links_and_fallback_generators(self):
        for source, destinations in CASES.items():
            text = (ROOT / source).read_text()
            check_links(text, destinations)
            # Every literal QR reference in the affected chapters must exist.
            for asset in re.findall(r'!\[\]\((\./qrcodes/[^)]+)\)', text):
                self.assertTrue((ROOT / asset).is_file(), asset)

    def test_epub_word_configuration_and_inheritance(self):
        base = yaml.safe_load((ROOT / "_quarto_epub_word_base.yml").read_text())
        check_formats(base)
        for language in ("TR", "EN"):
            config = yaml.safe_load((ROOT / f"_quarto_{language}_epub_word.yml").read_text())
            check_formats(config)
            self.assertIn("_quarto_epub_word_base.yml", config["metadata-files"])
        en = yaml.safe_load((ROOT / "_quarto_EN_epub_word.yml").read_text())
        self.assertEqual(en["format"]["docx"], {})

    def test_regressions_are_rejected(self):
        with self.assertRaisesRegex(AssertionError, "Missing QR"):
            decode_asset(ROOT / "qrcodes/does-not-exist.svg")
        with self.assertRaisesRegex(AssertionError, "format.docx"):
            check_formats({"format": {"epub": {}, "docx": None}})
        source = (ROOT / "tukuruk.qmd").read_text()
        broken = source.replace("carcinoma/HE1.html", "carcinoma/HE.html")
        with self.assertRaises(AssertionError):
            check_links(broken, CASES["tukuruk.qmd"])
        # A misleading SVG id cannot satisfy the actual pixel decoding check.
        asset = ROOT / "qrcodes/anthracosis-HE1_qrcode.svg"
        self.assertNotEqual(decode_asset(asset), BASE + "anthracosis/HE1.html")


if __name__ == "__main__":
    unittest.main(verbosity=2)
