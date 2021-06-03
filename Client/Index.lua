Package:Require ("HUD.lua")

team_m = 0
current_spectating_index  = 1

Events:Subscribe("Voice", function(bot, voice)

	local my_sound = Sound(
        Vector(), -- Location (if a 3D sound)
        voice, -- Asset Path
        false, -- Is 2D Sound
        true, -- Auto Destroy (if to destroy after finished playing)
        SoundType.SFX, -- Sound Type (SFX)
        1.25, -- Volume
        1, -- Pitch
        10, -- Inner Radius
        2500, -- Outer Radius
        AttenuationFunction.NaturalSound
	)

    my_sound:AttachTo(bot,AttachmentRule.SnapToTarget ,  "head")
end
)

Events:Subscribe("Music", function(music)
	local my_sound = Sound(
					Vector(), -- Location (if a 3D sound)
					music, -- Asset Path
					true, -- Is 2D Sound
					false, -- Auto Destroy (if to destroy after finished playing)
					0, -- Sound Type (SFX)
					0.5, -- Volume
					1 -- Pitch
			)
	Timer:SetTimeout(15000, function(m_music)
			if m_music:IsValid() then
					m_music:Destroy()
			end
			return false
	end, {my_sound})
end
)

Events:Subscribe("Theme", function(music)
	theme = Sound(
			Vector(), -- Location (if a 3D sound)
			music, -- Asset Path
			true, -- Is 2D Sound
			false, -- Auto Destroy (if to destroy after finished playing)
			0, -- Sound Type (SFX)
			0.5, -- Volume
			1 -- Pitch
		)
end
)

Events:Subscribe("StopTheme", function()
	if theme ~= nil then
		theme:Stop()
		theme:Destroy()
	end
end
)

main_hud = WebUI("Main HUD", "file:///UI/index.html")

Events:Subscribe("SetTeam", function(team)
	team_m = team
	main_hud:CallEvent("SetTeam", {team})
end
)

Events:Subscribe("UpdateMoney", function (money) 
	Package:Log("Money updated")
	main_hud:CallEvent("UpdateMoney", {money})
end)

Events:Subscribe("WinnerIs", function(winner, scoreboard)
	main_hud:CallEvent("WinnerIs", {winner, scoreboard})
end
)

taunt_1 = 0
Timer:SetTimeout(1000, function()
	taunt_1 = taunt_1 - 1
	main_hud:CallEvent("SetCooldown", {1, taunt_1})
end
)

taunt_2 = 0
Timer:SetTimeout(1000, function()
	taunt_2 = taunt_2 - 1
	main_hud:CallEvent("SetCooldown", {2, taunt_2})
end
)

taunt_3 = 0
Timer:SetTimeout(1000, function()
	taunt_3 = taunt_3 - 1
	main_hud:CallEvent("SetCooldown", {3, taunt_3})
end
)

taunt_4 = 3000000
Timer:SetTimeout(1000, function()
	taunt_4 = taunt_4 - 1
	main_hud:CallEvent("SetCooldown", {4, taunt_4})
end
)

Events:Subscribe("SpectateOnDeath", function()
	SpectateNext(1)
end
)

function SpectateNext(index_increment)
	if (NanosWorld:GetLocalPlayer():GetControlledCharacter()) then return end
	current_spectating_index = current_spectating_index + index_increment

	local players = {}
	for k, v in pairs(NanosWorld:GetPlayers()) do
		if (v ~= NanosWorld:GetLocalPlayer() and v:GetControlledCharacter() ~= nil) then
			table.insert(players, v)
		end
	end

	if (#players == 0) then return end

	if (not players[current_spectating_index]) then
		if (index_increment > 0) then
			current_spectating_index = 1
		else
			current_spectating_index = #players
		end
	end

	Client:Spectate(players[current_spectating_index])
end

Client:Subscribe("KeyUp", function(key)
	if team_m ~= "human" then
		if key == "One" then
			if taunt_1 <= 0 then
				taunt_1 = 2
				Events:CallRemote("TauntVoice", {})
				main_hud:CallEvent("SetDisabled", {1})
			end
		end

		if key == "Two" then
			if taunt_2 <= 0 then
				taunt_2 = 3
				Events:CallRemote("TauntAnim", {})
				main_hud:CallEvent("SetDisabled", {2})
			end
		end

		if key == "Three" then
			if taunt_3 <= 0 then
				taunt_3 = 20
				Events:CallRemote("Disguise", {})
				main_hud:CallEvent("SetDisabled", {3})
			end
		end
	end
	if key == "Right" then
		SpectateNext(1)
	end

	if key == "Left" then
		SpectateNext(-1)
	end

end
)

Events:Subscribe("SetObjectives", function(obj)
	main_hud:CallEvent("SetObjectives", {obj})
end)

Events:Subscribe("SetBots", function(obj)
	main_hud:CallEvent("SetBots", {obj})
end)

Events:Subscribe("KilledBot", function()
	main_hud:CallEvent("KilledBot", {"o"})
end)

Events:Subscribe("CompleteObjective", function(obj)
	main_hud:CallEvent("CompleteObjective", {obj})
end)

Events:Subscribe("StartTimer", function(time)
	main_hud:CallEvent("SetStartTime",{time})
end)

-- Function to add a Nametag to a Player
function AddNametag(player, character)
    -- Try to get it's character
    if (character == nil) then
        character = player:GetControlledCharacter()
        if (character == nil) then return end
    end

    -- Spawns the Nametag (TextRender), attaches it to the character and saves it to the player's values
    local nametag = TextRender(Vector(), Rotator(), player:GetName(), Color(1, 1, 1), 1, 0, 24, 0, true)
		nametag:AttachTo(character, "", Vector(0, 0, 250), Rotator())
    player:SetValue("Nametag", nametag)
end

-- Function to remove a Nametag from  a Player
function RemoveNametag(player, character)
    -- Try to get it's character
    if (character == nil) then
        character = player:GetControlledCharacter()
        if (character == nil) then return end
    end

    -- Gets the Nametag from the player, if any, and destroys it
    local text_render = player:GetValue("Nametag")
    if (text_render and text_render:IsValid()) then
        text_render:Destroy()
    end
end

Events:Subscribe("HightlightBot", function (bot)
	local highlight_color = Color(0.25, 1, 0, 0) * 10
	Client:SetHighlightColor(highlight_color)
	bot:SetHighlightEnabled(true)
end)
