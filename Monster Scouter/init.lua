local core_mainmenu = require("core_mainmenu")
local lib_helpers = require("solylib.helpers")
local lib_characters = require("solylib.characters")
local lib_unitxt = require("solylib.unitxt")
local lib_items = require("solylib.items.items")
local lib_menu = require("solylib.menu")
local lib_items_list = require("solylib.items.items_list")
local lib_items_cfg = require("solylib.items.items_configuration")
local cfg = require("Monster Scouter.configuration")
local cfgMonsters = require("Monster Scouter.monsters")
local optionsLoaded, options = pcall(require, "Monster Scouter.options")
local drop_charts = {
    ["Normal"] = require("Monster Scouter/Drops.normal"),
    ["Hard"] = require("Monster Scouter/Drops.hard"),
    ["Very Hard"] = require("Monster Scouter/Drops.very-hard"),
    ["Ultimate"] = require("Monster Scouter/Drops.ultimate")
  }

local optionsFileName = "addons/Monster Scouter/options.lua"
local ConfigurationWindow

local origPackagePath = package.path
package.path = './addons/Monster Scouter/lua-xtype/src/?.lua;' .. package.path
package.path = './addons/Monster Scouter/MGL/src/?.lua;' .. package.path
local xtype = require("xtype")
local mgl = require("MGL")
package.path = origPackagePath

local function SetDefaultValue(Table, Index, Value)
    Table[Index] = lib_helpers.NotNilOrDefault(Table[Index], Value)
end
local function SetValue(Table, Index, Value)
    Table[Index] = Value
end
local function convertColorToInt(Alpha,R,G,B)
    return bit.lshift(Alpha, 24) +
    bit.lshift(R, 16) +
    bit.lshift(G, 8) +
    bit.lshift(B, 0)
end

local function LoadOptions()
    if options == nil or type(options) ~= "table" then
        options = {}
    end
    -- If options loaded, make sure we have all those we need
    SetDefaultValue( options, "configurationEnableWindow", true )
    SetDefaultValue( options, "enable", true )
    SetDefaultValue( options, "ignoreMeseta", false )
    SetDefaultValue( options, "maxNumTrackers", 100 )
    SetDefaultValue( options, "numTrackers", 25 )
    SetDefaultValue( options, "updateThrottle", 0 )
    SetDefaultValue( options, "server", 1 )

    SetDefaultValue( options, "customScreenResEnabled", false )
    SetDefaultValue( options, "customScreenResX", lib_helpers.GetResolutionWidth() )
    SetDefaultValue( options, "customScreenResY", lib_helpers.GetResolutionHeight() )
    SetDefaultValue( options, "customFoVEnabled", false )
    SetDefaultValue( options, "customFoV0", 86 )
    SetDefaultValue( options, "customFoV1", 87 )
    SetDefaultValue( options, "customFoV2", 88 )
    SetDefaultValue( options, "customFoV3", 89 )
    SetDefaultValue( options, "customFoV4", 90 )

    local section = "tracker"
    if options[section] == nil or type(options[section]) ~= "table" then
        options[section] = {}
    end
    SetDefaultValue( options[section], "EnableWindow", true )
    SetDefaultValue( options[section], "HideWhenMenu", true )
    SetDefaultValue( options[section], "HideWhenSymbolChat", true )
    SetDefaultValue( options[section], "HideWhenMenuUnavailable", true )
    SetDefaultValue( options[section], "changed", true )
    SetDefaultValue( options[section], "boxOffsetX", 0 )
    SetDefaultValue( options[section], "boxOffsetY", 0 )
    SetDefaultValue( options[section], "boxSizeX", 40 )
    SetDefaultValue( options[section], "boxSizeY", 40 )
    SetDefaultValue( options[section], "W", 271 )
    SetDefaultValue( options[section], "H", 91 )
    SetDefaultValue( options[section], "AlwaysAutoResize", true )
    SetDefaultValue( options[section], "customFontScaleEnabled", false )
    SetDefaultValue( options[section], "fontScale", 1.4 )
    SetDefaultValue( options[section], "TransparentWindow", false )
    SetDefaultValue( options[section], "customTrackerColorEnable", true )
    SetDefaultValue( options[section], "customTrackerColorMarker", 0xFFFF9900 )
    SetDefaultValue( options[section], "customTrackerColorBackground", 0x00CCCCCC )
    SetDefaultValue( options[section], "customTrackerColorWindow", 0x00000000 )

    SetDefaultValue( options[section], "showNameOverride", false )
    SetDefaultValue( options[section], "showNameClosestItemsNum", 5 )
    SetDefaultValue( options[section], "showNameClosestDist", 130 )
    SetDefaultValue( options[section], "clampItemView", true )
    SetDefaultValue( options[section], "ignoreItemMaxDist", 420 )
    
    for id,monster in pairs(cfgMonsters.m) do
        if monster.cate then
            if options[section][id] == nil then
                options[section][id] = {}
            end
            SetDefaultValue( options[section][id], "enabled", true )
            SetDefaultValue( options[section][id], "showName", true )
            SetDefaultValue( options[section][id], "showHealthBar", true )
            --SetDefaultValue( options[section][id], "showDamage", true )
            options[section][id]["showDamage"] = false
            SetDefaultValue( options[section][id], "showWeakness", true )
            SetDefaultValue( options[section][id], "showStatusEffects", true )
            SetDefaultValue( options[section][id], "showRares", true )
        end
    end

end
LoadOptions()

-- Append server specific items
lib_items_list.AddServerItems(options.server)

local optionsStringBuilder = ""
local function BuildOptionsString(table, depth)
    local tabSpacing = 4
    local maxDepth = 5
    
    if not depth or depth == nil then
        depth = 0
    end
    local spaces = string.rep(" ", tabSpacing + tabSpacing * depth)
    
    --begin statement
    if depth < 1 then
        optionsStringBuilder = "return\n{\n"
    end
    --iterate over table
    for key, value in pairs(table) do
        
        local ktype = type(key)
        if ktype == "number" then
            -- check is float/double
            if key % 1 == 0 then
                key = string.format("[%i]", key)
            else
                key = string.format("[%f]", key)
            end
            
        end

        local vtype = type(value)
        if vtype == "string" then
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = \"%s\",\n", key, tostring(value))
        
        elseif vtype == "number" then
            -- check is float/double
            if value % 1 == 0 then
                optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %i,\n", key, tostring(value))
            else
                optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %f,\n", key, tostring(value))
            end
            
        elseif vtype == "boolean" or value == nil then
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = %s,\n", key, tostring(value))
            
        --recurse
        elseif vtype == "table" then
            if maxDepth > 5 then
                return
            end
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("%s = {\n", key)
            BuildOptionsString(value, depth + 1)
            optionsStringBuilder = optionsStringBuilder .. spaces .. string.format("},\n", key)
        end
        
    end
    --finalize statement
    if depth < 1 then
        optionsStringBuilder = optionsStringBuilder .. "}\n"
    end
end

local function SaveOptions(options)
    local file = io.open(optionsFileName, "w")
    if file ~= nil then
        BuildOptionsString(options)
        
        io.output(file)
        io.write(optionsStringBuilder)
        io.close(file)
    end
end

local playerSelfAddr = nil
local playerSelfCoords = nil
local playerSelfDirs = nil
local playerSelfNormDir = nil
local pCoord = nil
local cameraCoords = nil
local cameraDirs = nil
local cameraNormDirVec2 = nil
local cameraNormDirVec3 = nil
local item_graph_data = {}
local toolLookupTable = {}
local invToolLookupTable = {}
local resolutionWidth = {}
local resolutionHeight = {}
local trackerBox = {}
local screenFov = nil
local aspectRatio = nil
local eyeWorld    = nil
local eyeDir      = nil
local determinantScr = nil
local cameraZoom = nil
local lastCameraZoom = nil
local trackerWindowLookup = {}

-- camera related memory addresses
local _CameraPosX      = 0x00A48780
local _CameraPosY      = 0x00A48784
local _CameraPosZ      = 0x00A48788
local _CameraDirX      = 0x00A4878C
local _CameraDirY      = 0x00A48790
local _CameraDirZ      = 0x00A48794
local _CameraZoomLevel = 0x009ACEDC


-- section id list 
local section = {
    "Bluefull",
    "Greenill",
    "Oran",
    "Pinkal",
    "Purplenum",
    "Redria",
    "Skyly",
    "Viridia",
    "Yellowboze",
    "Whitill"
}
-- section id colors
local section_color = {
    ["Bluefull"]    = 0xFF0088F4,
    ["Greenill"]    = 0xFF74FB40,
    ["Oran"]        = 0xFFFFAA00,
    ["Pinkal"]      = 0xFFFF3898,
    ["Purplenum"]   = 0xFFA020F0,
    ["Redria"]      = 0xFFFF2031,
    ["Skyly"]       = 0xFF00DDF4,
    ["Viridia"]     = 0xFF00AE6C,
    ["Yellowboze"]  = 0xFFEAF718,
    ["Whitill"]     = 0xFFFFFFFF
}

local episodes = {
    [0] = "EPISODE 1",
    [1] = "EPISODE 2",
    [2] = "EPISODE 4"
}

