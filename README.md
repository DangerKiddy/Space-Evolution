# Space Evolution
Space Evolution is gamemode with procedural generation, space theme and start with nothing(Well, almost with nothing).

You have 2 humans at the start and you must find resources for feeding humans, crafting items and then flying away from earth and discovering other planets!

## Humans
Humans is simple AI which have special tasks. Human with low IQ just wandering around, but humans with IQ 80+ can explore the planet. Or you can force them to explore planet by clicking on them

When human exploring the planet, he/she will search for useful resources, if he/she will find something, you'll see message in chat what was found

## Resources
Amount of exists resources you can see in top-right corner on your screen, you need these resources for crafting, and some of them(Food) for humans. Each planet have different amount of resources

## Planets
Planets generates absolutely randomly, using perlin's noise and simple random functions. You can find over 1,000 planets, while playing this gamemode, some planets can be dry or flooded.

# API
You can modificate that gamemode as you want, you can change generation, behaivor of humans and so on

**NOTE:** in some functions/hooks/globals can be used same things but with different names:
- Pixel/Block
- World/Planet

## Generation
### Hooks
```lua
GM:SpaceEvo_PlanetStartLoading(PlanetName, Name, OnlyGenerate)
```
*Calls when planet starts loading*
- PlanetName(string): Name of folder of planet. Example: "earth"
- Name(string): Name of planet. Example: "Earth"
- OnlyGenerate(bool): Means that planet will be **only** generated, without visiting that planet 


```lua
GM:SpaceEvo_NewPlanetGenerating(PlanetName, Name, OnlyGenerate)
```
*Calls when new planet starting generation*
- PlanetName(string): Name of folder of planet. Example: "earth"
- Name(string): Name of planet. Example: "Earth"
- OnlyGenerate(bool): Means that planet will be **only** generated, without visiting that planet 


```lua
GM:SpaceEvo_CustomSeed(seed, resourceseed)
```
*Calls when new planet going to generate seed.*
Return true in that hook to override default seed generation
- seed(table): Seed of planet(Surface)
- resourceseed(table): Seed of resources(Under ground)

Example:
```lua
-- Same as default seed generation
hook.Add("SpaceEvo_CustomSeed", "TestSeed", function(Seed, ResourceSeed)
    for i=0, 255 do
	local num = math.random(255)
	while table.HasValue(Seed, num) do
	    num = math.random(255)
        end
	Seed[#Seed+1] = math.random(255)
    end
    for i=0, 255 do
        local num = math.random(255)
        while table.HasValue(ResourceSeed, num) do
            num = math.random(255)
        end
        ResourceSeed[#ResourceSeed+1] = math.random(255)
    end
    return true
end)
```


```lua
GM:SpaceEvo_OnSeedGenerated(PlanetName, SeedTbl)
```
*Called after seed generated and written in the planet's file*
- PlanetName(string): Name of folder of planet. Example: "earth"
- SeedTbl(table): Table of 2 seeds, SeedTbl.WorldSeed - Seed of surface, SeedTbl.ResourceSeed - Seed of resources(under ground)


```lua
GM:SpaceEvo_PreLoadPlanetSeed(PlanetName, seed)
```
*Calls before seed was loaded*
- PlanetName(string): Name of folder of planet. Example: "earth"
- seed(table): Table of 2 seeds, SeedTbl.WorldSeed - Seed of surface, SeedTbl.ResourceSeed - Seed of resources(under ground)
Return in that hook seed to override planet's seed. **It wouldn't re-write file of planet's seed**


```lua
GM:SpaceEvo_PostLoadPlanetSeed(PlanetName, seed)
```
*Called after planet's seed was loaded*
- PlanetName(string): Name of folder of planet. Example: "earth"
- SeedTbl(table): Table of 2 seeds, SeedTbl.WorldSeed - Seed of surface, SeedTbl.ResourceSeed - Seed of resources(under ground)


