SpaceEvo = SpaceEvo or {}
SpaceEvo.Items = SpaceEvo.Items or {}

SpaceEvo.Items.List = {
	{
		Name = "House",
		Img = Material("space_evolution/house.png"),
		Desc = "Allows you to increase the population on current planet",
		Need = {
			Wood = 50,
			Food = 0,
			Iron = 0,
			Oil = 0
		}
	},
	{
		Name = "Rocket",
		Img = Material("space_evolution/rocket.png"),
		Desc = "Allows you to travel to another planets",
		Need = {
			Wood = 50,
			Food = 50,
			Iron = 100,
			Oil = 500
		}
	},
	{
		Name = "Telescope",
		Img = Material("space_evolution/telescope.png"),
		Desc = "Allows you to search planets",
		Need = {
			Wood = 50,
			Food = 0,
			Iron = 25,
			Oil = 0
		}
	},
}

function SpaceEvo.Items:AddCraftableItem(tbl)
	SpaceEvo:PrintConsole("Adding "..tbl.Name.." to craft list")

	table.insert(SpaceEvo.Items, tbl)
end

SpaceEvo.Items.Storage = {}

if not file.Exists("space_evolution/items.dat", "DATA") then
	local t = {}
	for k, v in ipairs(SpaceEvo.Items.List) do
		t[v.Name] = 0
	end
	file.Write("space_evolution/items.dat", util.TableToJSON(t))
else
	local items = file.Read("space_evolution/items.dat", "DATA")
	SpaceEvo.Items.Storage = util.JSONToTable(items)
end