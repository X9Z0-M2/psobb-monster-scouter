
local widgetNames = {
    "name",
    "debuff",
    "se",
    "hp",
    "damage",
    "hit",
    "recommended",
    "rare",
    "resist",
    "probability",
}

local widgetDisplayTypes = {
    {"text"},                   --name
    {"text", "hbar", "vbar"},   --debuff
    {"text", "hbar", "vbar"},   --se
    {"text", "hbar", "vbar"},   --hp
    {"text", "hbar", "vbar"},   --damage
    {"text", "hbar", "vbar"},   --hit
    {"text"},                   --recommended
    {"text"},                   --rare
    {"text", "hbar", "vbar"},   --resist
    {"text", "hbar", "vbar"},   --probability
}

--populate lookup and reverse tables
local widgetTypeIdx = {}
local widgetTypeName = {}
local widgetNameIdx = {}
for i=1, #widgetNames do
    local name = widgetNames[i]
    local types = widgetDisplayTypes[i]
    widgetTypeIdx[name] = {}
    widgetTypeName[name] = {}
    widgetNameIdx[name] = i
    for j=1, #types do
        widgetTypeIdx[name][types[j]] = j
        widgetTypeName[name][j] = types[j]
    end
end

local function getTypeIndex(widgetName, typeText)
    return widgetTypeIdx[widgetName] ~= nil and widgetTypeIdx[widgetName][typeText] or nil
end
local function getTypeName(widgetName, typeIndex)
    return widgetTypeName[widgetName] ~= nil and widgetTypeName[widgetName][typeIndex] or nil
end
local function getNameIndex(widgetName)
    return widgetNameIdx[widgetName]
end
local function getTypesByName(widgetName)
    return widgetDisplayTypes[widgetNameIdx[widgetName]]
end

-- compile list of supported properties and document what they are
local widgetBaseProps = {
    "show", -- true/false
    "type", -- int
}
local widgetTextTypeProps = {
    "justify",        -- 0,1,2      - justify text right,center,left
    "newLine",        -- bool       - should show on same line or a new line
    "fontScale",      -- float      - scale this widget's text by _
    "useCustomColor", -- bool       - enable user defined text color, otherwise auto-color
}
local widgetVBarTypeProps = {
    "padx",           -- float      - "background" padding in pixels on x-axis - 0,nil = disabled, when < 0 will use addon's theme default
    "pady",           -- float      - "background" padding in pixels on y-axis - ^^^
    -- absolute positioning in pixels - 0,nil = disabled, > 0 will override
    "x",              -- float      - x position - 0x, 0y is topleft corner
    "y",              -- float      - y position
    "h",              -- float      - height
    "w",              -- float      - width
    -- relative position
    "spacing",        -- float      - pixels to prepend (before) this widget
    "newLine",        -- bool       - should show on same line or a new line
    -- relative height will be the default line spacing (pixels) for the current font size
    -- relative width is determined by the widget's specific config, ex: numBars, totalShown, ect
    "bgColor",        -- int        - "background" color HEX as 0xAARRGGBB. ex: 0xFFFF00FF = magenta, no transparency
}
local widgetHBarTypeProps = {
    "padx",           -- float      - "background" padding in pixels on x-axis - 0,nil = disabled, when < 0 will use addon's theme default
    "pady",           -- float      - "background" padding in pixels on y-axis - ^^^
    -- absolute positioning in pixels - 0,nil = disabled, > 0 will override
    "x",              -- float      - x position - 0x, 0y is topleft corner
    "y",              -- float      - y position
    "h",              -- float      - height
    "w",              -- float      - width
    -- relative position
    "spacing",        -- float      - pixels to prepend (before) this widget
    "newLine",        -- bool       - should show on same line or a new line
    -- relative height will be the default line spacing (pixels) for the current font size
    -- relative width is defaults to filling to the end of the window, whatever size that might be
    "bgColor",        -- int        - "background" color HEX as 0xAARRGGBB. ex: 0xFFFF00FF = magenta, no transparency
}
local widgetProperties = {}
widgetProperties[getNameIndex("name")] = {
    "colorAsWeakness",   -- bool - should autocolor the enemy's name to it's elemental weakness
    -- custom coloring
    "bossColor",         -- int  - color to show boss names
    "monsterColor",      -- int  - color to show enemy names
    "rareColor",         -- int  - color to show rare enemy names
}
widgetProperties[getNameIndex("debuff")] = {

}
widgetProperties[getNameIndex("se")] = {

}
widgetProperties[getNameIndex("hp")] = {

}
widgetProperties[getNameIndex("damage")] = {

}
widgetProperties[getNameIndex("hit")] = {

}
widgetProperties[getNameIndex("recommended")] = {
    "targHeavyThresh",     -- int - threshold before recommending the heavy attack style
    "targSpecThresh",      -- int - threshold before recommending the special attack style
}
widgetProperties[getNameIndex("rare")] = {

}
widgetProperties[getNameIndex("resist")] = {

}
widgetProperties[getNameIndex("probability")] = {

}



