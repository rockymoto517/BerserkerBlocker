local old_dr_multiplier = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type)
	local multiplier = old_dr_multiplier(self, damage_type)
	local qf_multi = self:temporary_upgrade_value("temporary", "first_aid_damage_reduction", 1)
	if berserkerQOL:check_table("qf_cancer") then
		multiplier = multiplier / qf_multi
	end

	return multiplier
end

local old_body_armor_addend = PlayerManager.body_armor_skill_addend
function PlayerManager:body_armor_skill_addend(override_armor)
	local addend = old_body_armor_addend(self, override_armor)
	local crew_add = self:upgrade_value("team", "crew_add_armor", 0)
	if berserkerQOL:check_table("ai_armor_cancer") then
		addend = addend - crew_add
	end

	return addend
end

local old_hp_addend = PlayerManager.health_skill_addend
function PlayerManager:health_skill_addend()
	local addend = old_hp_addend(self)
	if berserkerQOL:check_table("ai_hp_cancer") then
		return 0
	end

	return addend
end

local old_set_damage_absorption = PlayerManager.set_damage_absorption
function PlayerManager:set_damage_absorption(key, value)
	if key and key == "hostage_absorption" then
		return
	end
	old_set_damage_absorption(self, key, value)
end
