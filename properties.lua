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