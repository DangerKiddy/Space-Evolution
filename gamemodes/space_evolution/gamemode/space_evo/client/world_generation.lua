// perlin noise was taken from https://gist.github.com/SilentSpike/25758d37f8e3872e1636d90ad41fe2ed

--[[
    Implemented as described here:
    http://flafla2.github.io/2014/08/09/perlinnoise.html
]]--

perlin = {}
perlin.p = {}

local permutation = {}
local permutation_res = {}
-- Return range: [-1, 1]
function perlin:noise(x, y, z)
    y = y or 0
    z = z or 0

    -- Calculate the "unit cube" that the point asked will be located in
    local xi = bit.band(math.floor(x),255)
    local yi = bit.band(math.floor(y),255)
    local zi = bit.band(math.floor(z),255)

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

    -- We also fade the location to smooth the result
    local u = self.fade(x)
    local v = self.fade(y)
    local w = self.fade(z)

    -- Hash all 8 unit cube coordinates surrounding input coordinate
    local p = self.p
    local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
    A   = p[xi  ] + yi
    AA  = p[A   ] + zi
    AB  = p[A+1 ] + zi
    AAA = p[ AA ]
    ABA = p[ AB ]
    AAB = p[ AA+1 ]
    ABB = p[ AB+1 ]

    B   = p[xi+1] + yi
    BA  = p[B   ] + zi
    BB  = p[B+1 ] + zi
    BAA = p[ BA ]
    BBA = p[ BB ]
    BAB = p[ BA+1 ]
    BBB = p[ BB+1 ]

    -- Take the weighted average between all 8 unit cube coordinates
    return self.lerp(w,
        self.lerp(v,
            self.lerp(u,
                self:grad(AAA,x,y,z),
                self:grad(BAA,x-1,y,z)
            ),
            self.lerp(u,
                self:grad(ABA,x,y-1,z),
                self:grad(BBA,x-1,y-1,z)
            )
        ),
        self.lerp(v,
            self.lerp(u,
                self:grad(AAB,x,y,z-1), self:grad(BAB,x-1,y,z-1)
            ),
            self.lerp(u,
                self:grad(ABB,x,y-1,z-1), self:grad(BBB,x-1,y-1,z-1)
            )
        )
    )
end

-- Gradient function finds dot product between pseudorandom gradient vector
-- and the vector from input coordinate to a unit cube vertex
perlin.dot_product = {
    [0x0]=function(x,y,z) return  x + y end,
    [0x1]=function(x,y,z) return -x + y end,
    [0x2]=function(x,y,z) return  x - y end,
    [0x3]=function(x,y,z) return -x - y end,
    [0x4]=function(x,y,z) return  x + z end,
    [0x5]=function(x,y,z) return -x + z end,
    [0x6]=function(x,y,z) return  x - z end,
    [0x7]=function(x,y,z) return -x - z end,
    [0x8]=function(x,y,z) return  y + z end,
    [0x9]=function(x,y,z) return -y + z end,
    [0xA]=function(x,y,z) return  y - z end,
    [0xB]=function(x,y,z) return -y - z end,
    [0xC]=function(x,y,z) return  y + x end,
    [0xD]=function(x,y,z) return -y + z end,
    [0xE]=function(x,y,z) return  y - x end,
    [0xF]=function(x,y,z) return -y - z end
}
function perlin:grad(hash, x, y, z)
    return self.dot_product[bit.band(hash,0xF)](x,y,z)
end

-- Fade function is used to smooth final output
function perlin.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(t, a, b)
    return Lerp(t, a, b)
end

local generated = {}
local generated_resources = {}
local wide = 100 // world's wide
local WorldSize = 30 // actually, zoom
local quadSize = 10 // size of one block

// don't touch
local World = {}
local Resources = {}
local obj = Mesh()
local ojb_res = Mesh()
local verts_res = {}
local verts = {}
local basePos = Vector(quadSize*wide/2,-quadSize*wide/2,-12250)

