local lib_helpers = require("solylib.helpers")
local cfgMonsters = require("Monster Scouter.monsters")

local function getMonstersBySegment()
    local mt = {}
    for k,v in pairs(cfgMonsters.m) do
        if v.seg then
            v.id = k
            if mt[v.seg] == nil then
                mt[v.seg] = {}
            end
            table.insert(mt[v.seg],v)
        end
    end
    return mt
end
monstersBySegment = getMonstersBySegment()


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


local function ConfigurationWindow(configuration)
    local this =
    {
        title = "Monster Scouter - Configuration",
        open = false,
        changed = false,
    }

    local _configuration = configuration


    local function PresentColorEditor(label, default, custom)
        custom = custom or 0xFFFFFFFF
    
        local changed = false
        local i_default =
        {
            bit.band(bit.rshift(default, 24), 0xFF),
            bit.band(bit.rshift(default, 16), 0xFF),
            bit.band(bit.rshift(default, 8), 0xFF),
            bit.band(default, 0xFF)
        }
        local i_custom =
        {
            bit.band(bit.rshift(custom, 24), 0xFF),
            bit.band(bit.rshift(custom, 16), 0xFF),
            bit.band(bit.rshift(custom, 8), 0xFF),
            bit.band(custom, 0xFF)
        }
    
        local ids = { "##X", "##Y", "##Z", "##W" }
        local fmt = { "A:%3.0f", "R:%3.0f", "G:%3.0f", "B:%3.0f" }
    
        imgui.BeginGroup()
        imgui.PushID(label)
    
        imgui.PushItemWidth(50)
        for n = 1, 4, 1 do
            local changedDragInt = false
            if n ~= 1 then
                imgui.SameLine(0, 5)
            end
    
            changedDragInt, i_custom[n] = imgui.DragInt(ids[n], i_custom[n], 1.0, 0, 255, fmt[n])
            if changedDragInt then
                this.changed = true
            end
        end
        imgui.PopItemWidth()
    
        imgui.SameLine(0, 5)
        imgui.ColorButton(i_custom[2] / 255, i_custom[3] / 255, i_custom[4] / 255, i_custom[1] / 255)
        if imgui.IsItemHovered() then
            imgui.SetTooltip(
                string.format(
                    "#%02X%02X%02X%02X",
                    i_custom[4],
                    i_custom[1],
                    i_custom[2],
                    i_custom[3]
                )
            )
        end
    
        imgui.SameLine(0, 5)
        imgui.Text(label)
    
        default =
        bit.lshift(i_default[1], 24) +
        bit.lshift(i_default[2], 16) +
        bit.lshift(i_default[3], 8) +
        bit.lshift(i_default[4], 0)
    
        custom =
        bit.lshift(i_custom[1], 24) +
        bit.lshift(i_custom[2], 16) +
        bit.lshift(i_custom[3], 8) +
        bit.lshift(i_custom[4], 0)
    
        if custom ~= default then
            imgui.SameLine(0, 5)
            if imgui.Button("Revert") then
                custom = default
                this.changed = true
            end
        end
    
        imgui.PopID()
        imgui.EndGroup()
    
        return custom
    end

    local function CopyOverridedSettings(buttonName, section)
        if _configuration[section].AdditionalTrackerOverrides then
            local overrideName = buttonName .. "Override"
            if _configuration[section][overrideName] then
                _configuration[section][buttonName] = _configuration["tracker1"][buttonName]
                _configuration[section].changed = true
            end
        end
    end

    local _showWindowSettings = function()
        local success
        local serverList =
        {
            "Vanilla",
            "Ultima",
            "Ephinea",
            "Schthack",
        }

        local function configureMonster(monster, category, section, Additional)
            imgui.PushID(section..category.."cfg")
            local cateTabl    = _configuration[section][category]


            if imgui.Checkbox("Enable", cateTabl.enabled) then
                cateTabl.enabled = not cateTabl.enabled
                this.changed = true
            end

            -- imgui.SameLine(0, 4)
            -- if imgui.Checkbox("Show in Current Room Only", cateTabl.showName) then
            --     cateTabl.showName = not cateTabl.showName
            --     this.changed = true
            -- end

            if imgui.Checkbox("Show Name", cateTabl.showName) then
                cateTabl.showName = not cateTabl.showName
                this.changed = true
            end
            if imgui.Checkbox("Show Health Percent", cateTabl.showHealthPercent) then
                cateTabl.showHealthPercent = not cateTabl.showHealthPercent
                this.changed = true
            end
            if imgui.Checkbox("Show Health Amount", cateTabl.showHealthAmount) then
                cateTabl.showHealthAmount = not cateTabl.showHealthAmount
                this.changed = true
            end
            if imgui.Checkbox("Show Health Bar", cateTabl.showHealthBar) then
                cateTabl.showHealthBar = not cateTabl.showHealthBar
                this.changed = true
            end
            if imgui.Checkbox("Show Damage", cateTabl.showDamage) then
                cateTabl.showDamage = not cateTabl.showDamage
                this.changed = true
            end
            if imgui.Checkbox("Show Weakness", cateTabl.showWeakness) then
                cateTabl.showWeakness = not cateTabl.showWeakness
                this.changed = true
            end
            if imgui.Checkbox("Show Status Effects", cateTabl.showStatusEffects) then
                cateTabl.showStatusEffects = not cateTabl.showStatusEffects
                this.changed = true
            end
            if imgui.Checkbox("Show Rare Drops", cateTabl.showRares) then
                cateTabl.showRares = not cateTabl.showRares
                this.changed = true
            end

            if Additional ~= nil then

            end

            -- if imgui.Checkbox("Custom Color", cateTabl.useCustomColor) then
            --     cateTabl.useCustomColor = not cateTabl.useCustomColor
            --     this.changed = true
            -- end

            -- if cateTabl.useCustomColor then
            --     cateTabl.customBorderColor = PresentColorEditor("Border Color", 0xFFFF6900, cateTabl.customBorderColor)
            -- end


            imgui.PopID()
        end

        local numTrackersChanged = false
        local lastnumTrackers

        if imgui.TreeNodeEx("General", "DefaultOpen") then
            if imgui.Checkbox("Enable", _configuration.enable) then
                _configuration.enable = not _configuration.enable
                this.changed = true
            end

            imgui.PushItemWidth(100)
            lastnumTrackers =_configuration.numTrackers
            success, _configuration.numTrackers = imgui.InputInt("Num Trackers <- (WARNING: fps performance!)", _configuration.numTrackers)
            imgui.PopItemWidth()
            if success then
                this.changed = true
                numTrackersChanged = true
                _configuration.numTrackers = clampVal(_configuration.numTrackers, 1, _configuration.maxNumTrackers)
            end

            if imgui.Checkbox("Use Custom Screen Resolution", _configuration.customScreenResEnabled) then
                _configuration.customScreenResEnabled = not _configuration.customScreenResEnabled
                this.changed = true
            end

            if _configuration.customScreenResEnabled then
                local curX = imgui.GetCursorPosX()
                
                imgui.PushID("customScreenResEnabled")

                imgui.SetCursorPosX(curX + 20)
                imgui.PushItemWidth(100)
                success, _configuration.customScreenResX = imgui.InputInt("Screen Resolution Width", _configuration.customScreenResX)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                    _configuration.customScreenResX = clampVal(_configuration.customScreenResX, 1, _configuration.customScreenResX)
                end

                if _configuration.customScreenResX ~= lib_helpers.GetResolutionWidth() then
                    imgui.SameLine(0, 5)
                    if imgui.Button("Revert") then
                        _configuration.customScreenResX = lib_helpers.GetResolutionWidth()
                        this.changed = true
                    end
                end

                imgui.SetCursorPosX(curX + 20)
                imgui.PushItemWidth(100)
                success, _configuration.customScreenResY = imgui.InputInt("Screen Resolution Height", _configuration.customScreenResY)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                    _configuration.customScreenResY = clampVal(_configuration.customScreenResY, 1, _configuration.customScreenResY)
                end

                if _configuration.customScreenResY ~= lib_helpers.GetResolutionHeight() then
                    imgui.SameLine(0, 5)
                    if imgui.Button("Revert") then
                        _configuration.customScreenResY = lib_helpers.GetResolutionHeight()
                        this.changed = true
                    end
                end

                imgui.PopID()
                imgui.SetCursorPosX(curX)
            end

            if imgui.Checkbox("Use Custom FoV (Field of View)", _configuration.customFoVEnabled) then
                _configuration.customFoVEnabled = not _configuration.customFoVEnabled
                this.changed = true
            end

            if _configuration.customFoVEnabled then
                local curX = imgui.GetCursorPosX()
                imgui.PushID("customFoVEnabled")

                imgui.SetCursorPosX(curX + 20)
                imgui.PushItemWidth(200)
                --success, _configuration.customFoV0 = imgui.SliderFloat("Field of View @ Zoom 0 (Degrees)", _configuration.customFoV0, _configuration.customFoV4, 120)
                success, _configuration.customFoV0 = imgui.DragFloat("Field of View @ Zoom 0 (Degrees)", _configuration.customFoV0, 0.005, _configuration.customFoV4, 120)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SetCursorPosX(curX + 20)
                imgui.PushItemWidth(200)
                success, _configuration.customFoV1 = imgui.SliderFloat("Field of View @ Zoom 1 (Degrees)", _configuration.customFoV1, _configuration.customFoV4, _configuration.customFoV0)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SetCursorPosX(curX + 20)
                imgui.PushItemWidth(200)
                success, _configuration.customFoV2 = imgui.SliderFloat("Field of View @ Zoom 2 (Degrees)", _configuration.customFoV2, _configuration.customFoV4, _configuration.customFoV0)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SetCursorPosX(curX + 20)
                imgui.PushItemWidth(200)
                success, _configuration.customFoV3 = imgui.SliderFloat("Field of View @ Zoom 3 (Degrees)", _configuration.customFoV3, _configuration.customFoV4, _configuration.customFoV0)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end
                imgui.SetCursorPosX(curX + 20)
                imgui.PushItemWidth(200)
                success, _configuration.customFoV4 = imgui.DragFloat("Field of View @ Zoom 4 (Degrees)", _configuration.customFoV4, 0.005, 0, _configuration.customFoV0)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                end

                imgui.PopID()
                imgui.SetCursorPosX(curX)
            end

            imgui.PushItemWidth(100)
            success, _configuration.updateThrottle = imgui.InputInt("Delay Update (miliSeconds)", _configuration.updateThrottle)
            imgui.PopItemWidth()
            if success then
                this.changed = true
            end

            imgui.PushItemWidth(200)
            success, _configuration.server = imgui.Combo("Server", _configuration.server, serverList, table.getn(serverList))
            imgui.PopItemWidth()
            if success then
                this.changed = true
            end

            imgui.TreePop()
        end

        local numTrackersToIterate
        if numTrackersChanged and _configuration.numTrackers > lastnumTrackers then
            numTrackersToIterate = lastnumTrackers
        else
            numTrackersToIterate = _configuration.numTrackers
        end

        local section = "tracker"
        local nodeName = "Tracker"
        if _configuration[section].customTrackerColorEnable then
            local i_custom =
            {
                bit.band(bit.rshift(_configuration[section].customTrackerColorMarker, 24), 0xFF),
                bit.band(bit.rshift(_configuration[section].customTrackerColorMarker, 16), 0xFF),
                bit.band(bit.rshift(_configuration[section].customTrackerColorMarker, 8), 0xFF),
                bit.band(_configuration[section].customTrackerColorMarker, 0xFF)
            }
            imgui.ColorButton(i_custom[2] / 255, i_custom[3] / 255, i_custom[4] / 255, i_custom[1] / 255)
            if imgui.IsItemHovered() then
                imgui.SetTooltip(
                    string.format(
                        "#%02X%02X%02X%02X",
                        i_custom[4],
                        i_custom[1],
                        i_custom[2],
                        i_custom[3]
                    )
                )
            end
            imgui.SameLine(0, 5)
        end

        if imgui.TreeNodeEx(nodeName) then

            local section = "tracker"

            if imgui.Checkbox("Enable", _configuration[section].EnableWindow) then
                _configuration[section].EnableWindow = not _configuration[section].EnableWindow
                _configuration[section].changed = true
                this.changed = true
            end

            if imgui.TreeNodeEx("Window") then

                if imgui.Checkbox("Hide when menus are open", _configuration[section].HideWhenMenu) then
                    _configuration[section].HideWhenMenu = not _configuration[section].HideWhenMenu
                    this.changed = true
                end

                if imgui.Checkbox("Hide when symbol chat/word select is open", _configuration[section].HideWhenSymbolChat) then
                    _configuration[section].HideWhenSymbolChat = not _configuration[section].HideWhenSymbolChat
                    this.changed = true
                end

                if imgui.Checkbox("Hide when the menu is unavailable", _configuration[section].HideWhenMenuUnavailable) then
                    _configuration[section].HideWhenMenuUnavailable = not _configuration[section].HideWhenMenuUnavailable
                    this.changed = true
                end

                if imgui.Checkbox("Transparent window", _configuration[section].TransparentWindow) then
                    _configuration[section].TransparentWindow = not _configuration[section].TransparentWindow
                    _configuration[section].changed = true
                    this.changed = true
                end

                if imgui.Checkbox("Use Custom Font Scaling", _configuration[section].customFontScaleEnabled) then
                    _configuration[section].customFontScaleEnabled = not _configuration[section].customFontScaleEnabled
                    this.changed = true
                end
    
                if _configuration[section].customFontScaleEnabled then
                    local curX = imgui.GetCursorPosX()
                    
                    imgui.PushID("customFontScaleEnabled")
    
                    imgui.SetCursorPosX(curX + 20)
                    imgui.PushItemWidth(120)
                    success, _configuration[section].fontScale = imgui.InputFloat("Font Scale", _configuration[section].fontScale)
                    imgui.PopItemWidth()
                    if success then
                        this.changed = true
                    end
    
                    imgui.PopID()
                    imgui.SetCursorPosX(curX)
                end

                if imgui.Checkbox("Custom Tracker Color", _configuration[section].customTrackerColorEnable) then
                    _configuration[section].customTrackerColorEnable = not _configuration[section].customTrackerColorEnable
                    this.changed = true
                end

                if _configuration[section].customTrackerColorEnable then
                    _configuration[section].customTrackerColorMarker     = PresentColorEditor("Marker Color",     0xFFFF9900, _configuration[section].customTrackerColorMarker)
                    _configuration[section].customTrackerColorBackground = PresentColorEditor("Background Color", 0x4CCCCCCC, _configuration[section].customTrackerColorBackground)
                    _configuration[section].customTrackerColorWindow     = PresentColorEditor("Window Color",     0x46000000, _configuration[section].customTrackerColorWindow)
                end

                imgui.TreePop()
            end
            
            if imgui.TreeNodeEx("Display") then
    
                if imgui.Checkbox("Clamp Monsters Into View", _configuration[section].clampMonsterView) then
                    _configuration[section].clampMonsterView = not _configuration[section].clampMonsterView
                    this.changed = true
                end

                imgui.PushItemWidth(120)
                success, _configuration[section].ignoreItemMaxDist = imgui.InputInt("Always Ignore Monsters Further Than (Distance)", _configuration[section].ignoreItemMaxDist)
                imgui.PopItemWidth()
                if success then
                    this.changed = true
                    _configuration[section].ignoreItemMaxDist = clampVal(_configuration[section].ignoreItemMaxDist, 0, 999999)
                end

                imgui.TreePop()
            end

            if imgui.TreeNodeEx("Monsters") then
                local SWidth = 110
                local SWidthP = SWidth + 16

                for segment,monsters in pairs(monstersBySegment) do
                    if imgui.TreeNodeEx(segment) then

                        for i,monster in pairs(monsters) do
                            if monster.cate then

                                if imgui.TreeNodeEx(monster.cate) then

                                    configureMonster(monster, monster.id, section)
                                    imgui.TreePop()
                                end
                            end
                        end

                        imgui.TreePop()
                    end
                end

                imgui.TreePop()
            end

            imgui.Text("Position and Size")

            if imgui.Checkbox("Always Auto Resize", _configuration[section].AlwaysAutoResize) then
                _configuration[section].AlwaysAutoResize = not _configuration[section].AlwaysAutoResize
                _configuration[section].changed = true
                this.changed = true
            end
            if not _configuration[section].AlwaysAutoResize then
                imgui.PushItemWidth(100)
                success, _configuration[section].W = imgui.InputInt("Width", _configuration[section].W)
                imgui.PopItemWidth()
                if success then
                    _configuration[section].changed = true
                    this.changed = true
                end

                imgui.SameLine(0, 25)
                imgui.PushItemWidth(100)
                success, _configuration[section].H = imgui.InputInt("Height", _configuration[section].H)
                imgui.PopItemWidth()
                if success then
                    _configuration[section].changed = true
                    this.changed = true
                end
            end

            imgui.PushItemWidth(100)
            success, _configuration[section].boxOffsetX = imgui.InputInt("X Offset", _configuration[section].boxOffsetX)
            imgui.PopItemWidth()
            if success then
                _configuration[section].changed = true
                this.changed = true
            end

            imgui.SameLine(0, 10)
            imgui.PushItemWidth(100)
            success, _configuration[section].boxOffsetY = imgui.InputInt("Y Offset", _configuration[section].boxOffsetY)
            imgui.PopItemWidth()
            if success then
                _configuration[section].changed = true
                this.changed = true
            end

            imgui.PushItemWidth(100)
            success, _configuration[section].boxSizeX = imgui.InputInt("X Size", _configuration[section].boxSizeX)
            imgui.PopItemWidth()
            if success then
                _configuration[section].changed = true
                this.changed = true
            end

            imgui.SameLine(0, 25)
            imgui.PushItemWidth(100)
            success, _configuration[section].boxSizeY = imgui.InputInt("Y Size", _configuration[section].boxSizeY)
            imgui.PopItemWidth()
            if success then
                _configuration[section].changed = true
                this.changed = true
            end

            imgui.TreePop()
        end

    end

    this.Update = function()
        if this.open == false then
            return
        end

        local success

        imgui.SetNextWindowSize(500, 400, 'FirstUseEver')
        success, this.open = imgui.Begin(this.title, this.open)

        _showWindowSettings()

        imgui.End()
    end

    return this
end

return
{
    ConfigurationWindow = ConfigurationWindow,
}
