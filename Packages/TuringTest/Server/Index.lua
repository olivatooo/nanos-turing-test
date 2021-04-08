Package:RequirePackage("NanosWorldWeapons")
Package:Require("Utils.lua")
Package:Require("Bot.lua")
Package:Require("Constants.lua")
Package:Require("PlayerBot.lua")
Package:Require("PlayerHunter.lua")


player_list = {}
bots = {}
new_obj = {}
game_running = 0
start_time = 20
bot_m = nil
human_points = 0
bot_points = 0
number_of_bots = 0
number_of_hunters = 0
list_of_bots = {}
list_of_hunters = {}

function PlayTheme()
	local thm = "music_0"..tostring(math.random(1,8))
	Events:BroadcastRemote("Theme", {"TuringTest::"..thm})
end

function stop_theme()
	Events:BroadcastRemote("StopTheme", {})
end

function changeMap()
	Server:ChangeMap("PolygonCity::" .. Assets:GetMaps("PolygonCity")(math.random[#Assets:GetMaps("PolygonCity")]))
end

function spawn_timer()
	Timer:SetTimeout(1000, function()
		Events:BroadcastRemote("StartTimer", {start_time})
		if start_time == 1 then
			clear()
			Package:Log("Killed everyone")
			start_game()
			Package:Log("Starting bc there are more than 1 player")
			return false
		end
		start_time = start_time - 1
	end);
end

function spawnPlayer(player)
	if spawn_locations == nil or bounds == nil or objective_position == nil or objective_sm == nil then
		Events:Call("SendMapInfo", {})
	end
	player_list = NanosWorld:GetPlayers()
	if game_running == 0 then
		local mannequin = Character(spawn_locations[math.random(#spawn_locations)], Rotator(0, 0, 0), "NanosWorld::SK_Mannequin")
		player:Possess(mannequin)
		start_time = 10
		if #player_list >= 2 then
			spawn_timer()
		end
	end	
end

function update_money(player, amount)
	if player:IsValid() then
		player:SetValue("money", amount)
		Events:CallRemote("UpdateMoney", player, {amount})
	end
end

function add_money(player, amount)
	if player:IsValid() then
		update_money(player, player:GetValue("money")+amount)
	end
end

Player:Subscribe("Spawn", function(player)
	Server:BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> has joined the server")
	local gpd = Package:GetPersistentData()
	if gpd[player:GetName()] == nil then
		Package:SetPersistentData(player:GetName(), 0)
		update_money(player, 0)
	else
		update_money(player, gpd[player:GetName()])
	end
	spawnPlayer(player)	
end)


Player:Subscribe("UnPossess", function(player, character, is_player_disconnecting)
	Package:SetPersistentData(player:GetName(), player:GetValue("money"))
	Package:Log(is_player_disconnecting)
	if (is_player_disconnecting) then
		if player:GetValue("type") == "hunter" then
			number_of_hunters = number_of_hunters - 1
			if number_of_hunters == 0 then
				game_end("bots")
			end
		end

		if player:GetValue("type") == "bot" then
			number_of_bots = number_of_bots - 1
			Events:BroadcastRemote("KilledBot", {})
			if number_of_bots == 0 then
				game_end("human")
			end
		end
		if character then
			character:SetHealth(-1)
			character:Destroy()
		end

		player_list = NanosWorld:GetPlayers()
		if #player_list < 2 then
			clear()
			for index, value in ipairs(player_list) do
				spawnPlayer(value)
			end
			game_running = 0
		end

	end
end)

Player:Subscribe("Destroy", function(player)
	Server:BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> has left the server")
	player_list = NanosWorld:GetPlayers()
end)

function spectator(player)
	Server:SendChatMessage(player, "You are <red>dead</>! You can spectate other players by pressing <bold>Left</> or <bold>Right</> keys!")

	-- Unpossess the Character after 2	 seconds
	Timer:SetTimeout(2000, function(p)
		if (p and p:IsValid()) then
			p:UnPossess()
			Events:CallRemote("SpectateOnDeath", player, {})
		end
		return false
	end, {player})
end

function clear()
	local actors_to_destroy = {}
	for k, e in pairs(Character) do table.insert(actors_to_destroy, e) end
	for k, e in pairs(Prop) do table.insert(actors_to_destroy, e) end
	for k, e in pairs(StaticMesh) do table.insert(actors_to_destroy, e) end
	for k, e in pairs(Weapon) do table.insert(actors_to_destroy, e) end
	for k, e in pairs(Trigger) do table.insert(actors_to_destroy, e) end
	for k, e in pairs(Light) do table.insert(actors_to_destroy, e) end
	for k, e in pairs(actors_to_destroy) do e:Destroy() end
	bots = {}
	list_of_bots = {}
	list_of_hunters = {}
end

function game_end(winner)
	if game_running == 1 then
		game_running = 0
		stop_theme()
		if bot_m ~= nil then
			Package:Log("Canceled movement")
			Timer:ClearTimeout(bot_m)
		end

		Events:BroadcastRemote("WinnerIs", {winner, generate_scoreboard()})
		if winner == "bots" then
			for v,k in ipairs(list_of_bots) do
				add_money(k, 1000)
			end
			Events:BroadcastRemote("Music", {"TuringTest::bot_win"})
			bot_points = bot_points + 1
			if bot_points >= 10 then
				changeMap()
			end
			Server:BroadcastChatMessage("<blue>Bots WIN!</>")
		else
			for v,k in ipairs(list_of_hunters) do
				add_money(k, 1000)
			end
			Events:BroadcastRemote("Music", {"TuringTest::human_win"})
			human_points = human_points + 1
			if human_points >= 10 then
				changeMap()
			end
			Server:BroadcastChatMessage("<red>Humans WIN!</>")
		end
		Server:BroadcastChatMessage("<red>Humans:" .. human_points .."</>/<blue>Bots:" .. bot_points .."</>")
		
		Package:Log("Killed everyone")
		if #player_list < 2 then
			game_running = 0
		end

		Timer:SetTimeout(15000, function()
			clear()
			start_game()
			return false
		end)
	end
end

function str_objectives()
	local str_obj = ""
	for i=1,#new_obj do
		str_obj = str_obj .. new_obj[i] .. ","
	end
	return str_obj
end

function str_bots()
	local str_obj = ""
	for i=1,number_of_bots do
		str_obj = str_obj .. "o,"
	end
	return str_obj
end

function generate_scoreboard()
	local scoreboard = ""
	for k,v in ipairs(list_of_hunters) do
		if v:IsValid() then
			scoreboard = scoreboard .. v:GetName() .. ":" .. tostring(v:GetValue("money")) .. ","
		end
	end
	for k,v in ipairs(list_of_bots) do
		if v:IsValid() then
			scoreboard = scoreboard .. v:GetName() .. ":" .. tostring(v:GetValue("money")) .. ","
		end
	end
	return scoreboard
end

function start_game()
	bots = {}
	shuffled_spawn = {}
	number_of_bots = 0
	number_of_hunters = 0
	game_running = 1
	for i, v in ipairs(spawn_locations) do
		local pos = math.random(1, #shuffled_spawn+1)
		table.insert(shuffled_spawn, pos, v)
	end
	
	player_list = NanosWorld:GetPlayers()
	shuffled_player = {}
	for i, v in pairs(player_list) do
		local pos = math.random(1, #shuffled_player+1)
		table.insert(shuffled_player, pos, v)
	end
	
	for i, n in ipairs(shuffled_spawn) do
		local mannequin = Character(n, Rotator(0, 0, 0), "NanosWorld::SK_Mannequin")
		mannequin:SetMaterialColorParameter("Tint", Color(math.random(), math.random(), math.random()))

		if math.random(0, 100) > 60 then
			mannequin:AddSkeletalMeshAttached("shirt", shirt[math.random(#shirt)])
		end
		if math.random(0, 100) > 60 then
			mannequin:AddSkeletalMeshAttached("pants", pants[math.random(#pants)])
		end
		if math.random(0, 100) > 60 then
			mannequin:AddSkeletalMeshAttached("shoes", shoes[math.random(#shoes)])
		end
		if math.random(0, 100) > 60 then
			mannequin:AddStaticMeshAttached("beard", beard[math.random(#beard)], "beard")
		end
		if math.random(0, 100) > 60 then
			mannequin:AddStaticMeshAttached("hair", hair[math.random(#hair)], "hair_male")
		end
		local is_player = nil
		
		if #shuffled_player > math.floor(#player_list/2) then
			is_player = table.remove(shuffled_player, 1)
		end
		if is_player then
			create_bot(is_player, mannequin)
		else
			bot_movement_config(mannequin)
			table.insert(bots, mannequin)
		end
	end
	
	for i,v in pairs(shuffled_player) do
		create_hunter(v)
	end

	
	bot_movement()

	new_obj = generate_objectives()
	Package:Log(str_objectives())
	Events:BroadcastRemote("SetObjectives", {str_objectives()})
	Events:BroadcastRemote("SetBots", {str_bots()})
	PlayTheme()
	highlight_bots()
	Package:Log("Game Started")
	

end

Package:Subscribe("Load", function()
	for k,p in pairs(NanosWorld:GetPlayers()) do
		spawnPlayer(p)
	end
end)


Events:Subscribe("MapLoaded", function(map_custom_spawn_locations, map_bounds, map_objectives, map_sm, hotdog_stand)
	spawn_locations = map_custom_spawn_locations
	if not spawn_locations then
		Package:Log("Spawn Location not defined")
	end
	bounds = map_bounds
	if not bounds then
		Package:Log("map_bounds not defined")
	end
	objective_position = map_objectives
	if not objective_position then
		Package:Log("objective_position not defined")
	end
	objective_sm = map_sm
	if not objective_sm then
		Package:Log("objective_sm not defined")
	end
	objective_ms = table_invert(objective_sm)
	
	hotdog_stand_sm = hotdog_stand
	if not hotdog_stand_sm then
		Package:Log("hotdog_stand_sm not defined")
	end
end)


function spawn_props(prps_obj)
    local op = get_values(shuffle(objective_position))
	local op_stand = get_values(shuffle(hotdog_stand_sm))
	for i=1,3 do
		local head = table.remove(op_stand, 1)
		local trg = Trigger(head - Vector(0,0,100), 300, false, Color(1, 0, 0, 1))
		trg:Subscribe("BeginOverlap", function(trigger, actor_triggering)
			if actor_triggering:IsValid() then
				if actor_triggering:GetValue("flag") ~= nil then
					if actor_triggering:IsValid() then
					complete_objective(objective_ms[actor_triggering:GetValue("flag")])
					if actor_triggering:IsValid() then
						actor_triggering:Destroy()
					end
					end
				end
			end
		end)

		local sm = StaticMesh(
			head,
			Rotator(0, 0, 0),
			"PolygonCity::SM_Prop_HotdogStand_01"
		)

	end

    for i=1,#prps_obj do
        local head = table.remove(op, 1)
		local prop = objective_sm[prps_obj[i]]

		local p = Prop(
			head,
			Rotator(0, 0, 0),
			"PolygonCity::"..prop
		)

		local q = Prop(
			op[math.random(#op)],
			Rotator(0, 0, 0),
			"PolygonCity::".. prop
		)

		p:SetValue("flag", prop)
		q:SetValue("flag", prop)
    end
end

function generate_objectives()
    local obj = get_keys(objective_sm)
    local new_obj = {}
    for i=1,math.ceil(#player_list*1.5) do
        table.insert(new_obj, obj[math.random(#obj)])
    end
    spawn_props(new_obj)
    return new_obj
end


