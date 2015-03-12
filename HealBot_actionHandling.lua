--==============================================================================
--[[
	Author: Ragnarok.Lorand
	HealBot action handling functions
--]]
--==============================================================================

function getActionToPerform()
	local cureq = getCureQueue()
	local dbuffq = getDebuffQueue()
	local buffq = getBuffQueue()
	local queue = L({})
	local action = {}
	
	while (not cureq:empty()) do
		local cact = cureq:pop()
		queue:append(tostring(cact.action.en)..' → '..tostring(cact.name))
		if (action.cure == nil) and (not isTooFar(cact.name)) then
			action.cure = cact
		end
	end
	while (not dbuffq:empty()) do
		local dbact = dbuffq:pop()
		queue:append(tostring(dbact.action.en)..' → '..tostring(dbact.name))
		if (action.debuff == nil) and (not isTooFar(dbact.name)) and readyToCast(dbact.action) then
			action.debuff = dbact
		end
	end
	while (not buffq:empty()) do
		local bact = buffq:pop()
		queue:append(tostring(bact.action.en)..' → '..tostring(bact.name))
		if (action.buff == nil) and (not isTooFar(bact.name)) and readyToCast(bact.action) then
			action.buff = bact
		end
	end
	
	actionQueue:text(getPrintable(queue))
	actionQueue:visible(modes.showActionQueue)
	
	if (action.cure ~= nil) then
		if (action.debuff ~= nil) and (action.debuff.prio < action.cure.prio) then
			return action.debuff
		elseif (action.buff ~= nil) and (action.buff.prio < action.cure.prio) then
			return action.buff
		end
		return action.cure
	elseif (action.debuff ~= nil) then
		if (action.buff ~= nil) and (action.buff.prio < action.debuff.prio) then
			return action.buff
		end
		return action.debuff
	elseif (action.buff ~= nil) then
		return action.buff
	end
	return nil
end

function readyToCast(action)
	if (action == nil) then
		return false
	elseif (action.type == 'JobAbility') then
		return (windower.ffxi.get_ability_recasts()[action.recast_id] == 0)
	else
		local recast = windower.ffxi.get_spell_recasts()[action.recast_id]
		if (recast == 0) then
			local player = windower.ffxi.get_player()
			if (player == nil) then return false end
			local mainCanCast = (action.levels[player.main_job_id] ~= nil) and (action.levels[player.main_job_id] <= player.main_job_level)
			local subCanCast = (action.levels[player.sub_job_id] ~= nil) and (action.levels[player.sub_job_id] <= player.sub_job_level)
			local spellAvailable = windower.ffxi.get_spells()[action.id]
			return spellAvailable and (mainCanCast or subCanCast)
		end
		return (recast == 0)
	end
end

-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2015, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------