-- Check for combat medic
function PlayerDamage:set_revive_boost(revive_health_level)
	if berserkerQOL:check_table("combatmedic_cancer") then self._revive_health_multiplier = 1 else
	self._revive_health_multiplier = tweak_data.upgrades.revive_health_multiplier[revive_health_level] end
end

