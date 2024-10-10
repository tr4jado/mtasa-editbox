-- Utils

local screenW, screenH = guiGetScreenSize()

local cursor = {
    state = false,
    x = 0,
    y = 0
}

function cursor:update()
    local state = isCursorShowing()

    if state then
        local x, y = getCursorPosition()
        self.x, self.y = x * screenW, y * screenH
    end

    self.state = state
end

function cursor:box(x, y, width, height)
    return self.x >= x and self.x <= x + width and self.y >= y and self.y <= y + height
end

local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

_dxDrawText = dxDrawText
function dxDrawText(text, x, y, width, height, ...)
    return _dxDrawText(text, x, y, x + width, y + height, ...)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Class

Editbox = {}
Editbox.__index = Editbox

function Editbox.new(properties)
    local self = setmetatable({}, Editbox)

    self.focus = false

    self.x = 0
    self.y = 0
    self.width = false
    self.height = false

    self.render_target = nil

    -- Properties
    self.text = ""
    self.font = "default"
    self.masked = false
    self.is_number = false
    self.max_length = 0
    self.parent = {-1, -1, 0, 0}
    -- Properties

    if properties then
        for i, v in pairs(properties) do
            self[i] = v
        end
    end

    self.keys = {}

    for i in pairs({
        ["arrow_l"] = true,
        ["arrow_r"] = true,
        ["backspace"] = true,
        ["delete"] = true
    }) do
        self.keys[i] = {
            state = false,
            last = 0
        }
    end

    self.caret_position = 0
    self.offset = 0
    self.offset_temp = 0

    self.all_selected = false

    addEventHandler("onClientClick", root, function(...) self:onClick(...) end)
    addEventHandler("onClientCharacter", root, function(...) self:onCharacter(...) end)
    addEventHandler("onClientKey", root, function(...) self:onKey(...) end)
    addEventHandler("onClientPaste", root, function(...) self:onPaste(...) end)

    if self.masked then
        assert(type(self.masked) == "string", "Bad argument @ 'Editbox.new' [expected string at argument 1, got " .. type(self.masked) .. "]")
    end

    return self
end

function Editbox:draw(placeholder, x, y, width, height, color)
    cursor:update()

    local fontHeight = dxGetFontHeight(1, self.font)

    self.x = x
    self.y = y

    if not isElement(self.render_target) or (not self.width or self.width ~= width or not self.height or self.height ~= height) then
        self.width = width
        self.height = height

        if isElement(self.rendertarget) then
            destroyElement(self.rendertarget)
        end

        self.render_target = dxCreateRenderTarget(width, height, true)
    end

    local now = getTickCount()

    for i, v in pairs(self.keys) do
        if v.state and now - v.state >= 500 and now - v.last >= 30 then
            self:onKey(i, true)
        end
    end

    self.offset_temp = lerp(self.offset_temp, self.offset, 0.2)

    if self.offset_temp ~= self.offset then
        self:updateRenderTarget()
    end

    if self.text:len() == 0 and not self.focus then
        dxDrawText(placeholder, x, y, width, height, color, 1, self.font, "left", "center")
    else
        dxDrawImage(x, y, width, height, self.render_target, 0, 0, 0, color)
    end

    if self.focus and getTickCount() % 1000 < 500 then
        local caretX = clamp(self.width - 1, 0, dxGetTextWidth(self.text:sub(1, self.caret_position), 1, self.font) + self.offset_temp)
        dxDrawRectangle(x + caretX, y + (height - fontHeight) / 2, 1, fontHeight, color)
    end

    if self.all_selected then
        local rectangleWidth = math.min(self.width, dxGetTextWidth(self.text, 1, self.font) + self.offset_temp)
        dxDrawRectangle(x, y + (height - fontHeight) / 2, rectangleWidth, fontHeight, self.focus and tocolor(0, 170, 255, 100) or tocolor(0, 0, 0, 100))
    end
end

