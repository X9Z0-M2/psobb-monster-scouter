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
cfgMonsters.m[-1] = {cate = "Default", segment = "General"}
cfgMonsters.m[-20] = {cate = "Default", segment = "Slime Origin", color = 0xFFFFFFFF, display = true}

local optionsLoaded, options = pcall(require, "Monster Scouter.options")
local optionsFileName = "addons/Monster Scouter/options.lua"

local ConfigurationWindow
local drop_charts

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
    
    -- Initialise options with empty tables
    for id,monster in pairs(cfgMonsters.m) do
        if monster.cate then
            if options[section][id] == nil then
                options[section][id] = {}
            end
        end
    end

    local displayWidgets = {
        "name",
        "se",
        "hp",
        "damage",
        "hit",
        "recommended",
        "rare",
        "resist",
        "probability",
    }
    local function EstablishDisplayWidgets(section, id)
        local shownOptionOrderWasMissing = false
        if options[section][id].shownOptionOrder == nil then
            options[section][id].shownOptionOrder = {}
            shownOptionOrderWasMissing = true
        end
        for i=1, #displayWidgets do
            if options[section][id][displayWidgets[i]] == nil then
                options[section][id][displayWidgets[i]] = {}
            end
            if shownOptionOrderWasMissing then
                options[section][id].shownOptionOrder[i] = i
            end
        end
    end

    -- Slime Origin
    local id = -20
    EstablishDisplayWidgets(section, id)
    SetDefaultValue( options[section][id].name, "show", true )
    SetDefaultValue( options[section][id].name, "colorAsWeakness", false )
    SetDefaultValue( options[section][id].se, "show", false )
    SetDefaultValue( options[section][id].hp, "show", true )
    SetDefaultValue( options[section][id].hp, "type", "bar" )
    SetDefaultValue( options[section][id].damage, "show", false )
    SetDefaultValue( options[section][id].hit, "show", false )
    SetDefaultValue( options[section][id].recommended, "show", false )
    SetDefaultValue( options[section][id].rare, "show", false )
    SetDefaultValue( options[section][id].resist, "show", false )
    SetDefaultValue( options[section][id].probability, "show", false )

    for id,monster in pairs(cfgMonsters.m) do
        if monster.cate then
            SetDefaultValue( options[section][id], "enabled", true )

            EstablishDisplayWidgets(section, id)
            SetDefaultValue( options[section][id].name, "show", true )
            SetDefaultValue( options[section][id].name, "justify", 0 )
            SetDefaultValue( options[section][id].name, "fontScale", 1.0 )
            SetDefaultValue( options[section][id].name, "newLine", true )
            SetDefaultValue( options[section][id].name, "colorAsWeakness", true )
            SetDefaultValue( options[section][id].se, "show", true )
            SetDefaultValue( options[section][id].hp, "show", true )
            SetDefaultValue( options[section][id].hp, "type", "bar" )
            SetDefaultValue( options[section][id].damage, "show", false )
            SetDefaultValue( options[section][id].hit, "show", false )
            SetDefaultValue( options[section][id].recommended, "show", false )
            SetDefaultValue( options[section][id].recommended, "targHeavyThresh", 90 )
            SetDefaultValue( options[section][id].recommended, "targSpecThresh", 90 )
            SetDefaultValue( options[section][id].rare, "show", true )
            SetDefaultValue( options[section][id].resist, "show", false )
            SetDefaultValue( options[section][id].resist, "type", "vbar" )
            SetDefaultValue( options[section][id].probability, "show", false )
            SetDefaultValue( options[section][id].probability, "type", "vbar" )
        end
    end
end
LoadOptions()

local this = {
    first = true,
}

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

local function splitDropChartTargets()
    local dt = {}
    for difficulty, charts in pairs(drop_charts) do
        dt[difficulty] = {}
        for episode, chart in pairs(charts) do
            dt[difficulty][episode] = {}
            for sectionid, section_sub in pairs(chart) do
                dt[difficulty][episode][sectionid] = {}

                for targets, drops in pairs(section_sub) do
                    for target in string.gmatch(targets, "[^/]+") do
                        dt[difficulty][episode][sectionid][target] = drops
                    end
                end

            end
        end
    end
    drop_charts = dt
end


local playerSelfAddr = nil
local playerSelfCoords = nil
local playerSelfDirs = nil
local playerSelfAttackComboStep = nil
local pCoord = nil
local pEquipData = {}
local lData = {}
local pData = {}
local updatePlayerWeaponSpec = {}
local updateMonsterWeaponSpecDmg = {}
local cameraCoords = nil
local cameraDirs = nil
local resolutionWidth = {}
local resolutionHeight = {}
local trackerBox = {}
local trackerWindowPadding = {}
trackerWindowPadding.x = 8.0
trackerWindowPadding.y = 1.0
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
    "BLUEFULL",
    "GREENILL",
    "ORAN",
    "PINKAL",
    "PURPLENUM",
    "REDRIA",
    "SKYLY",
    "VIRIDIA",
    "YELLOWBOZE",
    "WHITILL"
}
-- section id colors
local section_color = {
    ["BLUEFULL"]    = 0xFF0088F4,
    ["GREENILL"]    = 0xFF74FB40,
    ["ORAN"]        = 0xFFFFAA00,
    ["PINKAL"]      = 0xFFFF3898,
    ["PURPLENUM"]   = 0xFFA020F0,
    ["REDRIA"]      = 0xFFFF2031,
    ["SKYLY"]       = 0xFF00DDF4,
    ["VIRIDIA"]     = 0xFF00AE6C,
    ["YELLOWBOZE"]  = 0xFFEAF718,
    ["WHITILL"]     = 0xFFFFFFFF
}

local episodes = {
    [0] = "EPISODE 1",
    [1] = "EPISODE 2",
    [2] = "EPISODE 4"
}