-- episode order
local episode = {
    "EPISODE 1",
    "EPISODE 1 Boxes",
    "EPISODE 2",
    "EPISODE 2 Boxes",
    "EPISODE 4",
    "EPISODE 4 Boxes",
    "QUEST"
}

-- difficulty list
local difficulty = {
    [1] = "Normal",
    [2] = "Hard",
    [3] = "Very Hard",
    [4] = "Ultimate"
}

-- memory addresses
local _SideMessage = pso.base_address + 0x006AECC8
local _PlayerArray = 0x00A94254
local _PlayerIndex = 0x00A9C4F4
local _PlayerCount = 0x00AAE168
local _Difficulty = 0x00A9CD68
local _Ultimate
local _Episode = 0xAAFDB8
local _Episode2 = 0x00A9B1C8

local party = { }
local cacheSide = false

local _ID = 0x1C
local _Room = 0x28
local _Room2 = 0x2E
local _PosX = 0x38
local _PosY = 0x3C
local _PosZ = 0x40

local _targetPointerOffset = 0x18
local _targetOffset = 0x108C

local _EntityCount = 0x00AAE164
local _EntityArray = 0

local _MonsterUnitxtID = 0x378
local _MonsterHP = 0x334
local _MonsterHPMax = 0x2BC
local _MonsterEvp = 0x2D0
local _MonsterAtp = 0x2CC
local _MonsterDfp = 0x2D2
local _MonsterMst = 0x2BE
local _MonsterAta = 0x2D4
local _MonsterLck = 0x2D6
local _MonsterEfr = 0x2F6
local _MonsterEth = 0x2F8
local _MonsterEic = 0x2FA
local _MonsterEdk = 0x2FC
local _MonsterElt = 0x2FE

local _MonsterBpPtr = 0x2B4
local _MonsterBpAtp = 0x0
local _MonsterBpMst = 0x2
local _MonsterBpEvp = 0x4
local _MonsterBpHp  = 0x6
local _MonsterBpDfp = 0x8
local _MonsterBpAta = 0xA
local _MonsterBpLck = 0xC
local _MonsterBpEsp = 0xE
local _MonsterBpExp = 0x1C

-- Special addresses for De Rol Le
local _BPDeRolLeData = 0x00A43CC8
local _MonsterDeRolLeHP = 0x6B4
local _MonsterDeRolLeHPMax = 0x6B0
local _MonsterDeRolLeSkullHP = 0x6B8
local _MonsterDeRolLeSkullHPMax = 0x20
local _MonsterDeRolLeShellHP = 0x39C
local _MonsterDeRolLeShellHPMax = 0x1C

-- Special addresses for Barba Ray
local _BPBarbaRayData = 0x00A43CC8
local _MonsterBarbaRayHP = 0x704
local _MonsterBarbaRayHPMax = 0x700
local _MonsterBarbaRaySkullHP = 0x708
local _MonsterBarbaRaySkullHPMax = 0x20
local _MonsterBarbaRayShellHP = 0x7AC
local _MonsterBarbaRayShellHPMax = 0x1C

-- Special address for Ephinea
local _ephineaMonsterArrayPointer = 0x00B5F800
local _ephineaMonsterHPScale = 0x00B5F804

-- read side message from memory buffer
local function get_side_text()
    local ptr = pso.read_u32(_SideMessage)
    if ptr ~= 0 then
        local text = pso.read_wstr(ptr + 0x14, 0xFF)
        return text
    end
    return ""
end

-- extract party dar, rare boosts, section id, and grab episode and difficulty
local function parse_side_message(text)
    local data = { }

    -- logic in identifying dar and rare boost
    local dropIndex = string.find(text, "Drop")
    local rareIndex = string.find(text, "Rare")
    local dropRareFormated  = string.find(text, "Drop/Rare")
    local idIndex = string.find(text, "ID")

    local dropStr,rareStr
    if dropRareFormated then
        local dropRareStr = string.sub(text, dropRareFormated,-1)
        for k,v in string.gmatch(dropRareStr, ":(.*)") do
            dropRareStr = k
            break
        end
        local i = 1
        for k,v in string.gmatch(dropRareStr, "(%d+)") do
            if i == 1 then
                dropStr = k
            elseif i == 2 then
                rareStr = k
            else
                break
            end
            i = i + 1
        end
    else
        dropStr = string.sub(text, dropIndex, rareIndex-1)
        rareStr = string.sub(text, rareIndex, -1)
    end

    local idStr = string.sub(text, idIndex+2, dropIndex-1)

    -- other data
    local _difficulty = pso.read_u32(_Difficulty)
    local _episode = pso.read_u32(_Episode2)
    
    data.dar = tonumber(string.match(dropStr, "%d+"))
    data.rare = tonumber(string.match(rareStr, "%d+"))
    data.id = string.match(idStr,"%a+")
    data.difficulty = difficulty[_difficulty + 1]
    data.episode = episodes[_episode]

    if data.dar == nil then
        data.dar = -1
    end
    if data.rare == nil then
        data.rare = -1
    end
    if data.id == nil then
        data.id = -1
    end
    if data.difficulty == nil then
        data.difficulty = -1
    end
    if data.episode == nil then
        data.episode = -1
    end
    
    return data
end

local function refresh_side_text()
    local side = get_side_text()
    if string.find(side, "ID") and string.find(side, "Drop") and string.find(side, "Rare") then
        party = parse_side_message(side)
        cacheSide = true
    end
end

local function CopyMonster(monster)
    local copy = {}

    copy.address  = monster.address
    copy.index    = monster.index
    copy.id       = monster.id
    copy.room     = monster.room
    copy.posX     = monster.posX
    copy.posY     = monster.posY
    copy.posZ     = monster.posZ
    copy.unitxtID = monster.unitxtID
    copy.HP       = monster.HP
    copy.HPMax    = monster.HPMax
    copy.HP2      = monster.HP2
    copy.HP2Max   = monster.HP2Max
    copy.name     = monster.name
    copy.attribute  = monster.attribute
    copy.isBoss   = monster.isBoss
    copy.Exp      = monster.Exp
    copy.color    = monster.color
    copy.display  = monster.display
    copy.Efr	  = monster.Efr
    copy.Eth	  = monster.Eth
    copy.Eic	  = monster.Eic
    copy.Elt	  = monster.Elt
    copy.Edk	  = monster.Edk

    return copy
end

local function GetMonsterDataDeRolLe(monster)
    local maxDataPtr = pso.read_u32(_BPDeRolLeData)
    local skullMaxHP = 0
    local shellMaxHP = 0
    local newName = monster.name
    local ephineaMonsters = pso.read_u32(_ephineaMonsterArrayPointer)
    local ephineaHPScale = 1.0
    
    if maxDataPtr ~= 0 then
        skullMaxHP = pso.read_u32(maxDataPtr + _MonsterDeRolLeSkullHPMax)
        shellMaxHP = pso.read_u32(maxDataPtr + _MonsterDeRolLeShellHPMax)
        if ephineaMonsters ~= 0 then
            ephineaHPScale = pso.read_f64(_ephineaMonsterHPScale)
            skullMaxHP = math.floor(skullMaxHP * ephineaHPScale)
            shellMaxHP = math.floor(shellMaxHP * ephineaHPScale)
        end
    end

    if monster.index == 0 then
        monster.HP = pso.read_u32(monster.address + _MonsterDeRolLeHP)
        monster.HPMax = pso.read_u32(monster.address + _MonsterDeRolLeHPMax)

        monster.HP2 = pso.read_u32(monster.address + _MonsterDeRolLeSkullHP)
        monster.HP2Max = skullMaxHP
    else
        monster.HP = pso.read_u32(monster.address + _MonsterDeRolLeShellHP)
        monster.HPMax = shellMaxHP
        monster.name = monster.name .. " Shell"
    end

    return monster
end

local function GetMonsterDataBarbaRay(monster)
    local maxDataPtr = pso.read_u32(_BPBarbaRayData)
    local skullMaxHP = 0
    local shellMaxHP = 0
    local newName = monster.name
    local ephineaMonsters = pso.read_u32(_ephineaMonsterArrayPointer)
    local ephineaHPScale = 1.0

    if maxDataPtr ~= 0 then
        skullMaxHP = pso.read_u32(maxDataPtr + _MonsterBarbaRaySkullHPMax)
        shellMaxHP = pso.read_u32(maxDataPtr + _MonsterBarbaRayShellHPMax)
        if ephineaMonsters ~= 0 then
            ephineaHPScale = pso.read_f64(_ephineaMonsterHPScale)
            skullMaxHP = math.floor(skullMaxHP * ephineaHPScale)
            shellMaxHP = math.floor(shellMaxHP * ephineaHPScale)
        end
    end

    if monster.index == 0 then
        monster.HP = pso.read_u32(monster.address + _MonsterBarbaRayHP)
        monster.HPMax = pso.read_u32(monster.address + _MonsterBarbaRayHPMax)

        monster.HP2 = pso.read_u32(monster.address + _MonsterBarbaRaySkullHP)
        monster.HP2Max = skullMaxHP
    else
        monster.HP = pso.read_u32(monster.address + _MonsterBarbaRayShellHP)
        monster.HPMax = shellMaxHP
        monster.name = monster.name .. " Shell"
    end

    return monster
