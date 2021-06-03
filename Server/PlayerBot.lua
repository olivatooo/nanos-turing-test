function create_bot(player, mannequin)
	add_money(player, 10)
	player:SetVOIPChannel(1)
	player:SetVOIPSetting(VOIPSetting.Global)
	table.insert(list_of_bots, player)
	player:SetValue("type", "bot")
	number_of_bots = number_of_bots + 1
	player:Possess(mannequin)
	mannequin:SetCanPickupPickables(false)
	Events:CallRemote("SetTeam", player, {"bot"})
	mannequin:Subscribe("Death", function(chara, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
		number_of_bots = number_of_bots - 1
		Events:BroadcastRemote("KilledBot", {})
		spectator(player)
		if number_of_bots == 0 then
			 game_end("human")
		end
		if (instigator) then
			add_money(instigator, 100)
			Server:BroadcastChatMessage("<cyan>" .. instigator:GetName() .. "</> killed <cyan>" .. player:GetName() .. "</>")
		else
			Server:BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> died")
		end
	end)
end

function highlight_bots()
	for index, value in ipairs(list_of_bots) do
		for idx, val in ipairs(list_of_bots) do
			if value ~= val then
				Events:CallRemote("HightlightBot", value, {val:GetControlledCharacter()})
			end
		end
	end
end


Events:Subscribe("TauntAnim", function(player)
	if player:GetControlledCharacter() ~= nil then
		if player:GetValue("money") >= 10 then
			add_money(player, -10)
			local anim_bot = player:GetControlledCharacter()
			if anim_bot:GetGaitMode() == 0 then
				anim_bot:PlayAnimation("NanosWorld::" .. assets_list[math.random(#assets_list)], math.random(0,1))
			else
				anim_bot:PlayAnimation("NanosWorld::" .. assets_list[math.random(#assets_list)], AnimationSlotType.UpperBody)
			end
		end
	end
end
)

Events:Subscribe("TauntVoice", function(player)
	if player:GetControlledCharacter() ~= nil then
		if player:GetValue("money") >= 10 then
			add_money(player, -10)
			local talk = "PolygonCity::taunt_" .. tostring(math.random(1,150))
			Events:BroadcastRemote("Voice", {player:GetControlledCharacter(), talk})
		end
	end
end
)

Events:Subscribe("Disguise", function (player)
	if player:GetControlledCharacter() ~= nil then
		if player:GetValue("money") >= 100 then
			add_money(player, -100)
			local mannequin =  player:GetControlledCharacter()
			mannequin:SetMaterialColorParameter("Tint", Color(math.random(), math.random(), math.random()))
			mannequin:RemoveSkeletalMeshAttached("shirt")
			mannequin:RemoveSkeletalMeshAttached("pants")
			mannequin:RemoveSkeletalMeshAttached("shoes")
			mannequin:RemoveSkeletalMeshAttached("beard")
			mannequin:RemoveSkeletalMeshAttached("hair")
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
		end
	end
end)

function complete_objective(key)
    table.remove(new_obj, 1)
	Events:BroadcastRemote("Music", {"PolygonCity::meow"})
    Events:BroadcastRemote("CompleteObjective", {key})
    if #new_obj == 0 then
		game_end("bots")
    end
end
