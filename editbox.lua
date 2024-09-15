-- Utils

local screenW, screenH = guiGetScreenSize()

local cursor = {
    x = 0,
    y = 0,
    state = false
}

function cursor.update()
    cursor.state = not isCursorShowing()

    local cursorX, cursorY = getCursorPosition()
    cursor.x, cursor.y = cursorX * screenW, cursorY * screenH
end

function cursor.box(x, y, width, height)
    return cursor.x >= x and cursor.x <= x + width and cursor.y >= y and cursor.y <= y + height
end

-- Editbox

Editbox = {}
Editbox.__index = Editbox
Editbox.instances = {}
Editbox.focus = nil

local list_properties = {
    font = "userdata",
    align = "string",
    wordbreak = "boolean",
    mask = "boolean",
    maskchar = "string",
    isnumber = "boolean",
    max = "number",
    caret = "boolean",
    parent = "table",
    text = "string"
}

function Editbox.new(properties)
    local self = {}
    setmetatable(self, {__index = Editbox})

    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0

    self.selected = false

    self.backspace = {
        press = false,
        last = 0
    }

    self.properties = { -- Valores padrões
        font = "default-bold",
        align = "left",
        max = 9999,
        caret = true,
        parent = {0, 0, 0, 0},
        text = ""
    }

    table.insert(Editbox.instances, self)

    if properties then
        assert(type(properties) == "table", "bad argument #1 to \"new\" (table expected, got " .. type(properties) .. ")")
        self:setProperties(properties)
    end

    return self
end

function Editbox:draw(display, x, y, width, height, color)
    cursor.update()
    self.x, self.y, self.width, self.height = x, y, width, height

    local font = self.properties.font
    local align = self.properties.align
    local wordbreak = self.properties.wordbreak
    local mask = self.properties.mask

    local tick = getTickCount()

    if self.backspace.press then
        if tick - self.backspace.press >= 500 and tick - self.backspace.last >= 50 then
            self.properties.text = self.properties.text:sub(1, #self.properties.text - 1)
            self.backspace.last = tick
        end
    end

    local text = mask and string.rep(self.properties.maskchar, #self.properties.text) or self.properties.text
    local textW, textH = dxGetTextSize(text, width, 1, 1, font, wordbreak)

    dxDrawText(
        (self.properties.text:len() > 0 or Editbox.focus == self) and ("%s%s"):format(text, (wordbreak and self.properties.cursor) and "|" or "") or display,
        x, y, width + x, height + y,
        color, 1, font,
        wordbreak and align or (textW > width and "right" or align),
        wordbreak and (textH > height and "bottom" or "top") or "top",
        true, wordbreak
    )

    if Editbox.focus == self then
        if self.properties.caret and not wordbreak then
            local caretX = x

            if align == "center" then
                caretX = x + (width + textW) / 2
            elseif align == "right" then
                caretX = x + width - 2
            elseif align == "left" then
                caretX = x + textW
            end

            caretX = math.min(caretX, x + width)

            local r, g, b = bitExtract(color, 0, 8), bitExtract(color, 8, 8), bitExtract(color, 16, 8)
            dxDrawRectangle(caretX, y, 1, height, tocolor(r, g, b, math.abs(math.sin(tick / 255) * 200)))
        end

        if self.selected then
            local rectX, rectY = x, y

            if align == "center" and textW <= width then
                rectX, rectY = x + ((width - textW) / 2), y + ((height - textH) / 2)
            end

            dxDrawRectangle(rectX, rectY, math.min(width, textW), height, tocolor(29, 161, 242, 50))
        end
    else
        self.selected = false
    end
end

function Editbox:setProperties(propertie, value)
    assert(propertie, "bad argument #1 to \"setProperties\" (got nil)")

    if type(propertie) == "table" then
        for k, v in pairs(propertie) do
            self:setProperties(k, v)
        end return
    end

    assert(list_properties[propertie], "bad argument #1 to \"setProperties\" (invalid propertie \"" .. propertie .. "\")")
    assert(type(value) == list_properties[propertie], "bad argument #2 to \"setProperties\": " .. propertie .. " (" .. list_properties[propertie] .. " expected, got \"" .. type(value) .. "\")")

    self.properties[propertie] = value
end

function Editbox:getProperties(propertie)
    assert(propertie, "bad argument #1 to \"getProperties\" (got nil)")
    assert(list_properties[propertie], "bad argument #1 to \"getProperties\" (invalid propertie \"" .. propertie .. "\")")

    return self.properties[propertie]
end

function Editbox:destroy()
    for i, v in ipairs(Editbox.instances) do
        if v == self then
            table.remove(Editbox.instances, i)
            self = nil
            break
        end
    end
end

-- Events

addEventHandler("onClientCharacter", root, function(char)
    local self = Editbox.focus
    if not self then return end

    if self.properties.isnumber and not tonumber(char) then return end

    if self.selected then
        self.properties.text = char
        self.selected = false
    else
        if #self.properties.text >= self.properties.max then return end
        self.properties.text = self.properties.text .. char
    end
end)

addEventHandler("onClientKey", root, function(key, state)
    local self = Editbox.focus
    if not self then return end

    if key == "backspace" then
        if state then
            if self.selected then
                self.properties.text = ""
                self.selected = false
            else
                self.properties.text = self.properties.text:sub(1, #self.properties.text - 1)

                self.backspace.press = getTickCount()
                self.backspace.last = getTickCount()
            end
        else
            self.backspace.press = false
        end
    else
        if getKeyState("lctrl") then
            if key == "a" then
                self.selected = true
            elseif key == "c" then
                if self.selected then
                    setClipboard(self.properties.text)
                end
            elseif key == "x" then
                if self.selected then
                    setClipboard(self.properties.text)
                    self.properties.text = ""
                    self.selected = false
                end
            end
        end
    end

    if not (getKeyState("lctrl") and key == "v") then
        cancelEvent()
    end
end)

addEventHandler("onClientPaste", root, function(text)
    local self = Editbox.focus
    if not self then return end

    if self.selected then
        self.properties.text = text
        self.selected = false
    else
        if #self.properties.text + #text > self.properties.max then
            return
        end

        self.properties.text = self.properties.text .. text
    end
end)

addEventHandler("onClientClick", root, function(button, state)
    if not (button == "left" and state == "down") then return end

    local focus = false

    for _, self in ipairs(Editbox.instances) do
        self.selected = false
        if cursor.box(unpack(self.properties.parent)) then focus = self end
    end

    Editbox.focus = focus
end)
