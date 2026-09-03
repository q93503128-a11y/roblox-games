local VisualAssetManifest = {}

-- External Creator Store assets are provenance/intake references only.
-- Monster Factory must never load these IDs at runtime.
-- A candidate is imported in Studio, sanitized, and then retained only as
-- repository/place-owned visual content after review.

VisualAssetManifest.RuntimeExternalLoadingAllowed = false

VisualAssetManifest.Candidates = {
    EnvironmentPrimary = {
        AssetId = 7436760067,
        Name = "Low Poly Asset Pack",
        Creator = "to_xiCchipYT",
        Status = "approved_for_sanitized_intake",
        IntendedUse = {
            "Meadow vegetation and hills",
            "Desert cacti and border dressing",
            "Simulator-style world boundaries",
        },
        Notes = "Creator description explicitly allows simulator-map use; no resale or commission use.",
    },

    InterfacePrimary = {
        AssetId = 130347426228193,
        Name = "GUI Asset Pack!",
        Creator = "IDemonicRBLX",
        Status = "approved_for_design_intake_only",
        IntendedUse = {
            "panel silhouettes",
            "button/card decoration",
            "shop and rewards visual reference",
        },
        Notes = "Free Creator Store model. Contains one script; remove all bundled scripts before retaining any visuals.",
    },

    FactoryShellReference = {
        AssetId = 6247256567,
        Name = "Factory low poly",
        Creator = "TheSaltyPeanuto",
        Status = "hold_reference_only",
        IntendedUse = {
            "industrial silhouette reference",
        },
        Notes = "Free Creator Store model, but provenance/use terms are less explicit than the primary environment pack. Do not make it canonical without a manual review.",
    },
}

return VisualAssetManifest
