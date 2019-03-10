-----------------------------------------------------------------------------------------------------------------
---- Leader Menu made by Radu拉杜 if you have a problem please contact me (Discord : Radu 拉杜#5953) --------------
---- Lider Menu facut de Radu拉杜, daca ai vreo problema nu uita sa ma contactezi ! (Discord : Radu 拉杜#5953) ----
-----------------------------------------------------------------------------------------------------------------

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_factions")

factions = {
	-- {Grup de Membru, Lider Grup, Nume Grup}	
	{"cop", "Chestor General", "Police"},
	{"Membru Akatsuki", "Lider Akatsuki", "Mafia Akatsuki"}
}

local function ch_inviteInFaction(player,choice)
	local user_id = vRP.getUserId({player})
	for i, v in pairs(factions) do
		group = v[1]
		if(vRP.hasGroup({user_id, group}))then
			groupLider = v[2]
			groupName = v[3]
			theGroup = tostring(group)
			vRP.prompt({player,"Id: ","",function(player,id)
				id = parseInt(id)
				groupName = tostring(groupName)
				local target = vRP.getUserSource({id})
				if(target)then
					if(vRP.hasGroup({id, theGroup}))then
						vRPclient.notify(player,{"~r~Jucator deja in ~g~"..groupName.."!"})
					else
						vRP.addUserGroup({id,theGroup})
						local name = GetPlayerName(target)
						vRPclient.notify(player,{"~w~L-ai adaugat pe ~g~"..name.."~w~ in ~g~"..groupName.."!"})
						vRPclient.notify(target,{"~w~Ai fost adaugat in ~g~"..groupName.."!"})
					end
				else
					vRPclient.notify(player,{"~r~Jucator nu a fost gasit!"})
				end
			end})
		end
	end
end

local function ch_removeFromFaction(player,choice)
	local user_id = vRP.getUserId({player})
	for i, v in pairs(factions) do
		group = v[1]
		if(vRP.hasGroup({user_id, group}))then
			groupLider = v[2]
			groupName = v[3]
			theGroup = tostring(group)
			vRP.prompt({player,"User id: ","",function(player,id)
				groupName = tostring(groupName)
				id = parseInt(id)
				local target = vRP.getUserSource({id})
				if(target)then
					if(vRP.hasGroup({id, theGroup}))then
						vRP.removeUserGroup({id,theGroup})
						local name = GetPlayerName(target)
						vRPclient.notify(player,{"~w~L-ai dat afara pe ~g~"..name.." ~w~din ~g~"..groupName.."!"})
						vRPclient.notify(target,{"~w~Ai fost dat afara din ~g~"..groupName.."!"})
					else
						vRPclient.notify(player,{"~w~Jucatorul nu este in ~r~"..groupName.."!"})
					end
				else
					vRPclient.notify(player,{"~r~Jucatorul nu a fost gasit!"})
				end
			end})
		end
	end
end

vRP.registerMenuBuilder({"main", function(add, data)
	local user_id = vRP.getUserId({data.player})
	if user_id ~= nil then
		local choices = {}
		for i, v in pairs(factions) do
			groupLider = v[2]
			if(vRP.hasGroup({user_id, groupLider}))then
				group = v[1]
				groupName = v[3]
				choices["Leader Menu"] = {function(player,choice)
					vRP.buildMenu({"Leader Menu", {player = player}, function(menu)
						menu.name = "Leader Menu"
						menu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
						menu.onclose = function(player) vRP.openMainMenu({player}) end
						menu["Invita Membrii"] = {ch_inviteInFaction, "Incita membrii in "..groupName}
						menu["Kick Membru"] = {ch_removeFromFaction, "Da afara membrii din "..groupName}
						vRP.openMenu({player,menu})
					end})
				end, "Lider menu pentru factiunea "..groupName}
			end
		end
		add(choices)
	end
end})

local function ch_leaveGroup(player,choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		for i, v in pairs(factions) do
			group = v[1]
			if(vRP.hasGroup({user_id, group}))then
				groupLider = v[2]
				groupName = v[3]
				theGroup = tostring(group)
				vRP.removeUserGroup({user_id,theGroup})
				vRPclient.notify(player,{"~w~Ai iesit din ~r~"..groupName.."!"})
				vRP.openMainMenu({player})
				local fMembers = vRP.getUsersByGroup({tostring(theGroup)})
				for i, v in ipairs(fMembers) do
					local member = vRP.getUserSource({tonumber(v)})
					vRPclient.notify(member,{"~r~"..GetPlayerName(player).." ~w~a iesit din factiune!"})
				end
			end
		end
	end
end

vRP.registerMenuBuilder({"main", function(add, data)
	local user_id = vRP.getUserId({data.player})
	if user_id ~= nil then
		local choices = {}
		for i, v in pairs(factions) do
			group = v[1]
			if(vRP.hasGroup({user_id, group}))then
				groupLider = v[2]
				groupName = v[3]
				choices["Paraseste Factiunea"] = {function(player,choice)
					vRP.buildMenu({"Parasesti Factiunea?", {player = player}, function(menu)
						groupName = tostring(groupName)
						menu.name = "Parasesti Factiunea?"
						menu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
						menu.onclose = function(player) vRP.openMainMenu({player}) end

						menu["DA"] = {ch_leaveGroup, "Paraseste "..groupName}
						menu["NU"] = {function(player) vRP.openMainMenu({player}) end}
						vRP.openMenu({player,menu})
					end})
				end, "Paraseste "..groupName}
			end
		end
		add(choices)
	end
end})

RegisterCommand('f', function(source, args, rawCommand)
	if(args[1] == nil)then
		TriggerClientEvent('chatMessage', source, "^3SYNTAX: /"..rawCommand.." [Message]") 
	else
		local user_id = vRP.getUserId({source})
		theGroup = ""
		for i, v in pairs(factions) do
			if vRP.hasGroup({user_id,tostring(v)}) then
				theGroup = tostring(v[1])
				theName = tostring(v[3])
			end
		end
		local fMembers = vRP.getUsersByGroup({tostring(theGroup)})
		for i, v in ipairs(fMembers) do
			local player = vRP.getUserSource({tonumber(v)})
			TriggerClientEvent('chatMessage', player, "^5["..theName.."] ^7| " .. GetPlayerName(source) .. ": " ..  rawCommand:sub(3))
		end
	end
end)
