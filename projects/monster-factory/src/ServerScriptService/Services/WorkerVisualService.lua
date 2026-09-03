local WorkerVisualService = {}

-- Visual Rebuild 006 retired the dedicated WorkerVisualStateUpdated bridge.
-- Equipped worker presentation now derives from the canonical public monster
-- state plus zone state on the client. The service remains as a compatibility
-- dependency because existing gameplay services still call PushState().

function WorkerVisualService.PushState(_player)
    -- Intentionally no-op. MonsterService/ZoneService already publish the
    -- canonical states consumed by WorkerCharacters.client.lua.
end

function WorkerVisualService.Init(_playerDataService, remoteService)
    -- Keep the old RemoteFunction inert for compatibility with the legacy
    -- ClientBootstrap until that controller is split further. Returning nil
    -- guarantees that it cannot create the old orb handoff visuals.
    remoteService.Get("RequestWorkerVisualState").OnServerInvoke = function(_player)
        return nil
    end
end

return WorkerVisualService
