-- Check if the player has berserker
Hooks:PostHook(PlayerInventory,"init", "Berserker_qol_find_zerk",
	function(self, ...)
	if managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier") or managers.player:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") then
		BerserkerQOL._has_zerk = true
	end
	if managers.player:has_category_upgrade("temporary", "temporary_first_aid_damage_reduction") then
		BerserkerQOL._has_qfaced = true
	else
		BerserkerQOL._has_qfaced = false
	end
end)
