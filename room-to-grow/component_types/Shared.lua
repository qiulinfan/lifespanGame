Shared = Shared or {}

Shared.font = "NotoSans-Regular"

Shared.palette = {
    ink = {33, 43, 41},
    cream = {246, 235, 205},
    paper = {223, 210, 176},
    sage = {92, 126, 101},
    sage_light = {142, 169, 137},
    amber = {205, 151, 66},
    terracotta = {169, 91, 64},
    blue = {72, 100, 112},
    stress = {184, 83, 65},
    shadow = {22, 29, 28}
}

if GameContent == nil or GameContent.chapters == nil then
    error("GameContent.lua is missing. Run tools/sync_content.py.")
end

Shared.chapters = GameContent.chapters

function Shared.Clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

function Shared.GetWindowSize()
    local width = 960
    local height = 540
    if Application.GetWindowWidth ~= nil then
        width = Application.GetWindowWidth()
        height = Application.GetWindowHeight()
    end
    return width, height
end

function Shared.ScreenToWorld(x, y)
    local width, height = Shared.GetWindowSize()
    local zoom = math.max(0.01, Camera.GetZoom())
    return Camera.GetPositionX() + (x - width * 0.5) / (100.0 * zoom),
           Camera.GetPositionY() + (y - height * 0.5) / (100.0 * zoom)
end

function Shared.DrawRect(x, y, width, height, color, alpha, order)
    local world_x, world_y = Shared.ScreenToWorld(x + width * 0.5,
                                                   y + height * 0.5)
    Image.DrawEx("panel", world_x, world_y, 0.0, width, height, 0.5, 0.5,
                 color[1], color[2], color[3], alpha or 255, order or 1000)
end

function Shared.DrawText(content, x, y, size, color, alpha)
    Text.Draw(content, x, y, Shared.font, size, color[1], color[2], color[3],
              alpha or 255)
end

function Shared.EstimateTextWidth(content, size)
    local units = 0.0
    for index = 1, #(content or "") do
        local character = string.sub(content, index, index)
        if string.find(" Iil.,:;'!|", character, 1, true) ~= nil then
            units = units + (character == " " and 0.34 or 0.31)
        elseif string.find("MWmw@%", character, 1, true) ~= nil then
            units = units + 0.84
        else
            units = units + 0.58
        end
    end
    return math.floor(units * size + 0.5)
end

function Shared.FitTextSize(content, preferred_size, minimum_size, max_width)
    local size = preferred_size
    while size > minimum_size and
        Shared.EstimateTextWidth(content, size) > max_width do
        size = size - 1
    end
    return size
end

function Shared.DrawCenteredText(content, center_x, y, size, color, alpha)
    local width = Shared.EstimateTextWidth(content, size)
    Shared.DrawText(content, center_x - width * 0.5, y, size, color, alpha)
end

function Shared.WrapText(content, max_characters)
    local lines = {}
    local current = ""
    for word in string.gmatch(content or "", "%S+") do
        if current == "" then
            current = word
        elseif #current + #word + 1 <= max_characters then
            current = current .. " " .. word
        else
            lines[#lines + 1] = current
            current = word
        end
    end
    if current ~= "" then lines[#lines + 1] = current end
    return lines
end

function Shared.DrawWrappedText(content, x, y, size, color, max_characters,
                                line_height, alpha)
    local lines = Shared.WrapText(content, max_characters)
    for index = 1, #lines do
        Shared.DrawText(lines[index], x, y + (index - 1) * line_height,
                        size, color, alpha)
    end
    return #lines * line_height
end

function Shared.DrawWrappedTextInRect(content, x, y, width, height, size,
                                      color, max_characters, line_height,
                                      alpha)
    local lines = Shared.WrapText(content, max_characters)
    local text_height = #lines * line_height
    local start_y = y + math.max(0, (height - text_height) * 0.5)
    for index = 1, #lines do
        Shared.DrawText(lines[index], x,
                        start_y + (index - 1) * line_height,
                        size, color, alpha)
    end
    return text_height
end

function Shared.MouseInRect(x, y, width, height)
    local mouse = Input.GetMousePosition()
    return mouse.x >= x and mouse.x <= x + width and
           mouse.y >= y and mouse.y <= y + height
end

function Shared.GetDirector()
    local actor = Actor.Find("director")
    if actor == nil then return nil end
    return actor:GetComponent("GameDirector")
end
