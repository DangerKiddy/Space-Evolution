SpaceEvo.Humans = SpaceEvo.Humans or {}
SpaceEvo.Humans.MaxIQ = 200
local hook = hook

function SpaceEvo.Humans:Print(msg)
	MsgC(Color(249, 135, 255), "[Humans] ", color_white, msg.."\n")
end

SpaceEvo.Humans.FirstName = {
	Male = {
		"Elon", "David", "John", "Jack", "Samuel", "Sean", "Thomas", "William", "Robert", "Ronald", "Ralph", "Philip", "Oliver", "Nathan", "Kevin", "Logan", "Jesus", "George", "Adam", "Jamie"
	},
	Female = {
		"Ada", "Alise", "Ava", "Barbara", "Caroline", "Chloe", "Daisy", "Fiona", "Gabriella", "Jane", "Joyce", "Isabella", "Lily", "Nicole", "Taylor", "Violet", "Savage", "Hyneman"
	}
}
SpaceEvo.Humans.LastName = {
	"Adamson", "Adrian", "Arnold", "Brown", "Brooks", "Cook", "Day", "Derrick", "Dowman", "Musk", "James", "Jones", "Porter", "Saunder", "Young", "Webster"
}

SpaceEvo.Humans.ExtraButtons = SpaceEvo.Humans.ExtraButtons or {}
function SpaceEvo.Humans:AddMenuButton(funcAdd)
	table.insert(SpaceEvo.Humans.ExtraButtons, funcAdd)
end
function SpaceEvo.Humans:AddFirstName(sex, name)
	table.insert(SpaceEvo.Humans.FirstName[sex], name)
end
function SpaceEvo.Humans:AddLastName(sex, lastname)
	table.insert(SpaceEvo.Humans.LastName, lastname)
end
function SpaceEvo.Humans:Kill(humanID, isUniqueID, reason, planet)
	local plan = planet or SpaceEvo.CurrentWorld
	local hum
	if isUniqueID then
		hum, humanID = SpaceEvo.Humans:FindByID(humanID)
	else
		hum = SpaceEvo.Planets[planet].Humans[humanID]
	end
	if hum.Goku then return end
	if reason then
		chat.AddText(hum.Model.Shirt, hum.FirstName.." "..hum.LastName, unpack(reason))
	end
	surface.PlaySound("space_evolution/death.wav")

	hook.Run("SpaceEvo_OnHumanKilled", hum, plan)
	table.remove(SpaceEvo.Planets[plan].Humans, humanID)
end

function SpaceEvo.Humans:Create(n1, n2, sex, planet, pos, parrents)
	if SpaceEvo.Removing then return end
	hook.Run("SpaceEvo_PreHumanCreate", n1, n2, sex, planet, pos, parrents)

	local t = SpaceEvo.Planets[planet].Humans

	local iq = math.random(70,90)
	local uniqueID = math.random(1,9999999)
	for k, v in ipairs(t) do
		if v.uniqueID == uniqueID then
			SpaceEvo.Humans:Create(n1, n2, sex, planet, pos)
			return
		end
	end
	local id = table.insert(t, {
		FirstName = n1,
		LastName = n2,
		Sex = sex,
		Job = "None",
		InLove = "No",
		uniqueID = uniqueID,
		IQ = iq,
		Pos = pos or {x = 0, y = 0},
		Parrents = parrents or {},

		Model = {
			Body = table.Random({Color(174,140,100), Color(140,109,76), Color(91, 67, 44)}),
			Shirt = HSVToColor(math.random(360), math.Rand(.5, 1), 1),
			Pants = HSVToColor(math.random(360), math.Rand(.5, 1), 1),
			Hairs = HSVToColor(math.random(360), 1, math.Rand(0, .5)),
		}
	})

	print("\n ")
	SpaceEvo.Humans:Print("Creating new human...\n- Name: "..n1.." "..n2.."\n- Sex: "..sex.."\n- Planet: "..planet.."\nIQ: "..iq)

	hook.Run("SpaceEvo_PostHumanCreate", SpaceEvo.Planets[planet].Humans[id])

	return SpaceEvo.Planets[planet].Humans[id]
end

