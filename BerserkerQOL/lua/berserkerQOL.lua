dofile(ModPath .. "lua/init.lua")
--Initialize Table

--[[
	1: Never block (never used directly)
	2: If you have berserker
	3: Always block
]]

local function __check_table(index)
	if index then
		return index == 2 and berserkerQOL._has_zerk or index == 3
	end
end

if RequiredScript == "lib/units/beings/player/playerinventory" then
    --Disable Hacker ECM
    Hooks:PostHook(PlayerInventory,"_start_feedback_effect", "Berserker_qol_start_feedback_effect", 
    function(self, ...)
    	local is_player = managers.player:player_unit() == self._unit
    	if not is_player and self._jammer_data and self._jammer_data.heal then
			if __check_table(berserkerQOL._data["hacker_cancer"]) then
    			self._jammer_data.heal = 0
			end
    	end
    end 
    )
	
	--Check if the player has berserker
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
	end
	)
end

if RequiredScript == "lib/units/beings/player/playerdamage" then
	function PlayerDamage:set_revive_boost(revive_health_level)
		if __check_table(berserkerQOL._data["combatmedic_cancer"]) then self._revive_health_multiplier = 1 else
		self._revive_health_multiplier = tweak_data.upgrades.revive_health_multiplier[revive_health_level] end
	end
end

if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	function UnitNetworkHandler:sync_cocaine_stacks(amount, in_use, upgrade_level, power_level, sender)
		local peer = self._verify_sender(sender)
	
		if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
			return
		end
	
		local peer_id = peer:id()
		local current_cocaine_stacks = managers.player:get_synced_cocaine_stacks(peer_id)
		local bqolmod_bool = __check_table(berserkerQOL._data["maniac_cancer"])
		
		if current_cocaine_stacks and not bqolmod_bool then
			amount = math.min((current_cocaine_stacks and current_cocaine_stacks.amount or 0) + (tweak_data.upgrades.max_cocaine_stacks_per_tick or 20), amount)
		end

		if bqolmod_bool then
			amount = 0
		end
	
		managers.player:set_synced_cocaine_stacks(peer_id, amount, in_use, upgrade_level, power_level)
	end

	--If the upgrades are CC TEAM upgrades, don't add them to the player
	function UnitNetworkHandler:add_synced_team_upgrade(category, upgrade, level, sender)
		local sender_peer = self._verify_sender(sender)
	
		if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not sender_peer then
			return
		end
	
		local peer_id = sender_peer:id()

		if __check_table(berserkerQOL._data["cc_cancer"]) then --check if they want it disabled on zerk and have zerk or want it always disabled (this gets used a lot)
			if category ~= "health" and category ~= "armor" and category ~= "damage_dampener" and category ~= "hostage_multiplier" and category ~= "passive_hostage_multiplier" then
				managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
			end
		else
			managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
		end
		
	end

	function UnitNetworkHandler:copr_teammate_heal(healer_unit, upgrade_level, sender)
		if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(healer_unit, sender) then
			return
		end
	
		local player_unit = managers.player:player_unit()
		local character_damage = alive(player_unit) and player_unit:character_damage()
	
		if not character_damage or not character_damage.on_copr_heal_received then
			return
		end
		
		if __check_table(berserkerQOL._data["leech_cancer"]) then
		else
			character_damage:on_copr_heal_received(healer_unit, upgrade_level)
		end
	end

end

if RequiredScript == "lib/player_actions/skills/playeractiontagteam" then
    --Disable Tag Team Vape
    PlayerAction.TagTeamTagged.Function = function (tagged, owner)
		if tagged ~= managers.player:local_player() then
			return
		end

		local base_values = owner:base():upgrade_value("player", "tag_team_base")
		local kill_health_gain = base_values.kill_health_gain * base_values.tagged_health_gain_ratio
		local timer = TimerManager:game()
		local end_time = timer:time() + base_values.duration
		local on_damage_key = {}

		local function on_damage(damage_info)
			local was_killed = damage_info.result.type == "death"
			local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged
			if was_killed and valid_player then
				end_time = math.min(end_time + base_values.kill_extension, timer:time() + base_values.duration)

				tagged:character_damage():restore_health(kill_health_gain, true)
			end
		end

		if __check_table(berserkerQOL._data["tt_cancer"]) then 
			return
		else
			CopDamage.register_listener(on_damage_key, {
				"on_damage"
			}, on_damage)
		end

		local ended_by_owner = false
		local on_end_key = {}

		local function on_action_end(end_tagged, end_owner)
			local tagged_match = tagged == end_tagged
			local owner_match = owner == end_owner
			ended_by_owner = tagged_match and owner_match
		end

		managers.player:add_listener(on_end_key, {
			"tag_team_end"
		}, on_action_end)

		local timer = TimerManager:game()

		while not ended_by_owner and alive(tagged) and (alive(owner) or timer:time() < end_time) do
			coroutine.yield()
		end

		CopDamage.unregister_listener(on_damage_key)
		managers.player:remove_listener(on_end_key)
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
		if __check_table(berserkerQOL._data["qf_cancer"]) or (berserkerQOL._data == 4 and berserkerQOL._has_qfaced == false) then
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
		
		if __check_table(berserkerQOL._data["ai_armor_cancer"]) then return addend else

		addend = addend + self:upgrade_value("team", "crew_add_armor", 0) end
	
		return addend
	end

	function PlayerManager:fixed_health_regen(health_ratio)
		local health_regen = 0
	
		if not health_ratio or not self:is_damage_health_ratio_active(health_ratio) then
			if __check_table(berserkerQOL._data["ai_hp_cancer"]) then return health_regen else

			health_regen = health_regen + self:upgrade_value("team", "crew_health_regen", 0) end
		end
	
		return health_regen
	end

	function PlayerManager:health_skill_addend()
		local addend = 0
		if __check_table(berserkerQOL._data["ai_hp_cancer"]) then return addend	else 
		
		addend = addend + self:upgrade_value("team", "crew_add_health", 0) end
	
		if table.contains(self._global.kit.equipment_slots, "thick_skin") then
			addend = addend + self:upgrade_value("player", "thick_skin", 0)
		end
	
		return addend
	end
end
