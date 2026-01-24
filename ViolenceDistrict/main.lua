-- ViolenceDistrict/main.lua
-- Fokus ESP per kategori (no global ESP)
-- Sidebar: ESP / Survivor / Killer / Other / Visual

print("[RiiHUB] ViolenceDistrict main.lua loaded")

-- ======================================================
-- UI API
-- ======================================================
local UI = _G.RiiHUB_UI
if not UI then
	warn("[RiiHUB] UI API belum tersedia")
	return
end

-- ======================================================
-- LOAD ESP MODULE
-- ======================================================
local BASE = "https://raw.githubusercontent.com/FahriSetiawan69/RiiHUB/main/ViolenceDistrict/"

local function loadModule(file)
	local ok, mod = pcall(function()
		return loadstring(game:HttpGet(BASE .. file))()
	end)
	if not ok then
		warn("[RiiHUB] Gagal load:", file)
		return nil
	end
	return mod
end

local ESP = loadModule("ESPModule.lua")

-- Simpan global (opsional)
_G.RiiHUB = _G.RiiHUB or {}
_G.RiiHUB.Modules = { ESP = ESP }

-- ======================================================
-- SIDEBAR TABS (FIXED)
-- ======================================================
UI:AddTab("ESP")
UI:AddTab("Survivor")
UI:AddTab("Killer")
UI:AddTab("Other")
UI:AddTab("Visual")

-- ======================================================
-- ESP TAB (PER CATEGORY CONTROL)
-- ======================================================
if ESP then
	-- Survivor ESP
	local tSurv = UI:AddToggle("ESP", "Survivor ESP")
	if tSurv then
		tSurv:Bind(function(on)
			if on then
				ESP:EnableSurvivor()
			else
				ESP:DisableSurvivor()
			end
		end)
	end

	-- Killer ESP
	local tKill = UI:AddToggle("ESP", "Killer ESP")
	if tKill then
		tKill:Bind(function(on)
			if on then
				ESP:EnableKiller()
			else
				ESP:DisableKiller()
			end
		end)
	end

	-- Generator ESP
	local tGen = UI:AddToggle("ESP", "Generator ESP")
	if tGen then
		tGen:Bind(function(on)
			if on then
				ESP:EnableGenerator()
			else
				ESP:DisableGenerator()
			end
		end)
	end

	-- Pallet ESP
	local tPal = UI:AddToggle("ESP", "Pallet ESP")
	if tPal then
		tPal:Bind(function(on)
			if on then
				ESP:EnablePallet()
			else
				ESP:DisablePallet()
			end
		end)
	end

	-- Gate ESP
	local tGate = UI:AddToggle("ESP", "Gate ESP")
	if tGate then
		tGate:Bind(function(on)
			if on then
				ESP:EnableGate()
			else
				ESP:DisableGate()
			end
		end)
	end

	-- Name + HP ESP
	local tNameHp = UI:AddToggle("ESP", "Name + HP")
	if tNameHp then
		tNameHp:Bind(function(on)
			if on then
				ESP:EnableNameHP()
			else
				ESP:DisableNameHP()
			end
		end)
	end
end

print("[RiiHUB] ViolenceDistrict ESP UI siap (semua OFF)")