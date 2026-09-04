import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


def load_module(name: str, filename: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / filename)
    mod = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(mod)
    return mod


runner = load_module("run_creator_store_profiles", "run_creator_store_profiles.py")
promoter = load_module("promote_creator_store_asset", "promote_creator_store_asset.py")


class CreatorStoreBatchTests(unittest.TestCase):
    def test_build_search_command_uses_profile_and_defaults(self):
        cmd = runner.build_search_command(
            {"id": "nature", "searchCategoryType": "Model", "query": "forest", "pages": 2},
            {"maxPageSize": 100, "sortCategory": "Ratings", "sortDirection": "Descending", "searchView": "Full", "includeOnlyVerifiedCreators": True},
            Path("out.json"),
            "auto",
        )
        self.assertIn("--category", cmd)
        self.assertIn("Model", cmd)
        self.assertIn("--verified-only", cmd)
        self.assertIn("100", cmd)

    def test_unknown_profile_is_rejected(self):
        data = {"profiles": [{"id": "known"}]}
        with self.assertRaises(ValueError):
            runner.selected_profiles(data, {"missing"})


class CreatorStorePromotionTests(unittest.TestCase):
    def complete_review(self, grade="A"):
        return {
            "assetId": 123,
            "name": "Reviewed Rock",
            "sourceUrl": "https://create.roblox.com/store/asset/123/reviewed-rock",
            "creator": "@creator",
            "metadataTriage": {"status": "QUARANTINE_NORMAL", "riskScore": 0, "reasons": []},
            "studioAudit": {
                "placeIsQuarantineOnly": True,
                "scriptsDisabledBeforeInspection": True,
                "descendantCount": 4,
                "scriptCount": 0,
                "localScriptCount": 0,
                "moduleScriptCount": 0,
                "suspiciousSourceFindings": [],
                "assetDependencies": [],
                "pivotOkay": True,
                "collisionOkay": True,
                "unexpectedOriginParts": False,
            },
            "visualReview": {
                "screenshots": ["shot.png"],
                "silhouette": 5,
                "materialQuality": 4,
                "styleFit": 5,
                "scaleFit": 5,
                "readabilityNear": 5,
                "readabilityFar": 4,
            },
            "productionFit": {
                "mobileMeasured": grade == "S",
                "repetitionCountTested": 50 if grade == "S" else None,
                "streamingTested": grade == "S",
                "performanceNotes": ["tested in target scene"] if grade == "A" else [],
            },
            "decision": {
                "grade": grade,
                "reviewer": "Godbase review",
                "reviewedAt": "2026-09-04",
                "sourceAttributionRecord": "credits/assets.md#123",
                "catalogName": "Reviewed Rock",
                "categories": ["nature", "rock"],
                "allowedUse": ["repeated prop"],
                "requiredModifications": [],
                "strengths": ["clean silhouette"],
            },
        }

    def test_pending_review_cannot_promote(self):
        review = self.complete_review()
        review["decision"]["grade"] = "PENDING"
        self.assertTrue(promoter.validate_review(review))

    def test_unresolved_suspicious_source_cannot_promote(self):
        review = self.complete_review()
        review["studioAudit"]["suspiciousSourceFindings"] = [{"patterns": ["numeric-require"]}]
        errors = promoter.validate_review(review)
        self.assertTrue(any("suspicious" in error for error in errors))

    def test_a_grade_can_generate_catalog_proposal(self):
        review = self.complete_review("A")
        catalog = {"schemaVersion": 1, "verifiedDate": "2026-09-03", "statusLegend": {}, "entries": []}
        out = promoter.update_catalog(catalog, review)
        self.assertEqual(out["entries"][0]["status"], "AUDITED_A")
        self.assertEqual(out["entries"][0]["assetId"], 123)

    def test_s_grade_requires_mobile_streaming_and_repetition(self):
        review = self.complete_review("S")
        review["productionFit"]["mobileMeasured"] = False
        errors = promoter.validate_review(review)
        self.assertTrue(any("mobile" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
