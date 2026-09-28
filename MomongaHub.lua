local Games = {
	[92163766632239] = {
		Name = "Anime World Capsule",
		URL = "https://raw.githubusercontent.com/Momonga67/MomongaHub/main/AnimeWorldCapsule.lua"
	},

	[111097829542198] = {
		Name = "Legacy Piece",
		URL = "https://raw.githubusercontent.com/Momonga67/MomongaHub/main/LegacyPiece.lua"
	}
}

local data = Games[game.PlaceId]

if not data then
	warn("[MomongaHub] Unsupported game!")
	warn("[MomongaHub] PlaceId: " .. tostring(game.PlaceId))
	return
end

print("[MomongaHub] Detected: " .. data.Name)

local success, err = pcall(function()
	local source = game:HttpGet(data.URL)
	local fn, compileError = loadstring(source)

	if not fn then
		error(compileError or "Compilation failed")
	end

	fn()
end)

if not success then
	warn("[MomongaHub] Failed to load " .. data.Name)
	warn(err)
end
