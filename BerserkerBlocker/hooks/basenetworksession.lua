Hooks:PostHook(BaseNetworkSession, "spawn_players", "Berserker_qol_spawn_players",
function(self)
	-- log("Current level id: "..tostring(managers.job:current_level_id()))
	local level_id = managers.job:current_level_id()
	if BerserkerQOL._data.testing_level ~= 0 and level_id == "modders_devmap" then
		local amount = (1 - BerserkerQOL._data.testing_level) * managers.player:player_unit():character_damage():_max_health() * 0.5
		managers.player:player_unit():character_damage():set_health(amount)
	end
end)