```lua
GM:SpaceEvo_OnPlanetGenerated(PlanetName, PlanetTable, seed)
```
*Calls when new planet was generated.* **It will be called when earth first generated too**
- PlanetName(string): Name of folder of planet. Example: "earth"
- PlanetTable(Planet): Table of new planet. You can find its structure in "Structures" section
- seed(table): Table of 2 seeds, SeedTbl.WorldSeed - Seed of surface, SeedTbl.ResourceSeed - Seed of resources(under ground)


```lua
GM:SpaceEvo_GenerateTerrain(BlockHeight, Neighbors, PlanetName)
```
*That hook calls when terrain is generating. It calls each time you loading(visiting) planet*
With that hook you can override default terrain generation, for example making somewhere winter, stone, mud or whatever. See example
- BlockHeight(float): Height of current block/pixel. You can see height of blocks alredy in game, or google more about Perlin noise
- Neighbors(table): Neighbors of block. You can find its structure in "Structures" section"
- PlanetName(string): Name of folder of planet. Example: "earth"

Example:
```lua
-- in that hook you must return name of block and its color
hook.Add("SpaceEvo_GenerateTerrain", "CustomGeneration", function(height, neighbors)
	if height >= 0.5 and height <= SpaceEvo.MountainHeight then
		return "Stone", Color(255*height,255*height,255*height)
	end
end)
```


```lua
GM:SpaceEvo_GenerateResources(BlockHeight, BlockSurface, Neighbors, PlanetName)
```
*Same as hook above, but allows you to override default resource generation. You can add your own resources or just make default generation better.*
Return same values as in hook above to override generation. You can check your resource generation using sv_cheats 1
- BlockHeight(float): Height of current block/pixel. You can see height of blocks alredy in game, or google more about Perlin noise
- BlockSurface(Block): That table contains information of block on surface. You can find its structure in "Structures" section
- Neighbors(table): Neighbors of block. You can find its structure in "Structures" section"
- PlanetName(string): Name of folder of planet. Example: "earth"


```lua
GM:SpaceEvo_PlanetFinishedGeneration(PlanetName)
```
*Calls after all hooks above and when planet was successfully generated(No errors)*
- PlanetName(string): Name of folder of planet. Example: "earth"



## Humans
### Functions
```lua
SpaceEvo.Humans:AddMenuButton(funcAdd)
```
*Allows you to add your custom button in popup menu, when you're clicking on human*
- funcAdd(function): Function which called each time you're pressing on human. function(Menu, Human, HumanID)
	- Menu(Panel): DermaMenu
	- Human(Human): Table of human. You can find its structure in "Structures" section
	- HumanID(int): ID of human in humans table

Example:
```lua
SpaceEvo.Humans:AddMenuButton(function(m, hum, humid)
	m:AddOption( "Suicide", function()
		SpaceEvo.Humans:Kill(humid, false, {color_white, " just suicided!"})
	end)
end)
```


```lua
SpaceEvo.Humans:AddFirstName(gender, name)
```
*Adds possible first names to table of first names. Same as table.insert(SpaceEvo.Humans.FirstName[gender], name)*
- gender(string): For which gender will be used that name. You can type here "Female" or "Male".
- name(string): Name which you want to add


```lua
SpaceEvo.Humans:AddLastName(lastname)
```
*Adds possible last names to table of first names. Same as table.insert(SpaceEvo.Humans.LastName, lastname)*
- lastname(string): Last name which you want to add


