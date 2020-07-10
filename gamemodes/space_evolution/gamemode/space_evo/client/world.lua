SpaceEvo.MainFrame = SpaceEvo.MainFrame

local hook = hook
local surface = surface
local draw = draw
local pairs = pairs
local ipairs = ipairs
local math = math
local FrameTime = FrameTime
local CurTime = CurTime
local table = table
local input = input
local timer = timer
local chat = chat
local file = file
local GetConVar = GetConVar
local Material = Material
local ScrW = ScrW
local ScrH = ScrH

CreateConVar("spaceevo_particles", 1, FCVAR_ARCHIVE)

function SpaceEvo.Circle( x, y, radius, seg, col )
	local cir = {}

	draw.NoTexture()
	surface.SetDrawColor(col)
	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end
local hideHUDElements = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSuitPower"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudWeaponSelection"] = true,
}
hook.Add("HUDShouldDraw", "hideshit", function(name)
	if hideHUDElements[name] then return false end
end)

for i=3, 50 do
	surface.CreateFont( "SpaceEvo_Pixel"..i, {
		font = "RetroVille NC",
		extended = true,
		size = ScreenScale(i),
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
end

local function Closest(vec, vectors)
	local dist = math.huge
	local closest, closestindex
	for k, v in ipairs(vectors) do
		local d = v:DistToSqr(vec)
		if d < dist then
			closest = v
			closestindex = k

			dist = d
		end
	end

	return closest, closestindex
end

function SpaceEvo:Button(text, parrent)
	local btn = vgui.Create("DButton", parrent)
	btn:SetText("")
	btn.Text = text
	btn:SetCursor("blank")
	btn.Paint = function(s, w, h)
		local add = s:IsHovered() and 30 or 0
		draw.RoundedBox(0, 0, 0, w, h, Color(150-add,150-add,150-add))
		draw.RoundedBox(0, 3, 3, w-6, h-6, Color(100-add,100-add,100-add))

		SpaceEvo:ShadowText(btn.Text, "SpaceEvo_Pixel8", w/2, h/2, color_white, 1, 1)
		local x, y = s:ScreenToLocal(input.GetCursorPos())
		SpaceEvo.Circle( x, y, 5, 30, color_white )
	end
	btn.OnCursorEntered = function()
		surface.PlaySound("space_evolution/btn_over.wav")
	end
	btn.Click = function()end
	btn.DoClick = function()
		btn:Click(btn)
		surface.PlaySound("space_evolution/btn_click.wav")
	end
	return btn
end

function SpaceEvo:Frame(frm)
	local frm2 = vgui.Create("DFrame", frm)
	frm2:SetCursor("blank")
		frm2.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(150,150,150))
			draw.RoundedBox(0, 3, 3, w-6, h-6, Color(100,100,100))
			local x, y = s:ScreenToLocal(input.GetCursorPos())
			SpaceEvo.Circle( x, y, 5, 30, color_white )
		end
		local clsBright = 150

		frm2.btnClose.Paint = function(self, w, h)
			draw.RoundedBox( 0, -3, 3, w+3, h, Color( clsBright, 0, 0, 255 ))
			SpaceEvo:ShadowText("X","SpaceEvo_Pixel7",w/2,h/2,color_white,1,1)
		end
		frm2.btnClose.OnCursorEntered = function()
			surface.PlaySound("space_evolution/btn_over.wav")
			clsBright = 255
		end
		frm2.btnClose.OnCursorExited = function()
			clsBright = 200
		end
		frm2.btnClose.DoClick = function()
			surface.PlaySound("space_evolution/btn_click.wav")
			frm2:Close()
		end

		frm2.lblTitle:SetFont("SpaceEvo_Pixel6")
		frm2.lblTitle:SizeToContents()

		frm2.btnMaxim:SetCursor("bank")
		frm2.btnMaxim.Paint = function(self,w,h) end
		frm2.btnMaxim:SetDisabled(true)
		frm2.btnMinim:SetCursor("bank")
		frm2.btnMinim.Paint = function(self,w,h) end
		frm2.btnMinim:SetDisabled(true)

	return frm2
end

function SpaceEvo:NearestPixel(pos)
	local w_mesh = {}
	for k, v in pairs(SpaceEvo.GeneratedWorld.WorldMesh or {}) do
		w_mesh[k] = v.Pos
	end
	return Closest(pos, w_mesh)
end

local function position()
	local camPos = SpaceEvo.CamPos or Vector()
	local v = Vector(0,0,-12250)
    local normal = (camPos - v):GetNormalized()
    local hitpos = util.IntersectRayWithPlane( camPos, gui.ScreenToVector( input.GetCursorPos() ), v, normal )
    return hitpos
end

function SpaceEvo:ShadowText(t, f, x, y, c, ax, ay)
	local x1, y1 = draw.SimpleText(t, f, x+1, y+1, color_black, ax, ay)
	draw.SimpleText(t, f, x, y, c, ax, ay)
	return x1, y1
end
local particles = {}
function SpaceEvo.Particle(pData)
	for i=1, pData.Amount do
		local pData1 = table.Copy(pData)
		pData1.pRotate = pData1.Rotate
		pData1.Dead = CurTime() + pData1.Time + math.Rand(0, pData1.Time)
		pData1.Dir.x = pData1.Dir.x + math.Rand(-pData1.Spread, pData1.Spread)
		pData1.Dir.y = pData1.Dir.y + math.Rand(-pData1.Spread, pData1.Spread)
		table.insert(particles, pData1)
	end
end

local body = Material("space_evolution/body.png")
local pants = Material("space_evolution/pants.png")
local shirt = Material("space_evolution/shirt.png")
local shoes = Material("space_evolution/shoes.png")
local hairs = Material("space_evolution/hairs.png")
local star = Material("space_evolution/star.png")

SpaceEvo.CursorPos = {x = 0, y = 0}

local fallingStar
local function CreateFrame()
	if IsValid(SpaceEvo.MainFrame) then
		SpaceEvo.MainFrame:Remove()
	end
	
	SpaceEvo.MainFrame = vgui.Create("DFrame")
	local frm = SpaceEvo.MainFrame
	frm:SetSize(ScrW(), ScrH())
	frm:MakePopup()
	frm:ShowCloseButton(false)
	frm:SetTitle("")
	frm:SetCursor("blank")
	local c = {x = 0, y = 0, pos = Vector()}
	local lastWorld = ""
	local w_mesh = {}

	local activePixel
	local Human
	local Obj
	local HumanSelected
	local function RunStar()
		timer.Simple(math.random(300,600), function()
			fallingStar = {x = math.random(ScrW()/2, ScrW()), y = 50}
			RunStar()
		end)
	end
	RunStar()
	frm.Paint = function(s, w, h)
		if not SpaceEvo.Planets then return end
		local d = (math.Round((SpaceEvo.CamPos or Vector()):Distance(Vector(0,0,-11500))))
		if (d) > 0 then return end
		hook.Run("SpaceEvo_PreFramePaint", s, w, h)

		if fallingStar and fallingStar.x > 0 and fallingStar.y < h then
			fallingStar.x = fallingStar.x - FrameTime()*1000
			fallingStar.y = fallingStar.y + FrameTime()*600
			surface.SetDrawColor(color_white)
			surface.SetMaterial(star)
			surface.DrawTexturedRectRotated(fallingStar.x, fallingStar.y, 48, 48, 0)
		end

		if GetConVar("spaceevo_particles"):GetBool() then
			for k, v in ipairs(particles) do
				if CurTime() > v.Dead then table.remove(particles, k) continue end
				if not v.Mat then draw.NoTexture() else surface.SetMaterial(v.Mat) end

				v.x = v.x + v.Dir.x*FrameTime()*300
				v.y = v.y + v.Dir.y*FrameTime()*300
				local r = math.Remap(v.Dead - CurTime(), 0, v.Time, v.ColorEnd.r, v.ColorStart.r)
				local g = math.Remap(v.Dead - CurTime(), 0, v.Time, v.ColorEnd.g, v.ColorStart.g)
				local b = math.Remap(v.Dead - CurTime(), 0, v.Time, v.ColorEnd.b, v.ColorStart.b)
				local a = math.Remap(v.Dead - CurTime(), 0, v.Time, v.ColorEnd.a, v.ColorStart.a)
				local size = math.Remap(v.Dead - CurTime(), 0, v.Time, v.EndSize, v.StartSize)
				v.pRotate = v.pRotate + v.Rotate

				surface.SetDrawColor(r, g, b, a)
				surface.DrawTexturedRectRotated(v.x, v.y, size, size, v.pRotate)
			end
		end

		draw.NoTexture()
		local mx, my = input.GetCursorPos()

		local obj = false
		for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects) do
			local t = SpaceEvo.Objects[v.Name]
			local x, y = v.Pos.x, v.Pos.y
			local pos = SpaceEvo.WorldPos + Vector(x*10, y*10)
			local p = (v.Pos):ToScreen()

			if not activePixel then t.Paint(v, p.x, p.y) continue end
			local vec = w_mesh[activePixel]
			local cc = (vec+Vector(5,5)):ToScreen()
			t.Paint(v, p.x, p.y, t.IsMouseOver(p.x, p.y, cc.x, cc.y))
			if t.IsMouseOver(p.x, p.y, cc.x, cc.y) then
				SpaceEvo:ShadowText(v.Name, "SpaceEvo_Pixel5", p.x, p.y-25, color_white, 1, TEXT_ALIGN_BOTTOM)
				obj = k
			end
		end
		Obj = obj

		local hum = false
		local smartestHuman = {iq = 0, name = "", col}
		for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans) do
			if v.DontDraw then continue end
			local x, y = v.Pos.x, v.Pos.y
			local pos = SpaceEvo.WorldPos + Vector(x*10, y*10)
			local p = (pos+Vector(5,5)):ToScreen()


			if not v.NextWaterCheck or v.NextWaterCheck < CurTime() or v.NextWaterCheck - CurTime() >= 100 then
				local vec, i = Closest(pos+Vector(5,5), w_mesh)
				v.InWater = SpaceEvo.GeneratedWorld.WorldMesh[i].Type == "Water"
				v.NextWaterCheck = CurTime() + 1 + (k/(#SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans*2))
			end
			if not v.InWater then
				surface.SetDrawColor(v.Model.Body)
				surface.SetMaterial(body)
				surface.DrawTexturedRectRotated(p.x, p.y, 25, 25, 0)

				surface.SetDrawColor(v.Model.Shirt)
				surface.SetMaterial(shirt)
				surface.DrawTexturedRectRotated(p.x, p.y, 25, 25, 0)

				surface.SetDrawColor(255,255,255)
				surface.SetMaterial(shoes)
				surface.DrawTexturedRectRotated(p.x, p.y, 25, 25, 0)

				surface.SetDrawColor(v.Model.Pants)
				surface.SetMaterial(pants)
				surface.DrawTexturedRectRotated(p.x, p.y, 25, 25, 0)
			else
				local velX, velY = SpaceEvo.Humans:GetVelocity(v)
				local w = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Water
				SpaceEvo.Particle({
					x = p.x,
					y = p.y+10,
					Spread = .1,
					Dir = {x = velX, y = velY},//
					Mat = nil,
					Time = .25,
					StartSize = 5,
					EndSize = 3,
					ColorStart = Color(w.r, w.g, w.b,100),
					ColorEnd = Color(200,200,200,0),
					Rotate = math.Rand(-.1, .1),
					Amount = 1
				})

				surface.SetDrawColor(v.Model.Body)
				surface.SetMaterial(body)
				surface.DrawTexturedRectRotated(p.x, p.y+10, 25, 25, 0)

				surface.SetDrawColor(v.Model.Shirt)
				surface.SetMaterial(shirt)
				surface.DrawTexturedRectRotated(p.x, p.y+10, 25, 25, 0)
			end

			if v.Sex == "Female" then
				surface.SetDrawColor(v.Model.Hairs)
				surface.SetMaterial(hairs)
				surface.DrawTexturedRectRotated(p.x, p.y+(v.InWater and 10 or 0), 25, 25, 0)
			end

			if math.Distance(p.x, p.y, c.x, c.y) <= 25 then
				hum = v

				local x, y = SpaceEvo:ShadowText(v.FirstName.." "..v.LastName, "SpaceEvo_Pixel5", p.x, p.y-25, color_white, 1, TEXT_ALIGN_BOTTOM)
				SpaceEvo:ShadowText(v.Task or "Watching the birds", "SpaceEvo_Pixel5", p.x, p.y-25+y, color_white, 1, TEXT_ALIGN_BOTTOM)
			end

			if v.IQ > smartestHuman.iq then
				smartestHuman.iq = v.IQ
				smartestHuman.name = v.FirstName.." "..v.LastName
				smartestHuman.col = v.Model.Shirt
			end

			if not v.Target or not GetConVar("developer"):GetBool() then continue end
			surface.SetDrawColor(255,0,0)
			surface.DrawLine( p.x, p.y, v.Target.x, v.Target.y )
		end
		Human = hum

		local vec, i = Closest(c.pos, w_mesh)
		if vec:DistToSqr(c.pos) >= 5000 or hum then
			activePixel = nil
			SpaceEvo.CursorPos = c
			SpaceEvo.Circle( c.x, c.y, 5, 30, color_white )
		else
			activePixel = i
			local cc = (vec+Vector(5,5)):ToScreen()
			SpaceEvo.CursorPos = cc
			SpaceEvo.Circle( cc.x, cc.y, 3, 30, color_white )

			if !obj then
				local x, y = SpaceEvo:ShadowText(SpaceEvo.GeneratedWorld.WorldMesh[i].Type, "SpaceEvo_Pixel5", cc.x, cc.y-25, color_white, 1, TEXT_ALIGN_BOTTOM)
				SpaceEvo:ShadowText("Height: "..math.Round(SpaceEvo.GeneratedWorld.WorldMesh[i].Height, 1), "SpaceEvo_Pixel5", cc.x, cc.y-25+y, color_white, 1, TEXT_ALIGN_BOTTOM)
				hook.Run("SpaceEvo_BlockPaint", i, SpaceEvo.GeneratedWorld.WorldMesh[i], cc.x, cc.y-25, y*2)
			end
		end

		if HumanSelected then
			local h = HumanSelected
			local x, y = h.Pos.x, h.Pos.y
			local pos = SpaceEvo.WorldPos + Vector(x*10, y*10)
			local p = (pos+Vector(5,5)):ToScreen()

			surface.SetDrawColor(0,255,0)

			local cc = (vec+Vector(5,5)):ToScreen()
			local to = vec:DistToSqr(c.pos) >= 5000 and c or cc
			surface.DrawLine( p.x, p.y, to.x, to.y )
		end


		local x, y = SpaceEvo:ShadowText("Planet: "..SpaceEvo.Planets[SpaceEvo.CurrentWorld].Name, "SpaceEvo_Pixel10", 15, 5, color_white)

		local x, y2 = SpaceEvo:ShadowText("Humans: "..#SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans, "SpaceEvo_Pixel7", 15, 10+y, color_white)
		SpaceEvo:ShadowText("Objects: "..#SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects, "SpaceEvo_Pixel7", 15, 10+y+y2, color_white)
		local x = SpaceEvo:ShadowText("Smartest: ", "SpaceEvo_Pixel7", 15, 10+y+y2*2, color_white)
		local x1 = SpaceEvo:ShadowText(smartestHuman.name, "SpaceEvo_Pixel7", 15+x, 10+y+y2*2, smartestHuman.col)
		SpaceEvo:ShadowText("(IQ: "..smartestHuman.iq..")", "SpaceEvo_Pixel7", 15+x+x1, 10+y+y2*2, color_white)

		local x, y = SpaceEvo:ShadowText("Resources: ", "SpaceEvo_Pixel10", w-15, 5, color_white, TEXT_ALIGN_RIGHT)

		local x, y2 = SpaceEvo:ShadowText("Iron: "..SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Iron, "SpaceEvo_Pixel7", w-15, 10+y, color_white, TEXT_ALIGN_RIGHT)
		SpaceEvo:ShadowText("Oil: "..SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Oil, "SpaceEvo_Pixel7", w-15, 10+y+y2, color_white, TEXT_ALIGN_RIGHT)
		SpaceEvo:ShadowText("Food: "..SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Food, "SpaceEvo_Pixel7", w-15, 10+y+y2*2, color_white, TEXT_ALIGN_RIGHT)
		SpaceEvo:ShadowText("Wood: "..SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Wood, "SpaceEvo_Pixel7", w-15, 10+y+y2*3, color_white, TEXT_ALIGN_RIGHT)

		hook.Run("SpaceEvo_PostFramePaint", s, w, h, 10+y+y2*4, 10+y+y2*3)
	end
	frm.OnMousePressed = function(s, c)
		if c == MOUSE_RIGHT then
			HumanSelected = nil
			return
		end

		local Object = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects[Obj or -228]
		if Obj and Object and not HumanSelected then
			local Object = Object
			local t = SpaceEvo.Objects[Object.Name]
			if t.Click then t.Click(Object) end
		elseif Human then
			if not HumanSelected or HumanSelected != Human then
				surface.PlaySound("space_evolution/human_click1.wav")
				HumanSelected = Human
			end
		elseif HumanSelected and activePixel then
			surface.PlaySound("space_evolution/human_click2.wav")
			local t = HumanSelected
			local humID = Human
			local m = DermaMenu() 
			m:AddOption(t.FirstName.." "..t.LastName, function()
				local frm2 = SpaceEvo:Frame(frm)
				frm2:SetSize(ScrH()/2, ScrH()/4)
				frm2:MakePopup()
				frm2:Center()
				frm2:ShowCloseButton(true)
				frm2:SetTitle(t.FirstName.." "..t.LastName)

				local p = vgui.Create("DPanel", frm2)
				p:Dock(FILL)
				p.Paint = function(s, w, h)
					surface.SetDrawColor(t.Model.Body)
					surface.SetMaterial(body)
					surface.DrawTexturedRect(5, 5, h-10, h-10)

					surface.SetDrawColor(t.Model.Shirt)
					surface.SetMaterial(shirt)
					surface.DrawTexturedRect(5, 5, h-10, h-10)

					surface.SetDrawColor(255,255,255)
					surface.SetMaterial(shoes)
					surface.DrawTexturedRect(5, 5, h-10, h-10)

					surface.SetDrawColor(t.Model.Pants)
					surface.SetMaterial(pants)
					surface.DrawTexturedRect(5, 5, h-10, h-10)

					if t.Sex == "Female" then
						surface.SetDrawColor(t.Model.Hairs)
						surface.SetMaterial(hairs)
						surface.DrawTexturedRect(5, 5, h-10, h-10)
					end

					local x, y = SpaceEvo:ShadowText("Name: "..t.FirstName.." "..t.LastName, "SpaceEvo_Pixel7", w-15, 10, color_white, TEXT_ALIGN_RIGHT)
					SpaceEvo:ShadowText("Parrents"..(#t.Parrents == 0 and ": No" or ""), "SpaceEvo_Pixel7", w-15, 10+y, color_white, TEXT_ALIGN_RIGHT)
					local i = 2
					for k, v in pairs(t.Parrents) do
						local l = SpaceEvo.Humans:FindByID(v)
						SpaceEvo:ShadowText(k..": "..((l and l.FirstName.." "..l.LastName) or "???"), "SpaceEvo_Pixel7", w-25, 10+y*i, color_white, TEXT_ALIGN_RIGHT)
						i = i + 1
					end

					local l = SpaceEvo.Humans:FindByID(t.InLove)
					SpaceEvo:ShadowText("In love: "..(t.InLove != "No" and ((l and l.FirstName.." "..l.LastName) or "???") or "No"), "SpaceEvo_Pixel7", w-15, 10+y*(i), color_white, TEXT_ALIGN_RIGHT)
					SpaceEvo:ShadowText("IQ: "..t.IQ, "SpaceEvo_Pixel7", w-15, 10+y*(i+1), color_white, TEXT_ALIGN_RIGHT)
					SpaceEvo:ShadowText("Task: "..(t.Task or "Watching the birds"), "SpaceEvo_Pixel7", w-15, 10+y*(i+2), color_white, TEXT_ALIGN_RIGHT)
					SpaceEvo:ShadowText("HP: "..(t.HP or 5), "SpaceEvo_Pixel7", w-15, 10+y*(i+3), color_white, TEXT_ALIGN_RIGHT)
				end
			end):SetIcon("icon16/user.png")
			m:AddSpacer()

			hook.Run("SpaceEvo_OnHumanSelected", t)

			for k, v in ipairs(SpaceEvo.Humans.ExtraButtons) do
				v(m, t, humID) // m - menu, t - human
			end

			if #SpaceEvo.Humans.ExtraButtons > 0 then m:AddSpacer() end
			local aP = activePixel

			local subMenu, parentMenuOption = m:AddSubMenu("Build")
			parentMenuOption:SetIcon("icon16/wrench.png")

			for k, v in pairs(SpaceEvo.Items.Storage) do
				if v == 0 then continue end
				local build = subMenu:AddOption(k, function()
					t.Task = "Going to build "..k
					t.NextTask = "Building "..k
					t.Build = k
					t.StartedBuild = nil
					local p = w_mesh[aP]
					local f = p:ToScreen()
					t.Target = {
						x = f.x,
						y = f.y,
						ID = aP
					}
					SpaceEvo.Items.Storage[k] = SpaceEvo.Items.Storage[k] - 1
				end)
				build:SetIcon("icon16/arrow_right.png")
			end

			m:AddOption("Go here", function()
				t.Task = "Wanders"
				local p = w_mesh[aP]
				local f = p:ToScreen()
				t.Target = {
					x = f.x,
					y = f.y
				}
				t.NextTask = nil
			end):SetIcon("icon16/arrow_down.png")
			local Object = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects[Obj]
			if not Object then
				m:AddOption("Research here", function()
					t.Task = "Exploring"
					local p = w_mesh[aP]
					local f = p:ToScreen()
					t.Target = {
						x = f.x,
						y = f.y,
						ID = aP
					}
					t.NextTask = nil
				end):SetIcon("icon16/zoom.png")
			elseif SpaceEvo.Objects[Object.Name].Usable then
				if SpaceEvo.Objects[Object.Name].CanUse(Object, t) then
					local Object = Object
					local Obj = Obj
					m:AddOption("Use "..Object.Name, function()
						t.Task = "Going to use "..Object.Name
						t.NextTask = "Using "..Object.Name
						t.Use = Obj
						local p = w_mesh[aP]
						local f = p:ToScreen()
						t.Target = {
							x = f.x,
							y = f.y,
							ID = aP
						}
						t.TaskEnd = nil
					end):SetIcon("icon16/cog.png")
				end
			end
			m:AddOption("Close"):SetIcon("icon16/cancel.png")
			m:Open()
			HumanSelected = nil
		end
	end

	local nextObjectThink = CurTime()
	frm.Think = function()
		frm:MoveToBack()
		if SpaceEvo.GeneratedWorld.WorldName != lastWorld then
			w_mesh = {}
			for k, v in pairs(SpaceEvo.GeneratedWorld.WorldMesh or {}) do
				w_mesh[k] = v.Pos
			end
		end

		local mx, my = input.GetCursorPos()
		local cursor = position()
		if not cursor then return end
		c = cursor:ToScreen()
		c.pos = cursor

		if SpaceEvo.Removing then return end
		if CurTime() < nextObjectThink then return end
		for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects) do
			local t = SpaceEvo.Objects[v.Name]
			t.Think(v, k)
		end
		nextObjectThink = CurTime() + 1
	end

	local Remove = vgui.Create("DButton", frm)
	surface.SetFont("SpaceEvo_Pixel10")
	local fw, fh = surface.GetTextSize("Remove world")
	local w, h = fw+20, fh+20
	Remove:SetSize(w,h)
	Remove:SetPos(10, frm:GetTall()-h-10)
	Remove:SetText("")
	Remove:SetCursor("blank")
	Remove.Paint = function(s, w, h)
		local add = s:IsHovered() and 30 or 0
		draw.RoundedBox(0, 0, 0, w, h, Color(150-add,150-add,150-add))
		draw.RoundedBox(0, 3, 3, w-6, h-6, Color(100-add,100-add,100-add))

		SpaceEvo:ShadowText("Remove world", "SpaceEvo_Pixel8", w/2, h/2, color_white, 1, 1)
		local x, y = s:ScreenToLocal(input.GetCursorPos())
		SpaceEvo.Circle( x, y, 5, 30, color_white )
	end
	Remove.OnCursorEntered = function()
		surface.PlaySound("space_evolution/btn_over.wav")
	end
	Remove.DoClick = function()
		surface.PlaySound("space_evolution/btn_click.wav")
		local d = DermaMenu()
		local subMenu, parentMenuOption = d:AddSubMenu("Do you want to remove whole progress?")
		parentMenuOption:SetIcon("icon16/bomb.png")

		local yesOption = subMenu:AddOption("Yes", function()
			hook.Run("SpaceEvo_PreSaveRemove")

			SpaceEvo.Removing = true
			SpaceEvo.CamToZ = 0
			local files, dirs = file.Find("space_evolution/*", "DATA")
			for k, v in ipairs(files) do
				file.Delete("space_evolution/"..v)
			end
			for k, v in ipairs(dirs) do
				local files = file.Find("space_evolution/"..v.."/*", "DATA")
				for k, f in ipairs(files) do
					file.Delete("space_evolution/"..v.."/"..f)
				end
				file.Delete("space_evolution/"..v.."/")
				chat.AddText(Color(255,0,0), "Destroying "..v)
			end

			timer.Simple(3, function()
				SpaceEvo.Removing = false
				SpaceEvo.CamToZ = -11500

				for k, v in pairs(SpaceEvo.Planets) do
					if istable(v) then SpaceEvo.Planets[k] = nil end
				end
				SpaceEvo.Planets.earth = {
					Name = "Earth",
					Hills = Color(0,255,0),
					Water = Color(0,0,150),
					Sand = Color(255,255,0),

					WaterAmount = 0,
					Humans = {},
					Objects = {},

					Resources = {
						Iron = 0,
						Oil = 0,
						Wood = 100,
						Food = 0
					}
				}

				SpaceEvo.Items.Storage = {}

				if not file.Exists("space_evolution/items.dat", "DATA") then
					local t = {}
					for k, v in ipairs(SpaceEvo.Items.List) do
						t[v.Name] = 0
					end
					file.Write("space_evolution/items.dat", util.TableToJSON(t))
					SpaceEvo.Items.Storage = t
				else
					local items = file.Read("space_evolution/items.dat", "DATA")
					SpaceEvo.Items.Storage = util.JSONToTable(items)
				end

			    chat.AddText(Color(255,0,0), "Generating new planet")

				SpaceEvo:GenerateWorld("earth")

    			file.Write("space_evolution/active_planet.dat", "earth")
			    if SpaceEvo.CurrentWorld == "earth" and #SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans < 2 then
			        SpaceEvo.Humans:Create(table.Random(SpaceEvo.Humans.FirstName["Male"]), table.Random(SpaceEvo.Humans.LastName), "Male", SpaceEvo.CurrentWorld)
			        SpaceEvo.Humans:Create(table.Random(SpaceEvo.Humans.FirstName["Female"]), table.Random(SpaceEvo.Humans.LastName), "Female", SpaceEvo.CurrentWorld)
			    end
			end)
			hook.Run("SpaceEvo_PostSaveRemove")
		end)
		yesOption:SetIcon("icon16/accept.png")

		local noOption = subMenu:AddOption("No", function() chat.AddText(color_white, "You decided to let them live") end)
		noOption:SetIcon("icon16/cross.png")
		d:Open()
	end

	local Save = vgui.Create("DButton", frm)
	surface.SetFont("SpaceEvo_Pixel10")
	local fw, fh = surface.GetTextSize("Save world")
	local w, h = fw+20, fh+20
	Save:SetSize(w,h)
	Save:SetPos(10, frm:GetTall()-h-10 - h - 10)
	Save:SetText("")
	Save:SetCursor("blank")
	Save.Paint = function(s, w, h)
		local add = s:IsHovered() and 30 or 0
		draw.RoundedBox(0, 0, 0, w, h, Color(150-add,150-add,150-add))
		draw.RoundedBox(0, 3, 3, w-6, h-6, Color(100-add,100-add,100-add))

		SpaceEvo:ShadowText("Save world", "SpaceEvo_Pixel8", w/2, h/2, color_white, 1, 1)
		local x, y = s:ScreenToLocal(input.GetCursorPos())
		SpaceEvo.Circle( x, y, 5, 30, color_white )
	end
	Save.OnCursorEntered = function()
		surface.PlaySound("space_evolution/btn_over.wav")
	end
	Save.DoClick = function()
		SpaceEvo:SaveGame()
		surface.PlaySound("space_evolution/success.wav")
	end


	local travel = vgui.Create("DButton", frm)
	surface.SetFont("SpaceEvo_Pixel10")
	local fw, fh = surface.GetTextSize("Travel menu")
	local w, h = fw+20, fh+20
	travel:SetSize(w,h)
	travel:SetPos(frm:GetWide()-w-10, frm:GetTall()-h-10)
	travel:SetText("")
	travel:SetCursor("blank")
	travel.Paint = function(s, w, h)
		local add = s:IsHovered() and 30 or 0
		draw.RoundedBox(0, 0, 0, w, h, Color(150-add,150-add,150-add))
		draw.RoundedBox(0, 3, 3, w-6, h-6, Color(100-add,100-add,100-add))

		SpaceEvo:ShadowText("Travel menu", "SpaceEvo_Pixel8", w/2, h/2, color_white, 1, 1)
		local x, y = s:ScreenToLocal(input.GetCursorPos())
		SpaceEvo.Circle( x, y, 5, 30, color_white )
	end
	travel.OnCursorEntered = function()
		surface.PlaySound("space_evolution/btn_over.wav")
	end
	travel.DoClick = function()
		surface.PlaySound("space_evolution/btn_click.wav")
		local frm2 = SpaceEvo:Frame(frm)
		frm2:SetSize(ScrH()/2, ScrH()/1.5)
		frm2:MakePopup()
		frm2:Center()
		frm2:ShowCloseButton(true)
		frm2:SetTitle("Planets")

		local pnls = {}

		local searc = vgui.Create("DTextEntry", frm2)
		searc:Dock(TOP)
		searc:SetSize(0,30)
		searc:SetFont("SpaceEvo_Pixel8")
		searc:SetPlaceholderText("Search...")
		searc:DockMargin(10, 0, 10, 10)
		searc.OnChange = function()
			for k, v in ipairs(pnls) do
				if v[2].Name:lower():find(searc:GetValue():lower()) then
					v[1]:SizeTo(v[1]:GetWide(), 75, 0)
					v[1]:DockMargin(10, 0, 10, 10)
				else
					v[1]:SizeTo(v[1]:GetWide(), 0, 0)
					v[1]:DockMargin(0, 0, 0, 0)
				end
			end
		end

		local scr = vgui.Create("DScrollPanel", frm2)
		scr:Dock(FILL)
		scr:SetCursor("blank")

		for planet, v in pairs(SpaceEvo.Planets) do
			if not istable(v) then continue end
			local p = vgui.Create("DButton", scr)
			table.insert(pnls, {p, v})
			p:Dock(TOP)
			p:SetSize(0, 75)
			p:SetText("")
			p:SetCursor("blank")
			p:DockMargin(10, 0, 10, 10)
			p.OnCursorEntered = function()
				surface.PlaySound("space_evolution/btn_over.wav")
			end
			p.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, s:IsHovered() and Color(125,125,125) or Color(150,150,150))

				local x, y = SpaceEvo:ShadowText("Name: "..v.Name, "SpaceEvo_Pixel9", 6, 3, color_white)
				local x, y1 = SpaceEvo:ShadowText("Humans: "..#v.Humans, "SpaceEvo_Pixel8", 6, 3+y, color_white)

				local x, y = s:ScreenToLocal(input.GetCursorPos())
				SpaceEvo.Circle( x, y, 5, 30, color_white )
			end
			p.DoClick = function()
				surface.PlaySound("space_evolution/btn_click.wav")
				local d = DermaMenu()
				local subMenu, parentMenuOption = d:AddSubMenu("Send 2 humans to that planet")
				parentMenuOption:SetIcon("icon16/world.png")

				local yesOption = subMenu:AddOption("Yes", function()
					local h1, h2
					for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans) do
						if v.Task:find("Rocket") then continue end
						local p = SpaceEvo.Humans:FindLove(v)
						if p then
							h1, h2 = v, p
							break
						end
					end

					if not h1 or not h2 then
						chat.AddText(Color(255,50,50), "Sadly there's no people who want fly together")
						return
					end


					local hums = {h1, h2}
					local rocketFound = false
					for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects) do
						if v.Name == "Rocket" then
							if not v.Travel or #v.Travel == 0 then
								v.Travel = {h1.uniqueID, h2.uniqueID}
								v.FlyTo = planet
								
								local f = v.Pos:ToScreen()
								for _, t in ipairs(hums) do
									t.Task = "Going to use "..v.Name
									t.NextTask = "Using "..v.Name
									t.Use = k
									t.Target = {
										x = f.x,
										y = f.y,
									}
									t.TaskEnd = nil
								end

								rocketFound = v
								break
							end
						end
					end

					if not rocketFound then chat.AddText(Color(255,0,0), "There's no available rocket for travelling!") return end
					chat.AddText(h1.Model.Shirt, h1.FirstName.." "..h1.LastName, color_white, " and ", h2.Model.Shirt, h2.FirstName.." "..h2.LastName, color_white, " are going to visit ", v.Hills, v.Name, Color(249, 135, 255), "!")
				end)
				yesOption:SetIcon("icon16/accept.png")

				local noOption = subMenu:AddOption("No")
				noOption:SetIcon("icon16/cross.png")

				local subMenu, parentMenuOption = d:AddSubMenu("Visit that planet")
				local yesOption = subMenu:AddOption("Yes", function()
					SpaceEvo:SaveGame()
					frm2:Close()
					SpaceEvo.CamToZ = 0
					file.Write("space_evolution/active_planet.dat", planet)
					timer.Simple(3, function()
						SpaceEvo:GenerateWorld(planet)
						SpaceEvo.CamToZ = -11500
					end)
				end)
				yesOption:SetIcon("icon16/accept.png")

				local noOption = subMenu:AddOption("No")
				noOption:SetIcon("icon16/cross.png")
				parentMenuOption:SetIcon("icon16/world.png")
				d:Open()
			end
		end
	end

	local craft = vgui.Create("DButton", frm)
	surface.SetFont("SpaceEvo_Pixel10")
	local fw, fh = surface.GetTextSize("Craft menu")
	local w, h = fw+20, fh+20
	craft:SetSize(w,h)
	craft:SetPos(frm:GetWide()-w-10, frm:GetTall()-h-10-h - 10)
	craft:SetText("")
	craft:SetCursor("blank")
	craft.Paint = function(s, w, h)
		local add = s:IsHovered() and 30 or 0
		draw.RoundedBox(0, 0, 0, w, h, Color(150-add,150-add,150-add))
		draw.RoundedBox(0, 3, 3, w-6, h-6, Color(100-add,100-add,100-add))

		SpaceEvo:ShadowText("Craft menu", "SpaceEvo_Pixel8", w/2, h/2, color_white, 1, 1)
		local x, y = s:ScreenToLocal(input.GetCursorPos())
		SpaceEvo.Circle( x, y, 5, 30, color_white )
	end
	craft.OnCursorEntered = function()
		surface.PlaySound("space_evolution/btn_over.wav")
	end
	craft.DoClick = function()
		surface.PlaySound("space_evolution/btn_click.wav")
		local frm2 = SpaceEvo:Frame(frm)
		frm2:SetSize(ScrH()/2, ScrH()/1.5)
		frm2:MakePopup()
		frm2:Center()
		frm2:ShowCloseButton(true)
		frm2:SetTitle("Craft menu")
		local scr = vgui.Create("DScrollPanel", frm2)
		scr:Dock(FILL)
		scr:SetCursor("blank")

		for k, v in ipairs(SpaceEvo.Items.List) do
			local p = vgui.Create("DButton", scr)
			p:Dock(TOP)
			p:SetSize(0, 75)
			p:SetText("")
			p:SetCursor("blank")
			p:DockMargin(10, 0, 10, 10)
			p.OnCursorEntered = function()
				surface.PlaySound("space_evolution/btn_over.wav")
			end
			p.Paint = function(s, w, h)
				draw.RoundedBox(0, 0, 0, w, h, s:IsHovered() and Color(125,125,125) or Color(150,150,150))

				surface.SetMaterial(v.Img)
				surface.SetDrawColor(255,255,255)
				surface.DrawTexturedRect(3, 3, 35, 35)

				local x, y = SpaceEvo:ShadowText(v.Name, "SpaceEvo_Pixel7", 40, 0, color_white)
				local x = SpaceEvo:ShadowText(v.Desc, "SpaceEvo_Pixel5", 40, y, color_white)
				SpaceEvo:ShadowText("You need:", "SpaceEvo_Pixel5", 10, 40, color_white)

				if not SpaceEvo.Items.Storage[v.Name] then SpaceEvo.Items.Storage[v.Name] = 0 end
				SpaceEvo:ShadowText("You have: "..(SpaceEvo.Items.Storage[v.Name] or 0), "SpaceEvo_Pixel4", w-2, h-2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
				local x = 10
				for k, v in pairs(v.Need) do
					if v == 0 then continue end
					local x1 = SpaceEvo:ShadowText(k..": "..v.."     ", "SpaceEvo_Pixel5", x, 55, color_white)
					x = x + x1
				end

				local x, y = s:ScreenToLocal(input.GetCursorPos())
				SpaceEvo.Circle( x, y, 5, 30, color_white )
			end
			p.DoClick = function()
				surface.PlaySound("space_evolution/btn_click.wav")
				for k, v in pairs(v.Need) do
					if SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources[k] < v then
						chat.AddText(Color(255,100,100), "You can't afford it!")
						return
					end
				end

				if not file.Exists("space_evolution/items.dat", "DATA") then
					file.Write("space_evolution/items.dat", util.TableToJSON({
						[v.Name] = 1
					}))
				else
					SpaceEvo.Items.Storage[v.Name] = (SpaceEvo.Items.Storage[v.Name] or 0) + 1
				end

				// I'm really lazy to do it more "pretty"
				for k, v in pairs(v.Need) do
					SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources[k] = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources[k] - v
				end
				hook.Run("SpaceEvo_OnItemCrafted", v)

				chat.AddText(Color(100,255,100), "You crafted "..v.Name.."!")
			end
		end
	end
	hook.Run("SpaceEvo_OnMainFrameCreated", SpaceEvo.MainFrame)
end
CreateFrame()
hook.Add("Initialize", "SpaceEvo.MainFrameCreate", CreateFrame)