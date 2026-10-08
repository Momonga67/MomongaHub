-- MomongaHub central game loader
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local PLACE_OR_GAME_ID = 93934100402512

local Routes = {
   
    [92163766632239] = "https://raw.githubusercontent.com/Momonga67/MomongaHub/refs/heads/main/AnimeWorldCapsule.lua",
    [111097829542198] = "https://raw.githubusercontent.com/Momonga67/MomongaHub/refs/heads/main/LegacyPiece.lua",
    [93934100402512] = "https://raw.githubusercontent.com/Momonga67/MomongaHub/refs/heads/main/CloverTime.lua",
    [90920025162454] = "https://raw.githubusercontent.com/Momonga67/MomongaHub/refs/heads/main/RollAFisherman.lua",
}

local id = game.PlaceId
local url = Routes[id]

if not url then
    id = game.GameId
    url = Routes[id]
end

if not url then
    warn("[MomongaHub] Unsupported game. PlaceId=" .. tostring(game.PlaceId) ..
         " GameId=" .. tostring(game.GameId))
    return
end

local ok, source = pcall(function()
    return game:HttpGet(url)
end)

if not ok then
    error("[MomongaHub] Failed to download game script: " .. tostring(source))
end

local chunk, compileError = loadstring(source)
if not chunk then
    error("[MomongaHub] Failed to compile game script: " .. tostring(compileError))
end

return chunk()
