-- Monitor Audio IA Series Q-SYS plugin entry point.
-- The build script expands these include directives into the .qplug file.

--[[ #include "info.lua" ]]

function GetColor(props)
    return { 88, 98, 80 }
end

function GetPrettyName(props)
    return "Monitor Audio IA Series " .. PluginInfo.Version
end

function GetPages(props)
    local pages = {}
    --[[ #include "pages.lua" ]]
    return pages
end

function GetProperties()
    local props = {}
    --[[ #include "properties.lua" ]]
    return props
end

function GetControls(props)
    local ctrls = {}
    --[[ #include "controls.lua" ]]
    return ctrls
end

function GetControlLayout(props)
    local layout = {}
    local graphics = {}
    setmetatable(graphics, {
        __newindex = function(target, name, graphic)
            rawset(target, name, graphic)
            table.insert(target, graphic)
        end
    })
    --[[ #include "layout.lua" ]]
    return layout, graphics
end

function GetComponents(props)
    return {}
end

if Controls then
    --[[ #include "runtime.lua" ]]
end