-- episode order
local episode = {
    "EPISODE 1",
    "EPISODE 1 BOXES",
    "EPISODE 2",
    "EPISODE 2 BOXES",
    "EPISODE 4",
    "EPISODE 4 BOXES",
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
local lua_biginteger = 4294967295 -- current compiled interpreter makes a sad panda...

local _ID = 0x1C
local _Room = 0x28
local _Room2 = 0x2E
local _PosX = 0x38
local _PosY = 0x3C
local _PosH = 0x78
local _PosH2 = 0x304
local _PosZ = 0x40

local _targetPointerOffset = 0x18
local _targetOffset = 0x108C

local _EntityCount = 0x00AAE164
local _EntityArrayBasePointer = 0x7B4BA0 + 2
local _EntityArray = 0 -- obtained later from base pointer contents

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

-- Special addresses for Pofuilly/Pouilly Slime
local _MonsterPofuillySlimeOriginEntityPointer = 0x3F8
local _MonsterOriginSlimePointer = 0x3C4

-- Special address for Ephinea
local _ephineaMonsterArrayPointer = 0x00B5F800
local _ephineaMonsterHPScale = 0x00B5F804

-- addresses for enemy state / animation state
local _MonsterTargeting = 0xC4

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
    data.id = string.upper( string.match(idStr,"%a+") )
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
    copy.posH     = monster.posH
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
    
    copy.Atp	  = monster.Atp
    copy.Dfp	  = monster.Dfp
    copy.Evp	  = monster.Evp
    copy.Mst	  = monster.Mst
    copy.Ata	  = monster.Ata
    copy.Lck	  = monster.Lck
    copy.Esp	  = monster.Esp
    copy.Exp	  = monster.Exp
    
    copy.targetingVal	  = monster.targetingVal
    copy.screenX          = monster.screenX
    copy.screenY          = monster.screenY
    copy.screenShow       = monster.screenShow
    copy.curPlayerDistance = monster.curPlayerDistance

    return copy
end

local function GetMonsterDataDeRolLe(monster)
    local maxDataPtr = pso.read_u32(_BPDeRolLeData)
    local skullMaxHP = 0
    local shellMaxHP = 0
    local ephineaMonsters = pso.read_u32(_ephineaMonsterArrayPointer)
    local ephineaHPScale = 1.0

    if maxDataPtr ~= 0 then
        skullMaxHP = pso.read_i32(maxDataPtr + _MonsterDeRolLeSkullHPMax)
        shellMaxHP = pso.read_i32(maxDataPtr + _MonsterDeRolLeShellHPMax)
        if ephineaMonsters ~= 0 then
            ephineaHPScale = pso.read_f64(_ephineaMonsterHPScale)
            skullMaxHP = math.floor(skullMaxHP * ephineaHPScale)
            shellMaxHP = math.floor(shellMaxHP * ephineaHPScale)
        end
    end

    if monster.index == 0 then
        monster.HP = pso.read_i32(monster.address + _MonsterDeRolLeHP)
        monster.HPMax = pso.read_i32(monster.address + _MonsterDeRolLeHPMax)

        monster.HP2 = pso.read_i32(monster.address + _MonsterDeRolLeSkullHP)
        monster.HP2Max = skullMaxHP
    else
        monster.HP = pso.read_i32(monster.address + _MonsterDeRolLeShellHP)
        monster.HPMax = shellMaxHP
        monster.name = monster.name .. " Shell"
    end

    return monster
end

-- The body, skull, and shell segments all have Barba Ray's unitxt ID. The game doesn't load the 
-- animations aka movement BP into a static address like it does for De Rol Le, so we
-- have to differentiate the objects by their class type.
local function GetMonsterDataBarbaRay(monster)
    local animationsBPPtr = 0
    local barbaTypeId = pso.read_u32(monster.address + 0x04)

    local isMainBody = false
    local isSkull = false
    local isShell = false
    if 0xA47AF8 == barbaTypeId then
        -- Main body and Skull (same class type)
        animationsBPPtr = pso.read_u32(monster.address + 0x628)
        isMainBody = true
        isSkull = true
    elseif 0xA47B0C == barbaTypeId then
        -- Shell segment
        local barbaRayParentObj = pso.read_u32(monster.address + 0x14)
        animationsBPPtr = pso.read_u32(barbaRayParentObj + 0x628)
        isShell = true
    end

    local skullMaxHP = 0
    local shellMaxHP = 0
    local ephineaMonsters = pso.read_u32(_ephineaMonsterArrayPointer)
    local ephineaHPScale = 1.0

    if animationsBPPtr ~= 0 then
        skullMaxHP = pso.read_i32(animationsBPPtr + _MonsterBarbaRaySkullHPMax)
        shellMaxHP = pso.read_i32(animationsBPPtr + _MonsterBarbaRayShellHPMax)
        if ephineaMonsters ~= 0 then
            ephineaHPScale = pso.read_f64(_ephineaMonsterHPScale)
            skullMaxHP = math.floor(skullMaxHP * ephineaHPScale)
            shellMaxHP = math.floor(shellMaxHP * ephineaHPScale)
        end
    end

    -- Check against the type ID in case a server modifies the monster set for the floor.
    if isMainBody or isSkull then
        monster.HP = pso.read_i32(monster.address + _MonsterBarbaRayHP)
        monster.HPMax = pso.read_i32(monster.address + _MonsterBarbaRayHPMax)

        monster.HP2 = pso.read_i32(monster.address + _MonsterBarbaRaySkullHP)
        monster.HP2Max = skullMaxHP
    elseif isShell then
        monster.HP = pso.read_i32(monster.address + _MonsterBarbaRayShellHP)
        monster.HPMax = shellMaxHP
        monster.name = monster.name .. " Shell"
    end

    return monster
end

local entityAddressLookup = {}

local function GetMonsterData(monster)
    local ephineaMonsters = pso.read_u32(_ephineaMonsterArrayPointer)
    
    monster.id = pso.read_u16(monster.address + _ID)
    monster.unitxtID = pso.read_u32(monster.address + _MonsterUnitxtID)

    monster.HP = 0
    monster.HPMax = 0

    monster.isBoss = 0
    
    -- if monster.name == "Unknown" then
    --     return monster
    -- end
    
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
    monster.posH = pso.read_f32(monster.address + _PosH)
    --print(string.format("%x",monster.address),string.format("%x",monster.address + _PosH2))
    monster.posH2 = pso.read_f32(monster.address + _PosH2)
    monster.posZ = pso.read_f32(monster.address + _PosZ)
        
    -- Other stuff
    monster.name = lib_unitxt.GetMonsterName(monster.unitxtID, _Ultimate)
    monster.attribute = pso.read_u16(monster.address + 0x2e8)
    if monster.unitxtID == 44 or monster.unitxtID == 45 or monster.unitxtID == 46 or monster.unitxtID == 47 or monster.unitxtID == 73 or monster.unitxtID == 76 or monster.unitxtID == 77 or monster.unitxtID == 78 or monster.unitxtID == 106 then
        monster.isBoss = 1
    end
    monster.color = 0xFFFFFFFF
    monster.display = true
    --print(string.format("%x",monster.address),string.format("%x",monster.address + _PosH))
    monster.targetingVal = pso.read_f32(monster.address + _MonsterTargeting)

    if monster.unitxtID == 45 then
        monster = GetMonsterDataDeRolLe(monster)
    elseif monster.unitxtID == 73 then
        monster = GetMonsterDataBarbaRay(monster)
    elseif monster.unitxtID == 0 then
        local mParentAddress = pso.read_u32(monster.address + _MonsterOriginSlimePointer)
        if mParentAddress ~= 0 and entityAddressLookup[mParentAddress] then
            local mParent = entityAddressLookup[mParentAddress]
            local UnitxtID = pso.read_u32(mParent.address + _MonsterUnitxtID)
            if UnitxtID == 19 or UnitxtID == 20 then
                monster.slimeEntityAddress = mParent.address
                monster.isSlimeOrigin = true
                monster.name = "Slime Origin"
                monster.HP = 1
                monster.HPMax = 1
                monster.unitxtID = -20
            end
        end
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

local function isMonsterShowEnabled(monster, section)
    if  cfgMonsters.m[monster.unitxtID] ~= nil
    and options[section][monster.unitxtID] ~= nil
    then
        if options[section][monster.unitxtID].overridden then
            if options[section][monster.unitxtID].enabled then
                return true
            end
        else -- overridden is false
            if options[section][-1].enabled then
                return true
            end
        end
    end
    return false
end


local function GetMonsterList(section)
    local monsterList = {}
    local monsterPreList = {}
    entityAddressLookup = {}

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

    for i=0, entityCount-1, 1 do
        local addr = pso.read_u32(_EntityArray + 4 * (i + playerCount))
        monsterPreList[i] = {
            display = true,
            index = i,
            address = addr,
        }
        if addr ~= 0 then
            entityAddressLookup[addr] = monsterPreList[i]
        end
    end

    local i = 0
    while i < entityCount do
        local monster = monsterPreList[i]

        -- If we got a pointer, then read from it
        if monster.address ~= 0 then
            monster = GetMonsterData(monster)
            
            --print(string.format('%X',monster.address),monster.name, monster.unitxtID, monster.HPMax, monster.HP, monster.posX,monster.posY,monster.posZ)
            -- if monster.name == 'Nano Dragon' then
            --     print(string.format("%x",monster.address))
            -- end

            if isMonsterShowEnabled(monster, section)
            then
                monster.color = cfgMonsters.m[monster.unitxtID].color
                monster.display = cfgMonsters.m[monster.unitxtID].display
                monster.width = cfgMonsters.m[monster.unitxtID].width

                if monster.targetingVal == 20 then -- monster 'idle'
                    monster.height = cfgMonsters.m[monster.unitxtID].height
                elseif cfgMonsters.m[monster.unitxtID].heightTarg ~= nil then
                    monster.height = cfgMonsters.m[monster.unitxtID].heightTarg
                elseif cfgMonsters.m[monster.unitxtID].height ~= nil then
                    monster.height = cfgMonsters.m[monster.unitxtID].height
                else
                    monster.height = 0
                end

                if monster.posH > 0 then
                    monster.posY = monster.posH
                elseif monster.posH2 > 0 then
                    monster.posY = monster.posH2
                end

                -- Calculate the distance between it and the player
                -- And hide the monster if its too far
                monster.pos3 = mgl.vec3(monster.posX, monster.posY, monster.posZ)
                monster.curPlayerDistance = mgl.length(monster.pos3 - pCoord)
                if monster.curPlayerDistance == nil then
                    monster.curPlayerDistance = lua_biginteger
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
                    head.curPlayerDistance = 0
                    if head.screenY then head.screenY = head.screenY - 80 end
                    head.bossCore = true
                    table.insert(monsterList, head)

                    monster.index = monster.index + 1
                    monster.HP = monster.HP2
                    monster.HPMax = monster.HP2Max
                    monster.name = monster.name .. " Skull"
                elseif monster.unitxtID == 73 and monster.index == 0 then
                    local head = CopyMonster(monster)
                    head.curPlayerDistance = 0
                    if head.screenY then head.screenY = head.screenY - 80 end
                    head.bossCore = true
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

local function GetPlayerCurAttackComboStep(player)
    local step = 0
    if player ~= 0 then
        -- 1 = idle
        -- 2 = walking
        -- 4 = running
        -- 5 = 1st shot
        -- 6 = 2st shot
        -- 7 = 3rd shot
        step = pso.read_u8(player + 0x348)
        if step < 5 then
            step = 0
        elseif step == 5 then
            step = 1
        elseif step == 6 then 
            step = 2
        elseif step == 7 then -- end of triple combo
            step = 3
        end

    end
    return step
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
local function ARGBtoHexColor(Clr)
    return  bit.lshift(Clr.a, 24) +
            bit.lshift(Clr.r, 16) +
            bit.lshift(Clr.g, 8) +
            bit.lshift(Clr.b, 0)
end
local function HextoARGBColor(Clr)
    return
    {
        a = bit.band(bit.rshift(Clr, 24), 0xFF),
        r = bit.band(bit.rshift(Clr, 16), 0xFF),
        g = bit.band(bit.rshift(Clr, 8), 0xFF),
        b = bit.band(Clr, 0xFF)
    }
end

local function LerpColor(Norm,Color1,Color2)
	local Ctbl = {}
	Ctbl.a = Lerp(Norm,Color1.a,Color2.a)
	Ctbl.r = Lerp(Norm,Color1.r,Color2.r)
	Ctbl.g = Lerp(Norm,Color1.g,Color2.g)
	Ctbl.b = Lerp(Norm,Color1.b,Color2.b)
    return Ctbl
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
local curFontScale = options["tracker"].customFontScaleEnabled and options["tracker"].fontScale or 1.0
local lastFontScale = curFontScale
local cache_inventory = nil
local invItemCount = 0
local windowTextSizes = {}
local usedWindowNameIdLookup = {}

local function sortByDistanceP(a,b)
    return a.curPlayerDistance < b.curPlayerDistance
end

local function UpdateMonsterCache(section)
    if last_monster_time + update_delay < current_time or cache_monster == nil then
        cache_monster = GetMonsterList(section)
         table.sort(cache_monster, sortByDistanceP)
        -- reassign a tracker window to its monster
        local prevTrackerWindowLookup = trackerWindowLookup
        trackerWindowLookup = {}
        local cache_monster_notracker = {}
        local function nextWindowNameId()
            local idx
            local retries = 0
            repeat
                idx = math.random(0, lua_biginteger)
                retries = retries + 1
            until not usedWindowNameIdLookup[idx] or retries > 10
            usedWindowNameIdLookup[idx] = true
            return idx
        end
        for i=1, #cache_monster, 1 do
            local monster = cache_monster[i]
            local windowNameId = prevTrackerWindowLookup[monster.id]
            if windowNameId then
                trackerWindowLookup[monster.id] = windowNameId
                monster.windowNameId = windowNameId
            else
                table.insert(cache_monster_notracker, monster)
            end
        end
        -- assign a tracker window to an monster
        for i=1, #cache_monster_notracker, 1 do
            local monster = cache_monster_notracker[i]
            local windowNameId = nextWindowNameId()
            if windowNameId then
                trackerWindowLookup[monster.id] = windowNameId
                monster.windowNameId = windowNameId
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

local function genFuncs_UpdatePlayerWeaponSpec()
    updatePlayerWeaponSpec = {}
    local maxWeapSpec = 40
    local nospec_func = function (equipData)
        equipData.isWeapNoSpec = true
        equipData.weapSpecialCategory = 0
    end
    local hpsteal_func = function (equipData)
        equipData.isWeapHPSteal = true
        equipData.weapSpecialCategory = 1
    end
    local tpsteal_func = function (equipData)
        equipData.isWeapTPSteal = true
        equipData.weapSpecialCategory = 2
    end
    local expsteal_func = function (equipData)
        equipData.isWeapEXPSteal = true
        equipData.weapSpecialCategory = 3
    end
    local sacrificial_func = function (equipData)
        equipData.isWeapSacrificial = true
        equipData.weapSpecialCategory = 4
    end
    local frozense_func = function (equipData)
        equipData.isWeapFrozenSE = true
        equipData.weapSpecialCategory = 5
    end
    local paralysisse_func = function (equipData)
        equipData.isWeapParalysisSE = true
        equipData.weapSpecialCategory = 6
    end
    local fireele_func = function (equipData)
        equipData.isWeapFireElement = true
        equipData.weapSpecialCategory = 7
    end
    local shockele_func = function (equipData)
        equipData.isWeapLightningElement = true
        equipData.weapSpecialCategory = 8
    end
    local instantkill_func = function (equipData)
        equipData.isWeapInstantKill = true
        equipData.weapSpecialCategory = 9
    end
    local confusionse_func = function (equipData)
        equipData.isWeapConfusionSE = true
        equipData.weapSpecialCategory = 10
    end
    local hpcut_func = function (equipData)
        equipData.isWeapHPCut = true
        equipData.weapSpecialCategory = 11
    end
    for i=0, maxWeapSpec, 1 do
        if i > 0 and i < 5 then -- Draw, Drain, Fill, Gush - HP Steal
            updatePlayerWeaponSpec[i] = hpsteal_func
        elseif i > 4 and i < 9 then -- Heart, Mind, Soul, Geist - TP Steal
            updatePlayerWeaponSpec[i] = tpsteal_func
        elseif i > 8 and i < 12 then -- Master's, Lord's, King's - EXP Steal
            updatePlayerWeaponSpec[i] = expsteal_func
        elseif i > 11 and i < 15 then -- Charge, Spirit, Berserk - Sacrificial
            updatePlayerWeaponSpec[i] = sacrificial_func
        elseif i > 14 and i < 19 then -- Ice, Frost, Freeze, Blizzard - Frozen Status Effect
            updatePlayerWeaponSpec[i] = frozense_func
        elseif i > 18 and i < 23 then -- Bind, Hold, Seize, Arrest - Paralysis Status Effect
            updatePlayerWeaponSpec[i] = paralysisse_func
        elseif i > 22 and i < 27 then -- Heat, Fire, Flame, Burning - Fire Elemental Damage
            updatePlayerWeaponSpec[i] = fireele_func
        elseif i > 26 and i < 31 then -- Shock, Thunder, Storm, Tempest - Lightning Elemental Damage
            updatePlayerWeaponSpec[i] = shockele_func
        elseif i > 30 and i < 35 then -- Dim, Shadow, Dark, Hell - Instant Kill
            updatePlayerWeaponSpec[i] = instantkill_func
        elseif i > 34 and i < 39 then -- Panic, Riot, Havoc, Chaos - Confusion Status Effect
            updatePlayerWeaponSpec[i] = confusionse_func
        elseif i > 38 and i < 41 then -- Devil's, Demon's - HP Cut
            updatePlayerWeaponSpec[i] = hpcut_func
        else
            updatePlayerWeaponSpec[i] = nospec_func
        end
    end
end

local function UpdatePlayerItemStats()
    local equipData = { -- fill in data to represent no data for items equipped
        NAstat = 0,
        ABstat = 0,
        MAstat = 0,
        DAstat = 0,
        weapSpecial = 0,
        weapSpecialName = "",
        weapSpecialColor = 0xFFFFFFFF,
        weapName = "",
        specRedux = 1,
        ataPenalty = 0,
        EqSmartlink = 0,
        EqVjaya = 0,
        v50xHellBoost = 1,
        v50xStatusBoost = 1,
        weapSpecialCategory = 0,
        isWeapHPSteal = false,
        isWeapTPSteal = false,
        isWeapEXPSteal = false,
        isWeapSacrificial = false,
        isWeapFrozenSE = false,
        isWeapParalysisSE = false,
        isWeapFireElement = false,
        isWeapLightningElement = false,
        isWeapInstantKill = false,
        isWeapConfusionSE = false,
        isWeapHPCut = false,
    }
    for i=1,invItemCount,1 do -- process currently equipped items
        local item = cache_inventory.items[i]
        if item.equipped then
            equipData.item = item
            if item.data[1] == 0x00 then -- is weapon
                if not item.weapon.isSRank then
                    equipData.NAstat = item.weapon.stats[2]/100
                    equipData.ABstat = item.weapon.stats[3]/100
                    equipData.MAstat = item.weapon.stats[4]/100
                    equipData.DAstat = item.weapon.stats[5]/100
                end
                equipData.weapSpecial = item.weapon.special
                equipData.weapSpecialName = lib_unitxt.GetSpecialName(item.weapon.special)
                equipData.weapSpecialColor = lib_items_cfg.weaponSpecial[item.weapon.special + 1]
                equipData.weapName = item.name
                local weapon_group = pso.read_u8(item.address + 0xf3)
                local pmt_data = pso.read_u32(0xA8DC94)
                local pmt_weapon_animations = pso.read_u32(pmt_data + 0x14)
                equipData.weapon_animation_type = pso.read_u8(pmt_weapon_animations + weapon_group)
                if     (equipData.weapon_animation_type > 4  -- 5,6,7,8,9
                    and equipData.weapon_animation_type < 10)
                    or  equipData.weapon_animation_type == 18
                then
                    equipData.ataPenalty = 1
                end
                if (0x1 < item.data[2]) then -- is special reduced weapon
                    if (item.data[2] < 0x5) then
                        equipData.specRedux = 0.50
                    elseif (item.data[2] == 0x5) or (7 < item.data[2] and (item.data[2] < 0xA)) then
                        equipData.specRedux = 0.33
                    end
                end
                if updatePlayerWeaponSpec[item.weapon.special] then -- sanity check
                    updatePlayerWeaponSpec[item.weapon.special](equipData)
                end
            end
            if item.hex == 0x010351 then -- is "Smartlink" unit
                equipData.EqSmartlink = 1
            end
            if item.hex == 0x000406 then -- Vjaya weapon
			    equipData.EqVjaya = 1
            end
            if item.data[1] == 0x01 and item.data[2] == 0x03 then -- is special enhancing unit
                -- V501
                if item.data[3] == 0x4A then
                    equipData.v50xHellBoost = 1.5
                    equipData.v50xStatusBoost = 1.5
                -- V502
                elseif item.data[3] == 0x4B then
                    equipData.v50xHellBoost = 2.0
                    equipData.v50xStatusBoost = 1.5
                end
            end
        end
    end
    pEquipData = equipData
end

local function UpdateLevelData()
    lData = {
        difficulty = pso.read_u32(_Difficulty),
    }
end

local function UpdatePlayerData()
    if playerSelfAddr == 0 then return end

    pData = {
        maxTP  = lib_characters.GetPlayerMaxTP( playerSelfAddr),
        maxAtp = lib_characters.GetPlayerMaxATP(playerSelfAddr,0),
        minAtp = lib_characters.GetPlayerMinATP(playerSelfAddr,0),
        ata    = lib_characters.GetPlayerATA(   playerSelfAddr),
        lck    = lib_characters.GetPlayerLCK(   playerSelfAddr),
        zalure = lib_characters.GetPlayerTechniqueLevel(playerSelfAddr, lib_characters.Techniques.Zalure),
        isCast = lib_characters.GetPlayerIsCast(playerSelfAddr),
        specPower = pso.read_u16(playerSelfAddr + 0x118),
        level  = lib_characters.GetPlayerLevel( playerSelfAddr),
        normalDmgMult       =  0.9,
        heavyDmgMult        = 17/9,
        specialDmgMult      =  5/9,
        sacrificialDmgMult  = 10/3,
        vjayaDmgMult        = 17/3,
        normAtk             = {},
        heavyAtk            = {},
        specAtk             = {}
    }

    for i=1, 3 do
        pData.normAtk[i]  = {}
        pData.heavyAtk[i] = {}
        pData.specAtk[i]  = {}
    end

    pData.normAtk[1].ata  = pData.ata         -- ata * 1.0 * 1.0
    pData.heavyAtk[1].ata = pData.ata * 0.7   -- ata * 0.7 * 1.0
    pData.specAtk[1].ata  = pData.ata * 0.5   -- ata * 0.5 * 1.0
    pData.normAtk[2].ata  = pData.ata * 1.3   -- ata * 1.0 * 1.3
    pData.heavyAtk[2].ata = pData.ata * 0.91  -- ata * 0.7 * 1.3
    pData.specAtk[2].ata  = pData.ata * 0.65  -- ata * 0.5 * 1.3
    pData.normAtk[3].ata  = pData.ata * 1.69  -- ata * 1.0 * 1.69
    pData.heavyAtk[3].ata = pData.ata * 1.183 -- ata * 0.7 * 1.69
    pData.specAtk[3].ata  = pData.ata * 0.845 -- ata * 0.5 * 1.69

    if pData.isCast == true and lData.difficulty == 3 then
        pData.castBoost = 30
    else
        pData.castBoost = 0
    end
    
    if lData.difficulty == 3 then
        pData.ailRedux = 2.5
    else
        pData.ailRedux = 6.67
    end
end

local function genFuncs_UpdateMonsterWeaponSpecDmg()

    local function calcSpecDamage(dmg)
        if dmg.specDMG >= 0 then
            dmg.minSpec = dmg.specDMG
            dmg.maxSpec = dmg.specDMG
        elseif dmg.specDMG < 0 then
            dmg.minSpec = dmg.minBase * pData.specialDmgMult
            dmg.maxSpec = dmg.maxBase * pData.specialDmgMult
        end
    end

    updateMonsterWeaponSpecDmg = {
        [0] = function (monster, dmg) -- no special

        end,
        [1] = function (monster, dmg) -- Draw, Drain, Fill, Gush - HP Steal
            dmg.specDraw = math.min(((pData.specPower+pData.castBoost)/100)*monster.HP,(lData.difficulty+1)*30)*pEquipData.specRedux
            dmg.specAilment = 100
            calcSpecDamage(dmg)
        end,
        [2] = function (monster, dmg) -- Heart, Mind, Soul, Geist - TP Steal
            if pData.isCast == false then
                dmg.specDraw = math.min((pData.specPower/100)*pData.maxTP,(lData.difficulty+1)*25)*pEquipData.specRedux
                dmg.specAilment = 100
            end
            calcSpecDamage(dmg)
        end,
        [3] = function (monster, dmg) -- Master's, Lord's, King's - EXP Steal
            dmg.specDraw = math.min(((pData.specPower+pData.castBoost)/100)*monster.Exp,(lData.difficulty+1)*20)*pEquipData.specRedux
            dmg.specAilment = 100
            calcSpecDamage(dmg)
        end,
        [4] = function (monster, dmg) -- Charge, Spirit, Berserk - Sacrificial
            if pEquipData.EqVjaya == 1 then
                dmg.minSpec = dmg.minBase * pData.vjayaDmgMult
                dmg.maxSpec = dmg.maxBase * pData.vjayaDmgMult
            else
                dmg.minSpec = dmg.minBase * pData.sacrificialDmgMult
                dmg.maxSpec = dmg.maxBase * pData.sacrificialDmgMult
            end
            dmg.specAilment = 100
        end,
        [5] = function (monster, dmg) -- Ice, Frost, Freeze, Blizzard - Frozen Status Effect
            dmg.specAilment = math.min((((pData.specPower+pData.castBoost)-monster.Esp)*pEquipData.specRedux),40)*pEquipData.v50xStatusBoost
            calcSpecDamage(dmg)
        end,
        [6] = function (monster, dmg) -- Bind, Hold, Seize, Arrest - Paralysis Status Effect
            dmg.specAilment = ((pData.specPower+pData.castBoost)-monster.Esp)*pEquipData.specRedux*pEquipData.v50xStatusBoost
            calcSpecDamage(dmg)
        end,
        [7] = function (monster, dmg) -- Heat, Fire, Flame, Burning - Fire Elemental Damage
            dmg.specDMG = (((pData.level-1)/(5-pData.specPower)+((pData.specPower+1)*20))*(100-(monster.Efr))*0.01)
            dmg.specAilment = 100
            calcSpecDamage(dmg)
        end,
        [8] = function (monster, dmg) -- Shock, Thunder, Storm, Tempest - Lightning Elemental Damage
            dmg.specDMG = (((pData.level-1)/(5-pData.specPower)+((pData.specPower+1)*20))*(100-(monster.Eth))*0.01)
            dmg.specAilment = 100
            calcSpecDamage(dmg)
        end,
        [9] = function (monster, dmg) -- Dim, Shadow, Dark, Hell - Instant Kill
            if monster.isBoss == 0 then
                dmg.specAilment = (pData.specPower-monster.Edk)*pEquipData.specRedux*pEquipData.v50xHellBoost
                dmg.specDMG = monster.HP
            end
            calcSpecDamage(dmg)
        end,
        [10] = function (monster, dmg) -- Panic, Riot, Havoc, Chaos - Confusion Status Effect
            dmg.specAilment = ((pData.specPower+pData.castBoost)-monster.Esp)*pEquipData.specRedux*pEquipData.v50xStatusBoost
            calcSpecDamage(dmg)
        end,
        [11] = function (monster, dmg) -- Devil's, Demon's - HP Cut
            if monster.isBoss == 0 then
                dmg.specDMG = (monster.HP*(1-(((pData.specPower+pData.castBoost)/100))))*pEquipData.specRedux
                dmg.specAilment = 50
            end
            calcSpecDamage(dmg)
        end
    }
end


local function PresentTargetMonster(monster, section)
    if monster ~= nil then
        if playerSelfAddr == 0 then return end
        
        local moptions
        if  options[section][monster.unitxtID]
            and options[section][monster.unitxtID].overridden
        then
            moptions = options[section][monster.unitxtID]
        else -- not overridden, so use default
            moptions = options[section][-1]
        end
		
        local mHP = monster.HP
        local mHPMax = monster.HPMax

        local atkTech = lib_characters.GetPlayerTechniqueStatus(monster.address, 0)
        local defTech = lib_characters.GetPlayerTechniqueStatus(monster.address, 1)

        local frozen = lib_characters.GetPlayerFrozenStatus(monster.address)
        local confused = lib_characters.GetPlayerConfusedStatus(monster.address)
        local paralyzed = lib_characters.GetPlayerParalyzedStatus(monster.address)
		local shocked = lib_characters.GetPlayerShockedStatus(monster.address)
		
		local MDistance = 0
        local dmg = {
            specDMG = -1,
            specAilment = 0,
            specDraw = 0,
            normAtt = {},
            heavyAtt = {},
            specAtt = {},
        }
        for i=1, 3 do
            dmg.normAtt[i] = {}
            dmg.heavyAtt[i] = {}
            dmg.specAtt[i] = {}
        end

		if monster.attribute == 1 then
			pData.maxAtp = lib_characters.GetPlayerMaxATP(playerSelfAddr,pEquipData.NAstat)
			pData.minAtp = lib_characters.GetPlayerMinATP(playerSelfAddr,pEquipData.NAstat)
		elseif monster.attribute == 2 then
			pData.maxAtp = lib_characters.GetPlayerMaxATP(playerSelfAddr,pEquipData.ABstat)
			pData.minAtp = lib_characters.GetPlayerMinATP(playerSelfAddr,pEquipData.ABstat)
		elseif monster.attribute == 4 then
			pData.maxAtp = lib_characters.GetPlayerMaxATP(playerSelfAddr,pEquipData.MAstat)
			pData.minAtp = lib_characters.GetPlayerMinATP(playerSelfAddr,pEquipData.MAstat)
		elseif monster.attribute == 8 then
			pData.maxAtp = lib_characters.GetPlayerMaxATP(playerSelfAddr,pEquipData.DAstat)
			pData.minAtp = lib_characters.GetPlayerMinATP(playerSelfAddr,pEquipData.DAstat)
		end
--TODO: obtain min and maxWeapon base ATP and grind in formula
        -- weapons with high base atp will not correctly calculate damage
        -- ... might also be related to weapon attributes...? more testing needed, but damage numbers are still incorrect..
		
		dmg.maxBase = ((pData.maxAtp - monster.Dfp)/5)
		dmg.minBase = ((pData.minAtp - monster.Dfp)/5)
		if defTech.type ~= 0 then -- monster zalured? 
			dmg.maxBase = ((pData.maxAtp - (monster.Dfp*(1-((((pData.zalure-1)*1.3)+10)/100))))/5)
			dmg.minBase = ((pData.minAtp - (monster.Dfp*(1-((((pData.zalure-1)*1.3)+10)/100))))/5)
		end
		
        dmg.minNormal = dmg.minBase * pData.normalDmgMult
        dmg.maxNormal = dmg.maxBase * pData.normalDmgMult
        dmg.minHeavy  = dmg.minBase * pData.heavyDmgMult
        dmg.maxHeavy  = dmg.maxBase * pData.heavyDmgMult
        dmg.minSpec   = 0
		dmg.maxSpec   = 0
		if dmg.minNormal < 1 then dmg.minNormal = 0 end
		if dmg.maxNormal < 1 then dmg.maxNormal = 0 end
		if dmg.minHeavy  < 1 then dmg.minHeavy  = 0 end
		if dmg.maxHeavy  < 1 then dmg.maxHeavy  = 0 end

-- convert from text string analysis to integer
		if (string.sub(lib_unitxt.GetClassName(lib_characters.GetPlayerClass(playerSelfAddr)),1,2) == "FO" or string.sub(lib_unitxt.GetClassName(lib_characters.GetPlayerClass(playerSelfAddr)),1,2) == "HU") and pEquipData.EqSmartlink == 0 and pEquipData.ataPenalty == 1 then
			MDistance = (math.sqrt(((monster.posX-playerSelfCoords.x)^2)+((monster.posZ-playerSelfCoords.z)^2)))*0.33
		end

        updateMonsterWeaponSpecDmg[pEquipData.weapSpecialCategory](monster, dmg)

        -- Calculate all 9 types of attack combinations
        local mEvp = monster.Evp * 0.2 - MDistance
        for i=1, 3 do
            dmg.normAtt[i].acc  = clampVal(pData.normAtk[i].ata  - mEvp, 0, 100)
            dmg.heavyAtt[i].acc = clampVal(pData.heavyAtk[i].ata - mEvp, 0, 100)
            dmg.specAtt[i].acc  = clampVal(pData.specAtk[i].ata  - mEvp, 0, 100)
            dmg.specAtt[i].hit  = clampVal(dmg.specAtt[i].acc    * dmg.specAilment/100, 0, 100)
        end


        local curX = imgui.GetCursorPosX()

        local function showName_Text(order)
            if moptions.name.show then
                --local mName = monster.name .. " " .. monster.id .. " " .. string.format("%X",monster.windowNameId)
                local mName = monster.name
                local mColor, winX, cPosX
                if moptions.name.colorAsWeakness and not monster.bossCore then
                    if (monster.Efr <= monster.Eth) and (monster.Efr <= monster.Eic) then
                        mColor = 0xFFFF6600
                    elseif (monster.Eth <= monster.Efr) and (monster.Eth <= monster.Eic) then
                        mColor = 0xFFFFFF00
                    elseif (monster.Eic <= monster.Efr) and (monster.Eic <= monster.Eth) then
                        mColor = 0xFF00FFFF
                    else
                        mColor = monster.color
                    end
                else
                    mColor = monster.color
                end

                if moptions.name.fontScale ~= 1.0 then
                    imgui.SetWindowFontScale(moptions.name.fontScale)
                end
                
                local cPosY = imgui.GetCursorPosY()
                local winX = imgui.GetWindowSize()
                local tSizex = imgui.CalcTextSize(mName)

                if moptions.name.justify == 0 then
                    if moptions.name.newLine then
                        imgui.SetCursorPosX(trackerWindowPadding.x)
                    else
                        imgui.SameLine(0,0)
                    end
                elseif moptions.name.justify == 1 then
                    local rePosX = winX*0.5 - tSizex*0.5
                    if moptions.name.newLine then
                        local cPosX = imgui.GetCursorPosX()
                        local xPos = clampVal(rePosX, cPosX, winX)
                        imgui.SetCursorPosX(xPos)
                    else
                        if order ~= 1 then
                            imgui.SameLine(0,0)
                        end
                        local cPosX = imgui.GetCursorPosX()
                        local xPos = clampVal(rePosX, cPosX, winX)
                        imgui.SameLine(xPos,0)
                    end
                else
                    local rePosX = winX - tSizex - trackerWindowPadding.x -1 -- subtract 1 extra so "AlwaysAutoResize" will work
                    if moptions.name.newLine then
                        local cPosX = imgui.GetCursorPosX()
                        local xPos = clampVal(rePosX, cPosX, winX)
                        imgui.SetCursorPosX(xPos)
                    else
                        if order ~= 1 then
                            imgui.SameLine(0,0)
                        end
                        local cPosX = imgui.GetCursorPosX()
                        local xPos = clampVal(rePosX, cPosX, winX)
                        imgui.SameLine(xPos,0)
                    end
                end

                lib_helpers.TextC(true, mColor, mName)

                if moptions.name.fontScale ~= 1.0 then
                    imgui.SetWindowFontScale(curFontScale)
                end
                return true
            end
            return false
        end

        -- Show J/Z status and Frozen, Confuse, or Paralyzed status
        local function showStatusEffects_Text(order)
            if moptions.se.show then
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
                return true
            end
            return false
        end

        local function showHealth_Bar(order)
            if moptions.hp.show and moptions.hp.type == "bar" then
                -- Draw enemy HP bar
                local mHPRatio  = clampVal(mHP/mHPMax,0,1)
                local NDmgRatio = clampVal(dmg.minNormal/mHPMax,0,1)
                local HDmgRatio = clampVal(dmg.minHeavy/mHPMax,0,1)
                local SDmgRatio = clampVal(dmg.minSpec/mHPMax,0,1)
                local bWidth -- = 220
                local dmgBHeigth = imgui.GetFontSize()/3
                local wPaddingX = 8

                local curY = order == 1 and imgui.GetCursorPosY() + dmgBHeigth + 6 or imgui.GetCursorPosY() + 6
                imgui.SetCursorPosY(curY)
                lib_helpers.imguiProgressBar(true, mHPRatio, -1, imgui.GetFontSize(), lib_helpers.HPToGreenRedGradient(mHPRatio), nil, mHP)
                --local endCurX = imgui.GetCursorPosX()
                local windowSizeX = imgui.GetWindowSize()
                local endCurX = windowSizeX - 1
                
                imgui.PushStyleColor("FrameBg", 0, 0, 0, 0)


                local curLen = (endCurX - curX) - wPaddingX
                bWidth = curLen
                local xSPos = (curLen)*mHPRatio - curLen * SDmgRatio + wPaddingX
                local xSClamp = clampVal(xSPos, wPaddingX, bWidth+wPaddingX)
                local specDmgBarWidth = math.max(curLen * SDmgRatio - math.abs(xSPos-xSClamp),0)
                
                local xHPos = (curLen)*mHPRatio - curLen * HDmgRatio + wPaddingX
                local xHClamp = clampVal(xHPos, wPaddingX, bWidth+wPaddingX)
                local heavyDmgBarWidth = math.max(curLen * HDmgRatio - math.abs(xHPos-xHClamp),0)

                local xNPos = (curLen)*mHPRatio - curLen * NDmgRatio + wPaddingX
                local xNClamp = clampVal(xNPos, wPaddingX, bWidth+wPaddingX)
                local normalDmgBarWidth = math.max(curLen * NDmgRatio - math.abs(xNPos-xNClamp),0)

                local attSpecHit = dmg.specAtt[1].hit
                local attNormHit = dmg.normAtt[1].acc
                local attHeavyHit = dmg.heavyAtt[1].acc
                if playerSelfAttackComboStep == 1 then 
                    attSpecHit = dmg.specAtt[2].hit
                    attNormHit = dmg.normAtt[2].acc
                    attHeavyHit = dmg.heavyAtt[2].acc
                elseif playerSelfAttackComboStep == 2 then 
                    attSpecHit = dmg.specAtt[3].hit
                    attNormHit = dmg.normAtt[3].acc
                    attHeavyHit = dmg.heavyAtt[3].acc
                elseif playerSelfAttackComboStep == 3 then 
                    attSpecHit = dmg.specAtt[3].hit
                    attNormHit = dmg.normAtt[3].acc
                    attHeavyHit = dmg.heavyAtt[3].acc
                end
                attSpecHit = clampVal(attSpecHit,0,100)/100
                attNormHit = clampVal(attNormHit,0,100)/100
                attHeavyHit = clampVal(attHeavyHit,0,100)/100

                local function showSpecDmgBar()
                    if specDmgBarWidth > 0 then
                        imgui.SetCursorPosX(xSClamp)
                        imgui.SetCursorPosY(curY - dmgBHeigth)
                        --print(dmg.specAtt[1].hit)
                        --print(string.format("%X",pEquipData.weapSpecialColor),HextoARGBColor(pEquipData.weapSpecialColor).a,HextoARGBColor(pEquipData.weapSpecialColor).r,HextoARGBColor(pEquipData.weapSpecialColor).g,HextoARGBColor(pEquipData.weapSpecialColor).b)

                        local specColor = ARGBtoHexColor(
                            LerpColor(
                                attSpecHit,
                                {a=255,r=70,g=70,b=70},
                                --HextoARGBColor(pEquipData.weapSpecialColor),
                                HextoARGBColor(pEquipData.weapSpecialColor)
                                --HextoARGBColor(pEquipData.weapSpecialColor)
                            )
                        )
                        lib_helpers.imguiProgressBar(true, 1.0, specDmgBarWidth, dmgBHeigth, specColor, nil)
                    end
                end
                local function showHeavyDmgBar()
                    if heavyDmgBarWidth > 0 then
                        imgui.SetCursorPosX(xHClamp)
                        imgui.SetCursorPosY(curY - dmgBHeigth)
                        local heavyColor = ARGBtoHexColor(
                            LerpColor(
                                attHeavyHit,
                                {a=255,r=70,g=70,b=70},
                                HextoARGBColor(0xFFFFAA00)
                            )
                        )
                        lib_helpers.imguiProgressBar(true, 1.0, heavyDmgBarWidth, dmgBHeigth, heavyColor, nil)
                    end
                end
                local function showNormalDmgBar()
                    if normalDmgBarWidth > 0 then
                        imgui.SetCursorPosX(xNClamp)
                        imgui.SetCursorPosY(curY - dmgBHeigth)
                        local normalColor = ARGBtoHexColor(
                            LerpColor(
                                attNormHit,
                                {a=255,r=70,g=70,b=70},
                                HextoARGBColor(0xFF00FF00)
                            )
                        )
                        lib_helpers.imguiProgressBar(true, 1.0, normalDmgBarWidth, dmgBHeigth, normalColor, nil)  
                    end
                end

                local damageBars = {
                    {
                        width = specDmgBarWidth,
                        showBar = showSpecDmgBar,
                    },
                    {
                        width = normalDmgBarWidth,
                        showBar = showNormalDmgBar,
                    },
                    {
                        width = heavyDmgBarWidth,
                        showBar = showHeavyDmgBar,
                    },
                }

                local function sortByWidth(a,b)
                    return a.width > b.width
                end
                table.sort(damageBars, sortByWidth)
                for i=1, table.getn(damageBars), 1 do
                    damageBars[i].showBar()
                end
                

                imgui.SetCursorPosY(curY + imgui.GetFontSize())
                
                -- imgui.SetCursorPosX(curX)
                -- imgui.SetCursorPosY(curY)
                --lib_helpers.imguiProgressBar(true, NDmgRatio, bWidth, imgui.GetFontSize(), 0xFF7070f9, nil)

                imgui.PopStyleColor()
                return true
            end
            return false
        end

        local function showDamage_Text(order)
            if moptions.damage.show then
                lib_helpers.Text(true, "%i", dmg.minNormal)
                lib_helpers.Text(false, "-")
                lib_helpers.Text(false, "%i", dmg.maxNormal)
                lib_helpers.Text(false, " Weak Hit")
                lib_helpers.Text(true, "%i", dmg.minHeavy)
                lib_helpers.Text(false, "-")
                lib_helpers.Text(false, "%i", dmg.maxHeavy)
                lib_helpers.Text(false, " Heavy Hit")

                if pEquipData.weapSpecial > 0 then
                    if dmg.minSpec == dmg.maxSpec then
                        lib_helpers.TextC(true, pEquipData.weapSpecialColor, "%i", dmg.specDMG)
                    else
                        lib_helpers.Text(true, "%i", dmg.minSpec)
                        lib_helpers.Text(false, "-")
                        lib_helpers.Text(false, "%i", dmg.maxSpec)
                    end
                    lib_helpers.Text(false, " Special Hit [")
                    lib_helpers.TextC(false, pEquipData.weapSpecialColor, pEquipData.weapSpecialName)
                    lib_helpers.Text(false, "] ")
                    if dmg.specAilment > 0 then
                        if pEquipData.isWeapEXPSteal then
                            lib_helpers.Text(false, "steal ")
                            lib_helpers.TextC(false, pEquipData.weapSpecialColor, "%i", math.max(dmg.specDraw,0))
                            lib_helpers.Text(false, " EXP")
                        elseif pEquipData.isWeapTPSteal and pData.isCast == false then
                            lib_helpers.Text(false, "steal ")
                            lib_helpers.TextC(false, pEquipData.weapSpecialColor, "%i", math.max(dmg.specDraw,0))
                            lib_helpers.Text(false, " TP")
                        elseif pEquipData.isWeapHPSteal then	
                            lib_helpers.Text(false, "steal ")
                            lib_helpers.TextC(false, pEquipData.weapSpecialColor, "%i", math.max(dmg.specDraw,0))
                            lib_helpers.Text(false, " HP")
                        elseif pEquipData.isWeapInstantKill and monster.isBoss == 0 then	
                            lib_helpers.Text(false, "chance to Instant Kill")
                        elseif pEquipData.isWeapConfusionSE and monster.isBoss == 0 then
                            lib_helpers.Text(false, "chance to Confuse")
                        elseif pEquipData.isWeapParalysisSE and (monster.attribute == 1 or monster.attribute == 2 or monster.attribute == 8) and monster.isBoss == 0 then
                            lib_helpers.Text(false, "chance to Paralyze")
                        elseif pEquipData.isWeapLightningElement and monster.attribute == 4 and monster.isBoss == 0 and monster.name ~= "Epsilon" then	
                            dmg.specAilment = pData.ailRedux*pEquipData.v50xStatusBoost
                            lib_helpers.Text(false, "chance to Shock")
                        elseif pEquipData.isWeapFrozenSE and not (monster.isBoss == 1 or monster.name == "Epsilon" or monster.name == "Zu" or monster.name == "Pazuzu" or monster.name == "Dorphon" or monster.name == "Dorphon Eclair" or monster.name == "Girtablulu" ) then
                            lib_helpers.Text(false, "chance to Freeze")
                        end
                    end
                end

                return true
            end
            return false
        end

        local function showHit_Text(order)
            if moptions.hit.show then
                if pEquipData.weapSpecial > 0 then
                    lib_helpers.Text(true, "S1: ")
                    lib_helpers.TextC(false, pEquipData.weapSpecialColor, "%i%% ", dmg.specAtt[1].hit)
                    lib_helpers.Text(false, " > S2: ")
                    lib_helpers.TextC(false, pEquipData.weapSpecialColor, "%i%% ", dmg.specAtt[2].hit)
                    lib_helpers.Text(false, " > S3: ")
                    lib_helpers.TextC(false, pEquipData.weapSpecialColor, "%i%% ", dmg.specAtt[3].hit)
                    return true
                end
            end
            return false
        end

        local function showRecommended_Text(order)
            if moptions.recommended.show then
                -- Display best first attack
                lib_helpers.Text(true, "[")
                if dmg.specAtt[1].acc >= moptions.recommended.targSpecThresh and pEquipData.weapSpecial > 0 then
                    lib_helpers.TextC(false, 0xFFFF2031, "S1: %i%% ", dmg.specAtt[1].acc)
                elseif dmg.heavyAtt[1].acc >= moptions.recommended.targHeavyThresh then
                    lib_helpers.TextC(false, 0xFFFFAA00, "H1: %i%% ", dmg.heavyAtt[1].acc)
                elseif dmg.normAtt[1].acc > 0 then
                    lib_helpers.TextC(false, 0xFF00FF00, "N1: %i%% ", dmg.normAtt[1].acc)
                else
                    lib_helpers.TextC(false, 0xFFBB0000, "N1: 0%%")
                end

                -- Display best second attack
                lib_helpers.Text(false, " > ")
                if dmg.specAtt[2].acc >= moptions.recommended.targSpecThresh and pEquipData.weapSpecial > 0 then
                    lib_helpers.TextC(false, 0xFFFF2031, "S2: %i%% ", dmg.specAtt[2].acc)
                elseif dmg.heavyAtt[2].acc >= moptions.recommended.targHeavyThresh then
                    lib_helpers.TextC(false, 0xFFFFAA00, "H2: %i%% ", dmg.heavyAtt[2].acc)
                elseif dmg.normAtt[2].acc > 0 then
                    lib_helpers.TextC(false, 0xFF00FF00, "N2: %i%% ", dmg.normAtt[2].acc)
                else
                    lib_helpers.TextC(false, 0xFFBB0000, "N2: 0%%")
                end

                -- Display best third attack
                lib_helpers.Text(false, "> ")
                if dmg.specAtt[3].acc >= moptions.recommended.targSpecThresh and pEquipData.weapSpecial > 0 then
                    lib_helpers.TextC(false, 0xFFFF2031, "S3: %i%%", dmg.specAtt[3].acc)
                elseif dmg.heavyAtt[3].acc >= moptions.recommended.targHeavyThresh then
                    lib_helpers.TextC(false, 0xFFFFAA00, "H3: %i%%", dmg.heavyAtt[3].acc)
                elseif dmg.normAtt[3].acc > 0 then
                    lib_helpers.TextC(false, 0xFF00FF00, "N3: %i%%", dmg.normAtt[3].acc)
                else
                    lib_helpers.TextC(false, 0xFFBB0000, "N3: 0%%")
                end
                lib_helpers.Text(false, "]")
                return true
            end
            return false
        end

        local function showRares_Text(order)
            if moptions.rare.show then
                if cacheSide then
                    local mName = string.upper(monster.name)
                    if drop_charts[party.difficulty]
                        and drop_charts[party.difficulty][party.episode]
                        and drop_charts[party.difficulty][party.episode][party.id]
                        and drop_charts[party.difficulty][party.episode][party.id][mName]
                    then
                        local mDrops = drop_charts[party.difficulty][party.episode][party.id][mName]
                        for i,drop in pairs(mDrops) do
                            if drop.item and drop.dar then

                                if drop.rare_d then
                                    -- assume rare_n(umerator) is 1 until another is specified
                                    local rare_n = 1
                                    if drop.rare_n ~= nil then
                                        rare_n = drop.rare_n
                                    end

                                    local rate =1 / (
                                                    -- on ephinea DAR is capped at 100% and is a whole integer percent value such as 54% and not 54.55% for example.
                                                    -- this is calculated and truncated before multiplying against the rare drop probability.

                                                    math.min( 10000, (math.floor((party.dar*drop.dar)/100)*100) )

                                                    -- https://wiki.pioneer2.net/w/Drop_charts#Drop_anything_rate
                                                    -- excerpt about RDR on Ephinea server:  'A monster's RDR cannot be boosted above 7/8 (87.5%).'
                                                   *math.min( 87.50, (party.rare*(rare_n/drop.rare_d)))

                                                ) * 1000000

                                    if rate < 10 then
                                        rate = math.floor(rate * 10) / 10 --chop off after the first decimal place
                                    else
                                        rate = math.floor(rate)           --chop off decimal to improve readability
                                    end

                                    lib_helpers.Text(true, "1/")
                                    lib_helpers.Text(false, "%g", rate)
                                    lib_helpers.Text(false, " ")
                                    lib_helpers.TextC(false, section_color[party.id], drop.item)
                                
                                -- backup method incase `rare_d` doesn't exist, but shouldn't ever fallback here
                                elseif drop.rare then
                                    local rate = 1/(math.min(10000, (math.floor((party.dar*drop.dar)/100)*100))
                                                  *(math.min(8750, (party.rare*drop.rare))))*100000000

                                    if rate < 10 then
                                        rate = math.floor(rate * 10) / 10
                                    else
                                        rate = math.floor(rate)
                                    end

                                    lib_helpers.Text(true, "1/")
                                    lib_helpers.Text(false, "%g", rate)
                                    lib_helpers.Text(false, " ")
                                    lib_helpers.TextC(false, section_color[party.id], drop.item)
                                end
                            end
                        end
                    end
                else
                    lib_helpers.Text(true, "Type /partyinfo to refresh...")
                end
                return true
            end
            return false
        end

        local function showResistances_VBar(order)
            if moptions.resist.show and moptions.resist.type == "vbar" then
                imgui.PushStyleVar_2("FramePadding", 0.5, 0.5)
                local height = imgui.GetFontSize()
                local width = 4

                imgui.PushStyleColor("PlotHistogram", 0, 1, 1, 1)
                imgui.PlotHistogram("##efr", {monster.Efr}, 1, 0, "", 0, 100, width, height)
                imgui.PopStyleColor()

                imgui.SameLine(0,0)
                imgui.PushStyleColor("PlotHistogram", 1, 1, 0, 1)
                imgui.PlotHistogram("##eth", {monster.Eth}, 1, 0, "", 0, 100, width, height)
                imgui.PopStyleColor()

                imgui.SameLine(0,0)
                imgui.PushStyleColor("PlotHistogram", 1, 0.4, 0, 1)
                imgui.PlotHistogram("##eic", {monster.Eic}, 1, 0, "", 0, 100, width, height)
                imgui.PopStyleColor()

                imgui.SameLine(0,0)
                imgui.PushStyleColor("PlotHistogram", 0.933, 0.098, 0.863, 1)
                imgui.PlotHistogram("##edk", {monster.Edk}, 1, 0, "", 0, 100, width, height)
                imgui.PopStyleColor()

                imgui.SameLine(0,0)
                imgui.PushStyleColor("PlotHistogram", 1, 1, 0.70196, 1)
                imgui.PlotHistogram("##elt", {monster.Elt}, 1, 0, "", 0, 100, width, height)
                imgui.PopStyleColor()

                imgui.SameLine(0,0)
                imgui.PushStyleColor("PlotHistogram", 1, 0.125, 0.19215, 1)
                imgui.PlotHistogram("##esp", {monster.Esp}, 1, 0, "", 0, 100, width, height)
                imgui.PopStyleColor()

                imgui.PopStyleVar()
                return true
            end
            return false
        end

        local function showProbability_VBar(order)
            if moptions.probability.show and moptions.probability.type == "vbar" then
                imgui.PushStyleVar_2("FramePadding", 0.5, 0.5)
                local height = imgui.GetFontSize()
                local prob = {
                    43.31,
                    79.43,
                    130.39,
                    198.25,
                    285.01,
                    392.55,
                    522.74,
                }
                local width = 3 * #prob

                local rareRate = lua_biginteger
                if cacheSide then
                    local mName = string.upper(monster.name)
                    if drop_charts[party.difficulty]
                        and drop_charts[party.difficulty][party.episode]
                        and drop_charts[party.difficulty][party.episode][party.id]
                        and drop_charts[party.difficulty][party.episode][party.id][mName]
                    then
                        local mDrops = drop_charts[party.difficulty][party.episode][party.id][mName]
                        for i,drop in pairs(mDrops) do
                            if drop.item and drop.rare and drop.dar then
                                rareRate = 1/((party.dar*drop.dar)*(party.rare*drop.rare))*100000000
                            end
                        end
                    end
                end

                for i=1, #prob do
                    prob[i] = (1 - ( (rareRate-1)/rareRate ) ^ prob[i]) * 100
                end

                imgui.PushStyleColor("PlotHistogram", 0, 1, 1, 1)
                imgui.PlotHistogram("##b1", prob, #prob, 0, "", 0, 100, width, height)
                imgui.PopStyleColor()

                imgui.PopStyleVar()
                return true
            end
            return false
        end


        monster_shown_options = {
            showName_Text,
            showStatusEffects_Text,
            showHealth_Bar,
            showDamage_Text,
            showHit_Text,
            showRecommended_Text,
            showRares_Text,
            showResistances_VBar,
            showProbability_VBar,
        }

        local showOrder = 1
        for i=1, #monster_shown_options do
            local wasShown = monster_shown_options[moptions.shownOptionOrder[i]](showOrder)
            if wasShown then 
                showOrder = showOrder + 1
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

    -- perform one time, ever
    if this.first == true then
        drop_charts = {
            ["Normal"] = require("Monster Scouter/Drops.normal"),
            ["Hard"] = require("Monster Scouter/Drops.hard"),
            ["Very Hard"] = require("Monster Scouter/Drops.very-hard"),
            ["Ultimate"] = require("Monster Scouter/Drops.ultimate"),
        }
        splitDropChartTargets()

        lib_items_list.AddServerItems(options.server)     -- Append server specific items
        genFuncs_UpdatePlayerWeaponSpec()
        genFuncs_UpdateMonsterWeaponSpecDmg()
        this.first = false
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
    playerSelfAttackComboStep = GetPlayerCurAttackComboStep(playerSelfAddr)
    pCoord            = mgl.vec3(playerSelfCoords.x,playerSelfCoords.y,playerSelfCoords.z)
    cameraCoords      = getCameraCoordinates()
    cameraDirs        = getCameraDirection()
    eyeWorld          = mgl.vec3(cameraCoords.x, cameraCoords.y, cameraCoords.z)
    eyeDir            = mgl.vec3(  cameraDirs.x,   cameraDirs.y,   cameraDirs.z)

    if _EntityArray == 0 then
        -- Get the address of the entity array from one of the instructions that references it.
        -- Works on base client and on a client patched with a different array.
        _EntityArray = pso.read_u32(_EntityArrayBasePointer)
    end
    refresh_side_text()

    UpdateMonsterCache(section)
    UpdateInventoryCache()
    monsterCount      = table.getn(cache_monster)
    invItemCount      = table.getn(cache_inventory.items)
    UpdateLevelData()
    UpdatePlayerItemStats()
    UpdatePlayerData()

    local monsterIdx = 0
    local windowParams = { "NoTitleBar", "NoResize", "NoMove", "NoInputs", "NoSavedSettings", "AlwaysAutoResize" }

    for i=1, options.numTrackers, 1 do
        monsterIdx = monsterIdx + 1
        if monsterIdx > options.numTrackers or monsterIdx > monsterCount or monsterCount < 1 then break end

        if (options[section].EnableWindow == true)
            and (options[section].HideWhenMenu == false or lib_menu.IsMenuOpen() == false)
            and (options[section].HideWhenSymbolChat == false or lib_menu.IsSymbolChatOpen() == false)
            and (options[section].HideWhenMenuUnavailable == false or lib_menu.IsMenuUnavailable() == false)
        then
            local monster = cache_monster[monsterIdx]
            --print(monster.HP, monster.HPMax, monster.name, monster.index, monster.screenShow )

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
                            imgui.SetWindowFontScale(curFontScale)
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
                end

                
                --local windowName = "Monster Scouter - Hud" .. cache_monster[monsterIdx].windowNameId
                imgui.PushStyleVar_2("WindowPadding", trackerWindowPadding.x, trackerWindowPadding.y)
                local windowName = "Monster Scouter - Hud"  .. string.format("%x",cache_monster[monsterIdx].windowNameId)
                if imgui.Begin( windowName,
                    nil, windowParams )
                then
                    imgui.SetWindowFontScale(curFontScale)
                    PresentTargetMonster(cache_monster[monsterIdx], section)
                    local wx, wy = imgui.GetWindowSize()
                    local ps =  lib_helpers.GetPosBySizeAndAnchor( sx, sy, wx, wy, 5 )
                    imgui.SetWindowPos( windowName, ps[1], ps[2]-wy/2, "Always" )
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
        version = "0.2.6",
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
