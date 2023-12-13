--[[
	1: Inherit from default
	2: Never block (never used directly)
	3: If you have berserker
	4: Always block
	5: Block if you have quick fix
]]

-- return the blocking status
function berserkerQOL:check_table(effect)
    local profile = managers.multi_profile and managers.multi_profile._global._current_profile or 1
	local save_value = berserkerQOL._data['skillset'..tostring(profile)][effect]
    if save_value == 1 or save_value == 0 then
		save_value = berserkerQOL._data.default[effect]
	end

	if effect == "qf_cancer" then
		if save_value == 3 and berserkerQOL._has_zerk then
			return true
		elseif save_value == 4 then
			return true
		elseif save_value == 5 and berserkerQOL._has_qfaced == false then
			return true
		end

		return false
	end

	if save_value == 3 and berserkerQOL._has_zerk then
		return true
	elseif save_value == 4 then
		return true
	else
		return false
	end
end
