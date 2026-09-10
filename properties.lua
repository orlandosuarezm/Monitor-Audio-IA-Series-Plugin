table.insert(props, {
    Name = "DebugLevel",
    Type = "enum",
    Choices = { "Off", "Errors", "All" },
    Value = "All"
})

-- Controla el color de las etiquetas descriptoras en la página Setup.
-- Q-SYS Designer no expone el tema claro/oscuro del lienzo al script del
-- plugin en tiempo de diseño, así que se deja como una propiedad manual:
-- "Dark" para lienzo oscuro (texto claro), "Light" para lienzo claro (texto oscuro).
table.insert(props, {
    Name = "UITheme",
    Type = "enum",
    Choices = { "Dark", "Light" },
    Value = "Dark"
})

-- Modelo de amplificador Monitor Audio con el que se está diseñando. Permite
-- previsualizar en el lienzo de Q-SYS Designer el número de zonas/canales
-- del modelo elegido, antes de desplegar el plugin y conectarlo a un
-- amplificador real (ver el uso de esta propiedad en layout.lua).
-- Al conectar con el amplificador real, Device.ApplyResponse detecta el
-- modelo que el propio equipo reporta y llama a Device.Set(), que vuelve a
-- reconstruir las zonas con los datos reales — esa detección en vivo tiene
-- prioridad sobre esta selección de diseño.
local modelChoices = {}
for _, model in ipairs(tblModels) do
    table.insert(modelChoices, model.Name)
end

table.insert(props, {
    Name = "Model",
    Type = "enum",
    Choices = modelChoices,
    Value = modelChoices[1]
})