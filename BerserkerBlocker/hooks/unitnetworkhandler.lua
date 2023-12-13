-- Set maniac stacks to 0
Hooks:PostHook(UnitNetworkHandler, "sync_cocaine_stacks", "berserkerQOL_sync_cocaine_stacks",
function(self, amount, ...)
	if berserkerQOL:check_table("maniac_cancer") then
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

	if berserkerQOL:check_table("cc_cancer") then --check if they want it disabled on zerk and have zerk or want it always disabled (this gets used a lot)
		if category ~= "health" and category ~= "armor" and category ~= "damage_dampener" and category ~= "hostage_multiplier" and category ~= "passive_hostage_multiplier" then
			managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
		end
	else
		managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
	end

end