end

local function GetMonsterData(monster)
    local ephineaMonsters = pso.read_u32(_ephineaMonsterArrayPointer)
    
    monster.id = pso.read_u16(monster.address + _ID)
    monster.unitxtID = pso.read_u32(monster.address + _MonsterUnitxtID)

    monster.HP = 0
    monster.HPMax = 0

    monster.isBoss = 0
    
    if monster.name == "Unknown" then
        return monster
    end
    
    if ephineaMonsters ~= 0 then
        monster.HPMax = pso.read_u32(ephineaMonsters + (monster.id * 32))
        monster.HP = pso.read_u32(ephineaMonsters + (monster.id * 32) + 0x04)
    else
        monster.HP = pso.read_u16(monster.address + _MonsterHP)
        monster.HPMax = pso.read_u16(monster.address + _MonsterHPMax)
    end	
    
    local bpPointer = pso.read_u32(monster.address + _MonsterBpPtr)
    
    monster.Atp = pso.read_u16(monster.address + _MonsterAtp) or pso.read_u16(bpPointer + _MonsterBpAtp)
    monster.Dfp = pso.read_u16(monster.address + _MonsterDfp) or pso.read_u16(bpPointer + _MonsterBpDfp)
    monster.Evp = pso.read_u16(monster.address + _MonsterEvp) or pso.read_u16(bpPointer + _MonsterBpEvp)
    monster.Mst = pso.read_u16(monster.address + _MonsterMst) or pso.read_u16(bpPointer + _MonsterBpMst)
    monster.Ata = pso.read_u16(monster.address + _MonsterAta) or pso.read_u16(bpPointer + _MonsterBpAta)
    monster.Lck = pso.read_u16(monster.address + _MonsterLck) or pso.read_u16(bpPointer + _MonsterBpLck)
    
    if bpPointer ~= 0 then
        monster.Esp = pso.read_u16(bpPointer + _MonsterBpEsp)

        if  pso.read_u32(_Episode) == 1 then
            monster.Exp = pso.read_u16(bpPointer + _MonsterBpExp) * 1.3
        else
            monster.Exp = pso.read_u16(bpPointer + _MonsterBpExp)
        end
    else
        monster.Esp = 0
        monster.Exp = 0
    end

    monster.Efr = pso.read_u16(monster.address + _MonsterEfr)
    monster.Eth = pso.read_u16(monster.address + _MonsterEth)
    monster.Eic = pso.read_u16(monster.address + _MonsterEic)
    monster.Edk = pso.read_u16(monster.address + _MonsterEdk)
    monster.Elt = pso.read_u16(monster.address + _MonsterElt)

    monster.room = pso.read_u16(monster.address + _Room)
    monster.posX = pso.read_f32(monster.address + _PosX)
    monster.posY = pso.read_f32(monster.address + _PosY)
    monster.posZ = pso.read_f32(monster.address + _PosZ)
        
    -- Other stuff
    monster.name = lib_unitxt.GetMonsterName(monster.unitxtID, _Ultimate)
    monster.attribute = pso.read_u16(monster.address + 0x2e8)
    if monster.unitxtID == 44 or monster.unitxtID == 45 or monster.unitxtID == 46 or monster.unitxtID == 47 or monster.unitxtID == 73 or monster.unitxtID == 76 or monster.unitxtID == 77 or monster.unitxtID == 78 or monster.unitxtID == 106 then
        monster.isBoss = 1
    end
    monster.color = 0xFFFFFFFF
    monster.display = true

    if monster.unitxtID == 45 then
        monster = GetMonsterDataDeRolLe(monster)
    end
    if monster.unitxtID == 73 then
        monster = GetMonsterDataBarbaRay(monster)
    end

    return monster
end

local function GetTargetMonster()
    local difficulty = pso.read_u32(_Difficulty)
    _Ultimate = difficulty == 3

    local pIndex = pso.read_u32(_PlayerIndex)
    local pAddr = pso.read_u32(_PlayerArray + 4 * pIndex)

    -- If we don't have address (maybe warping or something)
    if pAddr == 0 then
        return nil
    end

    local targetID = -1
    local targetPointerOffset = pso.read_u32(pAddr + _targetPointerOffset)
    if targetPointerOffset ~= 0 then
        targetID = pso.read_i16(targetPointerOffset + _targetOffset)
    end

    if targetID == -1 then
        return nil
    end

    local _targetPointerOffset = 0x18
    local _targetOffset = 0x108C

    local playerCount = pso.read_u32(_PlayerCount)
    local entityCount = pso.read_u32(_EntityCount)

    local i = 0
    while i < entityCount do
        local monster = {}

        monster.address = pso.read_u32(_EntityArray + 4 * (i + playerCount))
        -- If we got a pointer, then read from it
        if monster.address ~= 0 then
            monster.id = pso.read_i16(monster.address + _ID)

            if monster.id == targetID then
                monster = GetMonsterData(monster)
                return monster
            end
        end
        i = i + 1
    end

    return nil
end

local function computePixelCoordinates(pWorld, eyeWorld, eyeDir, determinant)

    local pRaster = mgl.vec2(0)
    local vis = -1

    local vDir = pWorld - eyeWorld
    vDir = mgl.normalize(vDir)
    local fdp = mgl.dot( eyeDir, vDir )

    --fdp must be nonzero ( in other words, vDir must not be perpendicular to angCamRot:Forward() )
    --or we will get a divide by zero error when calculating vProj below.
    if fdp == 0 then
        return pRaster,-1
    end

    --Using linear projection, project this vector onto the plane of the slice
    local ddfp = determinant/fdp
    local vProj = mgl.vec3( ddfp,ddfp,ddfp ) * vDir
    --get the up component from the forward vector assuming world yaxis (vertical axis 0,+1,0) is up
    --https://stackoverflow.com/questions/1171849/finding-quaternion-representing-the-rotation-from-one-vector-to-another/1171995#1171995
    local eyeRight = mgl.cross( eyeDir, mgl.vec3(0,1,0) )
    local eyeLeft  = mgl.cross( eyeRight, eyeDir )

    if fdp > 0.0000001 then
        vis = 1
    end
    pRaster.x =   mgl.dot(eyeRight,vProj) --0.5 * iScreenW + mgl.dot(eyeRight,vProj)
    pRaster.y = - mgl.dot(eyeLeft,vProj) --0.5 * iScreenH - mgl.dot(eyeLeft,vProj)

    return pRaster, vis
end

local function GetMonsterList(section)
    local monsterList = {}

    local difficulty = pso.read_u32(_Difficulty)
    _Ultimate = difficulty == 3

    local pIndex = pso.read_u32(_PlayerIndex)
    local pAddr = pso.read_u32(_PlayerArray + 4 * pIndex)

    -- If we don't have address (maybe warping or something)
    -- return the empty list
    if pAddr == 0 then
        return monsterList
    end

    -- Get player position
    local playerRoom1 = pso.read_u16(pAddr + _Room)
    local playerRoom2 = pso.read_u16(pAddr + _Room2)

    local playerCount = pso.read_u32(_PlayerCount)
    local entityCount = pso.read_u32(_EntityCount)

    local i = 0
    while i < entityCount do
        local monster = {}

        monster.display = true
        monster.index = i
        monster.address = pso.read_u32(_EntityArray + 4 * (i + playerCount))

        -- If we got a pointer, then read from it
        if monster.address ~= 0 then
            monster = GetMonsterData(monster)

            if cfgMonsters.m[monster.unitxtID] ~= nil 
                and options[section][monster.unitxtID] ~= nil
                and options[section][monster.unitxtID].enabled
            then
                monster.color = cfgMonsters.m[monster.unitxtID].color
                monster.display = cfgMonsters.m[monster.unitxtID].display
                monster.width = cfgMonsters.m[monster.unitxtID].width
                monster.height = cfgMonsters.m[monster.unitxtID].height

                -- Calculate the distance between it and the player
                -- And hide the monster if its too far
                monster.pos3 = mgl.vec3(monster.posX, monster.posY, monster.posZ)
                monster.curPlayerDistance = mgl.length(monster.pos3 - pCoord)
                if monster.curPlayerDistance == nil then
                    monster.curPlayerDistance = math.maxinteger
                end

                if cfgMonsters.maxDistance ~= 0 and tDist > cfgMonsters.maxDistance then
                    monster.display = false
                end

                -- Determine whether the player is in the same room as the monster
                if options.showCurrentRoomOnly and playerRoom1 ~= monster.room and playerRoom2 ~= monster.room then
                    monster.display = false
                end

                -- Do not show monsters that have been killed
                if monster.HP <= 0 then
                    monster.display = false
                end

                -- Get the monster's 3d position to a 2d pixel position
                if monster.display ~= false then
                    local aboveHeadPos = mgl.vec3(0, monster.height, 0)
                    local pRaster,visible = computePixelCoordinates(monster.pos3 + aboveHeadPos, eyeWorld, eyeDir, determinantScr)
                    monster.screenX = pRaster.x
                    monster.screenY = pRaster.y
                    monster.screenVisDirection = visible
                else
                    monster.screenShow = false
                    monster.screenX = nil
                    monster.screenY = nil
                    monster.screenVisDirection = -1
                end

                if options.clampMonsterView then
                    if monster.screenVisDirection < 0 then
                        local tempVec2 = mgl.normalize( mgl.vec2(-monster.screenX,-monster.screenY) ) * resolutionHeight.clampRescale
                        monster.screenX = tempVec2.x
                        monster.screenY = tempVec2.y
                    else
                        if not (monster.screenX > -resolutionHeight.clampRescale and monster.screenX < resolutionHeight.clampRescale and
                                monster.screenY > -resolutionWidth.clampRescale  and monster.screenY < resolutionWidth.clampRescale)
                        then
                            local tempVec2 = mgl.normalize( mgl.vec2(monster.screenX, monster.screenY) ) * resolutionHeight.clampRescale
                            monster.screenX = tempVec2.x
                            monster.screenY = tempVec2.y
                        end
                    end
                    monster.screenShow = true
                else
                    if monster.screenVisDirection < 0 then
                        monster.screenShow = false
                    else
                        monster.screenShow = true
                    end
                end

                -- If we have De Rol Le, make a copy for the body HP
                if monster.unitxtID == 45 and monster.index == 0 then
                    local head = CopyMonster(monster)
                    table.insert(monsterList, head)

                    monster.index = monster.index + 1
                    monster.HP = monster.HP2
                    monster.HPMax = monster.HP2Max
                    monster.name = monster.name .. " Skull"
                elseif monster.unitxtID == 73 and monster.index == 0 then
                    local head = CopyMonster(monster)
                    table.insert(monsterList, head)

                    monster.index = monster.index + 1
                    monster.HP = monster.HP2
                    monster.HPMax = monster.HP2Max
                    monster.name = monster.name .. " Skull"
                end

                if monster.screenShow then
                    table.insert(monsterList, monster)
                end
            end
        end
        i = i + 1
    end

    return monsterList