function SpaceEvo.Humans:CanBeInLove(hum1, hum2)
	return !hum1.Goku and !hum2.Goku and
		hum1 != hum2 and hum1.Sex != hum2.Sex and (
			!table.HasValue(hum1.Parrents, hum2.uniqueID) and !table.HasValue(hum2.Parrents, hum1.uniqueID) and
				(not hum1.Love and not hum2.Love or hum1.Love == hum2 or hum2.Love == hum1 or (hum1.Love and not hum2.Love) or (hum2.Love and not hum1.Love)))
end
function SpaceEvo.Humans:IsValid(uniqueID)
	for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans) do
		if v.uniqueID == uniqueID then
			return true
		end
	end
	return false
end
function SpaceEvo.Humans:FindLove(hum1)
	local partner
	for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans) do
		if SpaceEvo.Humans:CanBeInLove(hum1, v) then
			partner = v
			break
		end
	end

	return partner
end
function SpaceEvo.Humans:FindInRadius(pos, rad)
	local humans = {}
	for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans) do
		if Vector(pos.x, pos.y):DistToSqr(Vector(v.Pos.x, v.Pos.y)) > rad then continue end

		humans[#humans+1] = v
	end
	return humans
end
function SpaceEvo.Humans:GetPos(human)
	return SpaceEvo.WorldPos + Vector(human.Pos.x*10, human.Pos.y*10)
end
function SpaceEvo.Humans:GetScreenPos(human)
	local x, y = human.Pos.x, human.Pos.y
	local pos = SpaceEvo.WorldPos + Vector(x*10, y*10)
	return (pos+Vector(5,5)):ToScreen()
end
function SpaceEvo.Humans:GetVelocity(human)
	human.OldPosX = human.OldPosX or human.Pos.x
	human.OldPosY = human.OldPosY or human.Pos.y
	return human.OldPosX - human.Pos.x, human.OldPosY - human.Pos.y
end
function SpaceEvo.Humans:FindByID(id, planet)
	for k, v in ipairs(SpaceEvo.Planets[planet or SpaceEvo.CurrentWorld].Humans) do
		if v.uniqueID == id then
			return v, k
		end
	end
end

SpaceEvo.Found = {
	["Oil"] = "Oil rig",
	["Iron"] = "Mine",
	["Forest"] = "Felling",
	["Food"] = "Food warehouse",
}

function SpaceEvo.Humans:Think()
	if SpaceEvo.Removing then return end
	if not SpaceEvo.Planets then return end
	local d = (math.Round((SpaceEvo.CamPos or Vector()):Distance(Vector(0,0,-11500))))
	if (d) > 0 then return end
	for k, v in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans) do
		local override = hook.Run("SpaceEvo_HumanThink", k, v, SpaceEvo.CurrentWorld)
		if override then continue end

		if v.IQ >= 80 and not v.Task then
			// something like weighted random
			local t = {"Exploring","Exploring", "Exploring", "Exploring", "Exploring", "Exploring", "Exploring", "Exploring", "Exploring", "Wanders", "Wanders", "Searching for love"}
			v.Task = table.Random(t)
		elseif not v.Task and v.IQ < 80 then
			v.Task = table.Random({"Wanders", "Wanders", "Wanders", "Wanders", "Wanders", "Wanders", "Wanders", "Wanders", "Wanders", "Wanders", "Wanders", "Searching for love"})
		end

		v.NextEat = v.NextEat or CurTime() + math.random(10,30)
		if v.NextEat > CurTime() and (v.NextEat - CurTime()) > 60 then v.NextEat = CurTime() + math.random(10,30) end

		if v.NextEat <= CurTime() then
			local take = math.random(1,2)
			if SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Food < take then
				if SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Food <= 0 then
					v.HP = v.HP and v.HP - 1 or 29
				end
			else
				SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Food = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Resources.Food - take
				v.HP = math.Clamp(v.HP and v.HP + 1 or 30, 0, 30)
			end
			v.NextEat = CurTime() + math.random(25,30)
		end

		if (v.HP or 30) <= 0 and not v.Goku then
			chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " just ", Color(255,0,0), "died", color_white, " of hunger!")
			surface.PlaySound("space_evolution/death.wav")
			table.remove(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans, k)
			continue
		end

		if v.Task then
			if v.Task == "Wanders" then
				if not v.Target then
					local rTarget = table.Random(SpaceEvo.GeneratedWorld.WorldMesh)
					local t = rTarget.Pos:ToScreen()
					v.Target = {
						x = t.x,
						y = t.y
					}
					local p = SpaceEvo.Humans:GetScreenPos(v)
					if math.floor(math.Distance(p.x, p.y, v.Target.x, v.Target.y)) >= 100 then v.Target = nil end
				else
					local p = SpaceEvo.Humans:GetScreenPos(v)
					local sx, sy = math.Clamp((v.Target.x-p.x)/1000, -FrameTime()*2, FrameTime()*2), math.Clamp((p.y-v.Target.y)/1000, -FrameTime()*2, FrameTime()*2)
					v.OldPosX = v.Pos.x
					v.OldPosY = v.Pos.y
					v.Pos.x = v.Pos.x + sy
					v.Pos.y = v.Pos.y - sx

					if math.floor(math.Distance(p.x, p.y, v.Target.x, v.Target.y)) == 0 then
						v.Target = nil
						v.Task = v.NextTask
					end
				end
			elseif v.Task == "Exploring" then
				if not v.Target then
					local rTarget, i = table.Random(SpaceEvo.GeneratedWorld.WorldMesh)
					local t = rTarget.Pos:ToScreen()
					v.Target = {
						x = t.x,
						y = t.y,
						ID = i
					}
					local p = SpaceEvo.Humans:GetScreenPos(v)
					if math.floor(math.Distance(p.x, p.y, v.Target.x, v.Target.y)) <= 400 then v.Target = nil continue end

					if not v.shouldFind then v.shouldFind = math.random(300-v.IQ)<=25 and CurTime() end
					if v.shouldFind then
						local no = hook.Run("SpaceEvo_HumanSearchingResource", v, SpaceEvo.GeneratedWorld.WorldResourcesMesh[v.Target.ID])
						if SpaceEvo.GeneratedWorld.WorldResourcesMesh[v.Target.ID].Type == "Nothing" or no then
							v.Target = nil
							continue
						else
							chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " is sure that will find something useful")
							v.shouldFind = nil
						end
					end
				else
					local p = SpaceEvo.Humans:GetScreenPos(v)
					local sx, sy = math.Clamp((v.Target.x-p.x)/1000, -FrameTime()*2, FrameTime()*2), math.Clamp((p.y-v.Target.y)/1000, -FrameTime()*2, FrameTime()*2)
					v.OldPosX = v.Pos.x
					v.OldPosY = v.Pos.y
					v.Pos.x = v.Pos.x + sy
					v.Pos.y = v.Pos.y - sx

					if math.floor(math.Distance(p.x, p.y, v.Target.x, v.Target.y)) == 0 then
						v.Task = "Researching"
						v.TaskStart = CurTime()
						v.TaskEnd = CurTime() + 3
					end
				end
			elseif v.Task == "Researching" then
				if CurTime() > v.TaskEnd then
					if v.Target.ID and SpaceEvo.GeneratedWorld.WorldResourcesMesh[v.Target.ID].Type != "Nothing" then
						local typ = SpaceEvo.GeneratedWorld.WorldResourcesMesh[v.Target.ID].Type
						chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " found "..typ.."!")
						v.Task = "Building a(n) "..SpaceEvo.Found[typ] or typ
						v.Build = SpaceEvo.Found[typ] or typ
						v.IQ = math.Clamp(v.IQ + 3, 0, SpaceEvo.Humans.MaxIQ)
						if !v.Giving then
							v.Giving = true
							for k1, v1 in ipairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans) do
								if v1.Giving then continue end
								v1.IQ = math.Clamp(v1.IQ + 1, 0, SpaceEvo.Humans.MaxIQ)
							end
							v.Giving = false
						end

						hook.Run("SpaceEvo_OnResourceFound", v, SpaceEvo.GeneratedWorld.WorldResourcesMesh[v.Target.ID])
					else
						v.Target = nil
						v.Task = nil
					end
				else
					if v.TaskEnd - CurTime() > 30 then
						v.TaskStart = CurTime()
						v.TaskEnd = CurTime() + 3
						SpaceEvo.Humans:Print("Fixing broken human")
					end
				end
			elseif v.Task:find("Building") then
				if not v.StartedBuild then
					local pos = SpaceEvo.WorldPos + Vector(v.Pos.x*10, v.Pos.y*10)
					local vec, i = SpaceEvo:NearestPixel(pos)
					v.StartedBuild = SpaceEvo.Objects:Create(v.Build, vec)
				else
					local obj = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects[v.StartedBuild]
					if not obj then
						v.Task = nil
						v.StartedBuild = nil
						v.Target = nil
						v.NextTarget = nil
						v.TaskEnd = nil
						chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " forgot what wanted to do")
						continue
					end
					obj.InWater = v.InWater
					obj.BuildState = math.Clamp(obj.BuildState+SpaceEvo.Objects[v.Build].BuildValue, 0, SpaceEvo.Objects[v.Build].BuildMaxValue)
					if obj.BuildState >= SpaceEvo.Objects[v.Build].BuildMaxValue then
						if not v.Target.ID then
							v.Task = nil
							v.NextTask = nil
							v.Build = nil
							v.StartedBuild = nil
							v.Target = nil
							continue
						end

						v.Task = nil
						v.NextTask = nil
						v.Build = nil
						v.StartedBuild = nil
						v.Target = nil
					end
				end
			elseif v.Task:find("Going to") then
				local p = SpaceEvo.Humans:GetScreenPos(v)
				local sx, sy = math.Clamp((v.Target.x-p.x)/1000, -FrameTime()*2, FrameTime()*2), math.Clamp((p.y-v.Target.y)/1000, -FrameTime()*2, FrameTime()*2)
				v.OldPosX = v.Pos.x
				v.OldPosY = v.Pos.y
				v.Pos.x = v.Pos.x + sy
				v.Pos.y = v.Pos.y - sx

				if math.floor(math.Distance(p.x, p.y, v.Target.x, v.Target.y)) == 0 then
					SpaceEvo.Humans:Print(v.FirstName.." "..v.LastName.." reached to destination, now going to "..v.NextTask)
					v.Task = v.NextTask
				end
			elseif v.Task:find("Using") then
				if not v.Use then
						v.Task = nil
						v.StartedBuild = nil
						v.Target = nil
						v.NextTarget = nil
						v.TaskEnd = nil
						v.Use = nil
						SpaceEvo.Humans:Print(v.FirstName.." "..v.LastName.." - Can't find needed useObj: "..tostring(v.Use))
						chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " forgot what wanted to do")
					continue
				end
				local obj = SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects[v.Use]
				if not obj then
					v.Task = nil
					v.StartedBuild = nil
					v.Target = nil
					v.NextTarget = nil
					v.TaskEnd = nil
					v.Use = nil

					SpaceEvo.Humans:Print(v.FirstName.." "..v.LastName.." - Can't find needed object: "..tostring(v.Use).."/"..tostring(obj))
					chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " forgot what wanted to do")

					continue
				end
				if obj.Name == "House" then
					if #obj.Humans >= 2 then
						continue
					end
					if not table.HasValue(obj.Humans, v.uniqueID) then
						table.insert(obj.Humans, v.uniqueID)
					end
					v.DontDraw = true
				elseif obj.Name == "Telescope" then
					v.TaskEnd = v.TaskEnd or CurTime() + math.random(5,10)
					if CurTime() >= v.TaskEnd then
						if math.random(0,v.IQ) >= 100 then
							local pData = SpaceEvo.Planets:GenerateNewPlanet()
							chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " found a new planet!\nPlanet: ", pData.Hills, pData.Name)

							hook.Run("SpaceEvo_OnNewPlanetFound", v, pData)
						else
							chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " didn't find a new planet")
						end
						v.Task = nil
						v.StartedBuild = nil
						v.Target = nil
						v.NextTarget = nil
						v.TaskEnd = nil
						v.NextTask = nil
						v.Use = nil
					end
				elseif obj.Name == "Rocket" then
					local newPlanet = SpaceEvo.Planets[obj.FlyTo]
					v.Task = nil
					v.NextTask = nil
					v.StartedBuild = nil
					v.Target = nil
					v.NextTarget = nil
					v.TaskEnd = nil

					if not newPlanet then
						SpaceEvo.Humans:Print(v.FirstName.." "..v.LastName.." - Can't find needed planet: "..tostring(obj.FlyTo))
						chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " forgot what wanted to do")
						continue
					end

					table.insert(newPlanet.Humans, v)
					chat.AddText(v.Model.Shirt, v.FirstName.." "..v.LastName, color_white, " just left to another planet")

					hook.Run("SpaceEvo_HumanLeftToAnotherPlanet", v, newPlanet)

					table.RemoveByValue(obj.Travel, v.uniqueID)
					if #obj.Travel == 0 then
						table.insert(newPlanet.Objects, obj)
						table.remove(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects, v.Use)
					end
					v.Use = nil
					SpaceEvo.Planets:SavePlanet(obj.FlyTo)
					SpaceEvo:SaveGame()

					table.remove(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans, k)
				end
			elseif v.Task == "Searching for love" then
				local humans = SpaceEvo.Humans:FindInRadius(v.Pos, 1000, v)

				for k1, v1 in ipairs(humans) do
					if not SpaceEvo.Humans:CanBeInLove(v, v1) then continue end
					if v.Love then break end
					if v1.Task and (v1.Task:find("Using") or v1.Task:lower():find("Build") or v1.Task:find("House") or v1.Task:find("Rocket")) then continue end
					if hook.Run("SpaceEvo_CantBeInLove", v, v1) then continue end
					v.Love = v1.uniqueID

					local p = SpaceEvo.Humans:GetScreenPos(v1)

					v.Target = {}
					v.Target.x = p.x
					v.Target.y = p.y

					hook.Run("SpaceEvo_FoundLove", v, v1)
				end
				if not v.Love and not v.Target then
					local rTarget = table.Random(SpaceEvo.GeneratedWorld.WorldMesh)
					local t = rTarget.Pos:ToScreen()
					v.Target = {
						x = t.x,
						y = t.y
					}
				elseif v.Love then
					local hum = SpaceEvo.Humans:FindByID(v.Love)
					if not hum then
						v.Task = nil
						v.Target = nil
						continue
					end
					local p = SpaceEvo.Humans:GetScreenPos(hum)

					local p1 = SpaceEvo.Humans:GetScreenPos(v)
					if math.floor(math.Distance(p.x, p.y, p1.x, p1.y)) >= 15 then
						v.Target = {}
						v.Target.x = p.x
						v.Target.y = p.y
					else
						v.InLove = hum.uniqueID
						hum.InLove = v.uniqueID

						for k1, v1 in pairs(SpaceEvo.Planets[SpaceEvo.CurrentWorld].Objects) do
							if v1.Name == "House" and #v1.Humans == 0 and not v1.WillUse then
								v.Task = "Going to use "..v1.Name
								v.NextTask = "Using "..v1.Name
								v.Use = k1

								hum.Task = "Going to use "..v1.Name
								hum.NextTask = "Using "..v1.Name
								hum.Use = k1

								local f = v1.Pos:ToScreen()
								v.Target = {
									x = f.x,
									y = f.y,
									ID = aP
								}
								hum.Target = v.Target 

								v1.WillUse = {hum.uniqueID, v.uniqueID}

								break
							end
						end

						if not v.Task:find("House") then
							v.Task = nil
							v.Target = nil
							hum.Task = nil
							hum.Target = nil
						end
						v.Love = nil
					end
				end
				if v.Target then
					local p = SpaceEvo.Humans:GetScreenPos(v)
					local sx, sy = math.Clamp((v.Target.x-p.x)/1000, -FrameTime()*2, FrameTime()*2), math.Clamp((p.y-v.Target.y)/1000, -FrameTime()*2, FrameTime()*2)
					v.OldPosX = v.Pos.x
					v.OldPosY = v.Pos.y
					v.Pos.x = v.Pos.x + sy
					v.Pos.y = v.Pos.y - sx

					if math.floor(math.Distance(p.x, p.y, v.Target.x, v.Target.y)) == 0 then
						if not v.Love then v.Target = nil v.Task = nil end
					end
				end
			end

			if not v.Task or not v.Task:find("Using") then v.DontDraw = nil end
		end
	end
end
function GM:Think()
	SpaceEvo.Humans:Think()
end