if not _G.berserkerQOL then
	_G.berserkerQOL = _G.berserkerQOL or {}
	berserkerQOL._path = ModPath
	berserkerQOL._data_path = SavePath .. "berserkerQOL_save_data.txt"
	berserkerQOL._data = {}
	berserkerQOL._data["cc_cancer"] = 0
	berserkerQOL._data["maniac_cancer"] = 0
	berserkerQOL._data["hacker_cancer"] = 0
	berserkerQOL._data["tt_cancer"] = 0
	berserkerQOL._data["qf_cancer"] = 0
	berserkerQOL._has_zerk = false

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

	local save_exists = io.open(berserkerQOL._data_path, "r")
	if save_exists ~= nil then
		save_exists:close()
		berserkerQOL:Load()
	else
		berserkerQOL:Save()
	end

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_berserkerQOL", function( loc )
		loc:load_localization_file( berserkerQOL._path .. "menu/en.txt")
	end)

	Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_berserkerQOL", function( menu_manager )

		--Gather the options
		MenuCallbackHandler.berserkerQOL_callback_cc = function(self, item)
			berserkerQOL._data.berserkerQOL_cc_value = item:value()
			berserkerQOL._data["cc_cancer"] = berserkerQOL._data.berserkerQOL_cc_value
			berserkerQOL:Save()
		end

		MenuCallbackHandler.berserkerQOL_callback_maniac = function(self, item)
			berserkerQOL._data.berserkerQOL_maniac_value = item:value()
			berserkerQOL._data["maniac_cancer"] = berserkerQOL._data.berserkerQOL_maniac_value
			berserkerQOL:Save()
		end

		MenuCallbackHandler.berserkerQOL_callback_hacker = function(self, item)
			berserkerQOL._data.berserkerQOL_hacker_value = item:value()
			berserkerQOL._data["hacker_cancer"] = berserkerQOL._data.berserkerQOL_hacker_value
			berserkerQOL:Save()
		end

		MenuCallbackHandler.berserkerQOL_callback_tt = function(self, item)
			berserkerQOL._data.berserkerQOL_tt_value = item:value()
			berserkerQOL._data["tt_cancer"] = berserkerQOL._data.berserkerQOL_tt_value
			berserkerQOL:Save()
		end

		MenuCallbackHandler.berserkerQOL_callback_qf = function(self, item)
			berserkerQOL._data.berserkerQOL_qf_value = item:value()
			berserkerQOL._data["qf_cancer"] = berserkerQOL._data.berserkerQOL_qf_value
			berserkerQOL:Save()
		end

		berserkerQOL:Load()
		MenuHelper:LoadFromJsonFile(berserkerQOL._path .. "menu/options.json", berserkerQOL, berserkerQOL._data)

	end)
end