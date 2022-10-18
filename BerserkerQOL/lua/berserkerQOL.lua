dofile(ModPath .. "lua/init.lua")
-- require("lib/managers/multiprofilemanager")
-- Initialize Table

--[[
	1: Inherit from default
	2: Never block (never used directly)
	3: If you have berserker
	4: Always block
	5: Block if you have quick fix
]]

-- return the blocking status
local function __check_table(effect)
    _profile = managers.multi_profile and managers.multi_profile._global._current_profile or 31
    if berserkerQOL._data['skillset'..tostring(_profile)][effect] ~= 1 and berserkerQOL._data['skillset'..tostring(_profile)][effect] ~= 0 then
        if effect == "qf_cancer" then
            value = (berserkerQOL._data['skillset'..tostring(_profile)][effect] == 3 and berserkerQOL._has_zerk) or
					(berserkerQOL._data['skillset'..tostring(_profile)][effect] == 4) or
					(berserkerQOL._data['skillset'..tostring(_profile)][effect] == 5 and berserkerQOL._has_qfaced == false)
            berserkerQOL:log(effect, tostring(value))
			return value
		end

        value = (berserkerQOL._data['skillset'..tostring(_profile)][effect] == 3 and berserkerQOL._has_zerk) or
				(berserkerQOL._data['skillset'..tostring(_profile)][effect] == 4)
        berserkerQOL:log(effect, tostring(value))
		return value
    else
        if effect == "qf_cancer" then
            value = (berserkerQOL._data.default[effect] == 3 and berserkerQOL._has_zerk) or
					(berserkerQOL._data.default[effect] == 4) or
					(berserkerQOL._data.default[effect] == 5 and berserkerQOL._has_qfaced == false)
            berserkerQOL:log(effect, tostring(value))
			return value
		end

        value = (berserkerQOL._data.default[effect] == 3 and berserkerQOL._has_zerk) or
				(berserkerQOL._data.default[effect] == 4)
        berserkerQOL:log(effect, tostring(value))
		return value
	end
end

if RequiredScript == "lib/units/beings/player/playerinventory" then
	-- Check if the player has berserker
	Hooks:PostHook(PlayerInventory,"init", "Berserker_qol_find_zerk",
    	function(self, ...)
		if managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier") or managers.player:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") then
			berserkerQOL._has_zerk = true
		end
		if managers.player:has_category_upgrade("temporary", "temporary_first_aid_damage_reduction") then
			berserkerQOL._has_qfaced = true
		else
			berserkerQOL._has_qfaced = false
		end
	end)
end

if RequiredScript == "lib/units/beings/player/playerdamage" then
    -- Check for combat medic
	function PlayerDamage:set_revive_boost(revive_health_level)
		if __check_table("combatmedic_cancer") then self._revive_health_multiplier = 1 else
		self._revive_health_multiplier = tweak_data.upgrades.revive_health_multiplier[revive_health_level] end
	end
end

if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
    -- Set maniac stacks to 0
    Hooks:PostHook(UnitNetworkHandler, "sync_cocaine_stacks", "berserkerQOL_sync_cocaine_stacks",
    function(self, amount, ...)
        if __check_table("maniac_cancer") then
            amount = 0
        end
    end)

	--If the upgrades are CC TEAM upgrades, don't add them to the player
	function UnitNetworkHandler:add_synced_team_upgrade(category, upgrade, level, sender)
		local sender_peer = self._verify_sender(sender)

		if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not sender_peer then
			return
		end

		local peer_id = sender_peer:id()

		if __check_table("cc_cancer") then --check if they want it disabled on zerk and have zerk or want it always disabled (this gets used a lot)
			if category ~= "health" and category ~= "armor" and category ~= "damage_dampener" and category ~= "hostage_multiplier" and category ~= "passive_hostage_multiplier" then
				managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
			end
		else
			managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
		end

	end
end

if RequiredScript == "lib/managers/playermanager" then
    function PlayerManager:damage_reduction_skill_multiplier(damage_type)
		local multiplier = 1
		multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered", 1)
		multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered_strong", 1)
		multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_close_contact", 1)
		multiplier = multiplier * self:temporary_upgrade_value("temporary", "revived_damage_resist", 1)
		multiplier = multiplier * self:upgrade_value("player", "damage_dampener", 1)
		multiplier = multiplier * self:upgrade_value("player", "health_damage_reduction", 1)
		if __check_table("qf_cancer") then
		else
			multiplier = multiplier * self:temporary_upgrade_value("temporary", "first_aid_damage_reduction", 1)
		end
		multiplier = multiplier * self:temporary_upgrade_value("temporary", "revive_damage_reduction", 1)
		multiplier = multiplier * self:get_hostage_bonus_multiplier("damage_dampener")
		multiplier = multiplier * self._properties:get_property("revive_damage_reduction", 1)
		multiplier = multiplier * self._temporary_properties:get_property("revived_damage_reduction", 1)
		local dmg_red_mul = self:team_upgrade_value("damage_dampener", "team_damage_reduction", 1)

		if self:has_category_upgrade("player", "passive_damage_reduction") then
			local health_ratio = self:player_unit():character_damage():health_ratio()
			local min_ratio = self:upgrade_value("player", "passive_damage_reduction")

			if health_ratio < min_ratio then
				dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
			end
		end

		multiplier = multiplier * dmg_red_mul

		if damage_type == "melee" then
			multiplier = multiplier * managers.player:upgrade_value("player", "melee_damage_dampener", 1)
		end

		local current_state = self:get_current_state()

		if current_state and current_state:_interacting() then
			multiplier = multiplier * managers.player:upgrade_value("player", "interacting_damage_multiplier", 1)
		end

		return multiplier
	end

	function PlayerManager:body_armor_skill_addend(override_armor)
		local addend = 0
		addend = addend + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_addend", 0)

		if self:has_category_upgrade("player", "armor_increase") then
			local health_multiplier = self:health_skill_multiplier()
			local max_health = (PlayerDamage._HEALTH_INIT + self:health_skill_addend()) * health_multiplier
			addend = addend + max_health * self:upgrade_value("player", "armor_increase", 1)
		end

		if __check_table("ai_armor_cancer") then return
			addend
		end

		addend = addend + self:upgrade_value("team", "crew_add_armor", 0)

		return addend
	end

	function PlayerManager:health_skill_addend()
		local addend = 0
		if __check_table("ai_hp_cancer") then
			return addend
		end

		addend = addend + self:upgrade_value("team", "crew_add_health", 0)

		if table.contains(self._global.kit.equipment_slots, "thick_skin") then
			addend = addend + self:upgrade_value("player", "thick_skin", 0)
		end

		return addend
	end
end