end

local function GetPlayerCoordinates(player)
    local x = 0
    local y = 0
    local z = 0
    if player ~= 0 then
        x = pso.read_f32(player + 0x38)
        y = pso.read_f32(player + 0x3C)
        z = pso.read_f32(player + 0x40)
    end

    return
    {
        x = x,
        y = y,
        z = z,
    }
end

local function GetPlayerDirection(player)
    local x = 0
    local z = 0
    if player ~= 0 then
        x = pso.read_f32(player + 0x410)
        z = pso.read_f32(player + 0x418)
    end
    
    return
    {
        x = x,
        z = z,
    }
end

local function getCameraZoom()
    return pso.read_u32(_CameraZoomLevel)
end
local function getCameraCoordinates()
    return
    {
        x = pso.read_f32(_CameraPosX),
        y = pso.read_f32(_CameraPosY),
        z = pso.read_f32(_CameraPosZ),
    }
end
local function getCameraDirection()
    return
    {
        x = pso.read_f32(_CameraDirX), -- -1 to 1 in x direction (west to east)
        y = pso.read_f32(_CameraDirY), -- pitch
        z = pso.read_f32(_CameraDirZ), -- -1 to 1 in z direction (north to south)
    }
end

local function clampVal(clamp, min, max)
    return clamp < min and min or clamp > max and max or clamp
end

local function Norm(Val,Min,Max)
    return (Val - Min)/(Max - Min)
end
local function Lerp(Norm,Min,Max)
    return (Max - Min) * Norm + Min
end

local function shiftHexColor(color)
    return
    {
        bit.band(bit.rshift(color, 24), 0xFF),
        bit.band(bit.rshift(color, 16), 0xFF),
        bit.band(bit.rshift(color, 8), 0xFF),
        bit.band(color, 0xFF)
    }
end


local update_delay = options.updateThrottle
local current_time = 0
local last_monster_time = 0
local cache_monster = nil
local monsterCount = 0
local lastnumTrackers = options.numTrackers
local firstLoad = true
local last_inventory_index = -1
local last_inventory_time = 0
local lastFontScale = options["tracker"].fontScale
local cache_inventory = nil
local invItemCount = 0
local windowTextSizes = {}

local function sortByDistanceP(a,b)
    return a.curPlayerDistance < b.curPlayerDistance
end

local function UpdateMonsterCache(section)
    if last_monster_time + update_delay < current_time or cache_monster == nil then
        cache_monster = GetMonsterList(section)
         table.sort(cache_monster, sortByDistanceP)
        -- reassign a tracker window to its monster
        local trackerNum = 1
        local prevTrackerWindowLookup = trackerWindowLookup
        trackerWindowLookup = {}
        local cache_monster_notracker = {}
        local usedWindowNameIdLookup = {}
        local windowNameIdCurIdx = 1
        local function nextWindowNameId()
            for i=windowNameIdCurIdx, options.numTrackers, 1 do
                if not usedWindowNameIdLookup[i] then
                    windowNameIdCurIdx = 1 + i
                    return i
                end
                windowNameIdCurIdx = i
            end
        end
        for i=1, #cache_monster, 1 do
            if trackerNum > options.numTrackers then break end
            local monster = cache_monster[i]
            local windowNameId = prevTrackerWindowLookup[monster.id]
            if windowNameId then
                usedWindowNameIdLookup[windowNameId] = true
                trackerWindowLookup[monster.id] = windowNameId
                monster.windowNameId = windowNameId
                trackerNum = trackerNum + 1
            else
                table.insert(cache_monster_notracker, monster)
            end
        end
        -- assign a tracker window to an monster
        for i=1, #cache_monster_notracker, 1 do
            if trackerNum > options.numTrackers then break end
            local monster = cache_monster_notracker[i]
            local windowNameId = nextWindowNameId()
            if windowNameId then
                trackerWindowLookup[monster.id] = windowNameId
                monster.windowNameId = windowNameId
                trackerNum = trackerNum + 1
            else
                break -- no more trackers
            end
        end
        last_monster_time = current_time
    end
end

local function UpdateInventoryCache()
    local index = lib_items.Me

    if last_inventory_time + update_delay < current_time or last_inventory_index ~= index or cache_inventory == nil then
        cache_inventory = lib_items.GetInventory(index)
        last_inventory_index = index
        last_inventory_time = current_time
    end
end
local function PrintWText(wText)
    for i=1,table.getn(wText),1 do
        local clr = wText[i][2]
        if i ~= 1 then imgui.SameLine(0, 0) end
        if clr then
            imgui.TextColored(clr[2], clr[3], clr[4], clr[1], wText[i][1])
        else
            imgui.Text(wText[i][1])
        end
    end
end

local function getUnWText(wText)
    local str = ""
    for i=1,table.getn(wText),1 do
        str = str .. wText[i][1]
    end
    return str
end

local function getWText(wText,Default)
    if wText then
        return wText
    else
        return { {Default, nil} }
    end
end

local function PresentBoxTracker(item,section,curCount)
    local textC = {{"",nil}}


    local windowW,windowH = imgui.GetWindowSize()
    local padding     = 6
    local sizeX       = trackerBox.sizeX - padding
    local sizeY       = trackerBox.sizeY
    local windowWP    = windowW - padding

    -- if should show string "name" above item
    -- if options[section].showNameOverride then
    --     if curCount <= options[section].showNameClosestItemsNum then
    --         if options[section].showNameClosestDist <= 0 then
    --             textC = getWText(item.wName,item.name)
    --         elseif item.curPlayerDistance <= options[section].showNameClosestDist then
    --             textC = getWText(item.wName,item.name)
    --         end
    --     end
    -- else
    --     if curCount <= options[section].showNameClosestItemsNum then
    --         if options[section].showNameClosestDist <= 0 then
    --             textC = getWText(item.wName,item.name)
    --         else
    --             if item.curPlayerDistance <= options[section].showNameClosestDist and not item.screenShouldNotShow then
    --                 textC = getWText(item.wName,item.name)
    --             elseif cateTabl.showName and not item.screenShouldNotShow then
    --                 textC = getWText(item.wName,item.name)
    --             end
    --         end
    --     elseif cateTabl.showName and not item.screenShouldNotShow then
    --         textC = getWText(item.wName,item.name)
    --     end
    -- end
    textC = getWText(item.wName,item.name)

    local textW = imgui.CalcTextSize(getUnWText(textC)) -- get text width as simple string
    imgui.SetCursorPosX( (windowW - textW) * 0.5 ) -- center text
    PrintWText(textC)
    
    local cursorPosTY = imgui.GetCursorPosY() -- Don't change lines, need cursor pos After imgui.Text()
    local cursorPosY = clampVal( windowH * 0.5 - sizeY*0.5 + cursorPosTY*0.5, cursorPosTY, windowH )

    sizeX = clampVal( sizeX, 0,  windowWP - 2 )
    sizeY = clampVal( sizeY, 0,  windowH - cursorPosTY )

    --if cateTabl.showBox and cateTabl.enabled and not item.screenShouldNotShow then
        -- if cateTabl.useCustomColor then
        --     TrackerColor = shiftHexColor(cateTabl.customBorderColor)
        -- else
        --     TrackerColor = shiftHexColor(options[section].customTrackerColorMarker)
        -- end

        --imgui.PushStyleColor("Border", TrackerColor[2]/255, TrackerColor[3]/255, TrackerColor[4]/255, TrackerColor[1]/255)
        
        imgui.PushStyleColor("ChildWindowBg",0, 0, 0, 0)
        local borderSize = clampVal(5, 1, math.floor(sizeX*0.5) - 2)
        borderSize       = clampVal(borderSize,          1, math.floor(sizeY*0.5) - 2)
        for border=1, borderSize-1, 1 do
            imgui.SetCursorPosX( windowW*0.5 - sizeX*0.5 + border +1 )
            imgui.SetCursorPosY( cursorPosY + border - 1 )
            imgui.BeginChild( "itembox##" .. border, sizeX - border*2 - 2, sizeY - border*2 - 2, true, {"NoInputs"} )
            imgui.EndChild()
        end
        imgui.PopStyleColor()
        
        local border = borderSize
        imgui.SetCursorPosX( windowW*0.5 - sizeX*0.5 + border +1 )
        imgui.SetCursorPosY( cursorPosY + border - 1 )
        imgui.BeginChild( "itembox##" .. border, sizeX - border*2 - 2, sizeY - border*2 - 2, true, {"NoInputs"} )
        imgui.EndChild()
        --imgui.PopStyleColor()
    --end
