SpaceEvo.Planets = SpaceEvo.Planets or {}
function SpaceEvo.Planets:Print(msg)
	MsgC(Color(135, 255, 171), "[Planets] ", color_white, msg.."\n")
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
		Food = 50
	}
}

SpaceEvo.RandomPlanets1 = {
	"Ave", "Roid", "Heso", "Yamo", "Ea", "Ki", "Jo", "Halo", "Gero", "Mano", "Fero", "We", "Qu", "Yo", "Reko", "Fano", "Dedo", "Beo", "Dio", "Ero", "Dai", "Toshi", "Mizu", "Hi", "Tsuchi", "Nando", "Multi", "Keda",
	"Veor", "Weist", "Lora", "Madero", "Io", "Le", "Kero", "Sero", "Mero", "Dea", "Veso", "Ze", "Xo", "No", "Qor", "Kek", "Meno", "Bio", "Ame", "Gov", "Jeri", "De", "Ve", "Ind", "Sis", "So", "Loe", "Out", "Her"
}
SpaceEvo.RandomPlanets2 = {
	"some", "seid", "heuk", "noid", "mort", "red", "pob", "zet", "et", "aweq", "nago", "kero", "loid", "je", "kero", "shiro", "hoshi", "zero", "neko" , "kya", "mya", "dyo", "puskin", "uon", "eon", "isk", "usk", "osk",
	"sit", "kir", "vir", "zir", "Li", "one", "to", "wo", "loi", "kei", "veir", "voi", "zei", "lol", "logy, ame", "no", "gov", "lo", "nero", "iel", "pous", "cho", "troit", "lve", "onesia", "un", "si", "xer", "now"
}
SpaceEvo.Planets.Maximum = #SpaceEvo.RandomPlanets1 * #SpaceEvo.RandomPlanets2

function SpaceEvo.Planets:AddFirstName(n)
	if table.HasValue(SpaceEvo.RandomPlanets1, n) then SpaceEvo.Planets:Print("'"..n.."' already exists in first names of planets!") return end
	table.insert(SpaceEvo.RandomPlanets1, n)
	SpaceEvo.Planets.Maximum = #SpaceEvo.RandomPlanets1 * #SpaceEvo.RandomPlanets2
end
function SpaceEvo.Planets:AddLastName(n)
	if table.HasValue(SpaceEvo.RandomPlanets2, n) then SpaceEvo.Planets:Print("'"..n.."' already exists in last names of planets!") return end
	table.insert(SpaceEvo.RandomPlanets2, n)
	SpaceEvo.Planets.Maximum = #SpaceEvo.RandomPlanets1 * #SpaceEvo.RandomPlanets2
end

SpaceEvo.Planets:Print("Maximum possible planets: "..SpaceEvo.Planets.Maximum)

function SpaceEvo.Planets:GenerateNewPlanet()
	if SpaceEvo.Removing then return end
	local name = select(1, table.Random(SpaceEvo.RandomPlanets1))..select(1, table.Random(SpaceEvo.RandomPlanets2))
	if SpaceEvo.Planets[name] then
		return SpaceEvo:GenerateNewPlanet()
	end
	return SpaceEvo:GenerateWorld(name:lower(), name, true)
end
function SpaceEvo.Planets:SavePlanet(planet)
	if SpaceEvo.Removing then return end
	hook.Run("SpaceEvo_PreSavePlanet", SpaceEvo.Planets[planet])
	file.Write("space_evolution/"..planet.."/planet.txt", util.TableToJSON(SpaceEvo.Planets[planet], true))
	SpaceEvo.Planets:Print("Saved planet "..planet)
	hook.Run("SpaceEvo_PostSavePlanet", SpaceEvo.Planets[planet])
end

local _, planets = file.Find("space_evolution/*", "DATA")

SpaceEvo.Planets:Print("Caching exists planets...")
for k, v in ipairs(planets) do
	if not file.Exists("space_evolution/"..v.."/planet.txt", "DATA") then continue end
	local dat = util.JSONToTable(file.Read("space_evolution/"..v.."/planet.txt", "DATA"))
	SpaceEvo.Planets:Print("- Caching "..v.."...")
	SpaceEvo.Planets[v] = dat
	SpaceEvo.Planets[v].Name = v[1]:upper()..string.sub(v, 2)
end

