local install = arg[1] == "--install"
local root = "."
local outputDirectory = root .. "\\dist"
local outputPath = outputDirectory .. "\\MonitorAudioIASeries.qplug"

local function readFile(path)
    local file, err = io.open(path, "rb")
    if not file then error(err) end
    local content = file:read("*a")
    file:close()
    return content
end

local function writeFile(path, content)
    local file, err = io.open(path, "wb")
    if not file then error(err) end
    file:write(content)
    file:close()
end

local function include(path)
    local source = readFile(root .. "\\" .. path)
    return source:gsub("%-%-%[%[%s*#include%s+\"([^\"]+)\"%s*%]%]", function(child)
        local childPath = path:match("^(.*)[\\/]%w+%.lua$")
        if childPath then child = childPath .. "\\" .. child end
        return include(child)
    end)
end

os.execute("if not exist " .. outputDirectory .. " mkdir " .. outputDirectory)
writeFile(outputPath, include("plugin.lua"))
print("Built: " .. outputPath)

if install then
    local pluginDirectory = os.getenv("USERPROFILE") .. "\\Documents\\QSC\\Q-SYS Designer\\Plugins\\MonitorAudioIASeries"
    os.execute("if not exist \"" .. pluginDirectory .. "\" mkdir \"" .. pluginDirectory .. "\"")
    os.execute("copy /Y \"" .. outputPath .. "\" \"" .. pluginDirectory .. "\\MonitorAudioIASeries.qplug\" > nul")
    print("Installed: " .. pluginDirectory)
end