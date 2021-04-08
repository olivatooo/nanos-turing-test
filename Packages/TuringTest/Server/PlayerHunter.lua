function create_hunter(player)
	add_money(player, 10)
	player:SetVOIPChannel(2)
	player:SetVOIPSetting(VOIPSetting.Global)
	table.insert(list_of_hunters, player)
	local money = player:GetValue("money")
	
	local selected_mesh = character_meshes[math.random(#character_meshes)]
	local new_char = Character(spawn_locations[math.random(#spawn_locations)], Rotator(), selected_mesh)
	Events:CallRemote("SetTeam", player, {"human"})
	local wpn = nil
	if money < 2000 then
		wpn = NanosWorldWeapons.Glock(Vector(), Rotator())
	end
	if money > 2000 and money <5000 then
		wpn = NanosWorldWeapons.DesertEagle(Vector(), Rotator())
	end
	if money > 5000 and money <10000 then
		wpn = NanosWorldWeapons.Moss500(Vector(), Rotator())
	end
	if money > 10000 and money <15000 then
		wpn = NanosWorldWeapons.SMG11(Vector(), Rotator())
	end
	if money > 15000 and money <20000 then
		wpn = NanosWorldWeapons.AK74U(Vector(), Rotator())
	end
	if money > 20000 and money <25000 then
		wpn = NanosWorldWeapons.GE36(Vector(), Rotator())
	end
	if money > 20000 then
		wpn = NanosWorldWeapons.AR4(Vector(), Rotator())
		wpn:Subscribe("Fire", function(s, sh)
			s:SetBulletColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))		
		end)
	end
	wpn:SetBulletColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
	new_char:PickUp(wpn)
	new_char:SetMaxHealth(math.ceil(2000/#player_list))
	new_char:SetHealth(math.ceil(2000/#player_list))
	new_char:SetValue("type", "hunter")
	player:SetValue("type", "hunter")
	number_of_hunters = number_of_hunters + 1
	-- Customization
	if (selected_mesh == "NanosWorld::SK_Male") then
		local selected_hair = sk_male_hair_meshes[math.random(#sk_male_hair_meshes)]
		if (selected_hair ~= "") then
			new_char:AddStaticMeshAttached("hair", selected_hair, "hair_male")
		end

		local selected_beard = sk_male_beard_meshes[math.random(#sk_male_beard_meshes)]
		if (selected_beard ~= "") then
			new_char:AddStaticMeshAttached("beard", selected_beard, "beard")
		end
	end

	if (selected_mesh == "NanosWorld::SK_Female") then
		local selected_hair = sk_female_hair_meshes[math.random(#sk_female_hair_meshes)]
		if (selected_hair ~= "") then
			new_char:AddStaticMeshAttached("hair", selected_hair, "hair_female")
		end

		-- Those parameters are specific to female mesh
		new_char:SetMaterialColorParameter("BlushTint", Color(math.random(),math.random(),math.random()))
		new_char:SetMaterialColorParameter("EyeShadowTint", Color(math.random(),math.random(),math.random()))
		new_char:SetMaterialColorParameter("LipstickTint", Color(math.random(),math.random(),math.random()))
	end

	-- Adds eyes to humanoid meshes
	if (selected_mesh == "NanosWorld::SK_Male" or selected_mesh == "NanosWorld::SK_Female") then
		new_char:AddStaticMeshAttached("eye_left", "NanosWorld::SM_Eye", "eye_left")
		new_char:AddStaticMeshAttached("eye_right", "NanosWorld::SM_Eye", "eye_right")
		
		-- Those parameters are specific to humanoid meshes (were added in their materials)
		new_char:SetMaterialColorParameter("HairTint", Color(math.random(),math.random(),math.random()))
		new_char:SetMaterialColorParameter("Tint", Color(math.random(),math.random(),math.random()))

		new_char:SetMaterialScalarParameter("Muscular", math.random(100) / 100)
		new_char:SetMaterialScalarParameter("BaseColorPower", math.random(2) + 0.5)

		for i, morph_target in ipairs(human_morph_targets) do
			new_char:SetMorphTarget(morph_target, math.random(200) / 100 - 1)
		end
	end
	player:Possess(new_char)
	new_char:SetCanGrabProps(false)
	new_char:SetCameraMode(1)
	new_char:Subscribe("Death", function(chara, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
		spectator(player)
		number_of_hunters = number_of_hunters - 1
		if number_of_hunters == 0 then
			 game_end("bots")
		end
		if (instigator) then
			Server:BroadcastChatMessage("<cyan>" .. instigator:GetName() .. "</> killed <cyan>" .. player:GetName() .. "</>")
		else
			Server:BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> died")
		end
	end)
end