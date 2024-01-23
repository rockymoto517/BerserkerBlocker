if not _G.BerserkerQOL then
	_G.BerserkerQOL = _G.BerserkerQOL or {}
	BerserkerQOL._path = ModPath
	BerserkerQOL._data_path = SavePath .. "berserkerQOL_save_data.txt"
	BerserkerQOL._data = {}
    BerserkerQOL._data.default = {}
	BerserkerQOL._data.default["ff_cancer"] = 0
	BerserkerQOL._data.default["cc_cancer"] = 0
	BerserkerQOL._data.default["maniac_cancer"] = 0
	BerserkerQOL._data.default["qf_cancer"] = 0
	BerserkerQOL._data.default["ai_armor_cancer"] = 0
	BerserkerQOL._data.default["ai_hp_cancer"] = 0
	BerserkerQOL._data.default["combatmedic_cancer"] = 0
	BerserkerQOL._data.testing_level = 0.3
	BerserkerQOL._has_zerk = false
	BerserkerQOL._has_qfaced = false
	BerserkerQOL.num_profiles = #tweak_data.skilltree.skill_switches or 15

	for i = 1, BerserkerQOL.num_profiles do
		BerserkerQOL._data['skillset'..tostring(i)] = {
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
	function BerserkerQOL:Save()
		local save = io.open(self._data_path, 'w+')
		if save then
			save:write(json.encode(self._data))
			save:close()
		end
	end

	function BerserkerQOL:Load()
		local save = io.open(self._data_path, 'r')
		if save then
			for k, v in pairs(json.decode(save:read('*all')) or {}) do
				self._data[k] = v
			end
			save:close()
		end
	end

    BerserkerQOL.debug_on = false
    function BerserkerQOL:log(effect, text)
		if BerserkerQOL.debug_on and effect ~= "ai_armor_cancer" and effect ~= "ai_hp_cancer" then
        	log(string.format("[BQOL Debug] %s = %s", effect, text))
		end
    end

	dofile(BerserkerQOL._path.."lua/menusetup.lua")
	dofile(BerserkerQOL._path.."lua/tablecheck.lua")
    dofile(BerserkerQOL._path.."lua/paths.lua")

	BerserkerQOL.hooks_loaded = {}
end

local function main()
	if BerserkerQOL.hook_paths[RequiredScript] and not BerserkerQOL.hooks_loaded[RequiredScript] then
		dofile(BerserkerQOL.hook_paths[RequiredScript])
		BerserkerQOL.hooks_loaded[RequiredScript] = true
	end
end

main()
