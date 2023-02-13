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
	local old_dr_multiplier = PlayerManager.damage_reduction_skill_multiplier
    function PlayerManager:damage_reduction_skill_multiplier(damage_type)
		local multiplier = old_dr_multiplier(self, damage_type)
		local qf_multi = self:temporary_upgrade_value("temporary", "first_aid_damage_reduction", 1)
		if __check_table("qf_cancer") then
			multiplier = multiplier / qf_multi
		end

		return multiplier
	end

	local old_body_armor_addend = PlayerManager.body_armor_skill_addend
	function PlayerManager:body_armor_skill_addend(override_armor)
		local addend = old_body_armor_addend(self, override_armor)
		local crew_add = self:upgrade_value("team", "crew_add_armor", 0)
		if __check_table("ai_armor_cancer") then
			addend = addend - crew_add
		end

		return addend
	end

	local old_hp_addend = PlayerManager.health_skill_addend
	function PlayerManager:health_skill_addend()
		local addend = old_hp_addend(self)
		if __check_table("ai_hp_cancer") then
			return 0
		end

		return addend
	end
end

if RequiredScript == "lib/network/base/basenetworksession" then
    Hooks:PostHook(BaseNetworkSession, "spawn_players", "Berserker_qol_spawn_players",
    function(self)
		-- log("Current level id: "..tostring(managers.job:current_level_id()))
		local level_id = managers.job:current_level_id()
		if berserkerQOL._data.testing_level ~= 0 and level_id == "modders_devmap" then
			local amount = (1 - berserkerQOL._data.testing_level) * managers.player:player_unit():character_damage():_max_health() * 0.5
			managers.player:player_unit():character_damage():set_health(amount)
		end
    end)
end