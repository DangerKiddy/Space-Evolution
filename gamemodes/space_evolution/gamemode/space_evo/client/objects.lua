SpaceEvo.Objects = SpaceEvo.Objects or {}

function SpaceEvo.Objects:Print(msg)
	MsgC(Color(69, 135, 255), "[Objects] ", color_white, msg.."\n")
end
SpaceEvo.Objects:Print("Loading objects")
function SpaceEvo.Objects:Create(objName, objBlockPos)
	if SpaceEvo.Removing then return end
	SpaceEvo.Objects:Print("Creating new object("..objName..")")

	local id = table.insert(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects, {
		Name = objName,
		Pos = objBlockPos,

		BuildState = 0,
		CurrentTask = "Nothing",
	})
	hook.Run("SpaceEvo_OnObjectCreated", id, objName, objBlockPos)

	return id
end
function SpaceEvo.Objects:Get(id, planet)
	return SpaceEvo.Planets[planet or SpaceEvo.CurrentWorld].Objects[id]
end
function SpaceEvo.Objects:GetPos(obj)
	return SpaceEvo.WorldPos + Vector(obj.Pos.x*10, obj.Pos.y*10)
end
function SpaceEvo.Objects:GetScreenPos(obj)
	local x, y = obj.Pos.x, obj.Pos.y
	local pos = SpaceEvo.WorldPos + Vector(x*10, y*10)
	return (pos+Vector(5,5)):ToScreen()
end