```lua
SpaceEvo.Humans:Kill(humanID, isUniqueID, reason, planet)
```
*Allows you to kill a human*
- humanID(int): ID of human, it can be uniqueID of human(which can be get by Human.uniqueID, see structure of human's table) or human's ID from table of all humans
- isUniqueID(bool): If you used uniqueID of human, then place here true. Else false
- reason(table)[optional]: If you want to put message in chatbox, that this human was killed, add that table. Table values should be as arguments for chat.AddText - https://wiki.facepunch.com/gmod/chat.AddText
- planet(string)[optional]: If you want to kill human from another planet, use that argument. **You must use human's uniqueID to kill him/her on another planet**


```lua
SpaceEvo.Humans:Create(FirstName, LastName, Gender, planet, pos, parrents)
```
*Allows you to create human on any planet*
That function returns created human
- FirstName(string)
- LastName(string)
- Gender(string): "Male" or "Female
- planet(string): On which planet create this human
- pos(table)[optional]: If you want to create human on special position, use that table. {x = whatever, y = whatever}
- parrents(table)[optional]: Allows to add parrents to that human. {Dad = uniqueID, Mom = uniqueID}


```lua
SpaceEvo.Humans:CanBeInLove(hum1, hum2)
```
*Returns boolean, can hum1 be in love with hum2*
- hum1(Human): First human
- hum2(Human): Second human


```lua
SpaceEvo.Humans:FindLove(human)
```
*Finds and returns the partner for human*
- human(Human): For who search the partner


```lua
SpaceEvo.Humans:FindInRadius(WorldPosition, Radius)
```
*Returns table with humans which was found in that radius*. **Notice that here used world position, not screen position**
- WorldPosition(Vector): Center of sphere where to search
- Radius(int): Radius to search. **Must be squared**. This function uses "DistToSqr"


```lua
SpaceEvo.Humans:GetScreenPos(human)
```
*Returns screen position of human*
- human(Human): Human whose position needed


```lua
SpaceEvo.Humans:GetPos(human)
```
*Returns worls position of human*
- human(Human): Human whose position needed


```lua
SpaceEvo.Humans:GetVelocity(human)
```
*Returns velocity of human*
- human(Human): Human whose velocity needed


```lua
SpaceEvo.Humans:FindByID(id, planet)
```
*Returns human*
- id(int): uniqueID of needed human. **That function searches
- PlanetName(string)[optional]: Name of folder of planet. Example: "earth"


### Hooks

```lua
GM:SpaceEvo_HumanThink(humID, hum, planet)
```
*Calls each tick when human is thinking. Actually it is same as "hook.Add('Think', ..)"*
Return true to override human's behaivor
- humID(int): ID of human in their table (SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans)
- hum(Human)
- planet(string): Current planet


```lua
GM:SpaceEvo_HumanSearchingResource(hum, block)
```
*That hook calls each time when human scans whole planet to find useful resource. This happens randomly and depends of human's IQ.*
Return true in that function to prevent human from finding that block
**If you want to remove that ability, then do also "hum.shouldFind = nil" in that hook, to prevent human's stuck**
- hum(Human): Human who trying to find something useful
- block(Block): Block which he checking


```lua
GM:SpaceEvo_OnResourceFound(hum, block)
```
*That hook calls once when human was found something usefult and going to build special object for that resource*
- hum(Human): Human who found resource
- block(Block): Block which contains resource


```lua
GM:SpaceEvo_OnNewPlanetFound(hum, PlanetTable)
```
*That hook calls when human found new planet using the telescope*
- hum(Human): Human who found the planet
- PlanetTable(Planet): Planet which was found


```lua
GM:SpaceEvo_HumanLeftToAnotherPlanet(hum, newPlanet)
```
*Calls when human flying away to the another planet, using the rocket*
- hum(Human): Human who fly away
- newPlanet(Planet): The planet he went to


```lua
GM:SpaceEvo_CantBeInLove(hum1, hum2)
```
*That hook allows you to skip human which could be a partner for hum1*. ~~You are cruel if you do that~~
- hum1(Human): Human who searching partner
- hum2(Human): Human who could be a partner


```lua
GM:SpaceEvo_FoundLove(hum1, hum2)
```
*Calls after hum1 found his/her love*
- hum1(Human): Human who was searching for love
- hum2(Human): Human who was found by hum1


```lua
GM:SpaceEvo_PreHumanCreate(FirstName, LastName, Gender, planet, pos, parrents)
```
*That hook calls in function SpaceEvo.Humans:Create before all code and contains arguments which was used in that function*
- FirstName(string)
- LastName(string)
- Gender(string)
- planet(string): On which planet human will be created
**These arguments can be nil**
- pos(table): Position where to create human. {x = whatever, y = whatever}
- parrents(table): Parrents of that human. {Dad = uniqueID, Mom = uniqueID}


```lua
GM:SpaceEvo_PostHumanCreate(human)
```
*Called after human was created*
- human(Human): Human who was created


```lua
GM:SpaceEvo_OnHumanKilled(human, planet)
```
*Called when human was killed by calling SpaceEvo.Humans:Kill function*
- human(Human): Human who was killed
- planet(string): Planet on which human was killed


## Planets
### Functions

Next 2 functions need additional description. When new planet generating, it takes random name from 2 tables: SpaceEvo.RandomPlanets1 and SpaceEvo.RandomPlanets2. 
Basicly, it does that: 
```lua
select(1, table.Random(SpaceEvo.RandomPlanets1))..select(1, table.Random(SpaceEvo.RandomPlanets2))
```
It allows to create more unique planets with unique names.

```lua
SpaceEvo.Planets:AddFirstName(name)
```
*Allows you to add more possible names for planets. It will also increase amount of possible generated planets*
- name(string): First part of planet's name

```lua
SpaceEvo.Planets:AddLastName(name)
```
*Allows you to add more possible names for planets. It will also increase amount of possible generated planets*
- name(string): Last(Second) part of planet's name



```lua
SpaceEvo.Planets:GenerateNewPlanet()
```
*That function generates new random planet without loading(visiting) it*. **Game freezes when generating new planet**
Returns:
- PlanetTable(Planet): Table of new planet


```lua
SpaceEvo.Planets:SavePlanet(planet)
```
*That function allows you to save any planet which is generated*
- planet(string): PlanetName (must be lower case)


```lua
SpaceEvo:GenerateWorld(planet, name, dontopen)
```
*That function allows you to generate planet with special name*
- planet(string): PlanetName
- name(string): Planet's name (Usually it's same as planet, just starts with a capital letter)
- dontopen(bool)[optional]: If true then this planet will be only generated, without visiting it

