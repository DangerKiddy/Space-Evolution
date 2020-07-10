SpaceEvo = SpaceEvo or {}

function SpaceEvo:PrintEverywhere(msg)
	MsgC(Color(200, 255, 0), "[Space Evolution] ", color_white, msg.."\n")
	chat.AddText(Color(249, 255, 120), "[Space Evolution] ", color_white, msg.."\n")
end
function SpaceEvo:PrintConsole(msg)
	MsgC(Color(200, 255, 0), "[Space Evolution] ", color_white, msg.."\n")
end

function SpaceEvo:SaveGame()
	if SpaceEvo.Removing then return end
	hook.Run("SpaceEvo_PreSave")
	file.Write("space_evolution/items.dat", util.TableToJSON(SpaceEvo.Items.Storage))
	SpaceEvo.Planets:SavePlanet(SpaceEvo.CurrentWorld)

	SpaceEvo:PrintEverywhere("Saved current progress!")
	hook.Run("SpaceEvo_PostSave")
end

timer.Create("Autosave", 120, 0, SpaceEvo.SaveGame)