SpaceEvo.WorldPos = basePos
SpaceEvo.GeneratedWorld = SpaceEvo.GeneratedWorld or {}
function SpaceEvo:GenerateWorld(world, name, dontopen)
    print("\n ")

    hook.Run("SpaceEvo_PlanetStartLoading", world, name, dontopen)
    SpaceEvo.Planets:Print("Loading "..world.."...")
    if #World > 0 or IsValid(obj) then
        SpaceEvo.Planets:Print("Another planet loaded, cleaning...")
        if not dontopen then
            obj:Destroy()
            obj = Mesh()
            ojb_res = Mesh()
            verts_res = {}
            verts = {}
        end
        generated = {}
        generated_resources = {}
        permutation = {}
        permutation_res = {}
        World = {}
        Resources = {}
    end

    file.CreateDir("space_evolution/"..world.."/")

    local planet = SpaceEvo.Planets[world]
    if not file.Exists("space_evolution/"..world.."/seed.txt", "DATA") then
        local maxvalue = table.Random({2,10,50,125,255,10,50,125,255}) // something like weighted random, so "2" is rare
        local seedMin, seedMax = planet and planet.Seed_Random and planet.Seed_Random.min or math.random(0,maxvalue), planet and planet.Seed_Random and planet.Seed_Random.max or math.random(0,maxvalue)
        while seedMin == seedMax do
            seedMin, seedMax = planet and planet.Seed_Random and planet.Seed_Random.min or math.random(0,maxvalue), planet and planet.Seed_Random and planet.Seed_Random.max or math.random(0,maxvalue)
        end
        if seedMax < seedMin then
            seedMax, seedMin = seedMin, seedMax
        end
        SpaceEvo.Planets:Print("Generating seed's values - "..seedMin.." to "..seedMax)
        
        local maxvalue = table.Random({2,10,50,125,255,10,50,125,255}) // something like weighted random, so "2" is rare
        local seedrMin, seedrMax = planet and planet.SeedResource_Random and planet.SeedResource_Random.min or math.random(0,maxvalue), planet and planet.SeedResource_Random and planet.SeedResource_Random.max or math.random(0,maxvalue)
        if seedrMax < seedrMin then
            seedrMax, seedrMin = seedrMin, seedrMax
        end
        local SeedValuesUnique = seedMin == 0 and seedMax == 255

        SpaceEvo.Planets:Print("Generating new planet...")
        hook.Run("SpaceEvo_NewPlanetGenerating", world, name, dontopen)

        local override = hook.Run("SpaceEvo_CustomSeed", permutation, permutation_res)
        if not override then
            for i=0, 255 do
                local num = math.random(seedMin, seedMax)
                if i != 255 and SeedValuesUnique then
                    while table.HasValue(permutation, num) do
                        num = math.random(seedMin, seedMax)
                    end
                else
                    local chances = 0
                    while num == (permutation[#permutation-1] or -1) and chances < 10 do
                        num = math.random(seedMin, seedMax)
                        if chances == 0 then
                            SpaceEvo.Planets:Print("("..i.."/255)Trying to make terrain more pretty...")
                        end
                        chances = chances + 1
                    end
                end
                permutation[#permutation+1] = num
            end
            for i=0, 255 do
                local num = math.random(seedrMin, seedrMax)
                permutation_res[#permutation_res+1] = num
            end
        end
        file.Write("space_evolution/"..world.."/seed.txt", util.TableToJSON({WorldSeed = permutation, ResourceSeed = permutation_res}))
        hook.Run("SpaceEvo_OnSeedGenerated", world, {WorldSeed = permutation, ResourceSeed = permutation_res})
    else
        SpaceEvo.Planets:Print("Loading planet...")
        local f = util.JSONToTable(file.Read("space_evolution/"..world.."/seed.txt", "DATA"))
        local seed = hook.Run("SpaceEvo_PreLoadPlanetSeed", world, f) or f
        permutation = seed.WorldSeed
        permutation_res = seed.ResourceSeed
        hook.Run("SpaceEvo_PostLoadPlanetSeed", world, seed)
    end

    for i=0,255 do
        perlin.p[i] = permutation[i+1]
        perlin.p[i+256] = permutation[i+1]
    end
    for x=1, wide do
        for y=1, wide do
            local n = perlin:noise(x/WorldSize, y/WorldSize, .3)
            generated[#generated+1] = n
        end
    end

    for i=0,255 do
        perlin.p[i] = permutation_res[i+1]
        perlin.p[i+256] = permutation_res[i+1]
    end
    for x=1, wide do
        for y=1, wide do
            local n = perlin:noise(x/WorldSize, y/WorldSize, -.3)
            generated_resources[#generated_resources+1] = n
        end
    end

    local Hills = planet and planet.Hills or HSVToColor(math.random(360), 1, .75)//Color(0,255,0)
    local Water = planet and planet.Water or Color(math.random(100),math.random(100),150)
    local Sand = planet and planet.Sand or HSVToColor(math.random(0, 120), .5, .9)//Color(255,255,0)
    local Mountain = color_white
    local WaterInt = planet and planet.WaterAmount or math.Rand(-1,1)
    local MountainInt = world == "earth" and .75 or planet and planet.MountainInt or math.Rand(0, 1) // height for mountains

    if not planet or not file.Exists("space_evolution/"..world.."/planet.txt", "DATA") then
        SpaceEvo.Planets[world] = {
            Name = name or planet and planet.Name or nil,
            Hills = Hills,
            Water = Water,
            Sand = Sand,
            WaterAmount = WaterInt,
            MountainInt = MountainInt,
            Humans = {},
            Objects = {},

            Resources = {Iron = 0, Oil = 0, Food = 50, Wood = 100}
        }
        file.Write("space_evolution/"..world.."/planet.txt", util.TableToJSON(SpaceEvo.Planets[world], true))
        hook.Run("SpaceEvo_OnPlanetGenerated", world, SpaceEvo.Planets[world], {WorldSeed = permutation, ResourceSeed = permutation_res})
    end

    local x, y = 0, 0
    local i = 0
    for k, v in pairs(generated) do
        local v2 = math.abs(v)

        local neigh = {
            left = i == 0 and -1 or k-1,
            right = k+1,
            top = k-wide,
            bottom = k+wide
        }

        local customGeneration, customGenerationColor = hook.Run("SpaceEvo_GenerateTerrain", v, neigh, world)
        local typ = customGeneration or v >= MountainInt and "Snow" or (v > .1 and v < MountainInt and "Hills") or
            v <=.1 and v >= WaterInt and "Sand" or "Water"

        World[k] = {
            x = x,
            y = y,
            color = customGeneration and customGenerationColor or typ == "Snow" and Color(Mountain.r*(v2+.2),Mountain.g*(v2+.2),Mountain.b*(v2+.2)) or
                typ == "Hills" and Color(Hills.r,Hills.g*v2,Hills.b) or
                typ == "Sand" and Color(Sand.r*(v2+.3),Sand.g*(v2+.3),Sand.b) or
                typ == "Water" and Color(Water.r, Water.g, Water.b*(1.2-v2)) or color_black,

            v = v,
            slf = k,
            typ = typ,

            neighbors = neigh
        }

        i = i + 1
        x = x + quadSize
        if i >= wide then
            i = 0
            y = y + quadSize
            x = 0
        end
    end

    local x, y = 0, 0
    local i = 0
    for k, v in pairs(generated_resources) do
        local v2 = math.abs(v)
        local neigh = {
            left = i == 0 and -1 or k-1,
            right = k+1,
            top = k-wide,
            bottom = k+wide
        }
        local customResource, customResourceColor = hook.Run("SpaceEvo_GenerateResources", v, World[k], neigh, world)
        local typ = customResource or v >= .5 and "Oil" or v < .3 and v > .2 and World[k].typ == "Hills" and "Forest" or v <= .05 and v >= -.05 and World[k].typ != "Sand" and (World[k].typ == "Snow" and math.random(100)<25) and "Food" or
           v <= -.40 and "Iron" or "Nothing"

        Resources[k] = {
            x = x,
            y = y,
            color = customResource and customResourceColor or typ == "Oil" and Color(15,0,50) or typ == "Forest" and Color(0,200,0) or
                typ == "Iron" and Color(255,50,0) or typ == "Food" and Color(255,255,0) or color_black,

            v = v,
            slf = k,
            typ = typ,

            neighbors = neigh
        }

        i = i + 1
        x = x + quadSize
        if i >= wide then
            i = 0
            y = y + quadSize
            x = 0
        end
    end

    if dontopen then return SpaceEvo.Planets[world] end
    local function DrawMeshQuad(verts, basePos, size, col, add1, add2, add3, add4)
        add1, add2, add3, add4 = Vector(0,0,add1), Vector(0,0,add2), Vector(0,0,add3), Vector(0,0,add4)
        table.insert(verts, {pos = basePos + Vector(quadSize) + add1, u = 0, v = 0, color = col})
        table.insert(verts, {pos = basePos + add2, u = 0, v = 0, color = col})
        table.insert(verts, {pos = basePos + Vector(quadSize, quadSize) + add3, u = 0, v = 0, color = col})

        table.insert(verts, {pos = basePos + Vector(quadSize, quadSize) + add3, u = 0, v = 0, color = col})
        table.insert(verts, {pos = basePos + add2, u = 0, v = 0, color = col})
        table.insert(verts, {pos = basePos + Vector(0, quadSize) + add4, u = 0, v = 0, color = col})
    end
    local meshes = {}
    for k, v in pairs(World) do
        DrawMeshQuad(verts, basePos+Vector(-v.x, v.y), quadSize, v.color)
        meshes[k] = {Pos = basePos+Vector(-v.x, v.y), Col = v.color, Type = v.typ, Height = v.v, Resouce = Resources[k]}
    end
    local meshes_res = {}
    for k, v in pairs(Resources) do
        DrawMeshQuad(verts_res, basePos+Vector(-v.x, v.y), quadSize, v.color)
        meshes_res[k] = {Pos = basePos+Vector(-v.x, v.y), Col = v.color, Type = v.typ, Height = v.v, World = World[k]}
    end
    SpaceEvo.GeneratedWorld = {
        World = table.Copy(World),
        WorldResources = table.Copy(Resources),
        WorldMesh = table.Copy(meshes),
        WorldResourcesMesh = table.Copy(meshes_res),
        WorldName = world,
    }

    obj:BuildFromTriangles( verts )
    ojb_res:BuildFromTriangles( verts_res )
    SpaceEvo.CurrentWorld = world

    hook.Run("SpaceEvo_PlanetFinishedGeneration", world)

    return SpaceEvo.Planets[world]
end
SpaceEvo.Removing = false
if file.Exists("space_evolution/active_planet.dat", "DATA") then
    SpaceEvo:GenerateWorld(file.Read("space_evolution/active_planet.dat", "DATA"))
else
    file.Write("space_evolution/active_planet.dat", "earth")
    SpaceEvo:GenerateWorld("earth")
end
if SpaceEvo.CurrentWorld == "earth" and #SpaceEvo.Planets[SpaceEvo.CurrentWorld].Humans < 2 then
    SpaceEvo.Humans:Create(table.Random(SpaceEvo.Humans.FirstName["Male"]), table.Random(SpaceEvo.Humans.LastName), "Male", SpaceEvo.CurrentWorld)
    SpaceEvo.Humans:Create(table.Random(SpaceEvo.Humans.FirstName["Female"]), table.Random(SpaceEvo.Humans.LastName), "Female", SpaceEvo.CurrentWorld)
end

hook.Add( "PostDrawTranslucentRenderables", "DrawQuad_Example", function()
    if not IsValid(obj) then return end
    render.SetColorMaterial()

    hook.Run("PreWorldPaint")
    obj:Draw()
    hook.Run("PostWorldPaint")
    if not GetConVar("sv_cheats"):GetBool() then return end
    hook.Run("PreXrayPaint")
    ojb_res:Draw()
    hook.Run("PostXrayPaint")
end)
local z = 0
SpaceEvo.CamToZ = -11500
hook.Add( "CalcView", "MyCalcView", function(ply, pos, ang, fov)
    z = Lerp(FrameTime(), z, SpaceEvo.CamToZ)

    local view = {}
    view.origin = Vector(0,0,z)
    SpaceEvo.CamPos = view.origin
    view.angles = Angle(90)
    view.drawviewer = true
    view.fov = 90

    return view
end)
