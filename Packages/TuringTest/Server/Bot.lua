function random_move(bot)
	if bot:IsValid() then
		bot:MoveTo(Vector(
			math.random(bounds['x_lower'], bounds['x_upper']),
			math.random(bounds['y_lower'], bounds['y_upper']),
			math.random(bounds['z_lower'], bounds['z_upper']))
			, 800)
	end
end

function random_look(bot)
	if bot:IsValid() then
		bot:LookAt(Vector(
			math.random(bounds['x_lower'], bounds['x_upper']),
			math.random(bounds['y_lower'], bounds['y_upper']),
			math.random(bounds['z_lower'], bounds['z_upper'])
		)
	)
	end
end

function despair(bot)
	bot:SetSpeedMultiplier(math.random(1,2))
	bot:SetGaitMode(1)
	random_move(bot)
	random_look(bot)

	local my_id = Timer:SetTimeout(math.random(500, 1260), function(m_bot)

		if not m_bot:IsValid() then
			return false
		end

		if math.random(0, 100) > 80 then
			m_bot:PlayAnimation("NanosWorld::" .. assets_list[math.random(#assets_list)], math.random(0,1))	
		end

		if math.random(0, 100) > 38 then
			m_bot:Jump()	
		end

		if math.random(0, 100) > 99 then
			m_bot:SetRagdollMode(true)	
		end

		if math.random(0, 100) > 88 then
			m_bot:SetStanceMode(math.random(0,3))	
		end

		if math.random(0, 100) > 90 then
			m_bot:SetSpeedMultiplier(math.random(2,3))
		end

		if math.random(0, 100) > 10 then
			random_move(bot)
			random_look(bot)
			m_bot:SetGaitMode(math.random(1,2))
		end

		if math.random(0, 100) > 95 then
			return false
		end

	end, {bot})
	
end

function bot_movement_config(bot)
	bot:Subscribe("Death", function(chara, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
		if (instigator and instigator:IsValid()) then
			add_money(instigator, -100)
			Server:BroadcastChatMessage("<cyan>" .. instigator:GetName() .. "</> killed a bot...")
			instigator:GetControlledCharacter():ApplyDamage(math.random(100,130))
		end
	end)
	
	bot:Subscribe("TakeDamage", function(chara, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
	if math.random(0,100)>50 then
		despair(bot)
	end
	end)
end

function bot_movement()
	Package:Log("Bot movement started")
	bot_m = Timer:SetTimeout(math.random(150,250), function()
		if #bots == 0 then
			Package:Log("THERE ARE NO BOTS")
			return false
		end

		random_move(bots[math.random(#bots)])

		random_look(bots[math.random(#bots)])

		anim_bot = bots[math.random(#bots)]

		if anim_bot:GetGaitMode() == 0 then
			anim_bot:PlayAnimation("NanosWorld::" .. assets_list[math.random(#assets_list)], math.random(0,1))
		else
			anim_bot:PlayAnimation("NanosWorld::" .. assets_list[math.random(#assets_list)], AnimationSlotType.UpperBody)
		end

		if math.random(0, 100) > 50 then
			local talk_bot = bots[math.random(#bots)]
			local talk = "PolygonCity::taunt_" .. math.random(1,150)
			Events:BroadcastRemote("Voice", {talk_bot, talk})
		end

		if math.random(0, 100) > 90 then
			bots[math.random(#bots)]:Jump()
		end

		if math.random(0, 1000) > 990 then
			bots[math.random(#bots)]:SetRagdollMode(true)
		end

		if math.random(0, 100) > 50 then
			bots[math.random(#bots)]:SetStanceMode(math.random(0,3))	
		end

	end)
end

