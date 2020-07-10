include( "shared.lua" )

local cl = GM.FolderName .. "/gamemode/space_evo/client/"
local cl_files, folders = file.Find(cl .. "*", "LUA")
for k, v in pairs(cl_files) do
	include(cl..v)
end

function GM:HUDDrawTargetID()
	return false
end

function ScreenScale(num)
	return num*(ScrH()/360)
end
SScale = ScreenScale

_G["SScale"] = SScale
_G["ScreenScale"] = ScreenScale