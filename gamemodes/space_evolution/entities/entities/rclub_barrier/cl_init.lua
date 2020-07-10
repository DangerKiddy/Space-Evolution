include('shared.lua')

function ENT:Draw()
	if self:GetNWBool("dontDraw") then
		if GetConVar("developer"):GetBool() then
			self:SetColor(Color(255,0,0))
			self:DrawModel()
		end
		return
	end
	if GetConVar("developer"):GetBool() then
		self:DrawModel()
	else
		if LocalPlayer():GetNWString("RaceID") == self:GetNWString("RaceID") or LocalPlayer():GetNWString("RaceID") == (LocalPlayer():SteamID64()..self:GetNWString("RaceID")) or 
			LocalPlayer():GetNWString("RaceID") == (LocalPlayer():SteamID()..self:GetNWString("RaceID")) then
			self:DrawModel()
		end
	end
end

function ENT:Initialize()
	self:DestroyShadow()
end

function ENT:Think()
	self:DestroyShadow()
end