local function PrintWText(widgetOptions, text, color, forceSameLine, widgetOrder)
    if widgetOptions.fontScale ~= 1.0 then
        imgui.SetWindowFontScale(widgetOptions.fontScale)
    end
    
    local winX = imgui.GetWindowSize()
    local tSizex = imgui.CalcTextSize(text)

    if widgetOptions.justify == 0 then
        if widgetOptions.newLine then
            imgui.SetCursorPosX(trackerWindowPadding.x)
        else
            imgui.SameLine(0,0)
        end
    elseif widgetOptions.justify == 1 then
        local rePosX = winX*0.5 - tSizex*0.5
        if widgetOptions.newLine then
            local cPosX = imgui.GetCursorPosX()
            local xPos = clampVal(rePosX, cPosX, winX)
            imgui.SetCursorPosX(xPos)
        else
            if widgetOrder ~= 1 then
                imgui.SameLine(0,0) -- we have to tell imgui to place the cursor on the same line
            end
            local cPosX = imgui.GetCursorPosX() -- so we can get the cursor's position of the last item
            local xPos = clampVal(rePosX, cPosX, winX)
            imgui.SameLine(xPos,0) -- and then place the cursor where it needs to go with an absolute (window's content!) x coordinate
        end
    else
        local rePosX = winX - tSizex - trackerWindowPadding.x -1 -- subtract 1 extra so "AlwaysAutoResize" will work
        if widgetOptions.newLine then
            local cPosX = imgui.GetCursorPosX()
            local xPos = clampVal(rePosX, cPosX, winX)
            imgui.SetCursorPosX(xPos)
        else
            if widgetOrder ~= 1 then
                imgui.SameLine(0,0)
            end
            local cPosX = imgui.GetCursorPosX()
            local xPos = clampVal(rePosX, cPosX, winX)
            imgui.SameLine(xPos,0)
        end
    end

    lib_helpers.TextC(true, color, text)

    if widgetOptions.fontScale ~= 1.0 then
        imgui.SetWindowFontScale(curFontScale)
    end
end

local function showName_Widget(options, order)
    local woptions = options.name
    if woptions.show then
        local wtypes = widgetTypeIdx.debuff

        if woptions.type == wtypes.text then
            --local mName = monster.name .. " " .. monster.id .. " " .. string.format("%X",monster.windowNameId)
            local mName = monster.name
            local mColor, winX, cPosX
            if woptions.colorAsWeakness and not monster.bossCore then
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

            PrintMText(options.name, mName, mColor, false, order)

            return true
        end

    end
    return false
end

-- Show J/Z status
local function showDebuff_Widget(options, order)
    local woptions = options.debuff
    if woptions.show then
        local wtypes = widgetTypeIdx.debuff

        if woptions.type == wtypes.text then
            if atkTech.type == 0 then
                PrintMText(options.debuff, "    ", 0, false, order)
            else
                local atkTechText = atkTech.name .. atkTech.level .. string.rep(" ", 3 - #tostring(atkTech.level))
                PrintMText(options.debuff, atkTechText, 0xFFFF2031, false, order)
            end

            if defTech.type == 0 then
                PrintMText(options.debuff, "    ", 0, true, order)
            else
                local defTechText = defTech.name .. defTech.level .. string.rep(" ", 3 - #tostring(defTech.level))
                PrintMText(options.debuff, defTechText, 0xFF0088F4, true, order)
            end
            return true
        elseif woptions.type == wtypes.vbar then
            if atkTech.type == 0 then
                PrintMText(options.debuff, "    ", 0, false, order)
            else
                local atkTechText = atkTech.name .. atkTech.level .. string.rep(" ", 3 - #tostring(atkTech.level))
                PrintMText(options.debuff, atkTechText, 0xFFFF2031, false, order)
            end

            if defTech.type == 0 then
                PrintMText(options.debuff, "    ", 0, true, order)
            else
                local defTechText = defTech.name .. defTech.level .. string.rep(" ", 3 - #tostring(defTech.level))
                PrintMText(options.debuff, defTechText, 0xFF0088F4, true, order)
            end
            return true
        end

    end
    return false
end

-- Show Frozen, Confuse, Shocked, or Paralyzed status
local function showStatusEffects_Widget(options, order)
    local woptions = options.se
    if woptions.show then
        local wtypes = widgetTypeIdx.se

        if woptions.type == wtypes.text then
            if frozen then
                PrintMText(options.se, "F ", 0xFF00FFFF, false, order)
            elseif confused then
                PrintMText(options.se, "C ", 0xFFFF00FF, false, order)
            elseif shocked then
                PrintMText(options.se, "S ", 0xFFFFFF00, false, order)
            else
                PrintMText(options.se, "  ", 0, false, order)
            end
            if paralyzed then
                PrintMText(options.se, "P ", 0xFFFF4000, true, order)
            end
            return true
        end

    end
    return false
end

local function showHealth_Widget(options, order)
    local woptions = options.hp
    if woptions.show then
        local wtypes = widgetTypeIdx.hp

        if woptions.type == wtypes.bar then
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

    end
    return false
end

local function showDamage_Widget(options, order)
    local woptions = options.damage
    if woptions.show then
        local wtypes = widgetTypeIdx.damage

        if woptions.type == wtypes.text then
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

    end
    return false
end

local function showHit_Widget(options, order)
    local woptions = options.hit
    if woptions.show then
        local wtypes = widgetTypeIdx.hit

        if woptions.type == wtypes.text then
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

    end
    return false
end

local function showRecommended_Widget(options, order)
    local woptions = options.recommended
    if woptions.show then
        local wtypes = widgetTypeIdx.recommended

        if woptions.type == wtypes.text then
            -- Display best first attack
            lib_helpers.Text(true, "[")
            if dmg.specAtt[1].acc >= woptions.targSpecThresh and pEquipData.weapSpecial > 0 then
                lib_helpers.TextC(false, 0xFFFF2031, "S1: %i%% ", dmg.specAtt[1].acc)
            elseif dmg.heavyAtt[1].acc >= woptions.targHeavyThresh then
                lib_helpers.TextC(false, 0xFFFFAA00, "H1: %i%% ", dmg.heavyAtt[1].acc)
            elseif dmg.normAtt[1].acc > 0 then
                lib_helpers.TextC(false, 0xFF00FF00, "N1: %i%% ", dmg.normAtt[1].acc)
            else
                lib_helpers.TextC(false, 0xFFBB0000, "N1: 0%%")
            end

            -- Display best second attack
            lib_helpers.Text(false, " > ")
            if dmg.specAtt[2].acc >= woptions.targSpecThresh and pEquipData.weapSpecial > 0 then
                lib_helpers.TextC(false, 0xFFFF2031, "S2: %i%% ", dmg.specAtt[2].acc)
            elseif dmg.heavyAtt[2].acc >= woptions.targHeavyThresh then
                lib_helpers.TextC(false, 0xFFFFAA00, "H2: %i%% ", dmg.heavyAtt[2].acc)
            elseif dmg.normAtt[2].acc > 0 then
                lib_helpers.TextC(false, 0xFF00FF00, "N2: %i%% ", dmg.normAtt[2].acc)
            else
                lib_helpers.TextC(false, 0xFFBB0000, "N2: 0%%")
            end

            -- Display best third attack
            lib_helpers.Text(false, "> ")
            if dmg.specAtt[3].acc >= woptions.targSpecThresh and pEquipData.weapSpecial > 0 then
                lib_helpers.TextC(false, 0xFFFF2031, "S3: %i%%", dmg.specAtt[3].acc)
            elseif dmg.heavyAtt[3].acc >= woptions.targHeavyThresh then
                lib_helpers.TextC(false, 0xFFFFAA00, "H3: %i%%", dmg.heavyAtt[3].acc)
            elseif dmg.normAtt[3].acc > 0 then
                lib_helpers.TextC(false, 0xFF00FF00, "N3: %i%%", dmg.normAtt[3].acc)
            else
                lib_helpers.TextC(false, 0xFFBB0000, "N3: 0%%")
            end
            lib_helpers.Text(false, "]")
            return true
        end

    end
    return false
end

local function showRares_Widget(options, order)
    local woptions = options.rare
    if woptions.show then
        local wtypes = widgetTypeIdx.rare

        if woptions.type == wtypes.text then
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
                            lib_helpers.Text(true, "1/")
                            lib_helpers.Text(false, "%i", 1/((party.dar*drop.dar)*(party.rare*drop.rare))*100000000)
                            lib_helpers.Text(false, " ")
                            lib_helpers.TextC(false, section_color[party.id], drop.item)
                        end
                    end
                end
            else
                lib_helpers.Text(true, "Type /partyinfo to refresh...")
            end
            return true
        end

    end
    return false
end

local function showResistances_Widget(options, order)
    local woptions = options.resist
    if woptions.show then
        local wtypes = widgetTypeIdx.resist

        if woptions.type == wtypes.vbar then
            imgui.PushStyleVar_2("FramePadding", 0.5, 0.5)
            local height = imgui.GetFontSize()
            local width = 4

            imgui.PushStyleColor("PlotHistogram", 1, 0.4, 0, 1)
            imgui.PlotHistogram("##efr", {monster.Efr}, 1, 0, "", 0, 100, width, height)
            imgui.PopStyleColor()
            
            imgui.SameLine(0,0)
            imgui.PushStyleColor("PlotHistogram", 1, 1, 0, 1)
            imgui.PlotHistogram("##eth", {monster.Eth}, 1, 0, "", 0, 100, width, height)
            imgui.PopStyleColor()
            
            imgui.SameLine(0,0)
            imgui.PushStyleColor("PlotHistogram", 0, 1, 1, 1)
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

    end
    return false
end

local function showProbability_Widget(options, options, order)
    local woptions = options.probability
    if woptions.show then
        local wtypes = widgetTypeIdx.probability

        if woptions.type == wtypes.vbar then
            imgui.PushStyleVar_2("FramePadding", 0.5, 0.5)
            local height = imgui.GetFontSize()
            local prob = { -- i^ e (euler's number)
                43.31, 
                79.43,
                130.39,
                198.25,
                285.01,
                392.55,
                522.74,
            }
            local width = 4 * #prob

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

    end
    return false
end


local allShowWidgetFuncs = {
    showName_Widget,
    showDebuff_Widget,
    showStatusEffects_Widget,
    showHealth_Widget,
    showDamage_Widget,
    showHit_Widget,
    showRecommended_Widget,
    showRares_Widget,
    showResistances_Widget,
    showProbability_Widget,
}
local allShowWidgetFuncs_Count = #allShowWidgetFuncs

local function showAllWidgets(widgetOptions, showOrdering) -- example: showOrdering = {[1] = 2, [2] = 4, [3] = 1, [4] = 3}
    local shownOrder = 1
    for i=1, #showOrdering do
        local wasShown = allShowWidgetFuncs[showOrdering[i]](widgetOptions, shownOrder)
        if wasShown then 
            shownOrder = shownOrder + 1
        end
    end
end


return {
    names         = widgetNames,
    types         = widgetDisplayTypes,
    numWidgets    = allShowWidgetFuncs_Count,
    getTypeIndex  = getTypeIndex,
    getTypeName   = getTypeName,
    getTypesByName= getTypesByName,
    getNameIndex  = getNameIndex,
    showAll       = showAllWidgets,
}
