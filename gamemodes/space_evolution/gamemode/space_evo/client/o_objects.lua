local rig = Material("space_evolution/oil.png")
local felling = Material("space_evolution/felling.png")
local warehouse = Material("space_evolution/warehouse.png")
local warehouse2 = Material("space_evolution/warehouse_water.png")
local mine = Material("space_evolution/mine.png")
local house = Material("space_evolution/house.png")
local rocket = Material("space_evolution/rocket.png")
local telescope = Material("space_evolution/telescope.png")

SpaceEvo.Objects = {
	["Oil rig"] = {
		Name = "Oil rig",
		Paint = function(self, x, y)
			surface.SetMaterial(rig)
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRectRotated(x, y, 35, 35, 0)
		end,
		IsMouseOver = function(x, y, mx, my)
			return math.Distance(mx, my, x, y) <= 20
		end,
		Think = function(self)
			self.NextThink = self.NextThink or CurTime()

			if self.NextThink <= CurTime() then
				SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Oil = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Oil + 1
				self.NextThink = CurTime() + 15
			end
		end,

		Usable = false,
		BuildValue = .01,
		BuildMaxValue = 60,
		NeededIQ = 0,
	},
	["Mine"] = {
		Name = "Mine",
		Paint = function(self, x, y)
			surface.SetMaterial(mine)
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRectRotated(x, y, 35, 35, 0)
		end,
		IsMouseOver = function(x, y, mx, my)
			return math.Distance(mx, my, x, y) <= 20
		end,
		Think = function(self)
			self.NextThink = self.NextThink or CurTime()

			if self.NextThink <= CurTime() then
				SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Iron = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Iron + 1
				self.NextThink = CurTime() + math.random(20,25)
			end
		end,

		Usable = false,
		BuildValue = .03,
		BuildMaxValue = 60,
		NeededIQ = 0,
	},
	["Felling"] = {
		Name = "Felling",
		Paint = function(self, x, y)
			surface.SetMaterial(felling)
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRectRotated(x, y, 35, 35, 0)
		end,
		IsMouseOver = function(x, y, mx, my)
			return math.Distance(mx, my, x, y) <= 20
		end,
		Think = function(self)
			self.NextThink = self.NextThink or CurTime()

			if self.NextThink <= CurTime() then
				SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Wood = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Wood + 1
				self.NextThink = CurTime() + math.random(20,25)
			end
		end,

		Usable = false,
		BuildValue = .03,
		BuildMaxValue = 60,
		NeededIQ = 0,
	},
	["Food warehouse"] = {
		Name = "Food warehouse",
		Paint = function(self, x, y)
			if not self.InWater then
				surface.SetMaterial(warehouse)
			else
				surface.SetMaterial(warehouse2)
			end
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRectRotated(x, y, 35, 35, 0)
		end,
		IsMouseOver = function(x, y, mx, my)
			return math.Distance(mx, my, x, y) <= 20
		end,
		Think = function(self)
			self.NextThink = self.NextThink or CurTime()

			if self.NextThink <= CurTime() then
				SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Food = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Food + 1
				self.NextThink = CurTime() + math.random(10,30)
			end
		end,

		Usable = false,
		BuildValue = .05,
		BuildMaxValue = 100,
		NeededIQ = 0,
	},
	["House"] = {
		Name = "House",
		Paint = function(self, x, y, mouseOver)
			surface.SetMaterial(house)
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRectRotated(x, y, 35, 35, 0)

			if self.Humans and mouseOver then
				SpaceEvo:ShadowText("Humans inside: "..#self.Humans, "SpaceEvo_Pixel5", x, y-55, color_white, 1)
			end
		end,
		IsMouseOver = function(x, y, mx, my)
			return math.Distance(mx, my, x, y) <= 20
		end,
		Click = function(self)
			local m = DermaMenu() 

			for k, v in ipairs(self.Humans) do
				local human = SpaceEvo.Humans:FindByID(v)
				if not human then table.RemoveByValue(self.Humans, v) continue end
				m:AddOption(human.FirstName.." "..human.LastName, function()
					human.Task = nil
					human.NextTask = nil
					human.Use = nil
					human.Target = nil
					human.DontDraw = nil
					table.RemoveByValue(self.Humans, v)
				end):SetIcon("icon16/user.png")
			end

			m:Open()
		end,
		Think = function(self)
			self.NextThink = self.NextThink or CurTime()
			self.Humans = self.Humans or {}

			if self.NextThink > CurTime() and self.NextThink - CurTime() >= 20 then self.NextThink = CurTime() end

			if self.NextThink <= CurTime() then
				if #self.Humans == 2 then
					local brk = false
					local lastname = ""
					for k, v in ipairs(self.Humans) do
						local human = SpaceEvo.Humans:FindByID(v)
						if not human then
							brk = true
							continue
						end
						if brk then human.DontDraw = nil continue end
						if human.Sex == "Male" then
							lastname = human.LastName
						end
					end
					if not brk then
						if lastname != "" then
							local female = SpaceEvo.Humans:FindByID(self.Humans[1]).Sex == "Female" and SpaceEvo.Humans:FindByID(self.Humans[1]) or SpaceEvo.Humans:FindByID(self.Humans[2])
							local male = SpaceEvo.Humans:FindByID(self.Humans[1]).Sex == "Male" and SpaceEvo.Humans:FindByID(self.Humans[1]) or SpaceEvo.Humans:FindByID(self.Humans[2])
							female.InLove = male.uniqueID
							male.InLove = female.uniqueID

							local sex = table.Random({"Male", "Female"})
							local name = table.Random(SpaceEvo.Humans.FirstName[sex])

							local baby = SpaceEvo.Humans:Create(name, table.Random(SpaceEvo.Humans.LastName), sex, SpaceEvo.CurrentWorld, table.Copy(female.Pos), {
								Dad = male.uniqueID,
								Mom = female.uniqueID,
							})

							male.DontDraw = nil
							female.DontDraw = nil

							male.Task = nil
							female.Task = nil
							male.NextTask = nil
							female.NextTask = nil
							male.Use = nil
							female.Use = nil
							male.Target = nil
							female.Target = nil

							hook.Run("SpaceEvo_OnNewHumanBirth", male, female, baby, SpaceEvo.CurrentWorld)
							chat.AddText(male.Model.Shirt, male.FirstName.." "..male.LastName, color_white, " and ", female.Model.Shirt, female.FirstName.." "..female.LastName, color_white," now have a beautiful ", (sex == "Male" and Color(0,0,255) or Color(255,0,255)), (sex == "Male" and "son" or "daughter"), color_white, "!")
						end
					end
					self.Humans = {}
					self.NextThink = CurTime() + 10
				else
					if #self.Humans == 1 then
						local human = SpaceEvo.Humans:FindByID(self.Humans[1])
						if not human then table.RemoveByValue(self.Humans, v) return end
						human.Task = nil
						human.NextTask = nil
						human.Use = nil
						human.Target = nil
						human.DontDraw = nil

						self.Humans = {}
					end
					self.NextThink = CurTime() + 10
				end
			end
		end,
		CanUse = function(self, newHuman)
			if #self.Humans < 2 then
				local human = self.Humans[1] and SpaceEvo.Humans:FindByID(self.Humans[1])
				return not self.Humans[1] or not human or SpaceEvo.Humans:CanBeInLove(human, newHuman)
			else
				return false
			end
		end,

		Usable = true,
		BuildValue = .05,
		BuildMaxValue = 100,
		NeededIQ = 0,
	},
	["Rocket"] = {
		Name = "Rocket",
		Paint = function(self, x, y)
			surface.SetMaterial(rocket)
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRectRotated(x, y, 55, 55, 0)
		end,
		IsMouseOver = function(x, y, mx, my)
			return math.Distance(mx, my, x, y) <= 20
		end,
		Think = function(self, i)
			for k, v in pairs(self.Travel or {}) do
				local h = SpaceEvo.Humans:FindByID(v)
				if not h or not h.Task then table.remove(self.Travel, k) continue end
				if not h.Task:find(self.Name) or not h.NextTask:find(self.Name) then
					h.Use = i
					h.Task = "Going to use "..self.Name
					h.NextTask = "Using "..self.Name
					local f = self.Pos:ToScreen()
					h.Target = {
						x = f.x,
						y = f.y,
					}
				end
			end
		end,

		Usable = false,
		BuildValue = .05,
		BuildMaxValue = 150,
		NeededIQ = 0,
	},
	["Telescope"] = {
		Name = "Telescope",
		Paint = function(self, x, y)
			surface.SetMaterial(telescope)
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRectRotated(x, y, 35, 35, 0)
		end,
		IsMouseOver = function(x, y, mx, my)
			return math.Distance(mx, my, x, y) <= 20
		end,
		Think = function(self)
		end,
		CanUse = function(self, human)
			return true
		end,

		Usable = true,
		BuildValue = .05,
		BuildMaxValue = 30,
		NeededIQ = 0,
	},
}

function SpaceEvo.Objects:AddNew(index, tbl)
	if SpaceEvo.Objects[index] then ErrorNoHalt(index.." already exists in objects' table!:") PrintTable(SpaceEvo.Objects[index]) print() return end

	SpaceEvo.Found[index] = index
	SpaceEvo.Objects[index] = tbl

	SpaceEvo:PrintConsole("Adding "..index.." to objects list")
end