### Hooks
```lua
GM:SpaceEvo_PreSavePlanet(planet)
```
*Calls before saving the planet*.
- planet(Planet): Table of planet to save



```lua
GM:SpaceEvo_PostSavePlanet(planet)
```
*Calls after planet saved*.
- planet(Planet): Table of planet which was saved


## Objects and crafts
Objects are used for resource extraction or special actions (Like telescope, house or rocket)
### Functions
```lua
SpaceEvo.Objects:AddNew(index, tbl)
```
*That function allows you to add new object. If human will find resource which name == index, human will create that object on resource's position*
- index(string): Index for object. **Must be unique**
- tbl(table): Table of new object. Find structure of objects in "Structures" section


```lua
SpaceEvo.Objects:GetPos(obj)
```
*Returns world position of the object*
- obj(Object): Needed object


```lua
SpaceEvo.Objects:GetScreenPos(obj)
```
*Returns screen position of the object*
- obj(Object): Needed object


```lua
SpaceEvo.Items:AddCraftableItem(itemTbl)
```
*Adds item to the Craft menu*
- itemTbl(table): Table of item.
```lua
	{
		Name = "Telescope", -- Should be save as index in "SpaceEvo.Objects:AddNew" function
		Img = Material("space_evolution/telescope.png"), -- image which will be drawn
		Desc = "Allows you to search planets", -- description
		Need = { -- What player need to craft that item
			Wood = 50,
			Food = 0,
			Iron = 25,
			Oil = 0
		}
	},
```


