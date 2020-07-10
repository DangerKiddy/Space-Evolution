AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

local sv = GM.FolderName .. "/gamemode/space_evo/server/"
local sv_files, folders = file.Find(sv .. "*", "LUA")
for k, v in pairs(sv_files) do
	include(sv..v)
end
local cl = GM.FolderName .. "/gamemode/space_evo/client/"
local cl_files, folders = file.Find(cl .. "*", "LUA")
for k, v in pairs(cl_files) do
	AddCSLuaFile(cl..v)
end

function GM:EntityTakeDamage()
	return true
end

function GM:PlayerShouldTakeDamage()
	return false
end