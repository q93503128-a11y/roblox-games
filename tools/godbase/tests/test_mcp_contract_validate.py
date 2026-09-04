from __future__ import annotations

import importlib.util
import pathlib
import unittest

MODULE_PATH = pathlib.Path(__file__).resolve().parents[1] / "mcp_contract_validate.py"
spec = importlib.util.spec_from_file_location("mcp_contract_validate", MODULE_PATH)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)
validate_contract = module.validate_contract


def valid_contract():
    return {
        "project": {"name": "demo", "primaryLoop": "spawn -> play"},
        "studioTarget": {"requireExplicitStudioId": True},
        "boot": {"spawnTimeoutSeconds": 20},
        "routes": [
            {
                "id": "primary",
                "priority": "P0",
                "steps": [{"action": "navigate"}],
                "expected": ["completes"],
            }
        ],
        "visualStates": [{"id": "spawn", "required": True, "checks": ["no-z-fighting"]}],
        "deviceMatrix": [{"name": "desktop", "width": 1280, "height": 720}],
        "multiplayer": {"required": False, "maxClients": 8, "scenarios": []},
        "completion": {
            "allowedFinalStates": ["INTERNAL_PROTOTYPE", "READY_FOR_USER_TEST"],
            "readyRequires": ["zeroUnexpectedRuntimeErrors", "allP0RoutesPass"],
        },
    }


class MCPContractValidatorTests(unittest.TestCase):
    def test_valid_contract_passes(self):
        self.assertEqual(validate_contract(valid_contract()), [])

    def test_explicit_studio_id_policy_required(self):
        data = valid_contract()
        data["studioTarget"]["requireExplicitStudioId"] = False
        self.assertIn("studioTarget.requireExplicitStudioId must be true", validate_contract(data))

    def test_p0_route_required(self):
        data = valid_contract()
        data["routes"][0]["priority"] = "P1"
        self.assertIn("at least one P0 route is required", validate_contract(data))

    def test_multiplayer_scenarios_required_when_enabled(self):
        data = valid_contract()
        data["multiplayer"]["required"] = True
        self.assertIn(
            "multiplayer.scenarios required when multiplayer.required=true",
            validate_contract(data),
        )

    def test_client_cap_matches_current_studio_test_service_limit(self):
        data = valid_contract()
        data["multiplayer"]["maxClients"] = 9
        self.assertIn("multiplayer.maxClients must be between 1 and 8", validate_contract(data))


if __name__ == "__main__":
    unittest.main()
