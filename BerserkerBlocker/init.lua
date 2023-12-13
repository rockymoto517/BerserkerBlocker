if not _G.berserkerQOL then
	_G.berserkerQOL = _G.berserkerQOL or {}
	berserkerQOL._path = ModPath
	berserkerQOL._data_path = SavePath .. "berserkerQOL_save_data.txt"
	berserkerQOL._data = {}
    berserkerQOL._data.default = {}
	berserkerQOL._data.default["ff_cancer"] = 0
	berserkerQOL._data.default["cc_cancer"] = 0
	berserkerQOL._data.default["maniac_cancer"] = 0
	berserkerQOL._data.default["qf_cancer"] = 0
	berserkerQOL._data.default["ai_armor_cancer"] = 0
	berserkerQOL._data.default["ai_hp_cancer"] = 0
	berserkerQOL._data.default["combatmedic_cancer"] = 0
	berserkerQOL._data.testing_level = 0.3
	berserkerQOL._has_zerk = false
	berserkerQOL._has_qfaced = false
	berserkerQOL.num_profiles = #tweak_data.skilltree.skill_switches or 15

	for i = 1, berserkerQOL.num_profiles do
		berserkerQOL._data['skillset'..tostring(i)] = {
				["ff_cancer"] = 0,
				["cc_cancer"] = 0,
				["maniac_cancer"] = 0,
				["qf_cancer"] = 0,
				["ai_armor_cancer"] = 0,
				["ai_hp_cancer"] = 0,
				["combatmedic_cancer"] = 0
		}
	end

	--Build the menu
	function berserkerQOL:Save()
		local save = io.open(self._data_path, 'w+')
		if save then
			save:write(json.encode(self._data))
			save:close()
		end
	end

	function berserkerQOL:Load()
		local save = io.open(self._data_path, 'r')
		if save then
			for k, v in pairs(json.decode(save:read('*all')) or {}) do
				self._data[k] = v
			end
			save:close()
		end
	end

    berserkerQOL.debug_on = false
    function berserkerQOL:log(effect, text)
		if berserkerQOL.debug_on and effect ~= "ai_armor_cancer" and effect ~= "ai_hp_cancer" then
        	log(string.format("[BQOL Debug] %s = %s", effect, text))
		end
    end

	dofile(berserkerQOL._path.."lua/menusetup.lua")
	dofile(berserkerQOL._path.."lua/tablecheck.lua")
    dofile(berserkerQOL._path.."lua/paths.lua")

	berserkerQOL.hooks_loaded = {}
end

if berserkerQOL[RequiredScript] and not berserkerQOL.hooks_loaded[RequiredScript] then
    dofile(berserkerQOL[RequiredScript])
    berserkerQOL.hooks_loaded[RequiredScript] = true
end
