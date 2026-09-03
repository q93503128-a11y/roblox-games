local AnalyticsConfig = {}

AnalyticsConfig.Events = {
    SessionStart = "session_start",
    OnboardingStep = "onboarding_step",
    FirstHatch = "first_hatch",
    Hatch = "hatch",
    ZoneUnlock = "zone_unlock",
    Rebirth = "rebirth",
    QuestClaim = "quest_claim",
    AchievementClaim = "achievement_claim",
    DailyClaim = "daily_claim",
    PlaytimeClaim = "playtime_claim",
    ContextOfferShown = "context_offer_shown",
    PurchasePrompted = "purchase_prompted",
}

return AnalyticsConfig