end
local function PresentTargetMonster(monster, section)
    if monster ~= nil then
        local playerAddr = lib_characters.GetSelf()
        if playerAddr == 0 then
            return
        end
        
        local moptions = options[section][monster.unitxtID]
		
        local mHP = monster.HP
        local mHPMax = monster.HPMax
		
		local difficulty = pso.read_u32(_Difficulty)

		local PposX = pso.read_f32(playerAddr + _PosX)
		local PposZ = pso.read_f32(playerAddr + _PosZ)

        local atkTech = lib_characters.GetPlayerTechniqueStatus(monster.address, 0)
        local defTech = lib_characters.GetPlayerTechniqueStatus(monster.address, 1)
		
		local zalure = lib_characters.GetPlayerTechniqueLevel(playerAddr, lib_characters.Techniques.Zalure)

        local frozen = lib_characters.GetPlayerFrozenStatus(monster.address)
        local confused = lib_characters.GetPlayerConfusedStatus(monster.address)
        local paralyzed = lib_characters.GetPlayerParalyzedStatus(monster.address)
		local shocked = lib_characters.GetPlayerShockedStatus(monster.address)
		
		local myMaxTP = lib_characters.GetPlayerMaxTP(playerAddr)
		local myMaxAtp = lib_characters.GetPlayerMaxATP(playerAddr,0)
		local myMinAtp = lib_characters.GetPlayerMinATP(playerAddr,0)
		local myAta = lib_characters.GetPlayerATA(playerAddr)
		local myLck = lib_characters.GetPlayerLCK(playerAddr)
		
		local inventory = lib_items.GetInventory(lib_items.Me)
        local itemCount = table.getn(inventory.items)
		
		local NAstat = 0
		local ABstat = 0
		local MAstat = 0
		local DAstat = 0
		local weapon_group = 0
		local pmt_data = 0
		local pmt_weapon_animations = 0
		local weapon_animation_type = 0
		local ataPenalty = 0
		local EqSmartlink = 0
		local MDistance = 0
		local weapSpecial = ""
		local weapName = ""
		local weapEquipped = 0
		local numTargets = 0
		local numHits = 0
        local androidBoost = 0
		local specRedux = 1
		local specDMG = -1
		local specAilment = 0
		local specDraw = 0
		local weapHex = 0
		local v50xHellBoost = 1
        local v50xStatusBoost = 1
		local ailRedux = 1
		local specPower = pso.read_u16(playerAddr + 0x118)
		
		
		for i=1,itemCount,1 do
            local item = inventory.items[i]
            if item.equipped and item.data[1] == 0x00 then
				if not item.weapon.isSRank then
					NAstat = item.weapon.stats[2]/100
					ABstat = item.weapon.stats[3]/100
					MAstat = item.weapon.stats[4]/100
					DAstat = item.weapon.stats[5]/100
				end
				weapEquipped = item.weapon.special
				weapSpecial = lib_unitxt.GetSpecialName(weapEquipped)
				weapHex = item.data[2]
				weapName = item.name
				weapon_group = pso.read_u8(item.address + 0xf3)
				pmt_data = pso.read_u32(0xA8DC94)
				pmt_weapon_animations = pso.read_u32(pmt_data + 0x14)
				weapon_animation_type = pso.read_u8(pmt_weapon_animations + weapon_group)
				if weapon_animation_type == 5 or weapon_animation_type == 6 or weapon_animation_type == 7 or weapon_animation_type == 8 or weapon_animation_type == 9 or weapon_animation_type == 18 then
					ataPenalty = 1
				end
			end
			if item.equipped and item.name == "Smartlink" then
				EqSmartlink = 1
			end
			if item.equipped and item.data[1] == 0x01 and item.data[2] == 0x03 then
                -- V501
                if item.data[3] == 0x4A then
                    v50xHellBoost = 1.5
                    v50xStatusBoost = 1.5
                -- V502
                elseif item.data[3] == 0x4B then
                    v50xHellBoost = 2.0
                    v50xStatusBoost = 1.5
                end
            end
		end
		
		if monster.attribute == 1 then
			myMaxAtp = lib_characters.GetPlayerMaxATP(playerAddr,NAstat)
			myMinAtp = lib_characters.GetPlayerMinATP(playerAddr,NAstat)
		elseif monster.attribute == 2 then
			myMaxAtp = lib_characters.GetPlayerMaxATP(playerAddr,ABstat)
			myMinAtp = lib_characters.GetPlayerMinATP(playerAddr,ABstat)
		elseif monster.attribute == 4 then
			myMaxAtp = lib_characters.GetPlayerMaxATP(playerAddr,MAstat)
			myMinAtp = lib_characters.GetPlayerMinATP(playerAddr,MAstat)
		elseif monster.attribute == 8 then
			myMaxAtp = lib_characters.GetPlayerMaxATP(playerAddr,DAstat)
			myMinAtp = lib_characters.GetPlayerMinATP(playerAddr,DAstat)
		end
		
		local myMaxDamage = ((myMaxAtp - monster.Dfp)/5)*.9
		local myMinDamage = ((myMinAtp - monster.Dfp)/5)*.9
		
		if defTech.type == 0 then
		
		else
			myMaxDamage = ((myMaxAtp - (monster.Dfp*(1-((((zalure-1)*1.3)+10)/100))))/5)*.9
			myMinDamage = ((myMinAtp - (monster.Dfp*(1-((((zalure-1)*1.3)+10)/100))))/5)*.9
		end
		
		if myMinDamage < 1 then
			myMinDamage = 0
		end
		
		if myMaxDamage < 1 then
			myMaxDamage = 0
		end
		
		if (string.sub(lib_unitxt.GetClassName(lib_characters.GetPlayerClass(playerAddr)),1,2) == "FO" or string.sub(lib_unitxt.GetClassName(lib_characters.GetPlayerClass(playerAddr)),1,2) == "HU") and EqSmartlink == 0 and ataPenalty == 1 then
			MDistance = (math.sqrt(((monster.posX-PposX)^2)+((monster.posZ-PposZ)^2)))*0.33
		end
		
		if lib_characters.GetPlayerIsCast(playerAddr) == true and difficulty == 3 then
            androidBoost = 30
        end
		
		if (0x1 < weapHex) then
			if (weapHex < 0x5) then
				specRedux = 0.50
			elseif (weapHex == 0x5) or (7 < weapHex and (weapHex < 0xA)) then
				specRedux = 0.33
			end
		end
		
		if difficulty == 3 then
			ailRedux = 2.5
		else
			ailRedux = 6.67
		end
		
        local curX = imgui.GetCursorPosX()
		if moptions.showName then
            if moptions.showWeakness then
                if (monster.Efr <= monster.Eth) and (monster.Efr <= monster.Eic) then
                    lib_helpers.TextC(true, 0xFFFF6600, monster.name)
                elseif (monster.Eth <= monster.Efr) and (monster.Eth <= monster.Eic) then
                    lib_helpers.TextC(true, 0xFFFFFF00, monster.name)
                elseif (monster.Eic <= monster.Efr) and (monster.Eic <= monster.Eth) then
                    lib_helpers.TextC(true, 0xFF00FFFF, monster.name)
                else
                    lib_helpers.TextC(true, monster.color, monster.name)
                end
            else
                lib_helpers.TextC(true, monster.color, monster.name)
            end
		end
		
		-- Show J/Z status and Frozen, Confuse, or Paralyzed status
        if moptions.showStatusEffects then
            if atkTech.type == 0 then
                lib_helpers.TextC(true, 0, "    ")
            else
                lib_helpers.TextC(true, 0xFFFF2031, atkTech.name .. atkTech.level .. string.rep(" ", 2 - #tostring(atkTech.level)) .. " ")
            end

            if defTech.type == 0 then
                lib_helpers.TextC(false, 0, "    ")
            else
                lib_helpers.TextC(false, 0xFF0088F4, defTech.name .. defTech.level .. string.rep(" ", 2 - #tostring(defTech.level)) .. " ")
            end

            if frozen then
                lib_helpers.TextC(false, 0xFF00FFFF, "F ")
            elseif confused then
                lib_helpers.TextC(false, 0xFFFF00FF, "C ")
            elseif shocked then
                lib_helpers.TextC(false, 0xFFFFFF00, "S ")
            else
                lib_helpers.TextC(false, 0, "  ")
            end
            if paralyzed then
                lib_helpers.TextC(false, 0xFFFF4000, "P ")
            end
        end

		imgui.NextColumn()

		-- Calculate all 9 types of attack combinations
		local normAtk1_Acc = math.max(math.min((myAta * 1.0 * 1.0 ) - (monster.Evp * 0.2) - MDistance,100),0)
		local hardAtk1_Acc = math.max(math.min((myAta * 0.7 * 1.0 ) - (monster.Evp * 0.2) - MDistance,100),0)
		local specAtk1_Acc = math.max(math.min((myAta * 0.5 * 1.0 ) - (monster.Evp * 0.2) - MDistance,100),0)
		local normAtk2_Acc = math.max(math.min((myAta * 1.0 * 1.3 ) - (monster.Evp * 0.2) - MDistance,100),0)
		local hardAtk2_Acc = math.max(math.min((myAta * 0.7 * 1.3 ) - (monster.Evp * 0.2) - MDistance,100),0)
		local specAtk2_Acc = math.max(math.min((myAta * 0.5 * 1.3 ) - (monster.Evp * 0.2) - MDistance,100),0)
		local normAtk3_Acc = math.max(math.min((myAta * 1.0 * 1.69) - (monster.Evp * 0.2) - MDistance,100),0)
		local hardAtk3_Acc = math.max(math.min((myAta * 0.7 * 1.69) - (monster.Evp * 0.2) - MDistance,100),0)
		local specAtk3_Acc = math.max(math.min((myAta * 0.5 * 1.69) - (monster.Evp * 0.2) - MDistance,100),0)
		
		if weapSpecial == "Heat" or weapSpecial == "Fire" or weapSpecial == "Flame" or weapSpecial == "Burning" then
			specDMG = (((lib_characters.GetPlayerLevel(playerAddr)-1)+((specPower+1)*20))*(100-(monster.Efr))*0.01)
			specAilment = 100
		elseif weapSpecial == "Ice" or weapSpecial == "Frost" or weapSpecial == "Freeze" or weapSpecial == "Blizzard" then
			specAilment = math.min((((specPower+androidBoost)-monster.Esp)*specRedux),40)*v50xStatusBoost
		elseif weapSpecial == "Shock" or weapSpecial == "Thunder" or weapSpecial == "Storm" or weapSpecial == "Tempest" then
			specDMG = (((lib_characters.GetPlayerLevel(playerAddr)-1)+((specPower+1)*20))*(100-(monster.Eth))*0.01)
			specAilment = 100
		elseif weapSpecial == "Bind" or weapSpecial == "Hold" or weapSpecial == "Seize" or weapSpecial == "Arrest" then
			specAilment = ((specPower+androidBoost)-monster.Esp)*specRedux*v50xStatusBoost
		elseif weapSpecial == "Panic" or weapSpecial == "Riot" or weapSpecial == "Havoc" or weapSpecial == "Chaos" then
			specAilment = ((specPower+androidBoost)-monster.Esp)*specRedux*v50xStatusBoost
		elseif (weapSpecial == "Dim" or weapSpecial == "Shadow" or weapSpecial == "Dark" or weapSpecial == "Hell") and monster.isBoss == 0 then
			specAilment = (specPower-monster.Edk)*specRedux*v50xHellBoost
			specDMG = mHP
		elseif weapSpecial == "Draw" or weapSpecial == "Drain" or weapSpecial == "Fill" or weapSpecial == "Gush" then
			specDraw = math.min(((specPower+androidBoost)/100)*mHP,(difficulty+1)*30)*specRedux
			specAilment = 100
		elseif weapSpecial == "Heart" or weapSpecial == "Mind" or weapSpecial == "Soul" or weapSpecial == "Geist" then
			if lib_characters.GetPlayerIsCast(playerAddr) == false then
				specDraw = math.min((specPower/100)*myMaxTP,(difficulty+1)*25)*specRedux
				specAilment = 100
			else
				weapSpecial = "None"
			end
		elseif weapSpecial == "Master's" or weapSpecial == "Lord's" or weapSpecial == "King's" then
			specDraw = math.min(((specPower+androidBoost)/100)*monster.Exp,(difficulty+1)*20)*specRedux
			specAilment = 100
		elseif (weapSpecial == "Devil's" or weapSpecial == "Demon's") and monster.isBoss == 0 then
			specDMG = (mHP*(1-(((specPower+androidBoost)/100))))*specRedux
			specAilment = 50
		elseif weapSpecial == "Charge" or weapSpecial == "Spirit" or weapSpecial == "Berserk" or weapName == "Vjaya" then
			specAilment = 100
		end

		
		if moptions.showHealthBar then
			-- Draw enemy HP bar
            local mHPRatio = mHP/mHPMax
            local NDmgRatio = myMinDamage/mHPMax
            local HDmgRatio = myMinDamage*1.89/mHPMax
            local SDmgRatio
            local bWidth = 220
            local dmgBHeigth = imgui.GetFontSize()/3

            if weapSpecial == "Charge" or weapSpecial == "Spirit" or weapSpecial == "Berserk" then
                if weapName == "Vjaya" then
                    SDmgRatio = myMinDamage*5.67/mHPMax
                else
                    SDmgRatio = myMinDamage*3.33/mHPMax
                end
            elseif specDMG >= 0 then
                SDmgRatio = specDMG/mHPMax
            elseif specDMG < 0 then
                SDmgRatio = myMinDamage*0.56/mHPMax
            end
            
            local curY = imgui.GetCursorPosY()
			lib_helpers.imguiProgressBar(true, mHPRatio, -1, imgui.GetFontSize(), lib_helpers.HPToGreenRedGradient(mHPRatio), nil, mHP)
            imgui.SameLine()
            local endCurX = imgui.GetCursorPosX()
            
            imgui.PushStyleColor("FrameBg", 0, 0, 0, 0)

            local curLen = (endCurX - curX) - 8
            bWidth = curLen
            local xSPos = (curLen)*mHPRatio - curLen * SDmgRatio + 8
            local xSClamp = clampVal(xSPos, 8, bWidth+8)
            imgui.SetCursorPosX(xSClamp)
            imgui.SetCursorPosY(curY - dmgBHeigth)
            lib_helpers.imguiProgressBar(true, 1.0, curLen * SDmgRatio - math.abs(xSPos-xSClamp), dmgBHeigth, lib_items_cfg.weaponSpecial[weapEquipped + 1], nil)

            local xHPos = (curLen)*mHPRatio - curLen * HDmgRatio + 8
            local xHClamp = clampVal(xHPos, 8, bWidth+8)
            imgui.SetCursorPosX(xHClamp)
            imgui.SetCursorPosY(curY - dmgBHeigth)
            lib_helpers.imguiProgressBar(true, 1.0, curLen * HDmgRatio - math.abs(xHPos-xHClamp), dmgBHeigth, 0xFFFFAA00, nil)

            local xNPos = (curLen)*mHPRatio - curLen * NDmgRatio + 8
            local xNClamp = clampVal(xNPos, 8, bWidth+8)
            imgui.SetCursorPosX(xNClamp)
            imgui.SetCursorPosY(curY - dmgBHeigth)
            lib_helpers.imguiProgressBar(true, 1.0, curLen * NDmgRatio - math.abs(xNPos-xNClamp), dmgBHeigth, 0xFF00FF00, nil)  

            imgui.SetCursorPosY(curY+ imgui.GetFontSize())
            
            -- imgui.SetCursorPosX(curX)
            -- imgui.SetCursorPosY(curY)
            --lib_helpers.imguiProgressBar(true, NDmgRatio, bWidth, imgui.GetFontSize(), 0xFF7070f9, nil)

            imgui.PopStyleColor()
		end

		if moptions.showDamage then
			lib_helpers.Text(true, "%i", myMinDamage)
			lib_helpers.Text(false, "-")
			lib_helpers.Text(false, "%i", myMaxDamage)
			lib_helpers.Text(false, " Weak Hit")		
			lib_helpers.Text(true, "%i", (myMinDamage*1.89))
			lib_helpers.Text(false, "-")
			lib_helpers.Text(false, "%i", (myMaxDamage*1.89))
			lib_helpers.Text(false, " Heavy Hit")
		end
	
		
		if weapSpecial ~= "None" then
			if moptions.showDamage then
				if weapSpecial == "Charge" or weapSpecial == "Spirit" or weapSpecial == "Berserk" then
					if weapName == "Vjaya" then
						lib_helpers.Text(true, "%i", (myMinDamage*5.67))
						lib_helpers.Text(false, "-")
						lib_helpers.Text(false, "%i", (myMaxDamage*5.67))
					else
						lib_helpers.Text(true, "%i", (myMinDamage*3.33))
						lib_helpers.Text(false, "-")
						lib_helpers.Text(false, "%i", (myMaxDamage*3.33))
					end
				elseif specDMG >= 0 then
					lib_helpers.TextC(true, lib_items_cfg.weaponSpecial[weapEquipped + 1], "%i", specDMG)
				elseif specDMG < 0 then
					lib_helpers.Text(true, "%i", (myMinDamage*0.56))
					lib_helpers.Text(false, "-")
					lib_helpers.Text(false, "%i", (myMaxDamage*0.56))
				end
				lib_helpers.Text(false, " Special Hit [")
				lib_helpers.TextC(false, lib_items_cfg.weaponSpecial[weapEquipped + 1], lib_unitxt.GetSpecialName(weapEquipped))
				lib_helpers.Text(false, "] ")
				if specAilment > 0 then
						if weapSpecial == "Master's" or weapSpecial == "Lord's" or weapSpecial == "King's" then
							lib_helpers.Text(false, "steal ")
							lib_helpers.TextC(false, lib_items_cfg.weaponSpecial[weapEquipped + 1], "%i", math.max(specDraw,0))
							lib_helpers.Text(false, " EXP")
						elseif (weapSpecial == "Heart" or weapSpecial == "Mind" or weapSpecial == "Soul" or weapSpecial == "Geist") and lib_characters.GetPlayerIsCast(playerAddr) == false then
							lib_helpers.Text(false, "steal ")
							lib_helpers.TextC(false, lib_items_cfg.weaponSpecial[weapEquipped + 1], "%i", math.max(specDraw,0))
							lib_helpers.Text(false, " TP")
						elseif weapSpecial == "Draw" or weapSpecial == "Drain" or weapSpecial == "Fill" or weapSpecial == "Gush" then	
							lib_helpers.Text(false, "steal ")
							lib_helpers.TextC(false, lib_items_cfg.weaponSpecial[weapEquipped + 1], "%i", math.max(specDraw,0))
							lib_helpers.Text(false, " HP")
						elseif (weapSpecial == "Dim" or weapSpecial == "Shadow" or weapSpecial == "Dark" or weapSpecial == "Hell") and monster.isBoss == 0 then	
							lib_helpers.Text(false, "chance to Instant Kill")
						elseif weapSpecial == "Panic" or weapSpecial == "Riot" or weapSpecial == "Havoc" or weapSpecial == "Chaos"  and monster.isBoss == 0 then
							lib_helpers.Text(false, "chance to Confuse")
						elseif weapSpecial == "Bind" or weapSpecial == "Hold" or weapSpecial == "Seize" or weapSpecial == "Arrest" and (monster.attribute == 1 or monster.attribute == 2 or monster.attribute == 8) and monster.isBoss == 0 then	
							lib_helpers.Text(false, "chance to Paralyze")
						elseif weapSpecial == "Shock" or weapSpecial == "Thunder" or weapSpecial == "Storm" or weapSpecial == "Tempest" and monster.attribute == 4 and monster.isBoss == 0 and monster.name ~= "Epsilon" then	
							specAilment = ailRedux*v50xStatusBoost
							lib_helpers.Text(false, "chance to Shock")
						elseif weapSpecial == "Ice" or weapSpecial == "Frost" or weapSpecial == "Freeze" or weapSpecial == "Blizzard" and not (monster.isBoss == 1 or monster.name == "Epsilon" or monster.name == "Zu" or monster.name == "Pazuzu" or monster.name == "Dorphon" or monster.name == "Dorphon Eclair" or monster.name == "Girtablulu" ) then
							lib_helpers.Text(false, "chance to Freeze")
						end
				end
			end
			if moptions.showHit then
				lib_helpers.Text(true, "Spec1: ")
				lib_helpers.TextC(false, lib_items_cfg.weaponSpecial[weapEquipped + 1], "%i%% ", math.min(specAtk1_Acc*(math.max(specAilment,0)/100),100))
				lib_helpers.Text(false, " > Spec2: ")
				lib_helpers.TextC(false, lib_items_cfg.weaponSpecial[weapEquipped + 1], "%i%% ", math.min(specAtk2_Acc*(math.max(specAilment,0)/100),100))
				lib_helpers.Text(false, " > Spec3: ")
				lib_helpers.TextC(false, lib_items_cfg.weaponSpecial[weapEquipped + 1], "%i%% ", math.min(specAtk3_Acc*(math.max(specAilment,0)/100),100))
			end
		end
		
		if moptions.showHit then
			-- Display best first attack
			lib_helpers.Text(true, "[")
			if specAtk1_Acc >= options.targetSpecialThreshold and weapSpecial ~= "None" then
				lib_helpers.TextC(false, 0xFFFF2031, "Spec1: %i%% ", specAtk1_Acc)
			elseif hardAtk1_Acc >= options.targetHardThreshold then
				lib_helpers.TextC(false, 0xFFFFAA00, "Hard1: %i%% ", hardAtk1_Acc)
			elseif normAtk1_Acc > 0 then
				lib_helpers.TextC(false, 0xFF00FF00, "Norm1: %i%% ", normAtk1_Acc)
			else
				lib_helpers.TextC(false, 0xFFBB0000, "Norm1: 0%%")
			end

			-- Display best second attack
			lib_helpers.Text(false, " > ")
			if specAtk2_Acc >= options.targetSpecialThreshold and weapSpecial ~= "None" then
				lib_helpers.TextC(false, 0xFFFF2031, "Spec2: %i%% ", specAtk2_Acc)
			elseif hardAtk2_Acc >= options.targetHardThreshold then
				lib_helpers.TextC(false, 0xFFFFAA00, "Hard2: %i%% ", hardAtk2_Acc)
			elseif normAtk2_Acc > 0 then
				lib_helpers.TextC(false, 0xFF00FF00, "Norm2: %i%% ", normAtk2_Acc)
			else
				lib_helpers.TextC(false, 0xFFBB0000, "Norm2: 0%%")
			end

			-- Display best third attack
			lib_helpers.Text(false, "> ")
			if specAtk3_Acc >= options.targetSpecialThreshold and weapSpecial ~= "None" then
				lib_helpers.TextC(false, 0xFFFF2031, "Spec3: %i%%", specAtk3_Acc)
			elseif hardAtk3_Acc >= options.targetHardThreshold then
				lib_helpers.TextC(false, 0xFFFFAA00, "Hard3: %i%%", hardAtk3_Acc)
			elseif normAtk3_Acc > 0 then
				lib_helpers.TextC(false, 0xFF00FF00, "Norm3: %i%%", normAtk3_Acc)
			else
				lib_helpers.TextC(false, 0xFFBB0000, "Norm3: 0%%")
			end
			lib_helpers.Text(false, "]")
		end
		
		if moptions.showRares then
			if cacheSide then
				local row = drop_charts[party.difficulty][party.episode][party.id]
				for j = 1, #row do
					if string.find(string.lower(row[j].target), string.lower(monster.name), 1, true) then
						lib_helpers.Text(true, "1/")
						lib_helpers.Text(false, "%i", 1/((party.dar*row[j].dar)*(party.rare*row[j].rare))*100000000)
						lib_helpers.Text(false, " ")
						lib_helpers.TextC(false, section_color[party.id], row[j].item)
						break
					end
				end
			else
				lib_helpers.Text(true, "Type /partyinfo to refresh...")
			end
		end
    end
end

local function calcScreenResolutions(section, forced)
    if forced or not resolutionWidth.val or not resolutionHeight.val then
        if options.customScreenResEnabled then
            resolutionWidth.val          = options.customScreenResX
            resolutionHeight.val         = options.customScreenResY
        else
            resolutionWidth.val          = lib_helpers.GetResolutionWidth()
            resolutionHeight.val         = lib_helpers.GetResolutionHeight()
        end
        aspectRatio                      = resolutionWidth.val / resolutionHeight.val
        resolutionWidth.half             = resolutionWidth.val * 0.5
        resolutionHeight.half            = resolutionHeight.val * 0.5
        resolutionWidth.clampRescale     = resolutionWidth.val  * 1
        resolutionHeight.clampRescale    = resolutionHeight.val * 1

        trackerBox.sizeX                 = options[section].boxSizeX
        trackerBox.sizeHalfX             = options[section].boxSizeX * 0.5
        trackerBox.sizeY                 = options[section].boxSizeY
        trackerBox.sizeHalfY             = options[section].boxSizeY * 0.5
        trackerBox.offsetX               = options[section].boxOffsetX
        trackerBox.offsetY               = options[section].boxOffsetY

        resolutionWidth.clampBoxLowest   = -resolutionWidth.half  + trackerBox.sizeHalfX
        resolutionWidth.clampBoxHighest  =  resolutionWidth.half  - trackerBox.sizeHalfX
        resolutionHeight.clampBoxLowest  = -resolutionHeight.half + trackerBox.sizeHalfY + 2
        resolutionHeight.clampBoxHighest =  resolutionHeight.half - trackerBox.sizeHalfY - 2
    end
end
local function calcScreenFoV(section, forced)

    if not aspectRatio or not cameraZoom or not resolutionHeight.val then
        cameraZoom        = getCameraZoom()
        calcScreenResolutions(section, forced)
    end

    if forced or cameraZoom ~= lastCameraZoom or cameraZoom == nil then
        if options.customFoVEnabled then
            if     cameraZoom == 0 then
                screenFov = math.rad( options.customFoV0 )
            elseif cameraZoom == 1 then
                screenFov = math.rad( options.customFoV1 )
            elseif cameraZoom == 2 then
                screenFov = math.rad( options.customFoV2 )
            elseif cameraZoom == 3 then
                screenFov = math.rad( options.customFoV3 )
            elseif cameraZoom == 4 then
                screenFov = math.rad( options.customFoV4 )
            else
                screenFov = 69 -- a good guess
            end
        else
            screenFov = math.rad( 
                math.deg( 
                    2*math.atan(0.56470588 * aspectRatio) -- 0.56470588 is 768/1360
                ) - (cameraZoom-1) * 0.600 - clampVal(cameraZoom,0,1) * 0.300 -- the constant here should work for most to all aspect ratios between 1.25 to 1.77, gud enuff.
            ) 
        end
        determinantScr = aspectRatio * 3 * resolutionHeight.val / ( 6 * math.tan( 0.5 * screenFov ) )
        lastCameraZoom = CameraZoom
    end
end


local function present()
    local section = "tracker"

    -- If the addon has never been used, open the config window
    -- and disable the config window setting
    
    if options.configurationEnableWindow then
        ConfigurationWindow.open = true
        options.configurationEnableWindow = false
    end
    ConfigurationWindow.Update()
    
    if ConfigurationWindow.changed then
        ConfigurationWindow.changed = false
        if options.numTrackers > lastnumTrackers then
            LoadOptions()
            lastnumTrackers = options.numTrackers
        end
        local curFontScale
        if options[section].customFontScaleEnabled then
            curFontScale = options[section].fontScale
        else
            curFontScale = 1.0
        end
        if lastFontScale ~= curFontScale then
            lastFontScale = curFontScale
            windowTextSizes = {}
        end
        calcScreenResolutions(section, true)
        calcScreenFoV(section, true)
        SaveOptions(options)
        -- Update the delay too
        update_delay = options.updateThrottle
    end

    -- Global enable here to let the configuration window work
    if options.enable == false then
        return
    end

    --- Update timer for update throttle
    current_time = pso.get_tick_count()
-- --needed?
-- local myFloor = lib_characters.GetCurrentFloorSelf()
-- --needed?
    cameraZoom        = getCameraZoom()
    calcScreenResolutions(section)
    calcScreenFoV(section)
    playerSelfAddr    = lib_characters.GetSelf()
    playerSelfCoords  = GetPlayerCoordinates(playerSelfAddr)
    playerSelfDirs    = GetPlayerDirection(playerSelfAddr)
    pCoord            = mgl.vec3(playerSelfCoords.x,playerSelfCoords.y,playerSelfCoords.z)
    cameraCoords      = getCameraCoordinates()
    cameraDirs        = getCameraDirection()
    eyeWorld          = mgl.vec3(cameraCoords.x, cameraCoords.y, cameraCoords.z)
    eyeDir            = mgl.vec3(  cameraDirs.x,   cameraDirs.y,   cameraDirs.z)

    if _EntityArray == 0 then
        -- Get the address of the entity array from one of the instructions that references it.
        -- Works on base client and on a client patched with a different array.
        _EntityArray = pso.read_u32(0x7B4BA0 + 2)
    end
    refresh_side_text()

    UpdateMonsterCache(section)
    UpdateInventoryCache()
    monsterCount      = table.getn(cache_monster)
    invItemCount      = table.getn(cache_inventory.items)

    local monsterIdx = 0
    local windowParams = { "NoTitleBar", "NoResize", "NoMove", "NoInputs", "NoSavedSettings" }

    for i=1, options.numTrackers, 1 do
        monsterIdx = monsterIdx + 1
        if monsterIdx > options.numTrackers or monsterIdx > monsterCount or monsterCount < 1 then break end

        if (options[section].EnableWindow == true)
            and (options[section].HideWhenMenu == false or lib_menu.IsMenuOpen() == false)
            and (options[section].HideWhenSymbolChat == false or lib_menu.IsSymbolChatOpen() == false)
            and (options[section].HideWhenMenuUnavailable == false or lib_menu.IsMenuUnavailable() == false)
        then
            if cache_monster[monsterIdx].screenShow then

                if options[section].customTrackerColorEnable == true then
                    local FrameBgColor  = shiftHexColor(options[section].customTrackerColorBackground)
                    local WindowBgColor = shiftHexColor(options[section].customTrackerColorWindow)
                    local TrackerColor  = shiftHexColor(options[section].customTrackerColorMarker)
                    imgui.PushStyleColor("ChildWindowBg", FrameBgColor[2]/255, FrameBgColor[3]/255,  FrameBgColor[4]/255,  FrameBgColor[1]/255)
                    imgui.PushStyleColor("WindowBg",     WindowBgColor[2]/255, WindowBgColor[3]/255, WindowBgColor[4]/255, WindowBgColor[1]/255)
                    imgui.PushStyleColor("Border",        TrackerColor[2]/255, TrackerColor[3]/255,  TrackerColor[4]/255,  TrackerColor[1]/255)
                end

                if options[section].TransparentWindow == true then
                    imgui.PushStyleColor("WindowBg", 0.0, 0.0, 0.0, 0.0)
                end

                local textC = getWText(cache_monster[monsterIdx].wName, cache_monster[monsterIdx].name)
                local textP = getUnWText(textC)
                if options[section].customFontScaleEnabled then -- get text width and height for every item name text
                    local tx, ty
                    if not windowTextSizes[textP] then
                        if imgui.Begin( "##Monster Scouter - FontDummy",
                            nil, { "NoTitleBar", "NoResize", "NoMove", "NoInputs", "NoSavedSettings" } )
                        then
                            imgui.SetWindowFontScale(options[section].fontScale)
                            tx, ty = imgui.CalcTextSize(textP)
                            windowTextSizes[textP] = {
                                x = tx,
                                y = ty,
                            }
                        end
                        imgui.End()
                    end
                else
                    if not windowTextSizes[textP] then
                        tx, ty = imgui.CalcTextSize(textP)
                        windowTextSizes[textP] = {
                            x = tx,
                            y = ty,
                        }
                    end
                end

                local wx, wy
                local tx = windowTextSizes[textP].x
                local ty = windowTextSizes[textP].y
                local tyh = ty * 0.5
                local wPadding = 6
                local wPaddingh = wPadding * 0.5 - 2
                local wPaddingd = wPadding * 2

                if options[section].W < 1 or options[section].AlwaysAutoResize then
                    wx = clampVal(tx, trackerBox.sizeX, tx) + wPadding + 1
                else
                    wx = options[section].W
                end
                if options[section].H < 1 or options[section].AlwaysAutoResize then
                    wy = ty + trackerBox.sizeY + wPaddingd + 4
                else
                    wy = options[section].H
                end

                local sx, sy
                sx = cache_monster[monsterIdx].screenX + wPaddingh
                sy = cache_monster[monsterIdx].screenY - tyh
                if options[section].clampItemView then
                    sx = clampVal(  sx, 
                                    resolutionWidth.clampBoxLowest, resolutionWidth.clampBoxHighest )
                    sy = clampVal(  sy,
                                    resolutionHeight.clampBoxLowest + tyh, resolutionHeight.clampBoxHighest - tyh)
                else

                end

                local ps =  lib_helpers.GetPosBySizeAndAnchor( sx, sy, wx, wy, 5 ) -- 5 is "center" window anchor
                imgui.SetNextWindowPos( ps[1], ps[2], "Always" )
                imgui.SetNextWindowSize( wx, wy, "Always" )
                
                --local windowName = "Monster Scouter - Hud" .. cache_monster[monsterIdx].windowNameId
                imgui.PushStyleVar_2("WindowPadding", 8.0, 1.0)
                local windowName = "Monster Scouter - Hud" .. monsterIdx
                if imgui.Begin( windowName,
                    nil, windowParams )
                then
                    if options[section].customFontScaleEnabled then
                        imgui.SetWindowFontScale(options[section].fontScale)
                    else
                        imgui.SetWindowFontScale(1.0)
                    end
                    PresentTargetMonster(cache_monster[monsterIdx], section)
                    --PresentBoxTracker(cache_monster[monsterIdx],section,monsterIdx)
                end
                imgui.End()
                imgui.PopStyleVar()

                if options[section].customTrackerColorEnable == true then
                    imgui.PopStyleColor()
                    imgui.PopStyleColor()
                    imgui.PopStyleColor()
                end
    
                if options[section].TransparentWindow == true then
                    imgui.PopStyleColor()
                end
    
                options[section].changed = false

            end
        end
        if monsterIdx>=monsterCount then
            break
        end
    end
    firstLoad = false
end

local function init()
    ConfigurationWindow = cfg.ConfigurationWindow(options)

    local function mainMenuButtonHandler()
        ConfigurationWindow.open = not ConfigurationWindow.open
    end

    core_mainmenu.add_button("Monster Scouter", mainMenuButtonHandler)

    return
    {
        name = "Monster Scouter",
        version = "0.0.1",
        author = "X9Z0.M2",
        description = "DBZ-like Scouter for Monsters showing weaknesses, current HP, Drops, and Special Chance over their head",
        present = present,
    }
end

return
{
    __addon =
    {
        init = init
    }
}