```lua
GM:SpaceEvo_OnItemCrafted(item)
```
*Calls when player crafts item in Craft menu*
- item(Object's adding table): Item which was crafted


```lua
SpaceEvo.Objects:Create(objName, objBlockPos)
```
*That function allows you to create any object which exists by default or was added by "SpaceEvo.Objects:AddNew" function*
- objName(string): Object to create. Example: "Telescope"
- objBlockPos(table): Position of block where should be placed object 


```lua
SpaceEvo.Objects:Get(id, planet)
```
*Allows you to get object by using their ID, without using global table*
- id(int): ID of object in global table
- planet(string)[optional]: Where to search

### Hooks
```lua
GM:SpaceEvo_OnObjectCreated(objID, objName, objBlockPos)
```
*Called when object was created by function above*
- objID(int): ID of object in their table (SpaceEvo.Planets[planet].Objects)
- objName(string): Name of object
- objBlockPos(table): Position of block where it was placed


## Other functions and hooks
### Hooks
```lua
GM:SpaceEvo_PreFramePaint(panel, width, height)
```
*Calls before main frame was painted*


```lua
GM:SpaceEvo_BlockPaint(index, block, mousex, mousey, freeSpace)
```
*Calls when mouse over block and drawing block info*
- index(int): Index of block in their global table
- block(Block): Block's table
- mousex(float): x position of mouse
- mousey(float): y position of mouse with offset
- freeSpace(float): Y Coordinate where you can place something yours 


```lua
GM:SpaceEvo_PostFramePaint(panel, w, h, rightY, leftY)
```
*Calls after main frame was painted*
- panel(Panel): Main frame
- w(int): Width
- h(int): Height
- rightY(int): Y Coordinate where you have free space to place something yours under the "Resources:" text
- leftY(int): Same as above but at left, under "Planet:" text

```lua
GM:SpaceEvo_OnHumanSelected(human)
```
*Calls when player click on human and then on ground*


```lua
GM:SpaceEvo_PreSaveRemove()
```
*Calls before all saves being removed*


```lua
GM:SpaceEvo_PostSaveRemove()
```
*Calls after all saves was removed*


```lua
GM:SpaceEvo_OnMainFrameCreated(frame)
```
*Calls after SpaceEvo.MainFrame was created and loaded*


### Functions
```lua
SpaceEvo.Circle(x, y, radius, segments, color)
```
*Function for drawing filled circle*


```lua
SpaceEvo:Frame(Parrent[optional])
```
*Function for creating DFrame in gamemode's style*


```lua
SpaceEvo:Button(text, parrent)
```
*Function for creating DButton in gamemode's style*
- text(string): Text which should be drawn on button
**NOTE:** Button works a bit different than usual DButton:
```lua
local btn = SpaceEvo:Button("Sample text")
btn.Click = function(self)
	btn.Text = "Instead of 'DoClick' you must use 'Click' funciton, and instead of 'SetText' - '.Text = '"
end


```lua
SpaceEvo:NearestPixel(pos)
```
*That function used to get nearest block(Pixel) to position. You must use world coordinates in that function*
- Pos(Vector)


```lua
SpaceEvo:ShadowText(text, font, x, y, color, alignx, aligny)
```
*That function works same as draw.SimpleText but adds simple shadow*

**WIP**
```lua
SpaceEvo.Particle(pData)
```
*Creates 2D particles on the screen*
Example:
```lua
-- that is how water particles was done
				local velX, velY = SpaceEvo.Humans:GetVelocity(v)
				SpaceEvo.Particle({
					x = p.x,
					y = p.y+10,
					Spread = .1,
					Dir = {x = velX, y = velY},//
					Mat = nil,
					Time = .25,
					StartSize = 5,
					EndSize = 3,
					ColorStart = Color(100,155,255,100),
					ColorEnd = Color(180,200,255,0),
					Rotate = math.Rand(-.1, .1),
					Amount = 1
				})
```


## Globals

### Humans
```lua
SpaceEvo.Humans.MaxIQ = 200 -- Maximum IQ which human can reach
SpaceEvo.Humans.FirstName - Table of first names for humans
SpaceEvo.Humans.LastName - Table of last names for humans
SpaceEvo.Humans.ExtraButtons - Table which contains custom buttons, which was created with "SpaceEvo.Humans:AddMenuButton" function
```
### Planets
```lua
SpaceEvo.Planets -- All generated planets
SpaceEvo.Planets[planet].Humans -- Table of all humans on the planet
SpaceEvo.Planets[planet].Objects -- Table of all object on the planet
```

### Other
```lua
SpaceEvo.CurrentWorld -- Current planet. DON'T CHANGE IT WITH CODE
SpaceEvo.Items.Storage -- Items which you can find in Craft menu. {[ItemName] = ItemAmount}
SpaceEvo.MainFrame -- Main DFrame of gamemode
SpaceEvo.CursorPos -- Position of cursor
SpaceEvo.Removing -- true if all saves removing right now
SpaceEvo.CamPos -- Position of camera
SpaceEvo.WorldPos -- Position of the world(planet)
SpaceEvo.GeneratedWorld -- Table of generated world(planet)
-- That table contains 5 keys:
SpaceEvo.GeneratedWorld.World -- The whole table of generated blocks, but I'm not recommend to use it
SpaceEvo.GeneratedWorld.WorldResources -- Same as above but for resources
SpaceEvo.GeneratedWorld.WorldMesh -- Use that, it's processed and simple table of world's (planet's) blocks
SpaceEvo.GeneratedWorld.WorldResourcesMesh -- Use that for resources, it's processed and simple table of world's (planet's) resources
SpaceEvo.GeneratedWorld.WorldName -- Same as SpaceEvo.CurrentWorld
```

## Structures

### Block's table structure
```
Pos = Position of the block in the world coordinates
Col = Color of the block
Type = Type of the block(Hills, Sand, Water, ..)
Height = Height of the block
Resource = Table of not-processed resource, which located under that block (Resource from SpaceEvo.GeneratedWorld.WorldResources)
```
**In block of resource only one different: Instead of "Resource" it has "World"***


### Planet's table structure
```
Name = Name of the planet
Hills = Color of the hills
Water = Color of the water
Sand = Color of the sand

WaterAmount = Height of water. It's using in terrain generation: Height <=.1 and Height >= WaterAmount and "Sand" or "Water"
Humans = Table of all humans on that planet
Objects = Table of all objects on that planet

Resources = Table of resources on that planet:
Resources.Iron = Amount of iron
Resources.Oil = Amount of oil
Resources.Wood = Amount of wood
Resources.Food = Amount of food
```


### Human's table structure
```
FirstName = First name of human
LastName = Last name of human
Sex = Sex of human
Job = job of human(unused)
InLove = uniqueID of human he's in love
uniqueID = Unique ID of human
IQ = IQ
Pos = Position of human. Use SpaceEvo.Humans:GetPos(human) or SpaceEvo.Humans:GetScreenPos(human) to get calculated position
Parrents = Table of parrents with unique ids:
	Dad = uniqueID
	Mom = UniqueID
Model = Table of color for human's body
	Body = Color of his skin
	Shirt = Color of his shirt
	Pants = Color of his pants
	Hairs = Color of his hairs
	

```
### Not-processed block/resource table structure:
```
x = x position of the block
y = y position of the block
color = color of the block
v = height of the block
slf = self-index of the block
typ = type of the block
neighbors = neighbors of the block
```


### Blocks'/Resource's Neighbors structure
```
Simple table with simple values:
left = left block
right = right block
top = top block
bottom = bottom block

All these values ARE INTs, to get actual not-processed block use: 
SpaceEvo.GeneratedWorld.World[Block.neighbors.top]
to get processed block use:
SpaceEvo.GeneratedWorld.WorldMesh[Block.neighbors.top]
```


### Object's adding table structure
```
Name = Name of the object
Paint = Paint function(x Position X, y Position Y, mx Mouse Position X, my Mouse Position Y) for the object
IsMouseOver = function(x Position X, y Position Y, mx Mouse Position X, my Mouse Position Y), return true if mouse is over
Think = function(self), Think function of object

Usable = bool, if usable, then when you're selecting human and then your object, you'll be able to press "Use Object" in popup menu 
CanUse = function(self, human), Function which checks, can human use object
BuildValue = float/int, How much will be added to its BuildProgress each tick
BuildMaxValue = Max value to build it
NeededIQ = Unused
```
### Object's table structure
```
Name = Name of the object
Pos = position of the object. Use SpaceEvo.Objects:GetPos(obj) or SpaceEvo.Objects:GetScreenPos(obj) to get needed positions
BuildState = BuildState of object, not used much
CurrentTask = Unused
```

