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
    local namedGraphics = {}
    local graphics = namedGraphics
    --[[ #include "layout.lua" ]]
    local orderedGraphics = {}
    for _, graphic in pairs(namedGraphics) do
        table.insert(orderedGraphics, graphic)
    end
    return layout, orderedGraphics
end

function GetComponents(props)
    return {}
end

if Controls then
    --[[ #include "runtime.lua" ]]
end