function Editbox:updateRenderTarget()
    dxSetRenderTarget(self.render_target, true)

    local text = self.masked and self.masked:rep(#self.text) or self.text
    dxDrawText(text, self.offset_temp, 0, self.width, self.height, tocolor(255, 255, 255), 1, self.font, "left", "center")

    dxSetRenderTarget()
end

function Editbox:updateOffset()
    local textWidth = dxGetTextWidth(self.text, 1, self.font)
    local caretX = dxGetTextWidth(self.text:sub(1, self.caret_position), 1, self.font)

    if caretX + self.offset < 0 then
        self.offset = -caretX
    elseif caretX + self.offset > self.width then
        self.offset = self.width - caretX
    elseif textWidth <= self.width then
        self.offset = 0
    end
end

function Editbox:destroy()
    if isElement(self.render_target) then
        destroyElement(self.render_target)
    end

    removeEventHandler("onClientClick", root, function(...) self:onClick(...) end)
    removeEventHandler("onClientCharacter", root, function(...) self:onCharacter(...) end)
    removeEventHandler("onClientKey", root, function(...) self:onKey(...) end)
    removeEventHandler("onClientPaste", root, function(...) self:onPaste(...) end)

    self = nil
end

function Editbox:onClick(button, state)
    if not (button == "left" and state == "down") then return end

    if cursor:box(unpack(self.parent)) then
        if self.focus then
            local x = cursor.x - self.x - self.offset
            local new

            for i = 1, #self.text do
                local width = dxGetTextWidth(self.text:sub(1, i), 1, self.font)

                if width > x then
                    new = i
                    break
                end
            end

            if new then
                self.caret_position = new
            else
                self.caret_position = #self.text
            end

            self.all_selected = false
            self:updateOffset()
            self:updateRenderTarget()
        end

        self.focus = true
    else
        self.focus = false
    end
end

function Editbox:onCharacter(char)
    if not self.focus then return end
    if self.is_number and not tonumber(char) then return end
    if self.max_length > 0 and #self.text + 1 >= self.max_length then return end

    if self.all_selected then
        self.text = char
        self.caret_position = 1
        self.all_selected = false
    else
        self.text = self.text:sub(1, self.caret_position) .. char .. self.text:sub(self.caret_position + 1)
        self.caret_position = self.caret_position + 1
    end

    self:updateOffset()
    self:updateRenderTarget()
end

function Editbox:onKey(key, press)
    if not self.focus then return end

    if press then
        if key == "arrow_l" then
            if self.all_selected then
                self.caret_position = 0
                self.all_selected = false
            else
                self.caret_position = clamp(self.caret_position - 1, 0, #self.text)
            end
        elseif key == "arrow_r" then
            if self.all_selected then
                self.caret_position = #self.text
                self.all_selected = false
            else
                self.caret_position = clamp(self.caret_position + 1, 0, #self.text)
            end
        elseif key == "backspace" then
            if self.all_selected then
                self.text = ""
                self.caret_position = 0
                self.all_selected = false
            elseif self.caret_position > 0 then
                self.text = self.text:sub(1, self.caret_position - 1) .. self.text:sub(self.caret_position + 1)
                self.caret_position = self.caret_position - 1
            end
        elseif key == "delete" then
            if self.all_selected then
                self.text = ""
                self.caret_position = 0
                self.all_selected = false
            elseif self.caret_position < #self.text then
                self.text = self.text:sub(1, self.caret_position) .. self.text:sub(self.caret_position + 2)
            end
        elseif key == "c" and getKeyState("lctrl") then
            if self.all_selected then
                setClipboard(self.text)
            end
        elseif key == "x" and getKeyState("lctrl") then
            if self.all_selected then
                setClipboard(self.text)

                self.text = ""
                self.caret_position = 0
                self.all_selected = false
            end
        elseif key == "a" and getKeyState("lctrl") then
            self.all_selected = true
        end

        -- Atualize o offset após apagar caracteres
        self:updateOffset()
        self:updateRenderTarget()

        if self.keys[key] then
            if self.keys[key].state then
                self.keys[key].last = getTickCount()
            else
                self.keys[key].state = getTickCount()
                self.keys[key].last = getTickCount()
            end
        end
    else
        if self.keys[key] then
            self.keys[key].state = false
        end
    end
end

function Editbox:onPaste(text)
    if not self.focus then return end
    if self.is_number and not tonumber(text) then return end
    if self.max_length > 0 and #self.text + #text >= self.max_length then return end

    if self.all_selected then
        self.text = text
        self.caret_position = #text
        self.all_selected = false
    else
        self.text = self.text:sub(1, self.caret_position) .. text .. self.text:sub(self.caret_position + 1)
        self.caret_position = self.caret_position + #text
    end

    self:updateOffset()
    self:updateRenderTarget()
end

-- Example

local myedit = Editbox.new({
    parent = {100, 100, 200, 50},
})

addEventHandler("onClientRender", root, function()
    dxDrawRectangle(100, 100, 200, 50, tocolor(255, 255, 255))
    myedit:draw("Insira sua senha", 100, 100, 200, 50, tocolor(0, 0, 0, 255))
end)
