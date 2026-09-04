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


extract_mod = load_module("extract_quarantine_report", "extract_quarantine_report.py")
merge_mod = load_module("merge_creator_store_audit", "merge_creator_store_audit.py")


class QuarantinePipelineTests(unittest.TestCase):
    def test_extract_marked_json(self):
        text = "noise\nGODBASE_QUARANTINE_AUDIT_BEGIN\n{\"schemaVersion\":1,\"counts\":{\"scripts\":0}}\nGODBASE_QUARANTINE_AUDIT_END\nmore"
        out = extract_mod.extract(text)
        self.assertEqual(out["schemaVersion"], 1)
        self.assertEqual(out["counts"]["scripts"], 0)

    def test_merge_is_pending_not_auto_approved(self):
        record = merge_mod.build_record(
            123,
            "https://create.roblox.com/store/asset/123/example",
            "@creator",
            {"triageStatus": "QUARANTINE_NORMAL", "riskScore": 0, "reasons": []},
            {"counts": {"totalDescendants": 4, "scripts": 0, "localScripts": 0, "moduleScripts": 0, "baseScriptsDisabled": 0, "classes": {}}, "scriptFindings": [], "assetDependencies": [], "warnings": []},
        )
        self.assertEqual(record["decision"]["grade"], "PENDING")
        self.assertFalse(record["productionFit"]["mobileMeasured"])


if __name__ == "__main__":
    unittest.main()
