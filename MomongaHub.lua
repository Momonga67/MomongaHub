--========================================================
-- MOMONGAHUB UNIVERSAL LOADER
--========================================================

if getgenv().MomongaHubLoaderRunning then
	warn("[MomongaHub] Loader already ran. Stopping duplicate execution.")
	return
end

getgenv().MomongaHubLoaderRunning = true

local PLACE_ID = game.PlaceId
local GAME_ID = game.GameId

print("====================================")
print("[MomongaHub] LOADER STARTED")
print("[MomongaHub] PlaceId =", PLACE_ID)
print("[MomongaHub] GameId =", GAME_ID)
print("====================================")

local Games = {
	[92163766632239] = {
		Name = "Anime World Capsule",
		File = "AnimeWorldCapsule.lua"
	},

	[111097829542198] = {
		Name = "Legacy Piece",
		File = "LegacyPiece.lua"
	}
}

local selected = Games[PLACE_ID]

if not selected then
	warn("[MomongaHub] UNSUPPORTED PLACE")
	warn("[MomongaHub] PlaceId: " .. tostring(PLACE_ID))

	getgenv().MomongaHubLoaderRunning = nil
	return
end

print("[MomongaHub] Selected ONLY:")
print("[MomongaHub] " .. selected.Name)
print("[MomongaHub] File: " .. selected.File)

local URL =
	"https://raw.githubusercontent.com/Momonga67/MomongaHub/main/"
	.. selected.File
	.. "?v="
	.. tostring(os.time())

local success, result = pcall(function()

	print("[MomongaHub] Downloading:")
	print(URL)

	local source = game:HttpGet(URL)

	if not source or #source == 0 then
		error("Downloaded file is empty")
	end

	print(
		"[MomongaHub] Download successful. Size:",
		#source
	)

	local fn, compileError = loadstring(source)

	if not fn then
		error(
			"Compilation error: "
			.. tostring(compileError)
		)
	end

	print(
		"[MomongaHub] Executing ONLY "
		.. selected.File
	)

	fn()
end)

getgenv().MomongaHubLoaderRunning = nil

if not success then
	warn("[MomongaHub] LOAD FAILED:")
	warn(result)
else
	print(
		"[MomongaHub] Finished loading "
		.. selected.Name
	)
end
