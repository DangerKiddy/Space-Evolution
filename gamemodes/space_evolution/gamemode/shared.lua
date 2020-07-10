
local sh = GM.FolderName .. "/gamemode/space_evo/"
local sh_files, folders = file.Find(sh .. "*", "LUA")
for k, v in pairs(sh_files) do
	if SERVER then
		AddCSLuaFile(sh..v)
	end
	include(sh..v)
end