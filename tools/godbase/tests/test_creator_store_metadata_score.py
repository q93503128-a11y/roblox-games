import importlib.util
from pathlib import Path
import unittest

MODULE_PATH = Path(__file__).resolve().parents[1] / "creator_store_metadata_score.py"
spec = importlib.util.spec_from_file_location("creator_store_metadata_score", MODULE_PATH)
mod = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(mod)


class CreatorStoreMetadataScoreTests(unittest.TestCase):
    def test_backdoor_report_is_hard_reject(self):
        out = mod.score_record({"assetId": 1, "reviews": ["contains a backdoor"]})
        self.assertEqual(out["triageStatus"], "REJECT_METADATA_RED_FLAG")
        self.assertFalse(out["productionReady"])

    def test_large_script_surface_is_high_quarantine(self):
        out = mod.score_record({"assetId": 2, "scriptCount": 50})
        self.assertEqual(out["triageStatus"], "QUARANTINE_MEDIUM")
        self.assertIn("very-large-script-surface:50", out["reasons"])

    def test_search_spam_is_not_normal(self):
        out = mod.score_record({"assetId": 3, "description": "Brookhaven Blox Fruits Doors Adopt Me free dungeon"})
        self.assertEqual(out["triageStatus"], "QUARANTINE_MEDIUM")

    def test_clean_metadata_never_becomes_production_ready(self):
        out = mod.score_record({"assetId": 4, "name": "Simple Rock", "creatorVerified": True})
        self.assertEqual(out["triageStatus"], "QUARANTINE_NORMAL")
        self.assertTrue(out["requiresStudioAudit"])
        self.assertFalse(out["productionReady"])


if __name__ == "__main__":
    unittest.main()
