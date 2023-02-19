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
	local NUM_PROFILES = #tweak_data.skilltree.skill_switches or 15

	for i = 1, NUM_PROFILES do
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
	debug_on = false

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

    function berserkerQOL:log(effect, text)
		if debug_on and effect ~= "ai_armor_cancer" and effect ~= "ai_hp_cancer" then
        	log(string.format("[BQOL Debug] %s = %s", effect, text))
		end
    end

	local save_exists = io.open(berserkerQOL._data_path, "r")
	if save_exists ~= nil then
		save_exists:close()
		berserkerQOL:Load()
	else
		berserkerQOL:Save()
	end

    -- Helper function
    local function refresh_options()
        local _bqol_menu = MenuHelper:GetMenu("berserkerQOL_menu") or {_items = {}}
        for _, item in pairs(_bqol_menu._items) do
            if item._parameters and item._parameters.name == "berserkerQOL_skillset" then
                if item._options then
                    for i = 1, NUM_PROFILES do
                        local profile = managers.multi_profile._global._profiles[i]
                        item._options[i+1]._parameters.text_id = profile and profile.name or "Profile "..tostring(i)
                    end
                end
                break
            end
        end
    end

    -- Returns the updated value of the menu item
	local function update_value(index, profile)
		local ret = (profile == NUM_PROFILES+1 and berserkerQOL._data.default[index]) or (berserkerQOL._data['skillset'..tostring(profile)][index])
		return ret ~= 0 and ret or 1
	end

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_berserkerQOL", function(loc)
		loc:load_localization_file(berserkerQOL._path .. "menu/en.txt")
	end)

	Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_berserkerQOL", function(menu_manager)
		local selectedProfile = NUM_PROFILES + 1

		--Gather the options
		MenuCallbackHandler.berserkerQOL_callback_ff = function(self, item)
			if selectedProfile == NUM_PROFILES + 1 then
				berserkerQOL._data.default["ff_cancer"] = item:value()
				berserkerQOL._data._ff_cancer = item:value()
			else
				berserkerQOL._data['skillset'..tostring(selectedProfile)]["ff_cancer"] = item:value()
			end
		end

		MenuCallbackHandler.berserkerQOL_callback_cc = function(self, item)
			if selectedProfile == NUM_PROFILES + 1 then
				berserkerQOL._data.default["cc_cancer"] = item:value()
				berserkerQOL._data._cc_cancer = item:value()
			else
				berserkerQOL._data['skillset'..tostring(selectedProfile)]["cc_cancer"] = item:value()
			end
		end

		MenuCallbackHandler.berserkerQOL_callback_maniac = function(self, item)
			if selectedProfile == NUM_PROFILES + 1 then
				berserkerQOL._data.default["maniac_cancer"] = item:value()
				berserkerQOL._data._maniac_cancer = item:value()
			else
				berserkerQOL._data['skillset'..tostring(selectedProfile)]["maniac_cancer"] = item:value()
			end
		end

		MenuCallbackHandler.berserkerQOL_callback_qf = function(self, item)
			if selectedProfile == NUM_PROFILES + 1 then
				berserkerQOL._data.default["qf_cancer"] = item:value()
				berserkerQOL._data._qf_cancer = item:value()
			else
				berserkerQOL._data['skillset'..tostring(selectedProfile)]["qf_cancer"] = item:value()
			end
		end

		MenuCallbackHandler.berserkerQOL_callback_ai_armor = function(self, item)
			if selectedProfile == NUM_PROFILES + 1 then
				berserkerQOL._data.default["ai_armor_cancer"] = item:value()
				berserkerQOL._data._ai_armor_cancer = item:value()
			else
				berserkerQOL._data['skillset'..tostring(selectedProfile)]["ai_armor_cancer"] = item:value()
			end
		end

		MenuCallbackHandler.berserkerQOL_callback_ai_hp = function(self, item)
			if selectedProfile == NUM_PROFILES + 1 then
				berserkerQOL._data.default["ai_hp_cancer"] = item:value()
				berserkerQOL._data._ai_hp_cancer = item:value()
			else
				berserkerQOL._data['skillset'..tostring(selectedProfile)]["ai_hp_cancer"] = item:value()
			end
		end

		MenuCallbackHandler.berserkerQOL_callback_cm = function(self, item)
			if selectedProfile == NUM_PROFILES + 1 then
				berserkerQOL._data.default["combatmedic_cancer"] = item:value()
				berserkerQOL._data._combatmedic_cancer = item:value()
			else
				berserkerQOL._data['skillset'..tostring(selectedProfile)]["combatmedic_cancer"] = item:value()
			end
		end

		MenuCallbackHandler.berserkerQOL_callback_skillset = function(self, item)

			selectedProfile = tonumber(item:value())

			local _bqol_menu = MenuHelper:GetMenu("berserkerQOL_menu") or {_items = {}}

            -- Update the displayed options every time we switch skillsets
            for _, item in pairs(_bqol_menu._items) do
				local name = item._parameters.name

				if item._type == "multi_choice" and name ~= "berserkerQOL_skillset" then
					if name == "berserkerQOL_cc" then
						item:set_current_index(update_value("cc_cancer", selectedProfile))
					elseif name == "berserkerQOL_ff" then
						item:set_current_index(update_value("ff_cancer", selectedProfile))
					elseif name == "berserkerQOL_maniac" then
						item:set_current_index(update_value("maniac_cancer", selectedProfile))
					elseif name == "berserkerQOL_qf" then
						item:set_current_index(update_value("qf_cancer", selectedProfile))
					elseif name == "berserkerQOL_ai_armor" then
						item:set_current_index(update_value("ai_armor_cancer", selectedProfile))
					elseif name == "berserkerQOL_ai_hp" then
						item:set_current_index(update_value("ai_hp_cancer", selectedProfile))
					elseif name == "berserkerQOL_cm" then
						item:set_current_index(update_value("combatmedic_cancer", selectedProfile))
					end
				end
			end

			_bqol_menu = nil
		end

		MenuCallbackHandler.berserkerQOL_callback_apply = function(self)
			berserkerQOL:Save()
            -- Exit and enter menu on save to make it feel responsive
			managers.menu:back()
			managers.menu:open_node('berserkerQOL_menu')
		end

		MenuCallbackHandler.berserkerQOL_callback_test_percent = function(self, item)
			local value = math.floor(item:value()*100+0.5) / 100
			berserkerQOL._data.testing_level = value
		end

		MenuCallbackHandler.berserkerQOL_callback_apply_zerk = function(self)
			if Utils:IsInHeist() and managers.job:current_level_id() == "modders_devmap" then
				local amount = (1 - berserkerQOL._data.testing_level) * managers.player:player_unit():character_damage():_max_health() * 0.5
				managers.player:player_unit():character_damage():set_health(amount)
				berserkerQOL:Save()
			end
		end

        -- Add every profile to the profile option
        local populated_menu
        MenuCallbackHandler.berserkerQOL_focus_changed_callback = function(self)
            COUNT_PROFILES = managers.multi_profile and managers.multi_profile:profile_count() or 3

            if populated_menu then
                refresh_options()
                return
            end

            local _bqol_menu = MenuHelper:GetMenu("berserkerQOL_menu") or {_items = {}}
            for _, item in pairs(_bqol_menu._items) do
                if item._parameters and item._parameters.name == "berserkerQOL_skillset" then
					item:add_option(CoreMenuItemOption.ItemOption:new({
						_meta = "option",
						text_id = "default",
						value = COUNT_PROFILES + 1,
						localize = false
                    }))
                    for i = 1, COUNT_PROFILES do
                        item:add_option(CoreMenuItemOption.ItemOption:new({
							_meta = "option",
							text_id = managers.multi_profile and managers.multi_profile._global._profiles[i].name or "Profile "..tostring(i),
							value = i,
							localize = false
                        }))
                    end
                    break
                end
            end
            populated_menu = true
        end

		berserkerQOL:Load()
		MenuHelper:LoadFromJsonFile(berserkerQOL._path .. "menu/options.json", berserkerQOL, berserkerQOL._data)
	end)
end
