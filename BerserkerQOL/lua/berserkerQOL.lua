dofile(ModPath .. "lua/init.lua")
--Initialize Table

--[[
	1: Never block (never used directly)
	2: If you have berserker
	3: Always block
]]

if RequiredScript == "lib/units/beings/player/playerinventory" then
    --Disable Hacker ECM
    Hooks:PostHook(PlayerInventory,"_start_feedback_effect", "Berserker_qol_start_feedback_effect", 
    function(self, ...)
    	local is_player = managers.player:player_unit() == self._unit
    	if not is_player and self._jammer_data and self._jammer_data.heal then --check if jammer is active
			if berserkerQOL._data["hacker_cancer"] == 2 and berserkerQOL._has_zerk or berserkerQOL._data["hacker_cancer"] == 3 then
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
	end
	)
end

if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	function UnitNetworkHandler:sync_cocaine_stacks(amount, in_use, upgrade_level, power_level, sender)
		local peer = self._verify_sender(sender)
	
		if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
			return
		end
	
		local peer_id = peer:id()
		local current_cocaine_stacks = managers.player:get_synced_cocaine_stacks(peer_id)
		local bqolmod_bool = berserkerQOL._data["maniac_cancer"] == 2 and berserkerQOL._has_zerk or berserkerQOL._data["maniac_cancer"] == 3 --put this here so I only have to do this operation once (very minor speed optimization and bad for memory)
		
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

		if berserkerQOL._data["cc_cancer"] == 2 and berserkerQOL._has_zerk or berserkerQOL._data["cc_cancer"] == 3 then --check if they want it disabled on zerk and have zerk or want it always disabled (this gets used a lot)
			if category ~= "health" and category ~= "armor" and category ~= "damage_dampener" then
				managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
			end
		else
			managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
		end
		
	end
end

if RequiredScript == "lib/player_actions/skills/playeractiontagteam" then
    --Disable Tag Team Vape
    local old_tag_team_tagged = PlayerAction.TagTeamTagged.Function
    PlayerAction.TagTeamTagged.Function = function (...)
        if berserkerQOL._data["tt_cancer"] == 2 and berserkerQOL._has_zerk or berserkerQOL._data["tt_cancer"] == 3 then
			return
		end
		old_tag_team_tagged(...)
    end
end
